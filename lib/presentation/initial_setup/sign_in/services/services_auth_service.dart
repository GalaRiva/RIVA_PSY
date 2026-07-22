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

  Future<bool> authWithGoogle () async {
    try {
    final googleSignIn = GoogleSignIn(
      clientId: Platform.isAndroid ? null  : '408583851820-d1m3evieiu0ttbnt15gp3m2j9j0dqpn9.apps.googleusercontent.com'
    );


    final googleUser = await googleSignIn.signIn();
    if(googleUser == null) return false;
    _googleUser = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );



      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (_) {
      print(_);
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
      return false;
    }
  }
}

