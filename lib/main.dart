import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riva_psy/core/db/hive_db.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/providers/language_provider.dart';
import 'package:riva_psy/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/identity/local_identity_service.dart';
import 'core/services/insights/insight_workmanager.dart';
import 'core/services/notifications/awesome_notification_service.dart';
import 'core/utils/color_constant.dart';
import 'theme/app_theme.dart';
import 'widgets/fullscreen_audio_player_screen.dart';
import 'widgets/mini_player_bar.dart';

void main() async {
    final _mainSw = Stopwatch()..start();
    print('[STARTUP-DIAG] main() entered at ${DateTime.now()}');
    WidgetsFlutterBinding.ensureInitialized();
    if(!Platform.isIOS)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // First-run language auto-detection. easy_localization persists the
    // active locale under the SharedPreferences key 'locale' and, once
    // present, always uses it instead of re-deriving from the device
    // locale (see EasyLocalizationController.initEasyLocation). Writing
    // the detected locale under that same key before ensureInitialized()
    // makes this decision permanent after the first launch, same as a
    // manual choice via LanguagesPage/setLocale().
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('locale') == null) {
      const supportedLocalesByLanguageCode = {
        'ru': Locale('ru', 'RU'),
        'en': Locale('en', 'US'),
        'es': Locale('es', 'ES'),
      };
      final deviceLanguageCode =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final detectedLocale = supportedLocalesByLanguageCode[deviceLanguageCode] ??
          const Locale('en', 'US');
      await prefs.setString('locale', detectedLocale.toString());
    }

    await EasyLocalization.ensureInitialized();
    print('[STARTUP-DIAG] after EasyLocalization.ensureInitialized: ${_mainSw.elapsedMilliseconds}ms');
    print('[STARTUP-DIAG] total before runApp: ${_mainSw.elapsedMilliseconds}ms');

    // Firebase/Hive/audio/notifications used to all run here, awaited,
    // before runApp() — nothing could paint until every one of them
    // finished, which showed as a black flash between the native
    // LaunchScreen and K1Screen's own splash UI. K1Screen doesn't touch any
    // of them to render its first frame (just a local asset image + an
    // animation), so there's nothing stopping runApp() from happening
    // immediately and letting that work happen afterwards, in the
    // background, behind the already-visible splash screen instead of a
    // blank one. See bootstrapApp() below — it now runs from
    // K1Controller.initialization() instead.
      runApp(EasyLocalization(
          supportedLocales: [Locale('ru', 'RU'), Locale('en', 'US'), Locale('es', 'ES')],
          path: 'assets/translations', // <-- change the path of the translation files
          fallbackLocale: Locale('ru', 'RU'),
          child: MyApp()));

    //runApp( MyApp());
}

bool _appBootstrapped = false;

