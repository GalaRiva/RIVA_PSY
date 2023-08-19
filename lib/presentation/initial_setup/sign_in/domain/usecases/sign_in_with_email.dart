import 'package:firebase_auth/firebase_auth.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/data/repository.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/models/firebase_result.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/repository.dart';

class SignInWithEmail {
  final _repo = SignInDataRepository();

  Future<FirebaseResult> signInWithEmail (String email, String password) async {
    return _repo.signInWithEmail(email, password);
  }
}