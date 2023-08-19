import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseResult {
  final FirebaseResultStatus firebaseResultStatus;
  final String? exceptionMessage;
  FirebaseResult({required this.firebaseResultStatus, this.exceptionMessage});
}


enum FirebaseResultStatus {
  Error,
  Success
}