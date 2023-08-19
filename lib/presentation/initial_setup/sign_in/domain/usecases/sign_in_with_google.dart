import '../../data/repository.dart';
import '../models/firebase_result.dart';

class SignInWithGoogle {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> call() async {
    return _repo.signInWithGoogle();
  }
}
