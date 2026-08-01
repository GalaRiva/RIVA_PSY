import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/settings/settings_tariff_activated_screen/repository.dart';
import '../models/tariff_model.dart';

class UserRepo {
  UserRepo() {
    getService();
  }

  SharedPreferences? prefs;
  final _collection = FirebaseFirestore.instance.collection('Users');
  final _collectionUsersData =
      FirebaseFirestore.instance.collection('UsersData');

  final _fireStoreRepo = FireStoreRepositoryImpl();

  String userId()
      {
        final email = (CurrentUser.user.email ?? '').trim();
        // Confirmed live via the on-screen diagnostic: when the cached
        // email is empty, this used to still return authService alone
        // (e.g. "google") instead of failing — that's a valid-looking but
        // wrong Firestore doc id, so getAndSetRemoteUserLocally either
        // silently throws (null-asserting a login/email that was never
        // passed for this call site) or creates a stray doc under the
        // wrong id, either way never syncing the real one. Failing empty
        // here means the caller's `if (userId().isNotEmpty)` guard skips
        // the sync entirely instead of running it against a bogus id.
        final result = email.isEmpty ? '' : '$email $authService'.trim();
        print('[TARIFF-DIAG] userId(): email="${CurrentUser.user.email}" authService="$authService" -> "$result"');
        return result;
      }
  var authService = '';

  Future setLocalUserData ({
    String? login,
    String? email,
    String? password,
    int? reminderTime,
    int? old,
    bool? male,
    bool? passwordEnable,
    TariffModel? currentTariff,
    DateTime? registrationDate,
    List<String>? reminderTimeInStr
}) async {
    try {
      await _setTariff(currentTariff ?? await getTariff());
      await _setGender(male ?? await getGender());
      // await _setNumber(number ?? await getNumber());
      await _setOld(old ?? await getOld());
      await _setLogin(login ?? await getLogin());
      await _setPass(password ?? await getPass());
      await _setPasswordEnable(passwordEnable ?? await getPasswordEnable());
      await _setEmail(email ?? await getEmail());
      await _setReminderTime(reminderTime ?? await getReminderTime());
      await _setReminderTimeInStr(
          reminderTimeInStr ?? await getReminderTimeInStr());
      await _setRegistrationDate(
          registrationDate ?? await getRegistrationDate());
    } catch (_) {
      print(_);
    }
    }

  Future setService(String service) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    authService = service;
    await prefs!.setString('authService', service);
  }

  Future<String> getService() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return authService = prefs!.getString('authService') ?? '';
  }

  // set
  Future _setLogin(String text) async {
    print(userId());
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setString('login', text);
    CurrentUser.user.login = text;
  }

  Future _setPass(String text) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setString('pass', text);
    CurrentUser.user.password = text;
  }

  Future _setRegistrationDate(DateTime date) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setString('registrationDate', date.toIso8601String());
    CurrentUser.user.registrationDate = date;
  }

  Future _setNumber(String text) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setString('number', text);
      await _fireStoreRepo.updateUserDataNumber(number: text);
    //CurrentUser.user.number = text;
  }

  Future _setPasswordEnable(bool val) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setBool('passEnable', val);
    CurrentUser.user.passwordEnable = val;
  }

  Future _setReminderTime(int val) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setInt('reminderTime', val);
    CurrentUser.user.reminderTime = val;
  }

  Future _setOld(int val) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setInt('old', val);
    CurrentUser.user.old = val;
  }

  Future _setGender(bool val) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setBool('gender', val);
    CurrentUser.user.male = val;
  }

  Future _setEmail(String val) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setString('email', val);
    CurrentUser.user.email = val;
  }

  Future _setReminderTimeInStr(List<String> list) async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    await prefs!.setStringList('reminderTimeInStr', list);
    CurrentUser.user.reminderTimeInStr = list;
  }

  Future<void> _setTariff(TariffModel tariffModel) async {
    final _repo = K17Repo();
    await _repo.updateTariff(tariffModel);
  }

  // get local
  Future<String> getLogin() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getString('login') ?? '';
  }

  Future<String> getPass() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getString('pass') ?? '';
  }

  Future<String> getNumber() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getString('number') ?? '';
  }

  Future<String> getEmail() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getString('email') ?? '';
  }

  Future<bool> getPasswordEnable() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getBool('passEnable') ?? false;
  }

  Future<int> getReminderTime() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getInt('reminderTime') ?? 0;
  }

  Future<int> getOld() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getInt('old') ?? 33;
  }

  Future<bool> getGender() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getBool('gender') ?? true;
  }

  Future<List<String>> getReminderTimeInStr() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs!.getStringList('reminderTimeInStr') ?? [];
  }

  Future<TariffModel> getTariff() async {
    final _repo = K17Repo();
    return await _repo.getTariff();
  }

  Future<DateTime> getRegistrationDate() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return DateTime.parse(prefs!.getString('registrationDate') ??
        DateTime.now().toIso8601String());
  }

  // some checks
  bool checkActualTariff(TariffModel currentTariff) {
    if (currentTariff.name != TariffModel.BASE_TARIFF.name) {
      if (currentTariff.endDate.year < DateTime.now().year) {
        return false;
      } else if (currentTariff.endDate.month < DateTime.now().month &&
          currentTariff.endDate.year <= DateTime.now().year) {
        return false;
      } else if (currentTariff.endDate.day < DateTime.now().day &&
          currentTariff.endDate.month <= DateTime.now().month &&
          currentTariff.endDate.year <= DateTime.now().year) {
        return false;
      }
    }
    return true;
  }
}
