import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listenmebaby71_s_application17/core/db/firebase_firestore/data/repository.dart';
import 'package:listenmebaby71_s_application17/core/models/tariff_model.dart';
import 'package:listenmebaby71_s_application17/core/models/user_data_model.dart';
import 'package:listenmebaby71_s_application17/core/services/firebase/firebase_auth_exception_handler.dart';
import 'package:listenmebaby71_s_application17/core/utils/string_extension.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/models/firebase_sign_in_result.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/services/apple_is_available_service.dart';
import '../../../../core/user_data/user.dart';
import '../domain/models/firebase_data_result.dart';
import '../domain/models/firebase_result.dart';
import '../domain/models/firebase_user_result.dart';
import '../services/services_auth_service.dart';

class SignInDataRepository extends SignInDomainRepository {
  final _instance = FirebaseAuth.instance;

  @override
  Future<FirebaseResult> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _instance.createUserWithEmailAndPassword(
          email: email, password: password);
      return FirebaseSignInResult(
          user: userCredential.user,
          email: email,
          firebaseResultStatus: FirebaseResultStatus.Success,
          userId: email);
    } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message);
    }
  }

  @override
  Future<FirebaseResult> signInWithEmail(String email, String password) async {
    try {
      final user = await _instance.signInWithEmailAndPassword(
          email: email, password: password);

      return FirebaseSignInResult(
          user: user.user,
          firebaseResultStatus: FirebaseResultStatus.Success,
          userId: email);
    } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message);
    }
  }

  @override
  Future<FirebaseResult> confirmResetCodeForEmail(
      String code, String newPassword) async {
    try {
      await _instance.confirmPasswordReset(
          code: code, newPassword: newPassword);
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Success);
    } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message);
    }
  }

  @override
  Future<FirebaseResult> sendResetPasswordCodeEmail(String email) async {
    try {
      await _instance.sendPasswordResetEmail(email: email);
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Success);
    } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message);
    }
  }

  @override
  Future<FirebaseResult> verifyResetCodeForEmail(String code) async {
    try {
      final email = await _instance.verifyPasswordResetCode(code);
      if (email.isNotEmpty)
        return FirebaseSignInResult(
            firebaseResultStatus: FirebaseResultStatus.Success);
      else
        return FirebaseSignInResult(
            firebaseResultStatus: FirebaseResultStatus.Error,
            exceptionMessage:
                'Проверьте правильность введённого вами кода или попробуйте позднее');
    } on FirebaseAuthException catch (e) {
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage:
              'Проверьте правильность введённого вами кода или попробуйте позднее');
    }
  }

  @override
  Future<FirebaseResult> checkUserState(String userId, String? password) async {
    try {
      final _collection = FirebaseFirestore.instance.collection('Users');
      final _doc = await _collection.doc(userId).get();
      if ((_doc).exists) {
        final user = UserDataModel.fromJson(_doc.data()!);

        if (password == null || user.passwordHash == password.md5()) {
          return FirebaseUserResult(
              userResultStatus: FirebaseUserResultStatus.TrueData,
              firebaseResultStatus: FirebaseResultStatus.Success);
        }

        return FirebaseUserResult(
            userResultStatus: FirebaseUserResultStatus.WrongData,
            firebaseResultStatus: FirebaseResultStatus.Success);
      } else if (!(_doc).exists) {
        return FirebaseUserResult(
            userResultStatus: FirebaseUserResultStatus.NotExist,
            firebaseResultStatus: FirebaseResultStatus.Success);
      }
      final _error = AuthExceptionHandler.handleAuthException(
          FirebaseAuthException(code: ''));
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseUserResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message,
          userResultStatus: FirebaseUserResultStatus.Exception);
    } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseUserResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message,
          userResultStatus: FirebaseUserResultStatus.Exception);
    }
  }

  @override
  Future<FirebaseResult> createUser(
      {String? email,
      String? password,
      String? number,
      String? service}) async {
    try {
      final _collection = FirebaseFirestore.instance.collection('UsersData');
      String userId() {
        if (email != null) {
          if (service != null) return '$email $service';
          return email;
        }
        return number!;
      }

      final _doc = _collection.doc(userId());
      await _doc.set(UserDataModel(
              passwordHash: password != null ? password.md5() : null,
              email: email,
              number: number,
              service: service)
          .toJson());
      return FirebaseUserResult(
          userResultStatus: FirebaseUserResultStatus.WasCreated,
          firebaseResultStatus: FirebaseResultStatus.Success);
      } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseUserResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message,
          userResultStatus: FirebaseUserResultStatus.Exception);
    }
  }

  @override
  Future<FirebaseResult> resetUserPassword(
      String userId, String password) async {
    try {
      final _collection = _firestoreInstance.collection('UsersData');
      final _doc = _collection.doc(userId);
      await _doc.update(UserDataModel(passwordHash: password.md5()).toJson());
      return FirebaseUserResult(
          userResultStatus: FirebaseUserResultStatus.WasReset,
          firebaseResultStatus: FirebaseResultStatus.Success);
    } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseUserResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: _message,
          userResultStatus: FirebaseUserResultStatus.Exception);
    }
  }

  @override
  Future<FirebaseResult> sendSmsCodePhone(String email) {
    // TODO: implement sendSmsCodePhone
    throw UnimplementedError();
  }

  @override
  Future<FirebaseResult> signInWithPhone(String email, String password) {
    // TODO: implement signInWithPhone
    throw UnimplementedError();
  }

  @override
  Future<FirebaseResult> signUpWithPhone(String email, String password) {
    // TODO: implement signUpWithPhone
    throw UnimplementedError();
  }

  final _firestoreInstance = FirebaseFirestore.instance;
  final _servicesAuth = ServicesAuthService();

  Future<FirebaseResult> signInWithGoogle() async {
    try {
      if (await _servicesAuth.authWithGoogle()) {
        final userId = _servicesAuth.googleUser.email + ' google';

          final createUserResult = await createUser(
              email: _servicesAuth.googleUser.email, service: 'google');
          createUserResult as FirebaseUserResult;
          if (createUserResult.userResultStatus ==
              FirebaseUserResultStatus.WasCreated) {
            return FirebaseSignInResult(
                userId: userId,
                login: _servicesAuth.googleUser.displayName,
                email: _servicesAuth.googleUser.email,
                firebaseResultStatus: FirebaseResultStatus.Success);
          } else {
            return FirebaseSignInResult(
              firebaseResultStatus: FirebaseResultStatus.Error,
              exceptionMessage: createUserResult.exceptionMessage!,
            );

        }
      } else {
        return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage:
              'Произошла непредвиденная ошибка, проверьте подклюбчение к интернету',
        );
      }
      } on FirebaseAuthException catch (e) {
      final _error = AuthExceptionHandler.handleAuthException(e);
      final _message = AuthExceptionHandler.generateErrorMessage(_error);
      return FirebaseSignInResult(
        firebaseResultStatus: FirebaseResultStatus.Error,
        exceptionMessage: _message,
      );
    }
  }

  Future<FirebaseResult> signInWithApple() async {
    if (!await AppleIsAvailableService.isAvailable()) {
      return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage:
              'На вашем устройстве не доступен данный способ авторизации');
    } else {
      try {
        if (await _servicesAuth.authWithApple()) {
          final userId = _servicesAuth.appleUser.email! + ' apple';

            final createUserResult = await createUser(
                email: _servicesAuth.appleUser.email, service: 'apple');
            createUserResult as FirebaseUserResult;
            if (createUserResult.userResultStatus ==
                FirebaseUserResultStatus.WasCreated) {
              return FirebaseSignInResult(
                  userId: userId,
                  login: _servicesAuth.appleUser.displayName,
                  email: _servicesAuth.appleUser.email,
                  firebaseResultStatus: FirebaseResultStatus.Success);
            } else {
              return FirebaseSignInResult(
                firebaseResultStatus: FirebaseResultStatus.Error,
                exceptionMessage: createUserResult.exceptionMessage!,
              );
            }

        }
        return FirebaseSignInResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage:
              'Произошла непредвиденная ошибка, проверьте подклюбчение к интернету',
        );
      } catch (_) {
        return FirebaseSignInResult(
            firebaseResultStatus: FirebaseResultStatus.Error,
            exceptionMessage:
                'Произошла непредвиденная ошибка, проверьте подключение к интернету или повторите попытку попытку позднее');
      }
    }
  }

  @override
  Future<FirebaseResult> getAndSetRemoteUserLocally(
    String userId, {
    String? login,
    String? email,
  }) async {

    final userData =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    late final UserModel user;
    if (userData.data() != null) {
      user = UserModel.userFromFirebase(userData.data() ?? {});
    } else {
      user = UserModel(
        registrationDate: DateTime.now(),
        login: login!,
        email: email!,
        male: true,
        old: 18,
        currentTariff: TariffModel.BASE_TARIFF,

      );
      final firestoreRepo = FireStoreRepositoryImpl();
      await firestoreRepo.updateUser(
        userId: userId,
          user: user,
          create: true);
    }
    await CurrentUser.repo.setLocalUserData(
        login: user.login,
        email: user.email,
        registrationDate: user.registrationDate,
        currentTariff: user.currentTariff,
        male: user.male,
        old: user.old);
    return FirebaseDataResult(
        firebaseResultStatus: FirebaseResultStatus.Success);
    try {} catch (_) {
      return FirebaseDataResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: 'Ошибка сохранения данных, попробуйте ещё раз.');
    }
  }
}
