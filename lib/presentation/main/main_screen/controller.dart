import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/presentation/initial_setup/set_reminders_screen/k3_screen.dart';
import 'package:riva_psy/presentation/main/main_screen/widgets/try_irrational_dialog.dart';
import 'package:riva_psy/presentation/settings/settings_data_and_recovery/settings_data_and_recovery_screen/controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/shared_prefs.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_message_box.dart';
import '../../initial_setup/pill_reminders/pill_reminders_screen.dart';
import '../../initial_setup/recomendation_buy_tariff_screen/k4_screen.dart';
import '../../initial_setup/recomendation_buy_tariff_screen/recomendation_buy_tariff_screen.dart';
import '../../initial_setup/send_pushes_screen/send_pushe_screen.dart';

class K20Controller extends GetxController {

  Rx<bool> canView = false.obs;

  Future openMessages (BuildContext context) async {
    try {
      final dataAndRecoveryController = Get.put(DataAndRecoveryController());
      dataAndRecoveryController.init();
      if(dataAndRecoveryController.serviceEnable && DateTime.now().difference(dataAndRecoveryController.serviceCopyData ?? DateTime.now()).inDays > 6 || dataAndRecoveryController.serviceCopyData == null) {
        await dataAndRecoveryController.setCopyData(DataAndRecoveryController.serviceCopyDataKey, dataAndRecoveryController.serviceCopyData, DateTime.now());
      }
    } catch (_) {
      
    }


    const FIRST_MONTH_KEY = 'MONTH_PASSED';
    SharedPreferences prefs = SharedPrefs.sharedPreferences;
    if (SharedPrefs.sharedPreferences.getBool('set_reminders') == null)
      showDialog(
          useSafeArea: false,

          context: context, builder: (_) => K3Screen());
   else if (SharedPrefs.sharedPreferences.getBool('send_pushes') == null)
      showDialog(        useSafeArea: false,

          context: context, builder: (_) => SendPushesScreen());
    else if(!CurrentUser.tariffIsOrion() && SharedPrefs.sharedPreferences.getBool('recommendation_buy_tariff' ) == null) {
      showDialog(
        useSafeArea: false,
          context: context, builder: (_) => RecommendationBuyTariffScreen());
    } else if(SharedPrefs.sharedPreferences.getBool('pill_reminders' ) == null) {
      showDialog(        useSafeArea: false,

          context: context, builder: (_) => PillRemindersScreen());
    }


    else if((CurrentUser.user.registrationDate.month != DateTime.now().month || CurrentUser.user.registrationDate.year != DateTime.now().year) && ((prefs.getBool(FIRST_MONTH_KEY) ?? true) == true)){
      showDialog(
            context: context, builder: (BuildContext context) => CustomMessageBox(
          title: 'RIVA PSY',
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: getMargin(top: 30,right: 84, left: 84),
                    child: Text('Хотите изменить частоту и время напоминаний?', style: AppStyle.txtSFProDisplayLight14, textAlign: TextAlign.center,)),
                SizedBox(height: getVerticalSize(26),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                        height: getVerticalSize(32),
                        width: getHorizontalSize(136),
                        text: "Нет".toUpperCase(),
                        padding: ButtonPadding.PaddingT8,
                        onTap: () => Navigator.pop(context),
                        alignment: Alignment.center),
                    SizedBox(width: getHorizontalSize(13),),
                    CustomButton(
                        height: getVerticalSize(32),
                        width: getHorizontalSize(136),
                        text: "Да".toUpperCase(),
                        padding: ButtonPadding.PaddingT8,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
                        alignment: Alignment.center),
                  ],
                )
              ],
            ),
          ),
        )
        );
        await prefs.setBool(FIRST_MONTH_KEY, false);

    }
    else if (false ?? Random().nextInt(100) > 50 && !CurrentUser.usedOreonTrials && !CurrentUser.tariffIsOrion()) {
      showDialog(context: context, builder: (_) => K4Screen());
    }


    else if(!(prefs.getBool('workingOutMessageSend') ?? false)) {
      showDialog(
          context: context, builder: (BuildContext context) => Center(child: TryIrrationalDialog())
      ).then((value) =>  prefs.setBool('workingOutMessageSend', true));
    }

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}