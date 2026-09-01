import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/presentation/initial_setup/pill_reminders/pill_reminders_screen.dart';
import 'package:riva_psy/presentation/main/path/first_thougths_screen/repository.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/models/emotional_state_model.dart';
import '../../../core/user_data/user.dart';
import 'dart:ui';
import '../../../core/models/day_event_model.dart';
import '../../../core/services/apple_billing_service.dart';
import '../../../core/services/google_play_billing_service.dart';
import '../../../core/services/in_app_update_service.dart';

import '../../../providers/language_provider.dart';
import '../../../widgets/chip_selector.dart';
import '../../../widgets/inner_shadow.dart';
import '../../../widgets/pressable_scale.dart';
import '../../../widgets/spark_burst.dart';
import '../../../widgets/welcome_offer_banner.dart';
import '../../../widgets/gratitude_nudge_popup.dart';
import '../../../widgets/insight_popup.dart';
import '../../../core/models/event_model.dart';
import '../../../core/models/insight_model.dart';
import '../../../core/services/insights/insight_engine.dart';
import '../../../core/services/milestones/milestone_service.dart';
import '../path/path_final_screen/repository.dart';
import 'controller.dart';
import 'repository.dart';
import 'widgets/try_irrational_dialog.dart';
import '../../../theme/app_colors.dart';

Color _moodColor(double value) {
  final t = (value / 10).clamp(0.0, 1.0);
  return Color.lerp(const Color(0xFF6B85B8), const Color(0xFFFF9933), t)!;
}

const _quickPositiveEmotions = ['joy', 'tranquility', 'inspiration'];

