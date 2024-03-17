import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {

  static late final SharedPreferences _sharedPreferences;
  static set  setSharedPreferences (SharedPreferences value) => _sharedPreferences = value;
  static SharedPreferences get  sharedPreferences => _sharedPreferences;
}