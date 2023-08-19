import '../../data/repository.dart';
import '../models/firebase_result.dart';

class ResetFirebasePassword {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> resetFirebasePassword (String userId, String newPassword) async {
    return _repo.resetUserPassword(userId, newPassword);
  }
}