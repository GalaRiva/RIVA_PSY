import '../../data/repository.dart';
import '../models/firebase_result.dart';

class ConfirmResetEmailPassword {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> verifyResetCode (String code, String newPassword) async {
    return _repo.confirmResetCodeForEmail(code, newPassword);
  }
}