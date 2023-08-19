import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/sign_in/presentation/verification_screen/verification_screen.dart';
import 'package:listenmebaby71_s_application17/presentation/charts/concrete_pill/concrete_pill_screen.dart';

import '../presentation/charts/charts_calendar/k62_screen.dart';
import '../presentation/charts/charts_screen/k61_screen.dart';
import '../presentation/enter_password_screen/enter_password_screen.dart';
import '../presentation/initial_setup/recomendation_buy_tariff_screen/k4_screen.dart';
import '../presentation/initial_setup/send_pushes_screen/send_pushe_screen.dart';
import '../presentation/initial_setup/sign_in/presentation/reset_password_screen/reset_password_screen.dart';
import '../presentation/initial_setup/set_reminders_screen/k3_screen.dart';
import '../presentation/initial_setup/sign_in/presentation/sign_in_screen/k2_screen.dart';
import '../presentation/initial_setup/sign_in/presentation/sign_up_screen/k2_screen.dart';
import '../presentation/initial_setup/splash_screen/k1_screen.dart';
import '../presentation/main/main_screen/k20_screen.dart';
import '../presentation/main/path/add_emotion_screen/k24_page.dart';
import '../presentation/main/path/additional_emotions_screen/k31_screen.dart';
import '../presentation/main/path/first_thougths_screen/k38_screen.dart';
import '../presentation/main/path/path_final_screen/k39_screen.dart';
import '../presentation/main/path/what_body_parts_screen/k32_screen.dart';
import '../presentation/main/path/what_emotion_screen/k27_screen.dart';
import '../presentation/main/path/what_happened_screen/k22_screen.dart';
import '../presentation/main/path/what_i_do_screen/k37_screen.dart';
import '../presentation/main/path/where_happened_screen/k25_screen.dart';
import '../presentation/main/path/with_who_happened_screen/k26_screen.dart';
import '../presentation/recomendation/recomendation_screen/k70_screen.dart';
import '../presentation/records/calendar_add_screen/k51_screen.dart';
import '../presentation/records/calendar_search_screen/k50_screen.dart';
import '../presentation/records/record_add_screen/k54_screen.dart';
import '../presentation/records/record_edit_screen/k52_screen.dart';
import '../presentation/records/records_screen/k49_screen.dart';
import '../presentation/settings/about_app_screen/k7_screen.dart';
import '../presentation/settings/settings_buy_subscription_screen/k14_screen.dart';
import '../presentation/settings/settings_data_and_recovery/settings_data_and_recovery_screen/data_and_recovery_screen.dart';
import '../presentation/settings/settings_data_and_recovery/settings_recovery_screen/recovery_screen.dart';
import '../presentation/settings/settings_errors_screen/k11_screen.dart';
import '../presentation/settings/settings_offers_screen/k10_screen.dart';
import '../presentation/settings/settings_payment_subscription_screen/k15_screen.dart';
import '../presentation/settings/settings_profile_screen/k18_screen.dart';
import '../presentation/settings/settings_promo_screen/k16_screen.dart';
import '../presentation/settings/settings_reminders_screen/k12_page.dart';
import '../presentation/settings/settings_repeat_password_screen/k9_screen.dart';
import '../presentation/settings/settings_screen/k6_screen.dart';
import '../presentation/settings/settings_screen/k6_screen.dart';
import '../presentation/settings/settings_pills/settings_pills_calendar/settings_pills_calendar_screen.dart';
import '../presentation/settings/settings_pills/settings_pills/settings_pills_screen.dart';
import '../presentation/settings/settings_set_password/one_screen.dart';
import '../presentation/settings/settings_subscription_screen/k13_screen.dart';
import '../presentation/settings/settings_tariff_activated_screen/k17_screen.dart';

class AppRoutes {

  static const String splashScreen = '/splash_screen';

  static const String signUp = '/sign_up_screen';

  static const String signIn = '/sign_in_screen';

  static const String setRemindersScreen = '/set_reminders_screen';

  static const String recommendationBuyTariff = '/recommendation_buy_tariff_screen';

  static const String settings = '/settings_screen';

  static const String aboutApp = '/about_app_screen';

  static const String setPassword = '/settings_set_password';

  static const String repeatPassword = '/settings_repeat_password_screen';

  static const String offers = '/settings_offers_screen';

  static const String recovery = '/recovery';

