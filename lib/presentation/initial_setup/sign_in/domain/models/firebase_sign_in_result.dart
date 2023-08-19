import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_result.dart';

class FirebaseSignInResult extends FirebaseResult {
  final User? user;
  final String? userId;
  final String? email;
  final String? login;

  FirebaseSignInResult( {this.email, this.login,this.userId, this.user, required FirebaseResultStatus firebaseResultStatus, String? exceptionMessage}) : super(firebaseResultStatus: firebaseResultStatus, exceptionMessage: exceptionMessage);
}
