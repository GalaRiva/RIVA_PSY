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

  // google_sign_in 7.x moved from a per-call `GoogleSignIn()` instance to a
  // process-wide `GoogleSignIn.instance` that must be `initialize()`d
  // exactly once before any other call — repeating it is documented as
  // undefined behavior. GoogleDriveService (a separate feature, Drive
  // backup/restore) also calls GoogleSignIn.instance, so this guard is
  // static and shared via ensureGoogleSignInInitialized() rather than
  // living per-instance, since both features must not race to initialize
  // the same singleton independently.
  static bool _googleSignInInitialized = false;

  static Future<void> ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: Platform.isAndroid ? null : '408583851820-d1m3evieiu0ttbnt15gp3m2j9j0dqpn9.apps.googleusercontent.com',
      // Without this, the plugin has no audience to issue an ID token for —
      // on Android this can surface as ApiException: 10 (DEVELOPER_ERROR)
      // even when the signing cert and OAuth client are correctly
      // registered, since Firebase's signInWithCredential needs that ID
      // token. Value is the web (client_type 3) OAuth client from
      // android/app/google-services.json, the standard serverClientId for
      // an Android app backed by this Firebase project.
      serverClientId: '7653326357-b1mhkh0o9knlt688dlmh4r94ub8d38kg.apps.googleusercontent.com',
    );
    _googleSignInInitialized = true;
  }

  Future<bool> authWithGoogle () async {
    try {
    await ensureGoogleSignInInitialized();

    final googleUser = await GoogleSignIn.instance.authenticate();
    _googleUser = googleUser;

    // Synchronous in 7.x (was a Future in 6.x), and no longer carries an
    // accessToken — Firebase's signInWithCredential only needs the idToken.
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
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

