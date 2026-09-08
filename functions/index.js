const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const Stripe = require('stripe');
const { google } = require('googleapis');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { jwtVerify, createRemoteJWKSet } = require('jose');
const { SignedDataVerifier, Environment: AppleEnvironment } = require('@apple/app-store-server-library');

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

async function applyTariff(docId, tariffName, tariffEndIso, stripeCustomerId, appleOriginalTransactionId) {
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
  // Same idea as stripe_customer_id, but for Apple: verifyApplePurchase
  // stamps this the first time a given subscription's receipt is verified,
  // so appleServerNotifications (a true webhook — Apple calling us, not the
  // client) can later find the right Users doc from nothing but the
  // originalTransactionId in a renewal/refund/expiry event, with no email
  // or Firebase Auth session involved at all.
  if (appleOriginalTransactionId) {
    fields.apple_original_transaction_id = appleOriginalTransactionId;
  }
  await db.collection('Users').doc(docId).set(fields, { merge: true });
  logger.info('Applied tariff', { docId, tariffName, tariffEndIso, stripeCustomerId, appleOriginalTransactionId });
}

/**
 * Resolves an email to exactly one Users doc and applies the tariff.
 * On 0 or >1 matches, does NOT guess — logs to UnmatchedStripePayments
 * for manual review instead. A wrong automatic guess here means either
 * granting paid access to the wrong account or silently failing to grant
 * access to a paying customer — both worse than a short manual-review
 * delay.
 */
async function resolveAndApplyTariff(email, tariffName, tariffEndIso, stripeCustomerId, eventMeta, appleOriginalTransactionId) {
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

  await applyTariff(docs[0].id, tariffName, tariffEndIso, stripeCustomerId, appleOriginalTransactionId);
}

/**
 * The appleServerNotifications counterpart to resolveAndApplyTariff — Apple
 * calls this webhook server-to-server with no Firebase Auth session and no
 * email, only the subscription's originalTransactionId, so the user has to
 * be found by that instead. Same no-guessing policy as the email path: 0 or
 * >1 matches goes to manual review rather than risking the wrong account.
 */
