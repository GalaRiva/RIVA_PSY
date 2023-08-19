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
        errorMessage = "Неверный формат вводимой почты";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Неверный формат вводимого пароля";
        break;
      case AuthStatus.wrongPassword:
        errorMessage = "Неверный логин или пароль";
        break;
      case AuthStatus.userNotFound:
        errorMessage = "Такого пользователя не существует";
            break;
      case AuthStatus.invalidActionCode:
        errorMessage = "Код восстановления уже не дейсвителен";
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage =
        "Этот адресс электронной почты уже использует другой аккаунт";
        break;
      default:
        errorMessage = "Возникла ошибка. Проверьте подключение к интернету или попробуйте позднее.";
    }
    return errorMessage;
  }
}