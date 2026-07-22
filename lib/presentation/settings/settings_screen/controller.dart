import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/presentation/settings/settings_pills/repository.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills_add_bottom_sheet/settings_pills_add_bottom_sheet.dart';

class K6Controller extends GetxController {
  bool password = CurrentUser.user.passwordEnable;

  void onTapDataAndRecovery(context) {
    Navigator.pushNamed(context, AppRoutes.data_and_recovery);
  }

  Future onTapPill(context, GlobalKey<ScaffoldMessengerState> key) async {
    final pillRepo = PillsRepo();
    if ((await pillRepo.getEvent()).isNotEmpty)
      Navigator.pushNamed(context, AppRoutes.pills);
    else
      showModalBottomSheet(
          context: context, builder: (context) => PillsAddBottomSheet(),
      backgroundColor: ColorConstant.gray300.withOpacity(1),
      elevation: 0
    );
  }

  void changePasswordState(BuildContext context) {
    password = !password;
    print(password);
    CurrentUser.user.passwordEnable = password;
    CurrentUser.repo.setLocalUserData(passwordEnable: password);
    if (password) {
      Navigator.pushNamed(context, AppRoutes.setPassword).then((value) => update());
    }
    update();
  }
}