async function resolveAndApplyTariffByAppleTransaction(originalTransactionId, tariffName, tariffEndIso, eventMeta) {
  const snap = await db
    .collection('Users')
    .where('apple_original_transaction_id', '==', originalTransactionId)
    .get();

  if (snap.size === 0) {
    // Expected the first time a *fresh install/account* renews before it's
    // ever had a verifyApplePurchase() call stamp this field — not
    // necessarily an error, just nothing to update yet.
    await logUnmatched('no_match', { originalTransactionId, tariffName, tariffEndIso, ...eventMeta });
    return;
  }

  if (snap.size > 1) {
    await logUnmatched('multiple_matches', {
      originalTransactionId,
      tariffName,
      tariffEndIso,
      matchedDocIds: snap.docs.map((d) => d.id),
      ...eventMeta,
    });
    return;
  }

  await applyTariff(snap.docs[0].id, tariffName, tariffEndIso);
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

// Android package name (android/app/build.gradle's applicationId) — the
// Android Publisher API needs this to know which app's subscription the
// purchase token belongs to.
const ANDROID_PACKAGE_NAME = 'com.riva_psy.app';

const ACTIVE_SUBSCRIPTION_STATES = new Set([
  'SUBSCRIPTION_STATE_ACTIVE',
  'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
]);

/**
 * Verifies a Google Play Billing purchase server-side and applies the
 * Orion tariff — the Android-native counterpart to stripeWebhook, used now
 * that registering Stripe as an "alternative payment system" in Play
 * Console requires a registered company (see lib/core/services/
 * google_play_billing_service.dart for the client side).
 *
 * Never trusts the client's own claim of having purchased something — a
 * purchase token is just an opaque string the client could resend or
 * forge, so the only source of truth is Google's own Android Publisher
 * API, queried here with the Cloud Function's own service account
 * (no separate secret needed, unlike Stripe — see functions/README.md
 * for the one-time Play Console step that grants this service account
 * access).
 */
exports.verifyAndroidPurchase = onCall(
  { region: 'us-central1' },
  async (request) => {
    if (!request.auth || !request.auth.token.email) {
      throw new HttpsError('unauthenticated', 'Требуется вход в приложение.');
    }
    const { purchaseToken, productId } = request.data || {};
    if (!purchaseToken || typeof purchaseToken !== 'string') {
      throw new HttpsError('invalid-argument', 'purchaseToken обязателен.');
    }
    if (!productId || typeof productId !== 'string') {
      throw new HttpsError('invalid-argument', 'productId обязателен.');
    }

    const auth = new google.auth.GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    const androidpublisher = google.androidpublisher({ version: 'v3', auth });

    let subscription;
    try {
      const res = await androidpublisher.purchases.subscriptionsv2.get({
        packageName: ANDROID_PACKAGE_NAME,
        token: purchaseToken,
      });
      subscription = res.data;
    } catch (err) {
      logger.error('Android Publisher API error', {
        error: err.message,
        productId,
      });
      throw new HttpsError(
        'internal',
        'Не удалось проверить покупку через Google Play.'
      );
    }

    const state = subscription.subscriptionState;
    if (!ACTIVE_SUBSCRIPTION_STATES.has(state)) {
      logger.warn('verifyAndroidPurchase: subscription not active', {
        state,
        productId,
        email: request.auth.token.email,
      });
      throw new HttpsError(
        'failed-precondition',
        `Подписка не активна (статус: ${state}).`
      );
    }

    const lineItem = (subscription.lineItems || []).find(
      (item) => item.productId === productId
    ) || (subscription.lineItems || [])[0];
    const expiryTimeIso = lineItem && lineItem.expiryTime;
    if (!expiryTimeIso) {
      logger.error('verifyAndroidPurchase: no expiryTime in response', {
        productId,
        subscription,
      });
      throw new HttpsError(
        'internal',
        'Не удалось определить дату окончания подписки.'
      );
    }

    const email = request.auth.token.email;
    await resolveAndApplyTariff(email, ORION_TARIFF_NAME, expiryTimeIso, null, {
      source: 'google_play',
      productId,
      subscriptionState: state,
    });

    return { tariff: ORION_TARIFF_NAME, tariffIsEnd: expiryTimeIso };
  }
);

// App-Specific Shared Secret from App Store Connect -> Apps -> RIVA PSY ->
// Subscriptions -> App-Specific Shared Secret ("Manage" / "View"). This is
// the only credential Apple's *legacy* verifyReceipt endpoint needs — no
// API key file or JWT signing, unlike the newer App Store Server API.
// in_app_purchase_storekit (the client plugin) still populates
// PurchaseDetails.verificationData with a legacy base64 receipt, not a
// StoreKit 2 signed transaction, so this endpoint is the correct match for
// what the client actually sends.
const APPLE_SHARED_SECRET = defineSecret('APPLE_SHARED_SECRET');

const APPLE_VERIFY_RECEIPT_PRODUCTION_URL = 'https://buy.itunes.apple.com/verifyReceipt';
const APPLE_VERIFY_RECEIPT_SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt';

async function callAppleVerifyReceipt(url, receiptData, sharedSecret) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      'receipt-data': receiptData,
      password: sharedSecret,
      'exclude-old-transactions': true,
    }),
  });
  return res.json();
}

/**
 * Verifies an App Store purchase server-side and applies the Orion tariff
 * — the iOS-native counterpart to verifyAndroidPurchase above, used for
 * the same reason (Stripe as an "alternative payment system" isn't set up
 * for this account) — see lib/core/services/apple_billing_service.dart for
 * the client side.
 *
 * Never trusts the client's own claim of having purchased something — the
 * receipt is just base64 data the client could resend or forge, so the
 * only source of truth is Apple's own verifyReceipt response.
 *
 * NOT YET DEPLOYABLE: needs the APPLE_SHARED_SECRET secret set
 * (`firebase functions:secrets:set APPLE_SHARED_SECRET`) with the value
 * from App Store Connect before this can be deployed — see this file's
 * comment above the constant for exactly where to find it. Also needs the
 * riva_psy_orion_monthly/riva_psy_orion_yearly subscription products to
 * actually exist in App Store Connect first, or every verifyReceipt call
 * will just come back with no matching line item.
 */
