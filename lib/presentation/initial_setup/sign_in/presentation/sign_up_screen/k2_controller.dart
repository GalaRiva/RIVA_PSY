import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:riva_psy/core/models/tariff_model.dart';
import 'package:riva_psy/core/models/user_model.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/data/repository.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/repository.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/create_user.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/sign_up_with_email.dart';

import '../../../../../core/db/firebase_firestore/data/repository.dart';
import '../../../../../core/user_data/user.dart';
import '../../../../../core/utils/show_custom_message.dart';
import '../../../../../routes/app_routes.dart';
import '../../domain/models/firebase_result.dart';
import '../../domain/models/firebase_sign_in_result.dart';
import '../../domain/models/firebase_user_result.dart';
import '../../domain/usecases/check_user_state.dart';
import '../../domain/usecases/get_and_set_remote_data_locally.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_google.dart';

class K2Controller extends GetxController {
  final _instance = FirebaseFirestore.instance;

  bool _useEmail = true;

  bool get useEmail => _useEmail;

  void changeRegistrationMethod() {
    _useEmail = !useEmail;
    update();
  }

  Future createNewUser(context, login, String password,
      {String? number, String? email}) async {
    try {
        final signUpResult =
            await SignUpWithEmail().signUpWithEmail(email!, password);
        if (signUpResult.firebaseResultStatus == FirebaseResultStatus.Success) {
          signUpResult as FirebaseSignInResult;
          final getDataResult = await GetAndSetRemoteDataLocally()
              .getAndSetRemoteDataLocally(signUpResult.userId!, email: email, login: login);
          if (getDataResult.firebaseResultStatus ==
              FirebaseResultStatus.Success) {
            final createUserInDB = await CreateUser().createUser(email: email, password: password);
            // Was fire-and-forget (no `await`) — the Navigator call a few
            // lines down could fire before this write finished, cutting it
            // off. This write is redundant with the one inside
            // getAndSetRemoteDataLocally() above (same doc, same data) but
            // awaiting it is a safe, minimal fix either way.
            await FireStoreRepositoryImpl().updateUser(
                userId: email,
                user: UserModel(
                  registrationDate: DateTime.now(),
                  login: login,
                  email: email,
                  male: true,
                  old: 33,
                  currentTariff: TariffModel.BASE_TARIFF,
                ),
                create: true);

            if(createUserInDB.firebaseResultStatus == FirebaseResultStatus.Success) {
            await CurrentUser.repo.setService('');
            await CurrentUser.repo.setLocalUserData(email: email);

            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.splashScreen, (route) => false);
          } else {
              showMessage(context,
                  title: 'Регистрация', content: createUserInDB.exceptionMessage!);

            }
          } else {
            showMessage(context,
                title: 'Регистрация', content: getDataResult.exceptionMessage!);
          }
        } else {
          showMessage(context,
              title: 'Регистрация', content: signUpResult.exceptionMessage!);
        }
        } catch (e) {
      print(e);
      showMessage(context,
          title: 'Регистрация',
          content:
              'Произошла непредвиденная ошибка, проверьте подключение к интернету или попоробуйте позднее');
    }
  }

  Future authWithApple(context) async {
    try {
    final result = await SignInWithApple().call();
    if (result.firebaseResultStatus == FirebaseResultStatus.Success) {
      result as FirebaseSignInResult;
      final checkUserState = await CheckUserState().checkUserState(result.userId!,) as FirebaseUserResult;
      if(checkUserState.userResultStatus == FirebaseUserResultStatus.TrueData) {
        final dataSetResult = await GetAndSetRemoteDataLocally()
            .getAndSetRemoteDataLocally(
            result.userId!, email: result.email, login: result.login);
        if (dataSetResult.firebaseResultStatus == FirebaseResultStatus.Error) {
          showMessage(context, title: 'Регистрация', content: dataSetResult.exceptionMessage!);
        } else {
          await CurrentUser.repo.setService('apple');
          await CurrentUser.repo.setLocalUserData(email: result.email, login: result.login);

          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.splashScreen, (route) => false);
        }
      } else {
        final createUserInDB = await CreateUser().createUser(email: result.email, service: 'apple');

        FireStoreRepositoryImpl().updateUser(
            userId: result.userId!,
            user: UserModel(
              registrationDate: DateTime.now(),
              login: result.login,
              email: result.email,
              male: true,
              old: 33,
              currentTariff: TariffModel.BASE_TARIFF,
            ),
            create: true);

        if(createUserInDB.firebaseResultStatus == FirebaseResultStatus.Success) {
          final dataSetResult = await GetAndSetRemoteDataLocally()
              .getAndSetRemoteDataLocally(
              result.userId!, email: result.email, login: result.login);
          if (dataSetResult.firebaseResultStatus == FirebaseResultStatus.Success) {
            await CurrentUser.repo.setService('apple');
            await CurrentUser.repo.setLocalUserData(email: result.email, login: result.login);

            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.splashScreen, (route) => false);
          } else {
            showMessage(context, title: 'Регистрация', content: dataSetResult.exceptionMessage!);
          }
        } else {
          showMessage(context,
              title: 'Регистрация', content: createUserInDB.exceptionMessage!);

        }

      }

    } else {
      showMessage(context, title: 'Регистрация', content: result.exceptionMessage!);
    }
    } catch (e) {
      // Same safety net as authWithGoogle in sign_in_screen/k2_controller.dart:
      // an uncaught FirebaseException from Firestore calls in the chain above
      // used to leave the user stuck on this screen with no feedback after a
      // "successful" Apple auth.
      print(e);
      showMessage(context,
          title: 'Регистрация', content: 'network_error_try_later'.tr());
    }
  }

  Future authWithGoogle(context) async {
    try {
    final result = await SignInWithGoogle().call();
    if (result.firebaseResultStatus == FirebaseResultStatus.Success) {
      result as FirebaseSignInResult;
      final checkUserState = await CheckUserState().checkUserState(result.userId!,) as FirebaseUserResult;
      if(checkUserState.userResultStatus == FirebaseUserResultStatus.TrueData) {
        final dataSetResult = await GetAndSetRemoteDataLocally()
            .getAndSetRemoteDataLocally(
            result.userId!, email: result.email, login: result.login);
        print(dataSetResult.firebaseResultStatus.toString());

        if (dataSetResult.firebaseResultStatus == FirebaseResultStatus.Error) {
          showMessage(context, title: 'Регистрация', content: dataSetResult.exceptionMessage!);
        }
        else {
          await CurrentUser.repo.setService('google');
          await CurrentUser.repo.setLocalUserData(email: result.email);

          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.splashScreen, (route) => false);
        }
      } else {
        final createUserInDB = await CreateUser().createUser(email: result.email, service: 'google');

        FireStoreRepositoryImpl().updateUser(
            userId: result.userId!,
            user: UserModel(
              registrationDate: DateTime.now(),
              login: result.login,
              email: result.email,
              male: true,
              old: 33,
              currentTariff: TariffModel.BASE_TARIFF,
            ),
            create: true);

        if(createUserInDB.firebaseResultStatus == FirebaseResultStatus.Success) {
          final dataSetResult = await GetAndSetRemoteDataLocally()
              .getAndSetRemoteDataLocally(
              result.userId!, email: result.email, login: result.login);
          if (dataSetResult.firebaseResultStatus == FirebaseResultStatus.Success) {

            await CurrentUser.repo.setService('google');
            await CurrentUser.repo.setLocalUserData(email: result.email, login: result.login);

            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.splashScreen, (route) => false);
          } else {
            showMessage(context, title: 'Регистрация', content: dataSetResult.exceptionMessage!);
          }
        } else {
          showMessage(context,
              title: 'Регистрация', content: createUserInDB.exceptionMessage!);

        }

      }

    } else {
      showMessage(context, title: 'Регистрация', content: result.exceptionMessage!);
    }
    } catch (e) {
      // Same safety net as above — this file's authWithGoogle had never
      // been wrapped either (only sign_in_screen's was, previously).
      print(e);
      showMessage(context,
          title: 'Регистрация', content: 'network_error_try_later'.tr());
    }
  }
}
