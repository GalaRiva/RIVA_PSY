import '../../data/repository.dart';
import '../models/firebase_result.dart';

class SignUpWithEmail {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> signUpWithEmail (String email, String password) async {
    return _repo.signUpWithEmail(email, password);
  }
}