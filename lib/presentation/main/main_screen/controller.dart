import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vibration/vibration.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/presentation/initial_setup/set_reminders_screen/k3_screen.dart';
import 'package:riva_psy/presentation/main/main_screen/widgets/try_irrational_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/shared_prefs.dart';
import '../../initial_setup/recomendation_buy_tariff_screen/k4_screen.dart';
import '../../initial_setup/recomendation_buy_tariff_screen/recomendation_buy_tariff_screen.dart';
import '../../initial_setup/send_pushes_screen/send_pushe_screen.dart';

class K20Controller extends GetxController {

  Rx<bool> canView = false.obs;

  double sliderValue = 5;
  String? selectedEmotionKey;
  int saveBurstTrigger = 0;

  static const int positiveThreshold = 6;

  void setSliderValue(double value) {
    final crossedIntoPositive = sliderValue < positiveThreshold && value >= positiveThreshold;
    final crossedOutOfPositive = sliderValue >= positiveThreshold && value < positiveThreshold;
    final tickChanged = value.round() != sliderValue.round();
    sliderValue = value;
    if (value < positiveThreshold) selectedEmotionKey = null;
    if (crossedIntoPositive || crossedOutOfPositive) {
      // Raw Vibrator.vibrate() call (via the vibration package) instead of
      // HapticFeedback — the latter routes through
      // View.performHapticFeedback(), which silently no-ops if the device's
      // "Touch feedback"/"Vibrate on tap" system toggle is off, independent
      // of the app's own VIBRATE permission. This bypasses that toggle.
      Vibration.vibrate(duration: 70);
    } else if (tickChanged) {
      Vibration.vibrate(duration: 25);
    }
    update();
  }

  void selectEmotion(String key) {
    selectedEmotionKey = selectedEmotionKey == key ? null : key;
    update();
  }

  void triggerSaveBurst() {
    saveBurstTrigger++;
    update();
  }

  Future openMessages (BuildContext context) async {
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
    }

    // "Напоминания о приёме лекарств" popup (PillRemindersScreen) removed
    // from this onboarding chain by request — was shown once per user via
    // the 'pill_reminders' SharedPreferences flag, unconditionally, with
    // no way to disable it short of tapping through it. The reminders
    // *feature* itself (Настройки → Напоминания) is untouched, this only
    // removes the unprompted popup.

    // "Хотите изменить частоту и время напоминаний?" one-month-anniversary
    // popup removed by request — same reasoning as the pill-reminders popup
    // above (unprompted, no real value). The reminders feature itself is
    // untouched.

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