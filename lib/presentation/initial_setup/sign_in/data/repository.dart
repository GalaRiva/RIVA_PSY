import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';
import 'package:riva_psy/core/models/tariff_model.dart';
import 'package:riva_psy/core/models/user_data_model.dart';
import 'package:riva_psy/core/services/firebase/firebase_auth_exception_handler.dart';
import 'package:riva_psy/core/utils/string_extension.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/models/firebase_sign_in_result.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/repository.dart';
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

  // Confirmed on a real device: a single forced getIdToken(true) refresh
  // before the first Firestore Users read isn't reliably enough — retested
  // on an otherwise byte-identical build and the login race intermittently
  // still hit permission-denied, then succeeded on retry. So retry the read
  // itself a couple of times with a short delay and a fresh token each
  // time, instead of gambling on the claims landing before the first try.
  Future<DocumentSnapshot<Map<String, dynamic>>> _getUsersDocWithRetry(
      String userId) async {
    final _collection = FirebaseFirestore.instance.collection('Users');
    const maxAttempts = 3;
    const retryDelay = Duration(milliseconds: 400);
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      try {
        return await _collection.doc(userId).get();
      } on FirebaseException catch (e) {
        final isPermissionDenied = e.code == 'permission-denied';
        if (!isPermissionDenied || attempt == maxAttempts) rethrow;
        print(
            '[AUTH-DIAG] Users read denied (attempt $attempt/$maxAttempts), retrying in ${retryDelay.inMilliseconds}ms: $e');
        await Future.delayed(retryDelay);
      }
    }
    throw StateError(
        'unreachable: _getUsersDocWithRetry exhausted without returning or throwing');
  }

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
      final _doc = await _getUsersDocWithRetry(userId);
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
    } on FirebaseException catch (e) {
      // Firestore (cloud_firestore) throws plain FirebaseException, not
      // FirebaseAuthException — must be caught separately or it escapes
      // uncaught up to the calling controller (see authWithGoogle findings).
      print(e);
      final _message =
          AuthExceptionHandler.generateErrorMessage(AuthStatus.unknown);
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

      // Unlike the Users collection read (_getUsersDocWithRetry), this
      // write had zero protection against the same token-claims race —
      // createUser() runs right after sign-in/sign-up, same as
      // checkUserState, and login failures were traced to exactly this
      // race. Retry on permission-denied here too instead of assuming a
      // write is somehow less exposed to it than a read.
      const maxAttempts = 3;
      const retryDelay = Duration(milliseconds: 400);
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        await FirebaseAuth.instance.currentUser?.getIdToken(true);
        try {
          final _doc = _collection.doc(userId());
          await _doc.set(UserDataModel(
                  passwordHash: password != null ? password.md5() : null,
                  email: email,
                  number: number,
                  service: service)
              .toJson());
          break;
        } on FirebaseException catch (e) {
          final isPermissionDenied = e.code == 'permission-denied';
          if (!isPermissionDenied || attempt == maxAttempts) rethrow;
          print(
              '[AUTH-DIAG] UsersData write denied (attempt $attempt/$maxAttempts), retrying in ${retryDelay.inMilliseconds}ms: $e');
          await Future.delayed(retryDelay);
        }
      }
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
    } on FirebaseException catch (e) {
      // Firestore (cloud_firestore) throws plain FirebaseException, not
      // FirebaseAuthException — must be caught separately or it escapes
      // uncaught up to the calling controller (see authWithGoogle findings).
      print(e);
      final _message =
          AuthExceptionHandler.generateErrorMessage(AuthStatus.unknown);
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
    } on FirebaseException catch (e) {
      // Firestore (cloud_firestore) throws plain FirebaseException, not
      // FirebaseAuthException — must be caught separately or it escapes
      // uncaught up to the calling controller (see authWithGoogle findings).
      print(e);
      final _message =
          AuthExceptionHandler.generateErrorMessage(AuthStatus.unknown);
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
              'Произошла непредвиденная ошибка, проверьте подключение к интернету',
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
              'Произошла непредвиденная ошибка, проверьте подключение к интернету',
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
    // Diagnostic logging around the tariff-sync path — see
    // PROJECT_CONTEXT.md for the "Firestore says Орион, app shows
    // Базовый" investigation. Kept deliberately verbose so a single
    // logcat capture is enough to tell which branch actually ran,
    // instead of needing another round of "add more logs".
    print('[TARIFF-DIAG] getAndSetRemoteUserLocally: userId="$userId" login="$login" email="$email"');
    try {
      if(userId.isEmpty) {
        print('[TARIFF-DIAG] userId is empty, aborting');
        return FirebaseDataResult(
            firebaseResultStatus: FirebaseResultStatus.Error,
            exceptionMessage: 'Ошибка сохранения данных, попробуйте ещё раз.');

      }
    // Same retry-on-permission-denied race as checkUserState above — this
    // is the other spot that can be the *first* Firestore Users read after
    // sign-in (email/password path calls this directly, skipping
    // checkUserState).
    final userData = await _getUsersDocWithRetry(userId);
    late final UserModel user;
    if (userData.exists) {
      print('[TARIFF-DIAG] doc "$userId" exists, raw fields: ${userData.data()}');
      user = UserModel.userFromFirebase(userData.data() ?? {});
      print('[TARIFF-DIAG] parsed tariff: name="${user.currentTariff?.name}" endDate="${user.currentTariff?.endDate}"');
    } else {
      print('[TARIFF-DIAG] doc "$userId" does NOT exist — creating fresh BASE_TARIFF user under this id');
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
    print('[TARIFF-DIAG] setLocalUserData done, tariff written locally: "${user.currentTariff?.name}"');
    return FirebaseDataResult(
        firebaseResultStatus: FirebaseResultStatus.Success);
    } catch (e, st) {
      print('[TARIFF-DIAG] EXCEPTION in getAndSetRemoteUserLocally("$userId"): $e\n$st');
      return FirebaseDataResult(
          firebaseResultStatus: FirebaseResultStatus.Error,
          exceptionMessage: 'Ошибка сохранения данных, попробуйте ещё раз.');
    }
  }
}
