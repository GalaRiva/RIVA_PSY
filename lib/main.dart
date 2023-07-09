import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listenmebaby71_s_application17/core/db/hive_db.dart';
import 'package:listenmebaby71_s_application17/core/services/workmanager/workmanager_service.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user.dart';
import 'package:listenmebaby71_s_application17/routes/app_routes.dart';

import 'core/utils/color_constant.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  //message.notification!.android.smallIcon =
  print('background message ${message.notification!.body}');
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    await HiveDB.initDB();
    await WorkManagerService().initService();
    await CurrentUser.init();
    runApp(MyApp());
  } catch (_) {
    print('start error - ' + _.toString());
  }

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor:  ColorConstant.gray300,
        visualDensity: VisualDensity.standard,
      ),
      title: 'Rigel PSY',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashScreen,
      routes: AppRoutes.routes,
    );
  }
}