class K20Screen extends GetWidget<K20Controller> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    final _repo = K20Repo();
    final _dayEventsRepo = K39Repo();
    final controller = Get.put(K20Controller());
    Timer(Duration(seconds: 2), () async{
      await controller.openMessages(context);
    });
    // Fire-and-forget — InAppUpdateService itself guards against running
    // more than once per app session (this build() re-runs on every
    // GetBuilder update, same as the openMessages() Timer above).
    InAppUpdateService.checkAndPromptUpdate(context);
    // Also idempotent (no-ops if already listening) — must be started
    // somewhere the app reaches on every launch so a purchase completed
    // while the app was backgrounded still gets picked up and verified.
    GooglePlayBillingService.startListening();
    AppleBillingService.startListening();
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                child: Padding(
                  padding: getPadding(
                    left: 16,
                    right: 16,
                    bottom: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const GratitudeNudgePopup(),
                      const InsightPopup(),
                      const WelcomeOfferBanner(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: getPadding(
                            top: 20,
                          ),
                          child: Text(
                            DateTime.now().weekday.dayInText() +
                                ", " +
                                DateTime.now().day.toString() +
                                " " +
                                DateTime.now().month.monthInText(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight10Gray800,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: getPadding(
                            top: 20,
                          ),
                          child: CustomText(
                            "hi",
                            args: ["${CurrentUser.user.login!.isNotEmpty ? '' :''} ${CurrentUser.user.login!}"],
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtH1,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: getPadding(
                            top: 11,
                          ),
                          child: CustomText(
                            "how_do_you_feel",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayThin16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          top: 16,
                        ),
                        child: Center(
                          child: CustomText(
                            "normal",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight16,
                          ),
                        ),
                      ),
                      Center(
                        child: GetBuilder<K20Controller>(
                          builder: (_cardC) {
                          // Original single background color, unchanged —
                          // instead of shifting hue (too washed-out against
                          // gray2007c to read as "bright"), a white glow
                          // grows around the disc as the slider approaches
                          // "Прекрасно".
                          final glowStrength = (_cardC.sliderValue / 10).clamp(0.0, 1.0);
                          return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.15 + glowStrength * 0.65),
                                blurRadius: 10 + glowStrength * 34,
                                spreadRadius: glowStrength * 10,
                              ),
                            ],
                          ),
                          child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 0,
                          margin: getMargin(
                            top: 6,
                          ),
                          color: ColorConstant.gray2007c,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              getHorizontalSize(
                                101,
                              ),
                            ),
                          ),
                          child: Container(
                            height: getSize(
                              202,
                            ),
                            width: getSize(
                              202,
                            ),
                            padding: getPadding(
                              left: 17,
                              top: 19,
                              right: 17,
                              bottom: 19,
                            ),
                            decoration: AppDecoration.fillGray2007c.copyWith(
                              borderRadius: BorderRadiusStyle.circleBorder101,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: getMargin(
                                      left: 3,
                                      right: 3,
                                    ),
                                    padding: getPadding(
                                      left: 22,
                                      right: 22,
                                    ),
                                    decoration: BoxDecoration(),
                                  ),
                                ),
                                SizedBox(
                                  height: getSize(160),
                                  width: getSize(160),
                                  child: SleekCircularSlider(
                                      onChange: (_value) {
                                        controller.setSliderValue(_value);
                                      },
                                      appearance: CircularSliderAppearance(
                                        animationEnabled: false,
                                        infoProperties: InfoProperties(
                                          topLabelText: '',
                                          mainLabelStyle: TextStyle(color: Colors.transparent)
                                        ),
                                          startAngle: 105,
                                          angleRange: 330,
                                          size: 220,
                                          customColors: CustomSliderColors(
                                            trackColor: Colors.white,
                                            dotColor: ColorConstant.fromHex("#768295"),
                                            progressBarColors: [
                                              ColorConstant.fromHex('#403875'),
                                              ColorConstant.fromHex('#7FBDBA'),
                                            ],
                                          ),
                                          customWidths: CustomSliderWidths(
                                              handlerBorderWidth: 9,
                                              progressBarWidth: 15,
                                              handlerSize: 12,
                                              trackWidth: 15)),
                                      min: 0,
                                      max: 10,
                                      // Fixed at mount time on purpose — this is
                                      // an *initial* value, not a live-controlled
                                      // one. Feeding it controller.sliderValue on
                                      // every rebuild made the slider's own
                                      // didUpdateWidget think the value changed
                                      // externally and re-run its internal
                                      // animate/sync logic on every drag tick,
                                      // fighting the live drag gesture instead of
                                      // just letting the slider report onChange.
                                      initialValue: 5,
                                    ),
                                ),
                                GetBuilder<K20Controller>(
                                  builder: (_c) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: getSize(95),
                                  height: getSize(95),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _moodColor(_c.sliderValue).withOpacity(0.55),
                                        _moodColor(_c.sliderValue).withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: getSize(95),
                                    height: getSize(95),

                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: const Color(0xFF2A456F).withOpacity(0.6), blurRadius: 1, spreadRadius: 0),
                                          BoxShadow(color:ColorConstant.fromHex('#D7E1E1'), blurRadius: 10, spreadRadius: 5),
                                        ],
                                    ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: Container(

                                    child: CustomImageView(
                                      svgPath: ImageConstant.imgFrame185,
                                      fit: BoxFit.fill,
                                      height: getSize(
                                        155,
                                      ),
                                      width: getSize(
                                        155,
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),
                                GetBuilder<K20Controller>(
                                  builder: (_c) => SparkBurst(trigger: _c.saveBurstTrigger),
                                ),
                              ],
                            ),
                          ),
                          ),
                          );
                          },
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          top: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: getPadding(
                                bottom: 1,
                              ),
                              child: CustomText(
                                "terribly",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16,
                              ),
                            ),
                            Padding(
                              padding: getPadding(
                                top: 1,
                              ),
                              child: CustomText(
                                "fine",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GetBuilder<K20Controller>(
                        builder: (_c) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _c.sliderValue >= K20Controller.positiveThreshold
                              ? Padding(
                                  key: const ValueKey('quick_emotion_chips'),
                                  padding: getPadding(top: 8),
                                  child: Center(
                                    // Scaled down — this row competes with
                                    // "Пройти путь" for vertical space below
                                    // the fold, and the chips don't need to
                                    // be full-size to stay tappable.
                                    child: Transform.scale(
                                      scale: 0.85,
                                      child: ChipSelector<String>(
                                        selected: _c.selectedEmotionKey,
                                        onSelected: _c.selectEmotion,
                                        options: _quickPositiveEmotions
                                            .map((key) => ChipOption(value: key, label: key.tr()))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(key: ValueKey('no_chips')),
                        ),
                      ),
                      GetBuilder<K20Controller>(
                        builder: (_c) => PressableScale(
                          onTap: () async {
                            final currentValue = _c.sliderValue.round();
                            await _repo.updateEvent(EmotionalStateModel(currentValue, DateTime.now()));
                            final emotionKey = _c.selectedEmotionKey;
                            DayEventModel? savedEvent;
                            if (emotionKey != null) {
                              final events = await _dayEventsRepo.getEvent();
                              savedEvent = DayEventModel(
                                howDoYouFeel: currentValue,
                                date: DateTime.now(),
                                showInCharts: true,
                                whatEmotion: [EventModel(emotionKey.tr(), '', emotionKey)],
                                emotionIntensity: currentValue,
                                emotionInDayEvent: EmotionInDayEvent.POSITIVE,
                              );
                              events.add(savedEvent);
                              await _dayEventsRepo.updateEvent(events);
                              InsightEngine().run().catchError((_) => <InsightModel>[]);
                            }
                            _c.selectedEmotionKey = null;
                            _c.triggerSaveBurst();
                            // Give the button's spring-back and the spark
                            // burst time to actually be seen before any
                            // milestone celebration overlay covers the
                            // screen — the "record saved" confirmation
                            // dialog that used to sit here was redundant
                            // with the spark burst itself and got removed.
                            await Future.delayed(const Duration(milliseconds: 550));
                            if (savedEvent != null) {
                              MilestoneService.maybeCelebrate(context, savedEvent!);
                            }
                          },
                          child: CustomButton(
                            text: 'save'.tr().toUpperCase(),
                            margin: getMargin(
                              left: 74,
                              top: 18,
                              right: 74,
                            ),
                            variant: ButtonVariant.OutlineBluegray60014,
                            borderRadius: 12,
                          ),
                        ),
                      ),
                      CustomButton(

                          onTap: (){
                          Navigator.pushNamed(context, AppRoutes.whatHappened, arguments: DayEventModel().copyWith(howDoYouFeel: controller.sliderValue.round(), showInCharts: true));
                          },
                        text: 'complete_path'.tr().toUpperCase(),
                        margin: getMargin(
                          left: 68,
                          top: 14,
                          right: 68,
                          bottom: 16,
                        ),
                        // Bright/filled, matching the medication module's
                        // primary Save button (cyan700 + white text) — was
                        // the same muted outline style as every other
                        // secondary button, which buried the screen's
                        // second-most-important action.
                        bgColor: ColorConstant.cyan700,
                        textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                        borderRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomBar(
            onChanged: (BottomBarEnum type) {},
          ),
        );
      }
    );
  }
}
