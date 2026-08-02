const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const Stripe = require('stripe');

admin.initializeApp();
const db = admin.firestore();

const STRIPE_SECRET_KEY = defineSecret('STRIPE_SECRET_KEY');
const STRIPE_WEBHOOK_SECRET = defineSecret('STRIPE_WEBHOOK_SECRET');

// Must match TariffModel.BASE_TARIFF.endDate in the Flutter app exactly
// (lib/core/models/tariff_model.dart) — checkActualTariff() on the client
// depends on this specific far-future date to treat the tariff as
// "always active", not on the tariff name alone.
const BASE_TARIFF_NAME = 'Базовый';
const BASE_TARIFF_END_ISO = '9999-12-24T00:00:00.000';
const ORION_TARIFF_NAME = 'Орион';

/**
 * Users doc IDs are built deterministically by the app as
 * `${email} ${authService}` (authService is 'google', 'apple', or '' for
 * plain email signup — see lib/core/user_data/user_repo.dart, userId()).
 * Trying the known candidates directly is more reliable than querying the
 * `email` field, since that field can be empty on accounts created before
 * the 2026-08-01 fix that started persisting it. The field query is kept
 * as a secondary net for any doc that doesn't follow the pattern.
 */
async function findUserDocs(email) {
  const candidateIds = [email, `${email} google`, `${email} apple`];
  const found = new Map();

  await Promise.all(
    candidateIds.map(async (id) => {
      const snap = await db.collection('Users').doc(id).get();
      if (snap.exists) found.set(snap.id, snap);
    })
  );

  const fieldQuerySnap = await db
    .collection('Users')
    .where('email', '==', email)
    .get();
  fieldQuerySnap.forEach((doc) => found.set(doc.id, doc));

  return Array.from(found.values());
}

