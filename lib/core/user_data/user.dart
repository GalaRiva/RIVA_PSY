import 'package:listenmebaby71_s_application17/core/models/tariff_model.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user_repo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../models/user_model.dart';

class CurrentUser extends UserModel {
  static UserModel user = UserModel(
      login: '',
      email: '',
      password: '',
      reminderTime: 1,
      currentTariff: TariffModel.BASE_TARIFF,
      old: 33,
      male: true, registrationDate: DateTime.now());

  CurrentUser()
      : super(
            login: user.login,
            password: user.password,
            reminderTime: user.reminderTime,
            currentTariff: user.currentTariff,
            old: user.old,
            male: user.male,
  registrationDate: user.registrationDate);
  static final repo = UserRepo();

  static Future init() async {
    if(Platform.isIOS) {
      var status = await Permission.storage.status;
      if (status.isDenied) {
        // You can request multiple permissions at once.
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
          Permission.camera,
        ].request();
        print(statuses[Permission.storage]);
      }
    }
    repo.authService = await repo.getService();
    user.login = await repo.getLogin();
    user.password = await repo.getPass();
    user.passwordEnable = await repo.getPasswordEnable();
    user.reminderTime = await repo.getReminderTime();
    user.old = await repo.getOld();
    user.male = await repo.getGender();
    user.email = await repo.getEmail();
    user.currentTariff = await repo.getTariff();
    user.reminderTimeInStr = await repo.getReminderTimeInStr();
    user.registrationDate = await repo.getRegistrationDate();
    if (!repo.checkActualTariff(user.currentTariff!)) {
      user.currentTariff = TariffModel.BASE_TARIFF;
      await repo.setLocalUserData(currentTariff: user.currentTariff);
    }
  }

  static bool tariffIsStandard() {
    if (user.currentTariff!.name == TariffModel.ORION_TARIFF.name)
      return true;
    return false;
  }
}
