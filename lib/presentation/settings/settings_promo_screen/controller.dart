import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/db/firebase_firestore/data/repository.dart';
import '../../../core/models/tariff_model.dart';
import '../../../core/user_data/user.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_message_box.dart';
import 'models/promo_model.dart';

class K16Controller {
  final _collection = FirebaseFirestore.instance.collection('Promo');

  final _fireStoreRepo = FireStoreRepositoryImpl();

  Future submitPromo(String promo, BuildContext context) async {
    //try {

    final data = await _fireStoreRepo.getPromoModel(promo: promo);
    print('promo: ' + data.toString());
    if (data.isNotEmpty) {
      final promoModel = PromoModel.fromType(data);
      final tariff = TariffModel(
          name: TariffModel.STANDARD_TARIFF.name,
          endDate: TariffModel.STANDARD_TARIFF.endDate,
          description: TariffModel.STANDARD_TARIFF.description,
          cost: TariffModel.STANDARD_TARIFF.cost,
          advantages: TariffModel.STANDARD_TARIFF.advantages);
      if (await _fireStoreRepo.canActivatePromo(promo: promoModel)) {
        if (promoModel.discount == 100) {
          tariff.cost = 0;
          if (await _fireStoreRepo.activatePromo(promo: promo)) {
            _fireStoreRepo.updateUser(userId: CurrentUser.repo.userId(), currentTariff: tariff);
            Navigator.pushNamed(context, AppRoutes.tariffActivated);
            await CurrentUser.repo.setLocalUserData(currentTariff: tariff);
          }
        } else {
          final costWithDiscount = ((tariff.cost / 100) * promoModel.discount);
          tariff.cost -= costWithDiscount;
          Navigator.pushNamed(context, AppRoutes.buySubscription,
              arguments: {'tariff': tariff.toJson(), 'promo': promo});
        }

      } else {
        _showMessage(context, 'Данный промокод уже был активирован');
      }
    } else
      _showMessage(context, 'Данный промокод неактивен');

    /*} catch (_) {
      print(_);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Ошибка, проверьте подключение к интернету или попробуйте позднее')));
    }*/
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomMessageBox(
        title: 'Промокод',
        content: message,
      ),
    );
  }
}
