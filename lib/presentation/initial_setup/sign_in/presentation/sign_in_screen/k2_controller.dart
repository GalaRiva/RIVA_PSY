import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/core/utils/show_custom_message.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/models/firebase_result.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/models/firebase_sign_in_result.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/models/firebase_user_result.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/check_user_state.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/get_and_set_remote_data_locally.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/sign_in_with_email.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/sign_in_with_google.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/presentation/widgets/sms_code_message.dart';

import '../../../../../core/db/firebase_firestore/data/repository.dart';
import '../../../../../core/models/tariff_model.dart';
import '../../../../../core/models/user_model.dart';
import '../../../../../routes/app_routes.dart';
import '../../data/repository.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/sign_in_with_apple.dart';

class K2AuthController extends GetxController {
  bool _useEmail = true;

  bool get useEmail => _useEmail;

  void changeAuthMethod() {
    _useEmail = !useEmail;
    update();
  }

  bool obscurePassword = true;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    update();
  }

  Future auth(context, password, {String? email, String? number}) async {
    try {
      /*final FirebaseResult userStateCheck =
          await CheckUserState().checkUserState(email!, password);
      userStateCheck as FirebaseUserResult;
      if (userStateCheck.userResultStatus ==
          FirebaseUserResultStatus.TrueData) {*/
        final signInResult =
            await SignInWithEmail().signInWithEmail(email!, password);
        if (signInResult.firebaseResultStatus == FirebaseResultStatus.Success) {
          signInResult as FirebaseSignInResult;
          // Was un-awaited: the tariff synced here could still be mid-write
          // when the setLocalUserData below re-reads local tariff storage,
          // losing the race and reverting to BASE_TARIFF (see updateTariff).
          await GetAndSetRemoteDataLocally().getAndSetRemoteDataLocally(signInResult.userId!);
          await CurrentUser.repo.setService('');
          await CurrentUser.repo.setLocalUserData(email: email);

          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.splashScreen, (route) => false);
        } else {
          showMessage(context,
              title: 'Авторизация',
              content: signInResult.exceptionMessage!);
        }

      /*if (userStateCheck.userResultStatus ==
          FirebaseUserResultStatus.WrongData) {
        showMessage(context,
            title: 'Авторизация', content: 'Неверный логин или пароль');
      }
      if (userStateCheck.userResultStatus ==
          FirebaseUserResultStatus.NotExist) {
        showMessage(context,
            title: 'Авторизация',
            content: 'Данного пользователя не существует');
      }
      if (userStateCheck.userResultStatus ==
          FirebaseUserResultStatus.Exception) {
        showMessage(context,
            title: 'Авторизация',
            content: userStateCheck.exceptionMessage!);
      }*/
    } catch (e) {
      print(e);
      showMessage(context,
          title: 'Авторизация',
          content:
              'An unexpected error occurred, please check your internet connection or try again later');
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
          showMessage(context, title: 'Registration', content: dataSetResult.exceptionMessage!);
        } else {
          await CurrentUser.repo.setService('apple');
          await CurrentUser.repo.setLocalUserData(email: result.email);

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
            await CurrentUser.repo.setLocalUserData(email: result.email);

            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.splashScreen, (route) => false);
          } else {
            showMessage(context, title: 'Registration', content: dataSetResult.exceptionMessage!);
          }
        } else {
          showMessage(context,
              title: 'Registration', content: createUserInDB.exceptionMessage!);

        }

      }

    } else {
      showMessage(context, title: 'Registration', content: result.exceptionMessage!);
    }
    } catch (e) {
      // Same safety net as authWithGoogle below: an uncaught FirebaseException
      // from Firestore calls in the chain above used to leave the user stuck
      // on this screen with no feedback after a "successful" Apple auth.
      print(e);
      showMessage(context,
          title: 'Registration', content: 'network_error_try_later'.tr());
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
          if (dataSetResult.firebaseResultStatus == FirebaseResultStatus.Error) {
            showMessage(context, title: 'Registration', content: dataSetResult.exceptionMessage!);
          }
          else {
            await CurrentUser.repo.setService('google');
            await CurrentUser.repo.setLocalUserData(email: result.email, login: result.login);

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
              showMessage(context, title: 'Registration', content: dataSetResult.exceptionMessage!);
            }
          } else {
            showMessage(context,
                title: 'Registration', content: createUserInDB.exceptionMessage!);

          }

        }

      } else {
        showMessage(context, title: 'Registration', content: result.exceptionMessage!);
      }
    } catch (e) {
      // Safety net: any uncaught exception from the chain above (e.g. a
      // Firestore FirebaseException not handled deeper in the stack) used to
      // leave the user stuck on this screen with no feedback — "successful
      // auth into nowhere". Always surface something instead of swallowing.
      print(e);
      showMessage(context,
          title: 'Registration', content: 'network_error_try_later'.tr());
    }
  }
}
