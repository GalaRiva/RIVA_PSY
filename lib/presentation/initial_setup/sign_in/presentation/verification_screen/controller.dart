import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/models/user_model.dart';
import '../../../../../core/user_data/user.dart';
import '../../../../../routes/app_routes.dart';

class VerificationController extends GetxController {
  final String verificationID;

  VerificationController(this.verificationID);

  var status = VerificationStatus.waiting;
  final smsController = TextEditingController();

  Future verify(BuildContext context) async {
    final credentials = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: smsController.text);

    try {
      await FirebaseAuth.instance.signInWithCredential(credentials);
      /*final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(CurrentUser.user.number)
          .get();
      final user = UserModel.userFromFirebase(userData.data()!);
      CurrentUser.user.number = user.number!;
      CurrentUser.user.currentTariff = user.currentTariff!;
      CurrentUser.user.registrationDate = user.registrationDate;
      await CurrentUser.repo.setLogin(user.login!);
      await CurrentUser.repo.setNumber(user.number!);
      await CurrentUser.repo.setRegistrationDate(user.registrationDate);
      await CurrentUser.repo.setTariff(user.currentTariff!);
      await CurrentUser.repo.setGender(user.male!);
      await CurrentUser.repo.setOld(user.old!);
      status = VerificationStatus.successful;*/
    } catch (_) {
      status = VerificationStatus.failed;
    }
    _getAnswer(context);
  }

  void _getAnswer(BuildContext context) {
    if (status == VerificationStatus.successful) {
      Timer(
          Duration(
            seconds: 1,
          ), () {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.setRemindersScreen, (route) => false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Проверьте правильность написания смс')));
    }
  }
}

enum VerificationStatus { waiting, successful, failed }