exports.verifyApplePurchase = onCall(
  { secrets: [APPLE_SHARED_SECRET], region: 'us-central1' },
  async (request) => {
    if (!request.auth || !request.auth.token.email) {
      throw new HttpsError('unauthenticated', 'Требуется вход в приложение.');
    }
    const { receiptData, productId } = request.data || {};
    if (!receiptData || typeof receiptData !== 'string') {
      throw new HttpsError('invalid-argument', 'receiptData обязателен.');
    }
    if (!productId || typeof productId !== 'string') {
      throw new HttpsError('invalid-argument', 'productId обязателен.');
    }

    const sharedSecret = APPLE_SHARED_SECRET.value();
    let body;
    try {
      body = await callAppleVerifyReceipt(
        APPLE_VERIFY_RECEIPT_PRODUCTION_URL,
        receiptData,
        sharedSecret
      );
      // Status 21007: a sandbox receipt was sent to the production
      // endpoint — Apple's own documented way of telling test purchases
      // apart from real ones without the client having to know which
      // environment it's running in (StoreKit Testing / TestFlight both
      // produce sandbox receipts).
      if (body.status === 21007) {
        body = await callAppleVerifyReceipt(
          APPLE_VERIFY_RECEIPT_SANDBOX_URL,
          receiptData,
          sharedSecret
        );
      }
    } catch (err) {
      logger.error('Apple verifyReceipt request failed', { error: err.message, productId });
      throw new HttpsError('internal', 'Не удалось проверить покупку через App Store.');
    }

    if (body.status !== 0) {
      logger.warn('verifyApplePurchase: non-zero status', {
        status: body.status,
        productId,
        email: request.auth.token.email,
      });
      throw new HttpsError(
        'failed-precondition',
        `Покупка не подтверждена App Store (статус: ${body.status}).`
      );
    }

    // latest_receipt_info holds every transaction in the receipt — pick
    // the one for this product with the furthest-out expiry, since a
    // renewed subscription's receipt contains its own purchase history
    // too.
    const entries = (body.latest_receipt_info || []).filter(
      (entry) => entry.product_id === productId
    );
    const latest = entries.sort(
      (a, b) => Number(b.expires_date_ms) - Number(a.expires_date_ms)
    )[0];
    if (!latest || !latest.expires_date_ms) {
      logger.error('verifyApplePurchase: no matching line item', { productId, status: body.status });
      throw new HttpsError('internal', 'Не удалось определить дату окончания подписки.');
    }

    const expiryTimeIso = new Date(Number(latest.expires_date_ms)).toISOString();
    if (Date.now() > Number(latest.expires_date_ms)) {
      logger.warn('verifyApplePurchase: subscription already expired', { productId, expiryTimeIso });
      throw new HttpsError('failed-precondition', 'Срок подписки истёк.');
    }

    // Stamped on the Users doc below so appleServerNotifications (a true
    // server-to-server webhook, with no email or auth session available)
    // can find this same user later for renewals/refunds/expiry it learns
    // about independently of the app ever calling this function again.
    const originalTransactionId = latest.original_transaction_id;

    const email = request.auth.token.email;
    await resolveAndApplyTariff(email, ORION_TARIFF_NAME, expiryTimeIso, null, {
      source: 'app_store',
      productId,
    }, originalTransactionId);

    return { tariff: ORION_TARIFF_NAME, tariffIsEnd: expiryTimeIso };
  }
);

// Firebase's built-in signInWithCredential("apple.com") reliably rejects a
// verifiably genuine, correctly-signed Apple identityToken with
// invalid-credential / "Invalid OAuth response from apple.com" on this
// project (confirmed 2026-09-05: independently decoded the token and
// verified its RS256 signature against Apple's own published JWKS by hand —
// signature valid, aud/nonce/exp all correct — yet Firebase's own
// verification still rejects it). Filed with Firebase support, but rather
// than block Apple Sign-In on their fix, this function does the same
// verification ourselves and mints a Firebase custom token instead, which
// takes a completely different code path from the broken one.
const APPLE_JWKS = createRemoteJWKSet(new URL('https://appleid.apple.com/auth/keys'));
// Native iOS/Android sign-in uses the app's own bundle id as audience;
// the web-redirect fallback (webAuthenticationOptions) uses the Services ID.
const APPLE_AUDIENCES = ['com.riva.psy', 'com.riva.psy.signin'];

