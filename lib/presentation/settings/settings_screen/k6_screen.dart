import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart' ;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/string_extension.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart' ;

import 'controller.dart';
import 'widgets/card_settings_button_widget.dart';
import '../../../theme/app_colors.dart';
import '../../initial_setup/strengths_quiz/quiz_flow.dart';
import '../../initial_setup/set_reminders_screen/k3_screen.dart';
import '../../consultation/consultation_screen.dart';
import '../../../core/services/insights/insight_workmanager.dart';
import '../../../core/services/insights/insights_repo.dart';
import '../../../core/services/rating/rating_request_service.dart';
import '../../recomendation/recomendation_screen/portrait/data/portrait_repo.dart';
import '../../../core/utils/shared_prefs.dart';

class K6Screen extends GetWidget {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K6Controller());
    return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: getPadding(left: 16, right: 16, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                                padding: getPadding(top: 64),
                                child: Divider(
                                    height: getVerticalSize(1),
                                    thickness: getVerticalSize(1),
                                    color: ColorConstant.gray50)),
                            Padding(
                                padding: getPadding(top: 25),
                                child: Text("Настройки",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            SizedBox(
                              height: getVerticalSize(78),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.profile),
                              title: 'your_profile',
                              svgIcon: ImageConstant.imgUser,
                              controller: controller,
                              svgSize: 24,
                              bgColor: ColorConstant.cyan700,
                              textColor: Colors.white,
                              iconColor: Colors.white,
                            ),
                            SizedBox(
                              height: getVerticalSize(21),
                            ),
                            CardSettingsButtonWidget(context,
                                onTap: () => onTapRowrefresh(context),
                                title: 'about_app',
                                svgIcon: ImageConstant.imgRefresh,
                                controller: controller,
                                svgSize: 24),
                            GetBuilder(
                              builder: (K6Controller _c) => CardSettingsButtonWidget(context,
                                  onTap: () => controller.password
                                      ? onTapRowlock(context)
                                      : null,
                                  title: 'passwprd',
                                  svgIcon: ImageConstant.imgLock,
                                  controller: controller,
                                  svgSize: 20,
                                  onSwitch: (value) {
                                    controller.changePasswordState(context);
                                    controller.update();
                                  },
                                  valueForSwitch: controller.password),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () =>
                                  controller.onTapDataAndRecovery(context),
                              title: 'data_and_recovery',
                              svgIcon: ImageConstant.imgClip,
                              controller: controller,
                              svgSize: 20,
                            ),
                            SizedBox(
                              height: getVerticalSize(21),
                            ),
                            Visibility(
                                child: CardSettingsButtonWidget(context,
                                    onTap: () async =>
                                        await controller.onTapPill(
                                            context,
                                            GlobalKey<
                                                ScaffoldMessengerState>()),
                                    title: 'apoinment_reminders',
                                    svgIcon: ImageConstant.imgPill,
                                    controller: controller,
                                    svgSize: 24,
                                    height: 53)),
                            SizedBox(
                              height: getVerticalSize(21),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowcheckmark(context),
                              title: 'suggestions',
                              svgIcon: ImageConstant.imgCheckmarkGray800,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowcheckmarkone(context),
                              title: 'report_an_error',
                              svgIcon: ImageConstant.imgCheckmarkGray80024x24,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => launchUrl(
                                  Uri.parse('mailto:support@rivapsy.com')),
                              title: 'write_to_us',
                              svgIcon: ImageConstant.imgMail,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.reminders),
                              title: 'reminders',
                              svgIcon: ImageConstant.imgClockGray800,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowclose(context),
                              title: 'subscription',
                              svgIcon: ImageConstant.imgClose,
                              controller: controller,
                              svgSize: 24,
                            ),
                            SizedBox(
                              height: getVerticalSize(40),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.selectLanguage),
                              title: 'language',
                              svgIcon: ImageConstant.imgUser,
                              controller: controller,
                              svgSize: 24,
                            ),
                            if (context.locale.languageCode == 'ru')
                              CardSettingsButtonWidget(
                                context,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ConsultationScreen())),
                                title: 'consultation_menu_item',
                                svgIcon: ImageConstant.imgConsultation,
                                controller: controller,
                                svgSize: 24,
                              ),
                            // Dev-only entry points — kept for quick
                            // on-device testing, but must never ship visible
                            // to real users, so gated behind kDebugMode.
                            if (kDebugMode) ...[
                              // Exercises the exact same production flow real
                              // registration now triggers — keep this entry
                              // point for quick on-device testing without
                              // needing a fresh account each time.
                              CardSettingsButtonWidget(
                                context,
                                onTap: () async {
                                  await PortraitRepo().debugForceFillAll();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text(
                                        'Все 12 тестов «Проекция Я» + бонус заполнены (доминанта А), гейты открыты.'),
                                  ));
                                },
                                title: '🧪 Portrait force-fill (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              CardSettingsButtonWidget(
                                context,
                                onTap: () async {
                                  await PortraitRepo().debugClearAll();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text(
                                        'Все результаты «Проекция Я» сброшены — можно проходить тесты с нуля.'),
                                  ));
                                },
                                title: '🧪 Portrait clear (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              CardSettingsButtonWidget(
                                context,
                                onTap: () async {
                                  await SharedPrefs.sharedPreferences.setBool('portrait_onboarding_shown', false);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Онбординг «Проекция Я» сброшен — покажется заново при следующем открытии.'),
                                  ));
                                },
                                title: '🧪 Portrait onboarding reset (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              CardSettingsButtonWidget(
                                context,
                                onTap: () async {
                                  await PortraitRepo().debugCompleteNextTest();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('+1 тест засчитан — новая группа звёзд должна открыться.'),
                                  ));
                                },
                                title: '🧪 Portrait +1 test (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              CardSettingsButtonWidget(
                                context,
                                onTap: () => startPostRegistrationQuizFlow(context),
                                title: '🧪 Quiz test (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              CardSettingsButtonWidget(
                                context,
                                onTap: () => showDialog(
                                    useSafeArea: false,
                                    context: context,
                                    builder: (_) => K3Screen()),
                                title: '🧪 Reminders test (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              // Runs the real nightly insight checks immediately
                              // instead of waiting for WorkManager (which can be
                              // delayed hours by Doze/charging constraints) —
                              // only fires a notification if a check actually
                              // finds something, same as the real job.
                              CardSettingsButtonWidget(
                                context,
                                onTap: () {
                                  runNightlyInsightAnalysisNow();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text(
                                        'Проверка запущена. Если в дневнике достаточно данных — уведомление придёт через несколько секунд.'),
                                  ));
                                },
                                title: '🧪 Insight test (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              // Wipes stored insights so a stale one (e.g. one
                              // whose notification failed to display before the
                              // icon-resource bug was fixed) can't sit on
                              // cooldown and block re-testing a fresh one.
                              CardSettingsButtonWidget(
                                context,
                                onTap: () {
                                  InsightsRepo().clearAll();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Сохранённые инсайты очищены.'),
                                  ));
                                },
                                title: '🧪 Clear insights (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              CardSettingsButtonWidget(
                                context,
                                onTap: () {
                                  runGratitudeNudgeNow();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Уведомление с благодарностью отправлено — проверь шторку.'),
                                  ));
                                },
                                title: '🧪 Gratitude test (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                              // Clears the rating-request throttle (last-call
                              // timestamp + lifetime count) so the quiz-result
                              // review prompt can be re-tested without waiting
                              // 90 days between attempts.
                              CardSettingsButtonWidget(
                                context,
                                onTap: () async {
                                  await RatingRequestService.debugResetThrottle();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Троттлинг запроса оценки сброшен.'),
                                  ));
                                },
                                title: '🧪 Reset rating throttle (temp)',
                                svgIcon: ImageConstant.imgUser,
                                controller: controller,
                                svgSize: 24,
                              ),
                            ],
                          ])))),
        ),
        bottomNavigationBar:
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTapRowrefresh(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.aboutApp);
  }

  onTapRowlock(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.setPassword);
  }

  onTapRowcheckmark(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.offers);
  }

  onTapRowcheckmarkone(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.errors);
  }

  onTapRowclose(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.subscription);
  }
}
