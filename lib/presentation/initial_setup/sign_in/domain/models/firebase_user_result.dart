import 'firebase_result.dart';

class FirebaseUserResult extends FirebaseResult {
  FirebaseUserResult({required this.userResultStatus, required FirebaseResultStatus firebaseResultStatus, String? exceptionMessage}) : super(firebaseResultStatus: firebaseResultStatus, exceptionMessage: exceptionMessage);
final FirebaseUserResultStatus userResultStatus;
}

enum FirebaseUserResultStatus {
  TrueData,
  WrongData,
  WasCreated,
  WasReset,
  NotExist,
  Exception
}