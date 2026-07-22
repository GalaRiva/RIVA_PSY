import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';

import '../../../core/models/tariff_model.dart';
import '../../../core/services/payments/yookassa_payments.dart';
import '../../../core/user_data/user.dart';
import '../../../routes/app_routes.dart';
import '../settings_tariff_activated_screen/repository.dart';

class BuySubscriptionController extends GetxController {
  final String? promo;
  BuySubscriptionController(this.promo) {
    _yookassa = YookassaPayments();
  }

  late final YookassaPayments _yookassa;

  Future onTapGoToTariff(TariffModel tariff, BuildContext context) async {
      _pay(tariff, context, );
  }

  Future _pay(TariffModel tariff, BuildContext context) async {
    try {
      _yookassa.pay(
        context,
          amountInRub: tariff.cost,

          onComplete: () async {
          if(promo != null) {
            await FireStoreRepositoryImpl().activatePromo(promo: promo!);
          }
            await _updateTariff(tariff);
            Navigator.pushNamed(context, AppRoutes.tariffActivated,
                arguments: tariff);
          },
          testMode: false);
    } catch (_) {
      print(_.toString());
    }
  }

  Future _updateTariff(TariffModel tariff) async {
    if(tariff.trial) {
      await FireStoreRepositoryImpl().useTrial(trialName: tariff.nameInEn);

    }

    await CurrentUser.repo.setLocalUserData(currentTariff: tariff);
    FireStoreRepositoryImpl().updateUser(userId: CurrentUser.repo.userId(), currentTariff: tariff);
    update();
  }
}