// Everything main() used to await before runApp() — see its own comment
// above for why it moved. Called from K1Controller.initialization(), which
// already needs Firebase/Hive/notifications ready before its own logic
// runs, so this is awaited there before anything else. Guarded to run only
// once per app process: K1Controller.initialization() (and therefore this)
// can run again later in the same session if the user gets routed back
// through the splash screen (e.g. from enterPasswordScreen) — re-running
// Firebase.initializeApp()/HiveDB.initDB() a second time would throw.
Future<void> bootstrapApp() async {
  if (_appBootstrapped) return;
  _appBootstrapped = true;
  final _sw = Stopwatch()..start();
  await Firebase.initializeApp();
  print('[STARTUP-DIAG] after Firebase.initializeApp: ${_sw.elapsedMilliseconds}ms');
  FirebaseAuth.instance.authStateChanges().listen((user) {
    print('[AUTHSTATE-DIAG] authStateChanges: uid=${user?.uid} email=${user?.email} at ${DateTime.now()}');
  });
  print('[AUTHSTATE-DIAG] initial currentUser at app start: ${FirebaseAuth.instance.currentUser?.uid}');
  try {
    HttpOverrides.global = MyHttpOverrides();
    SharedPrefs.setSharedPreferences = await SharedPreferences.getInstance();
    await HiveDB.initDB();
    print('[STARTUP-DIAG] after HiveDB.initDB: ${_sw.elapsedMilliseconds}ms');
    // Lock-screen/notification playback controls for AppAudioService's
    // shared player — must run before any AudioPlayer is created (it
    // isn't yet; that's lazy on first play()), and before runApp() per
    // the package's own contract. The androidNotification* params are
    // ignored on iOS (that side is driven by UIBackgroundModes: audio in
    // Info.plist instead) but the call itself must still run there too —
    // it's what registers the shared player with MPNowPlayingInfoCenter/
    // Control Center. Requires MainActivity to extend FlutterFragmentActivity
    // on Android (see MainActivity.kt) — without that this silently breaks
    // every AppAudioService.play() call there.
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.riva_psy.app.channel.audio',
      androidNotificationChannelName: 'Аудио',
      androidNotificationOngoing: true,
    );
    print('[STARTUP-DIAG] after JustAudioBackground.init: ${_sw.elapsedMilliseconds}ms');
    final notificationService = AwesomeNotificationService();
    // Must run before anything else touches AwesomeNotifications (e.g.
    // WorkManagerService().initService(), called right after this returns
    // in K1Controller.initialization()) — see initializeOnce()'s own doc
    // comment for the hang this fixes.
    await notificationService.initializeOnce();
    print('[STARTUP-DIAG] after notificationService.initializeOnce: ${_sw.elapsedMilliseconds}ms');
    notificationService.setListeners();
    // Nothing anywhere ever cleared the home-screen badge count, so it
    // only ever grew — every delivered notification is "read" the moment
    // the user opens the app at all, badge or no, so clearing it on every
    // launch is the correct behavior here (not just once on first read).
    AwesomeNotifications().resetGlobalBadge();
    if (!Platform.isIOS) {
      await registerNightlyInsightTask().catchError((_) {});
      registerGratitudeNudgeTask().catchError((_) {});
    }
    //initializeDateFormatting('ru_RU');

    // Zero-friction entry: no forced registration screen anymore.
    // A registered user (has a Firebase Auth session) goes through the
    // splash screen exactly as before; a first-time/anonymous user gets a
    // local UUID (offline, no server round-trip) and goes through the
    // exact same splash screen — K1Controller.initialization() already
    // conditionally skips its Firestore/CurrentUser sync when there's no
    // Firebase Auth session, so it's already safe for an anonymous user.
    // Registration itself now only happens contextually, from the
    // subscription/backup screens (see AccountRequiredSheet).
    await LocalIdentityService.ensureLocalId();
  } catch (_) {}
  print('[STARTUP-DIAG] bootstrapApp total: ${_sw.elapsedMilliseconds}ms');
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
        navigatorObservers: [FullscreenAudioPlayerRouteObserver()],
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.lightTheme.copyWith(
          scrollbarTheme: ScrollbarThemeData(
            trackColor: MaterialStatePropertyAll<Color>(Colors.white),
            thumbColor: MaterialStatePropertyAll<Color>(ColorConstant.fromHex('#7F7F90')),
            trackBorderColor: MaterialStatePropertyAll<Color>(Colors.transparent),
          ),
          visualDensity: VisualDensity.standard,
        ),
        title: 'RIVA PSY',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initialRoute ,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        // Most screens use fixed-size containers around text (getSize()-based,
        // scaled to screen dimensions, not to font size) — at large OS
        // accessibility text-scale settings that overflows and clips text
        // instead of reflowing. Clamping keeps the OS setting's benefit
        // (still noticeably bigger text) without letting it grow past what
        // the fixed layouts can absorb.
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
          // MiniPlayerBar mounted once here (not per-screen) so it floats
          // above whatever route is active app-wide, driven purely by
          // AppAudioService.state — see its own doc comment for why.
          child: Stack(
            children: [
              child!,
              const MiniPlayerBar(),
            ],
          ),
        ),
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