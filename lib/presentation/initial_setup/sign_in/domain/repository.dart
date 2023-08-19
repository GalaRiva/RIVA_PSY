import 'package:firebase_auth/firebase_auth.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/models/firebase_result.dart';

abstract class SignInDomainRepository {

  // FirebaseAuth MAIL
  Future<FirebaseResult> signInWithEmail (String email, String password);
  Future<FirebaseResult> signUpWithEmail (String email, String password);
  Future<FirebaseResult> sendResetPasswordCodeEmail (String email);
  Future<FirebaseResult> verifyResetCodeForEmail (String code);
  Future<FirebaseResult> confirmResetCodeForEmail (String code, String newPassword);

  // FirebaseAuth PHONE

  Future<FirebaseResult> signInWithPhone (String email, String password);
  Future<FirebaseResult> signUpWithPhone (String email, String password);
  Future<FirebaseResult> sendSmsCodePhone (String email);

  // FirebaseFirestore

  Future<FirebaseResult> checkUserState (String userId, String? password);
  Future<FirebaseResult> createUser ({String? email, String? password, String? number});
  Future<FirebaseResult> resetUserPassword (String userId, String password);

  // Services

  Future<FirebaseResult> signInWithGoogle ();
  Future<FirebaseResult> signInWithApple ();

  // Other

  Future<FirebaseResult> getAndSetRemoteUserLocally (String userId);
}