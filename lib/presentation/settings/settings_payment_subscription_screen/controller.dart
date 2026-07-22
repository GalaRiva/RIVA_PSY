import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/services/payments/yookassa_payments.dart';

import '../../../core/models/tariff_model.dart';
import '../../../core/user_data/user.dart';
import '../../../routes/app_routes.dart';
import '../settings_tariff_activated_screen/repository.dart';

class PaymentSubscriptionController extends GetxController {
  final BuildContext context;

  PaymentSubscriptionController(this.context) {
    _yookassa = YookassaPayments();
  }

  late final YookassaPayments _yookassa;

  Future pay(TariffModel tariff) async {
    /*_yookassa.pay(
        amountInRub: 1,
        onComplete: () async {
          await _updateTariff(tariff);
      Navigator.pushNamed(
          context, AppRoutes.tariffActivated, arguments: tariff);
    }, testMode: true
    );*/
  }

  Future _updateTariff(TariffModel tariff) async {
    final _repo = K17Repo();
    await _repo.updateTariff(tariff);
    CurrentUser.user.currentTariff = tariff;
    CurrentUser.repo.setLocalUserData(currentTariff: tariff);
  }

}