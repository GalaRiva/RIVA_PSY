import '../../data/repository.dart';
import '../models/firebase_result.dart';

class SendResetCodeToEmail {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> sendResetCodeToEmail (String email) async {
    return _repo.sendResetPasswordCodeEmail(email);
  }
}