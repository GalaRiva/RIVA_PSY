import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listenmebaby71_s_application17/core/db/hive_db.dart';
import 'package:listenmebaby71_s_application17/core/services/workmanager/workmanager_service.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user.dart';
import 'package:listenmebaby71_s_application17/routes/app_routes.dart';

import 'core/services/notifications/awesome_notification_service.dart';
import 'core/utils/color_constant.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  //message.notification!.android.smallIcon =
  print('background message ${message.notification!.body}');
}

void main() async {

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    await HiveDB.initDB();
    WorkManagerService().initService();
    await CurrentUser.init();
    final notificationService = AwesomeNotificationService();
    notificationService.setListeners();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event == null)
        AppRoutes.initialRoute = AppRoutes.signUp;
      else {
        AppRoutes.initialRoute = AppRoutes.splashScreen;
      }

      runApp(MyApp());
    });


}

class MyApp extends StatelessWidget {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: MaterialColor(ColorConstant.cyan700.value, color),
        scrollbarTheme: ScrollbarThemeData(
          trackColor: MaterialStatePropertyAll<Color>(Colors.white),
          thumbColor: MaterialStatePropertyAll<Color>(ColorConstant.fromHex('#7F7F90')),
          trackBorderColor: MaterialStatePropertyAll<Color>(Colors.transparent),
        ),
        scaffoldBackgroundColor:  ColorConstant.gray300,
        visualDensity: VisualDensity.standard,
      ),
      title: 'Rigel PSY',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialRoute ,
      routes: AppRoutes.routes,
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