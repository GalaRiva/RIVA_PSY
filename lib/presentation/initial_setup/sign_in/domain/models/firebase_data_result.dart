import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_result.dart';

class FirebaseDataResult extends FirebaseResult {

  FirebaseDataResult( {required FirebaseResultStatus firebaseResultStatus, String? exceptionMessage}) : super(firebaseResultStatus: firebaseResultStatus, exceptionMessage: exceptionMessage);
}