exports.verifyAppleIdentityToken = onCall(
  { region: 'us-central1' },
  async (request) => {
    const { identityToken, rawNonce } = request.data || {};
    if (!identityToken || typeof identityToken !== 'string') {
      throw new HttpsError('invalid-argument', 'identityToken обязателен.');
    }
    if (!rawNonce || typeof rawNonce !== 'string') {
      throw new HttpsError('invalid-argument', 'rawNonce обязателен.');
    }

    let payload;
    try {
      const verified = await jwtVerify(identityToken, APPLE_JWKS, {
        issuer: 'https://appleid.apple.com',
        audience: APPLE_AUDIENCES,
      });
      payload = verified.payload;
    } catch (err) {
      logger.warn('verifyAppleIdentityToken: token verification failed', {
        error: err.message,
      });
      throw new HttpsError('unauthenticated', 'Не удалось проверить данные Apple.');
    }

    const expectedNonce = crypto.createHash('sha256').update(rawNonce).digest('hex');
    if (payload.nonce !== expectedNonce) {
      logger.warn('verifyAppleIdentityToken: nonce mismatch', { sub: payload.sub });
      throw new HttpsError('unauthenticated', 'Не удалось проверить данные Apple.');
    }

    const email = payload.email;
    if (!email) {
      throw new HttpsError(
        'failed-precondition',
        'Apple не передал email для этого аккаунта.'
      );
    }

    // Reuse the existing Firebase Auth user if this email already has one
    // (e.g. previously signed up via Google) rather than minting a second,
    // colliding account — Firebase Auth enforces unique emails across all
    // users regardless of provider, and the app's own Firestore user
    // profiles are already keyed by "<email> <service>" independently of
    // the Auth uid, so sharing one underlying Auth account across
    // providers for the same email is exactly the existing app-level model.
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
    } catch (err) {
      if (err.code !== 'auth/user-not-found') throw err;
      userRecord = await admin.auth().createUser({
        email,
        emailVerified: payload.email_verified === true || payload.email_verified === 'true',
      });
    }

    const customToken = await admin.auth().createCustomToken(userRecord.uid);
    logger.info('verifyAppleIdentityToken: issued custom token', {
      uid: userRecord.uid,
      sub: payload.sub,
    });
    return { customToken, email };
  }
);

/**
 * App Store Server Notifications V2 — Apple calls this URL itself (real
 * server-to-server webhook, no client involved) on subscription lifecycle
 * events: renewals, expirations, refunds, billing-retry grace periods, etc.
 * Complements verifyApplePurchase (which only runs once, right after a
 * purchase, because the app calls it) by keeping tariff_is_end accurate for
 * everything that happens *after* that — a renewal the app never opens
 * again to observe, a refund, a family-sharing revocation, or a user who
 * cancels via iPhone Settings instead of inside the app.
 *
 * The app's bundle id (com.riva.psy) is not enough on its own to find the
 * right Users doc — there's no email or Firebase Auth session on an
 * incoming webhook. Apple's transaction payload does reliably carry
 * originalTransactionId, which is why verifyApplePurchase stamps
 * apple_original_transaction_id on the Users doc on every receipt
 * verification — see that function and resolveAndApplyTariffByAppleTransaction.
 *
 * Registered as TWO separate Cloud Functions/URLs (below), matching how
 * App Store Connect itself asks for a production URL and a separate
 * Sandbox URL under Информация о приложении → "Уведомления сервера App
 * Store" — each SignedDataVerifier is bound to one environment at
 * construction time (see the library's own docs for why), so this avoids
 * needing to guess the environment from unverified data before knowing
 * which verifier to even try.
 */

// The app's own numeric Apple ID (App Store Connect → Информация о
// приложении → "Apple ID", not any per-subscription id) — required by
// SignedDataVerifier for the Production environment only; Sandbox omits it.
const APP_APPLE_ID = 6809211171;
const APP_BUNDLE_ID = 'com.riva.psy';

// Apple Root CA - G3 (https://www.apple.com/certificateauthority/), the
// root that App Store Server Notifications' certificate chain leads back
// to. DER-encoded, bundled at deploy time — see functions/certs/README.md
// for where this came from and how to refresh it.
const appleRootCertificates = [
  fs.readFileSync(path.join(__dirname, 'certs', 'AppleRootCA-G3.cer')),
];

function makeAppleNotificationVerifier(environment) {
  return new SignedDataVerifier(
    appleRootCertificates,
    true, // enableOnlineChecks — also checks certificate revocation + expiry
    environment,
    APP_BUNDLE_ID,
    environment === AppleEnvironment.PRODUCTION ? APP_APPLE_ID : undefined
  );
}

const appleNotificationVerifierProd = makeAppleNotificationVerifier(AppleEnvironment.PRODUCTION);
const appleNotificationVerifierSandbox = makeAppleNotificationVerifier(AppleEnvironment.SANDBOX);

// notificationType values where the subscription is active (or should still
// be treated as such) right now.
const APPLE_ACTIVE_NOTIFICATION_TYPES = new Set(['SUBSCRIBED', 'DID_RENEW']);
// notificationType values where the subscription has definitively ended.
const APPLE_TERMINATED_NOTIFICATION_TYPES = new Set([
  'EXPIRED',
  'GRACE_PERIOD_EXPIRED',
  'REFUND',
  'REVOKE',
]);

