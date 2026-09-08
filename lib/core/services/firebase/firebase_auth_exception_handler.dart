import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  invalidActionCode,
  unknown,
  userNotFound
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "user-not-found":
        status = AuthStatus.userNotFound;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "invalid-action-code":
        status = AuthStatus.invalidActionCode;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }

  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = 'auth_error_invalid_email'.tr();
        break;
      case AuthStatus.weakPassword:
        errorMessage = 'auth_error_weak_password'.tr();
        break;
      case AuthStatus.wrongPassword:
        errorMessage = 'auth_error_wrong_password'.tr();
        break;
      case AuthStatus.userNotFound:
        errorMessage = 'auth_error_user_not_found'.tr();
            break;
      case AuthStatus.invalidActionCode:
        errorMessage = 'auth_error_invalid_action_code'.tr();
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage = 'auth_error_email_already_exists'.tr();
        break;
      default:
        errorMessage = 'network_error_try_later'.tr();
    }
    return errorMessage;
  }
}