async function logUnmatched(reason, details) {
  logger.warn('Unmatched Stripe payment', { reason, ...details });
  await db.collection('UnmatchedStripePayments').add({
    reason,
    ...details,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function applyTariff(docId, tariffName, tariffEndIso, stripeCustomerId) {
  const fields = {
    tariff: tariffName,
    tariff_is_end: tariffEndIso,
  };
  // Opportunistic — every event that reaches here already has the Stripe
  // customer id in hand, so we stamp it whenever we have it. This is what
  // createPortalSession() looks up later to open that person's Customer
  // Portal without asking Stripe to search by email every time.
  if (stripeCustomerId) {
    fields.stripe_customer_id = stripeCustomerId;
  }
  await db.collection('Users').doc(docId).set(fields, { merge: true });
  logger.info('Applied tariff', { docId, tariffName, tariffEndIso, stripeCustomerId });
}

/**
 * Resolves an email to exactly one Users doc and applies the tariff.
 * On 0 or >1 matches, does NOT guess — logs to UnmatchedStripePayments
 * for manual review instead. A wrong automatic guess here means either
 * granting paid access to the wrong account or silently failing to grant
 * access to a paying customer — both worse than a short manual-review
 * delay.
 */
async function resolveAndApplyTariff(email, tariffName, tariffEndIso, stripeCustomerId, eventMeta) {
  const docs = await findUserDocs(email);

  if (docs.length === 0) {
    await logUnmatched('no_match', { email, tariffName, tariffEndIso, ...eventMeta });
    return;
  }

  if (docs.length > 1) {
    await logUnmatched('multiple_matches', {
      email,
      tariffName,
      tariffEndIso,
      matchedDocIds: docs.map((d) => d.id),
      ...eventMeta,
    });
    return;
  }

  await applyTariff(docs[0].id, tariffName, tariffEndIso, stripeCustomerId);
}

function isoFromUnixSeconds(unixSeconds) {
  return new Date(unixSeconds * 1000).toISOString();
}

exports.stripeWebhook = onRequest(
  { secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET], region: 'us-central1' },
  async (req, res) => {
    const stripe = Stripe(STRIPE_SECRET_KEY.value());

    let event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        req.headers['stripe-signature'],
        STRIPE_WEBHOOK_SECRET.value()
      );
    } catch (err) {
      // Signature check failed — reject before touching Firestore at all.
      // This is what stops anyone from forging a request and granting
      // themselves a paid tariff for free.
      logger.error('Stripe signature verification failed', err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    try {
      switch (event.type) {
        case 'checkout.session.completed': {
          const session = event.data.object;
          if (session.mode !== 'subscription' || !session.subscription) {
            break;
          }
          const email = session.customer_details?.email || session.customer_email;
          if (!email) {
            await logUnmatched('no_email', {
              eventId: event.id,
              eventType: event.type,
              sessionId: session.id,
            });
            break;
          }
          const subscription = await stripe.subscriptions.retrieve(session.subscription);
          const tariffEndIso = isoFromUnixSeconds(subscription.current_period_end);
          await resolveAndApplyTariff(email, ORION_TARIFF_NAME, tariffEndIso, session.customer, {
            eventId: event.id,
            eventType: event.type,
            subscriptionId: subscription.id,
          });
          break;
        }

        case 'invoice.payment_succeeded': {
          const invoice = event.data.object;
          // A one-off invoice (no subscription attached) isn't a renewal
          // we manage tariffs from.
          if (!invoice.subscription) {
            break;
          }
          const customer = await stripe.customers.retrieve(invoice.customer);
          const email = customer.deleted ? null : customer.email;
          if (!email) {
            await logUnmatched('no_email', {
              eventId: event.id,
              eventType: event.type,
              invoiceId: invoice.id,
            });
            break;
          }
          const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
          const tariffEndIso = isoFromUnixSeconds(subscription.current_period_end);
          await resolveAndApplyTariff(email, ORION_TARIFF_NAME, tariffEndIso, invoice.customer, {
            eventId: event.id,
            eventType: event.type,
            subscriptionId: subscription.id,
            invoiceId: invoice.id,
          });
          break;
        }

        case 'customer.subscription.deleted': {
          const subscription = event.data.object;
          const customer = await stripe.customers.retrieve(subscription.customer);
          const email = customer.deleted ? null : customer.email;
          if (!email) {
            await logUnmatched('no_email', {
              eventId: event.id,
              eventType: event.type,
              subscriptionId: subscription.id,
            });
            break;
          }
          // Kept even on cancellation — still useful for re-opening the
          // Customer Portal later (e.g. to resubscribe).
          await resolveAndApplyTariff(email, BASE_TARIFF_NAME, BASE_TARIFF_END_ISO, subscription.customer, {
            eventId: event.id,
            eventType: event.type,
            subscriptionId: subscription.id,
          });
          break;
        }

        default:
          // Event type we don't act on — acknowledge so Stripe stops retrying it.
          break;
      }

      res.status(200).send('ok');
    } catch (err) {
      logger.error('Error processing Stripe event', {
        eventId: event.id,
        eventType: event.type,
        error: err.message,
        stack: err.stack,
      });
      // Non-2xx makes Stripe retry this event later — appropriate for a
      // transient failure (e.g. a Firestore hiccup), since resolveAndApplyTariff
      // itself is safe to run again for the same event.
      res.status(500).send('internal error');
    }
  }
);

/**
 * Called from the subscription-management web page (Firebase Hosting)
 * AFTER the visitor has completed Firebase Auth's email-link sign-in —
 * i.e. after they've proven they actually control the mailbox for that
 * email, not just typed one in. request.auth is populated automatically
 * by the Callable Functions SDK from the caller's Firebase ID token, so
 * the email used below is the verified one, never a client-supplied
 * string — that's what stops a stranger from opening someone else's
 * billing portal just by knowing their email address.
 */
exports.createPortalSession = onCall(
  { secrets: [STRIPE_SECRET_KEY], region: 'us-central1' },
  async (request) => {
    if (!request.auth || !request.auth.token.email) {
      throw new HttpsError('unauthenticated', 'Требуется вход по ссылке из письма.');
    }
    const email = request.auth.token.email;
    const stripe = Stripe(STRIPE_SECRET_KEY.value());

    // Primary path: a Users doc we already stamped with stripe_customer_id
    // (via the webhook above) — no Stripe call needed for the common case.
    let stripeCustomerId = null;
    const docs = await findUserDocs(email);
    const docsWithCustomerId = docs.filter((d) => d.get('stripe_customer_id'));
    if (docsWithCustomerId.length === 1) {
      stripeCustomerId = docsWithCustomerId[0].get('stripe_customer_id');
    }

    // Fallback: direct Stripe lookup by email. Uses the basic list filter
    // (real-time/consistent) rather than the Search API (eventually
    // consistent — a customer created moments ago might not be indexed
    // yet), since this can run right after a fresh checkout.
    if (!stripeCustomerId) {
      const customers = await stripe.customers.list({ email, limit: 2 });
      if (customers.data.length === 1) {
        stripeCustomerId = customers.data[0].id;
      } else {
        logger.warn('createPortalSession: could not resolve a single Stripe customer', {
          email,
          firestoreMatches: docs.length,
          stripeMatches: customers.data.length,
        });
        throw new HttpsError(
          'not-found',
          'Не удалось найти подписку для этого email. Напишите нам: support@rivapsy.com'
        );
      }
    }

    const portalSession = await stripe.billingPortal.sessions.create({
      customer: stripeCustomerId,
      return_url: 'https://rigel-psy-9361c.web.app/',
    });

    return { url: portalSession.url };
  }
);