  static const String errors = '/settings_errors_screen';

  static const String reminders = '/settings_reminders_screen';

  static const String subscription = '/settings_subscription_screen';

  static const String buySubscription = '/settings_buy_subscription_screen';

  static const String paymentSubscription = '/settings_payment_subscription_screen';

  static const String promo = '/settings_promo_screen';

  static const String tariffActivated = '/settings_tariff_activated_screen';

  static const String profile = '/settings_profile_screen';

  static const String main = '/main_screen';

  static const String whatHappened = '/what_happened_screen';

  static const String addEmotion = '/add_emotion_screen';

  static const String whereHappened = '/where_happened_screen';

  static const String withWhoHappened = '/with_who_happened_screen';

  static const String whatEmotion = '/what_emotion_screen';

  static const String additionalEmotions = '/additional_emotions_screen';

  static const String what_body_parts = '/what_body_parts_screen';

  static const String what_i_do = '/what_i_do_screen';

  static const String first_thougths = '/first_thougths_screen';

  static const String path_final = '/path_final_screen';

  static const String records = '/records_screen';

  static const String calendar_search = '/calendar_search_screen';

  static const String calendar_add = '/calendar_add_screen';

  static const String record_edit = '/record_edit_screen';

  static const String record_add = '/record_add_screen';

  static const String charts = '/charts_screen';

  static const String charts_calendar = '/charts_calendar';

  static const String recommendations = '/recommendation_screen';

static const String enterPasswordScreen = '/enter_password_screen';

  static const String data_and_recovery = '/data_and_recovery';

  static const String verify = '/verify';

  static const String resetPassword = '/reset_password';

  static const send_pushes = '/send_pushes';

  static const pills_calendar = '/pills_calendar';

  static const pills = '/pills';

  static const concrete_pill = '/concrete_pill';

  static String currentRoute = main;

  static String initialRoute = splashScreen;

  static bool notificationScreenIsInitial = true;

  static Map<String, WidgetBuilder> routes = {
    enterPasswordScreen: (context) => EnterPasswordScreen(),
    // initial setup
    splashScreen: (context) => K1Screen(),
    signUp: (context) => K2Screen(),
    signIn: (context) => K2AuthScreen(),
    verify: (context) => VerificationScreen(),
    resetPassword: (context) => ResetPasswordScreen(),
    setRemindersScreen: (context) => K3Screen(),
    recommendationBuyTariff: (context) => K4Screen(),
    send_pushes: (context) => SendPushesScreen(),
    // settings
    settings: (context) => K6Screen(),
    aboutApp: (context) => K7Screen(),
    setPassword: (context) => OneScreen(),
    repeatPassword: (context) => K9Screen(),
    offers: (context) => K10Screen(),
    errors: (context) => K11Screen(),
    reminders: (context) => K12Page(),
    subscription: (context) => K13Screen(),
    buySubscription: (context) => K14Screen(),
    paymentSubscription: (context) => K15Screen(),
    promo: (context) => K16Screen(),
    tariffActivated: (context) => K17Screen(),
    profile: (context) => K18Screen(),
    data_and_recovery: (context) => DataAndRecoveryScreen(),
    recovery: (context) => RecoveryScreen(),
    pills_calendar: (context) => PillsCalendarScreen(),
    pills: (context) => PillsScreen(),
    concrete_pill: (context) => ConcretePillScreen(),
    // main
    main: (context) => K20Screen(),
    addEmotion: (context) => K24Page(),
    additionalEmotions: (context) => K31Screen(),
    first_thougths: (context) => K38Screen(),
    path_final: (context) => K39Screen(),
    what_body_parts: (context) => K32Screen(),
    whatEmotion: (context) => K27Screen(),
    whatHappened: (context) => K22Screen(),
    what_i_do: (context) => K37Screen(),
    whereHappened: (context) => K25Screen(),
    withWhoHappened: (context) => K26Screen(),
    // recommendations
    recommendations: (context) => K70Screen(),
    // records
    calendar_add: (context) => K51Screen(),
    calendar_search: (context) => K50Screen(),
    record_add: (context) => K54Screen(),
    record_edit: (context) => K52Screen(),
    records: (context) => K49Screen(),
    // charts
    charts_calendar: (context) => K62Screen(),
    charts: (context) => K61Screen(),


  };
}
