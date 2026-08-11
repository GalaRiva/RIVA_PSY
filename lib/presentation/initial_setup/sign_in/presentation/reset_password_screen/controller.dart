import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/show_custom_message.dart';
import 'package:riva_psy/core/utils/string_extension.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/data/repository.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/models/firebase_result.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/confirm_reset_email_password.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/send_reset_code_to_email.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/domain/usecases/verefy_reset_code.dart';
import 'package:riva_psy/widgets/custom_message_box.dart';
import '../widgets/sms_code_message.dart';


class ResetPasswordController extends GetxController {
  final BuildContext context;
  ResetPasswordController(this.context);

  final numberController = TextEditingController();
  final email = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool _useEmail = true;

  bool get useEmail => _useEmail;

  void changeResetPasswordMethod() {
    _useEmail = !useEmail;
    update();
  }

  final _repo = SignInDataRepository();

  Future onConfirm (GlobalKey <FormState> key) async {
    if(key.currentState!.validate()) {
       _resetPassword(email.text);
    }
  }
  Future _resetPassword(String email) async {
    try {
      bool _error = false;
      final FirebaseResult result = await SendResetCodeToEmail().sendResetCodeToEmail(email);
      if(result.firebaseResultStatus == FirebaseResultStatus.Success) {
        Navigator.pop(context);
        showMessage(context, title: 'Восстановление пароля', content: 'Вам был выслано письмо на указанную почту');


      } else {
        showMessage(context, title: 'Восстановление пароля', content: result.exceptionMessage!);
      }
    } catch (_) {
      print(_);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error, please check your internet connection or try again later')));
    }
  }

  void showRecoverySms (bool error) {
    showDialog(context: context, builder: (context) => smsCodeMessage<ResetPasswordController>(context, onConfirm: (String code)async{
      final verifyResult = await VerifyResetCode().verifyResetCode(code);
      if(verifyResult.firebaseResultStatus == FirebaseResultStatus.Success) {
        error = false;
        Navigator.pop(context);

          showMessage(context, title: 'Восстановление пароля', content: 'Вам был выслано письмо на указанную почту');


      } else {
        showMessage(context, title: 'Восстановление пароля', content: verifyResult.exceptionMessage!);

      }
    }, error: error));
  }
}