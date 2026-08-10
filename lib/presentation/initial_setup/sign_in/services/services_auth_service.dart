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

  // Reverted from google_sign_in 7.x (Credential Manager) back to the
  // classic 6.x native Google Sign-In SDK. Credential Manager's
  // "[16] Account reauth failed" turned out to be a confirmed, unfixable
  // (from our side) instability in Google's own Play Services component —
  // see https://github.com/flutter/flutter/issues/184918, closed by a
  // Flutter maintainer as "not_planned" with the same package version,
  // same error, same working config. The old SDK doesn't go through
  // Credential Manager at all, so it isn't exposed to that bug.
  // Shared across ServicesAuthService and GoogleDriveService like the old
  // per-instance API required — each feature gets its own GoogleSignIn
  // instance with the scopes it needs, no shared initialization step.
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
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: Platform.isIOS ? null :  WebAuthenticationOptions(clientId: 'com.riva.app', redirectUri: Uri.parse('https://living-beryl-class.glitch.me/callbacks/sign_in_with_apple')),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],

        nonce: Platform.isIOS ? nonce : null,
      );

      print(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: Platform.isIOS ? null : appleCredential.authorizationCode,

      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      final userEmail = '${appleCredential.email}';
      _appleUser = authResult.user;
      return true;
    } catch (exception) {
      print(exception);
      lastError = exception.toString();
      return false;
    }
  }
}

