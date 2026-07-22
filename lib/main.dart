import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/db/hive_db.dart';
import 'package:listenmebaby71_s_application17/core/utils/shared_prefs.dart';
import 'package:listenmebaby71_s_application17/providers/language_provider.dart';
import 'package:listenmebaby71_s_application17/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/notifications/awesome_notification_service.dart';
import 'core/utils/color_constant.dart';

void main() async {

    WidgetsFlutterBinding.ensureInitialized();
    if(!Platform.isIOS)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await EasyLocalization.ensureInitialized();
    await Firebase.initializeApp();
    try {
      HttpOverrides.global = MyHttpOverrides();
      SharedPreferences.getInstance().then((value) => SharedPrefs.setSharedPreferences = value);
      await HiveDB.initDB();
      final notificationService = AwesomeNotificationService();
      notificationService.setListeners();
      //initializeDateFormatting('ru_RU');

      final event = await FirebaseAuth.instance
          .currentUser;
      if (event == null)
        AppRoutes.initialRoute = AppRoutes.signUp;
      else {
        AppRoutes.initialRoute = AppRoutes.splashScreen;
      }
    } catch (_) {

    }

      runApp(EasyLocalization(
          supportedLocales: [Locale('ru', 'RU'),/* Locale('es', 'ES'),*/],
          path: 'assets/translations', // <-- change the path of the translation files
          fallbackLocale: Locale('ru', 'RU'),
          child: MyApp()));

    //runApp( MyApp());
}

class MyApp extends StatelessWidget {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LanguageProvider>(create: (BuildContext context) {

      return LanguageProvider();
    },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primaryColor: MaterialColor(ColorConstant.cyan700.value, color),
          scrollbarTheme: ScrollbarThemeData(
            trackColor: MaterialStatePropertyAll<Color>(Colors.white),
            thumbColor: MaterialStatePropertyAll<Color>(ColorConstant.fromHex('#7F7F90')),
            trackBorderColor: MaterialStatePropertyAll<Color>(Colors.transparent),
          ),
          scaffoldBackgroundColor:  ColorConstant.gray200,
          visualDensity: VisualDensity.standard,
        ),
        title: 'Rigel PSY',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initialRoute ,
        routes: AppRoutes.routes,
      ),
    );
  }
}


Map<int, Color> color = {
  50: Color.fromRGBO(255, 92, 87, .1),
  100: Color.fromRGBO(255, 92, 87, .2),
  200: Color.fromRGBO(255, 92, 87, .3),
  300: Color.fromRGBO(255, 92, 87, .4),
  400: Color.fromRGBO(255, 92, 87, .5),
  500: Color.fromRGBO(255, 92, 87, .6),
  600: Color.fromRGBO(255, 92, 87, .7),
  700: Color.fromRGBO(255, 92, 87, .8),
  800: Color.fromRGBO(255, 92, 87, .9),
  900: Color.fromRGBO(255, 92, 87, 1),
};

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..maxConnectionsPerHost = 300
      ..connectionTimeout = const Duration(minutes: 6)
      ..idleTimeout = const Duration(minutes: 6);
  }
}