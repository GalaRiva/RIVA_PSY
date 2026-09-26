import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';
import 'package:riva_psy/core/models/tariff_model.dart';
import 'package:riva_psy/core/user_data/user_repo.dart';

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

  static bool usedOreonTrials = false;
  static final repo = UserRepo();

  static Future init() async {
    // Used to ask for storage + camera permission here on every iOS
    // launch. Camera isn't used anywhere in the app (only the photo
    // gallery picker is) and "storage" isn't a permission on iOS at all,
    // so this was an unexplained permission prompt at startup — the kind
    // of thing App Review flags (5.1.1: permission requests must relate
    // to a feature the user is actually using). Gallery access is now
    // requested by image_picker itself, at the moment it's needed.
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
    if((user.email ?? '').isNotEmpty)
    usedOreonTrials = !(await FireStoreRepositoryImpl().canUseTrial(trialName: 'Oreon'));
    if (!repo.checkActualTariff(user.currentTariff!)) {
      user.currentTariff = TariffModel.BASE_TARIFF;
      await repo.setLocalUserData(currentTariff: user.currentTariff);
    }
  }

  // Sign-out drops back to the anonymous state, but `user` is a static
  // field that otherwise just keeps whatever was last loaded by init() —
  // including currentTariff. Without this, a signed-out session could keep
  // showing Orion-tier UI (no paywall) using a cached value from before
  // logout, since init() itself only runs when a Firebase Auth session
  // exists and is skipped entirely for an anonymous user.
  static void reset() {
    user = UserModel(
        login: '',
        email: '',
        password: '',
        reminderTime: 1,
        currentTariff: TariffModel.BASE_TARIFF,
        old: 33,
        male: true,
        registrationDate: DateTime.now());
    usedOreonTrials = false;
  }

  static bool tariffIsOrion() {
    if (user.currentTariff!.name == TariffModel.ORION_TARIFF_YEAR.name)
      return true;
    return false;
  }
}
