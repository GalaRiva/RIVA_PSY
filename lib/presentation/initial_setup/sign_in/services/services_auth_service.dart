import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
class ServicesAuthService {
  GoogleSignInAccount? _googleUser;
  GoogleSignInAccount get googleUser => _googleUser!;
  User? _appleUser;
  User get appleUser => _appleUser!;

  // Temporary diagnostic aid: the catch blocks below used to swallow the
  // real exception behind a generic "проверьте подключение к интернету"
  // message, which made a Play-App-Signing cert mismatch (the OAuth client
  // rejecting an unrecognized signing cert) indistinguishable from an actual
  // network problem. Surfacing the raw exception text in the dialog lets us
  // tell those apart from a single test round instead of guessing blind.
  String? lastError;

  // Tried google_sign_in 7.x (Credential Manager on Android / new SDK on
  // iOS) again 2026-09-04 specifically to fix a real iOS crash inside
  // FLTGoogleSignInPlugin.signInWithCompletion: (confirmed via an on-device
  // crash log — not a hang, a watchdog-killed relaunch that looked like one)
  // on 5.x. Reverted back to 6.x within the hour: Android's Credential
  // Manager failed a real sign-in attempt (GetCredentialResponse error from
  // the framework, before any account picker UI ever appeared) which
  // google_sign_in mapped to a generic "canceled" exception, silently
  // swallowing the real reason (diagnostic showed "[diag] null"). Same
  // failure class as the original "[16] Account reauth failed" that caused
  // the first 7.x -> 6.x revert (see https://github.com/flutter/flutter/issues/184918,
  // closed not_planned) — the old SDK doesn't go through Credential Manager
  // at all, so 6.x isn't exposed to it. Checked for a newer google_sign_in_android
  // patch and a signing-cert mismatch as possible causes — neither panned
  // out (already on the latest google_sign_in_android; profile build uses
  // the same release-signed cert 6.x used successfully). Test device was
  // MIUI (Xiaomi), which is known to be more aggressive about breaking
  // Google Play Services integrations than stock Android — worth retrying
  // on a non-MIUI device before assuming this is unfixable again. The iOS
  // crash is a still-open, separate problem; don't re-attempt 7.x to fix it
  // without first checking whether Google has since released a
  // 6.x-compatible google_sign_in_ios patch, or whether a
  // non-Credential-Manager alternative exists.
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web (client_type 3) OAuth client from android/app/google-services.json
    // — needed so Firebase's signInWithCredential has an audience to
    // validate the ID token against.
    serverClientId: '7653326357-b1mhkh0o9knlt688dlmh4r94ub8d38kg.apps.googleusercontent.com',
  );

  Future<bool> authWithGoogle () async {
    try {
      // Sign out first so the account picker always shows, rather than
      // silently reusing (or failing to reuse) a cached session.
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User dismissed the account picker.
        return false;
      }
      _googleUser = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      print(e);
      lastError = e.toString();
      return false;
    }

  }

  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> authWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. The nonce in the identity
    // token returned by Apple is expected to match the sha256 hash of
    // `rawNonce`.
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: Platform.isIOS
            ? null
            : WebAuthenticationOptions(
                clientId: 'com.riva.psy.signin',
                redirectUri: Uri.parse(
                    'https://rigel-psy-9361c.firebaseapp.com/__/auth/handler'),
              ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Was routed through a Cloud Function (verifyAppleIdentityToken) that
      // independently verified the identity token and minted a Firebase
      // custom token instead — Firebase's own signInWithCredential("apple.com")
      // was reliably rejecting a verifiably genuine, correctly-signed Apple
      // identityToken on this project (confirmed 2026-09-05 by hand-checking
      // the token's RS256 signature against Apple's published JWKS — valid).
      // Firebase Auth support (2026-09-10) identified the actual cause: the
      // credential needs Apple's authorizationCode passed as `accessToken` —
      // without it, Firebase's own backend-to-Apple validation call can't
      // complete. Back to the standard signInWithCredential path with that
      // included. If this regresses, the Cloud Function + signInWithCustomToken
      // path above (see git history around 2026-09-05) is the known-working
      // fallback — verifyAppleIdentityToken is still deployed, just unused
      // by this method for now.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      _appleUser = authResult.user;
      return true;
    } on FirebaseAuthException catch (exception) {
      print(exception);
      // Default toString() is just "[plugin/code] message" — code and
      // message are already exactly that, but spelling them out
      // separately (plus any stack trace Firebase attaches) rules out
      // there being more detail hiding behind a truncated dialog before
      // concluding the client genuinely has nothing more to show.
      lastError = 'code=${exception.code} message=${exception.message} '
          'plugin=${exception.plugin}';
      return false;
    } catch (exception) {
      print(exception);
      lastError = '${exception.runtimeType}: ${exception.toString()}';
      return false;
    }
  }
}

