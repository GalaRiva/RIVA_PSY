import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:listenmebaby71_s_application17/core/models/tariff_model.dart';
import 'package:listenmebaby71_s_application17/core/models/user_model.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/data/repository.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/repository.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/usecases/create_user.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/domain/usecases/sign_up_with_email.dart';

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
            FireStoreRepositoryImpl().updateUser(userId: email, user: CurrentUser.user, create: true);

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
        } catch (_) {
      print(_);
      showMessage(context,
          title: 'Регистрация',
          content:
              'Произошла непредвиденная ошибка, проверьте подключение к интернету или попоробуйте позднее');
    }
  }

  Future authWithApple(context) async {
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
          await CurrentUser.repo.setLocalUserData(email: result.email);

          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.splashScreen, (route) => false);
        }
      } else {
        final createUserInDB = await CreateUser().createUser(email: result.email, service: 'apple');

        FireStoreRepositoryImpl().updateUser(userId: result.userId!, user: CurrentUser.user, create: true);

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
  }

  Future authWithGoogle(context) async {
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

        FireStoreRepositoryImpl().updateUser(userId: result.userId!, user: CurrentUser.user, create: true);

        if(createUserInDB.firebaseResultStatus == FirebaseResultStatus.Success) {
          final dataSetResult = await GetAndSetRemoteDataLocally()
              .getAndSetRemoteDataLocally(
              result.userId!, email: result.email, login: result.login);
          if (dataSetResult.firebaseResultStatus == FirebaseResultStatus.Success) {

            await CurrentUser.repo.setService('google');
            await CurrentUser.repo.setLocalUserData(email: result.email);

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
  }
}
