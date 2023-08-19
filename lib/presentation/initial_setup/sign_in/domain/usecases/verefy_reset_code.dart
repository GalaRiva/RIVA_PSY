import '../../data/repository.dart';
import '../models/firebase_result.dart';

class VerifyResetCode {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> verifyResetCode (String code) async {
    return _repo.verifyResetCodeForEmail(code);
  }
}