async function handleAppleServerNotification(verifier, req, res) {
  const signedPayload = req.body && req.body.signedPayload;
  if (!signedPayload || typeof signedPayload !== 'string') {
    logger.warn('appleServerNotifications: request missing signedPayload');
    res.status(400).send('missing signedPayload');
    return;
  }

  let notification;
  try {
    notification = await verifier.verifyAndDecodeNotification(signedPayload);
  } catch (err) {
    // Signature/chain/bundle-id/environment check failed — reject before
    // touching Firestore at all, same reasoning as stripeWebhook's
    // signature check: this is what stops a forged request from granting
    // itself a free tariff.
    logger.error('appleServerNotifications: notification verification failed', {
      error: err.message,
    });
    res.status(400).send('invalid signature');
    return;
  }

  const notificationType = notification.notificationType;
  const subtype = notification.subtype;
  const environment = notification.data && notification.data.environment;
  const signedTransactionInfo = notification.data && notification.data.signedTransactionInfo;

  logger.info('appleServerNotifications: received', {
    notificationType,
    subtype,
    environment,
    notificationUUID: notification.notificationUUID,
  });

  // TEST notifications ("Send Test Notification" in App Store Connect, or
  // requestTestNotification()) and a few other types carry no transaction
  // data — nothing to apply, just acknowledge so Apple doesn't retry.
  if (!signedTransactionInfo) {
    res.status(200).send('ok');
    return;
  }

  let transaction;
  try {
    transaction = await verifier.verifyAndDecodeTransaction(signedTransactionInfo);
  } catch (err) {
    logger.error('appleServerNotifications: transaction verification failed', {
      error: err.message,
      notificationType,
    });
    res.status(400).send('invalid transaction signature');
    return;
  }

  const originalTransactionId = transaction.originalTransactionId;
  const expiresDate = transaction.expiresDate; // unix ms, or undefined for non-subscription types
  if (!originalTransactionId) {
    logger.warn('appleServerNotifications: transaction has no originalTransactionId', { notificationType });
    res.status(200).send('ok');
    return;
  }

  const eventMeta = {
    source: 'app_store_server_notification',
    notificationType,
    subtype,
    environment,
    productId: transaction.productId,
    notificationUUID: notification.notificationUUID,
  };

  try {
    const isGraceBillingRetry = notificationType === 'DID_FAIL_TO_RENEW' && subtype === 'GRACE_PERIOD';

    if (APPLE_ACTIVE_NOTIFICATION_TYPES.has(notificationType) || isGraceBillingRetry) {
      // A billing-retry grace period still counts as active — Apple's own
      // guidance is to keep access on through GRACE_PERIOD_EXPIRED, using
      // this same expiresDate (which Apple extends to cover the grace
      // window) rather than cutting access at the first missed charge.
      if (!expiresDate) {
        logger.error('appleServerNotifications: no expiresDate on an active-type notification', eventMeta);
      } else {
        await resolveAndApplyTariffByAppleTransaction(
          originalTransactionId,
          ORION_TARIFF_NAME,
          new Date(expiresDate).toISOString(),
          eventMeta
        );
      }
    } else if (
      APPLE_TERMINATED_NOTIFICATION_TYPES.has(notificationType) ||
      (notificationType === 'DID_FAIL_TO_RENEW' && !isGraceBillingRetry)
    ) {
      await resolveAndApplyTariffByAppleTransaction(
        originalTransactionId,
        BASE_TARIFF_NAME,
        BASE_TARIFF_END_ISO,
        eventMeta
      );
    }
    // Everything else (DID_CHANGE_RENEWAL_STATUS, DID_CHANGE_RENEWAL_PREF,
    // OFFER_REDEEMED, PRICE_INCREASE, CONSUMPTION_REQUEST, RENEWAL_EXTENDED,
    // REFUND_DECLINED, ...) doesn't change whether the subscription is
    // active right now — acknowledged (so Apple stops retrying) but no
    // tariff write.

    res.status(200).send('ok');
  } catch (err) {
    logger.error('appleServerNotifications: error applying tariff', {
      error: err.message,
      stack: err.stack,
      ...eventMeta,
    });
    // Non-2xx makes Apple retry this notification later — appropriate for a
    // transient failure (e.g. a Firestore hiccup), since
    // resolveAndApplyTariffByAppleTransaction is safe to run again for the
    // same event.
    res.status(500).send('internal error');
  }
}

exports.appleServerNotificationsProd = onRequest(
  { region: 'us-central1' },
  (req, res) => handleAppleServerNotification(appleNotificationVerifierProd, req, res)
);

exports.appleServerNotificationsSandbox = onRequest(
  { region: 'us-central1' },
  (req, res) => handleAppleServerNotification(appleNotificationVerifierSandbox, req, res)
);
