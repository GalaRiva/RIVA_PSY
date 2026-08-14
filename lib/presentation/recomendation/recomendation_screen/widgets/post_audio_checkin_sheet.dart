import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/emotional_state_model.dart';
import 'package:riva_psy/core/models/event_model.dart';
import 'package:riva_psy/core/models/insight_model.dart';
import 'package:riva_psy/core/services/insights/insight_engine.dart';
import 'package:riva_psy/presentation/main/main_screen/repository.dart';
import 'package:riva_psy/presentation/main/path/path_final_screen/repository.dart';
import 'package:riva_psy/widgets/chip_selector.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

const _quickPositiveEmotions = ['joy', 'tranquility', 'inspiration'];

/// "Практика завершена. Как вы себя чувствуете сейчас?" — a lightweight
/// mood check-in shown after a meditation track finishes on its own (not on
/// a manual stop). Reuses the same slider/chip/save mechanics as the main
/// screen's quick check-in, plus tags the just-finished practice as a
/// `whatHappened` context so future insights can eventually say things like
/// "this practice tends to lower your anxiety."
class PostAudioCheckinSheet extends StatefulWidget {
  final String trackTitle;

  const PostAudioCheckinSheet({Key? key, required this.trackTitle}) : super(key: key);

  @override
  State<PostAudioCheckinSheet> createState() => _PostAudioCheckinSheetState();
}

class _PostAudioCheckinSheetState extends State<PostAudioCheckinSheet> {
  // Not fed back into SleekCircularSlider's initialValue on rebuild — that
  // widget's own didUpdateWidget re-runs its animate/sync logic whenever
  // initialValue changes, fighting a live drag. initialValue below stays a
  // fixed literal on purpose; this field is only read at save time.
  double _sliderValue = 6;
  String? _selectedEmotionKey;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final currentValue = _sliderValue.round();
    await K20Repo().updateEvent(EmotionalStateModel(currentValue, DateTime.now()));

    final emotionKey = _selectedEmotionKey;
    if (emotionKey != null) {
      final repo = K39Repo();
      final events = await repo.getEvent();
      events.add(DayEventModel(
        howDoYouFeel: currentValue,
        date: DateTime.now(),
        showInCharts: true,
        whatEmotion: [EventModel(emotionKey.tr(), '', emotionKey)],
        whatHappened: EventModel(widget.trackTitle, '', null),
        emotionIntensity: currentValue,
        emotionInDayEvent: EmotionInDayEvent.POSITIVE,
      ));
      await repo.updateEvent(events);
      InsightEngine().run().catchError((_) => <InsightModel>[]);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              'post_audio_checkin_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: getVerticalSize(16)),
            SizedBox(
              height: 140,
              width: 140,
              child: Center(
                child: SleekCircularSlider(
                  onChange: (v) => _sliderValue = v,
                  appearance: CircularSliderAppearance(
                    animationEnabled: false,
                    infoProperties: InfoProperties(
                      topLabelText: '',
                      mainLabelStyle: const TextStyle(color: Colors.transparent),
                    ),
                    startAngle: 105,
                    angleRange: 330,
                    size: 140,
                    customColors: CustomSliderColors(
                      trackColor: Colors.white,
                      dotColor: ColorConstant.fromHex("#768295"),
                      progressBarColors: [
                        ColorConstant.fromHex('#403875'),
                        ColorConstant.fromHex('#7FBDBA'),
                      ],
                    ),
                    customWidths: CustomSliderWidths(
                      handlerBorderWidth: 7,
                      progressBarWidth: 12,
                      handlerSize: 10,
                      trackWidth: 12,
                    ),
                  ),
                  min: 0,
                  max: 10,
                  initialValue: 6,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('terribly'.tr(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text('fine'.tr(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            SizedBox(height: getVerticalSize(16)),
            Center(
              child: ChipSelector<String>(
                selected: _selectedEmotionKey,
                onSelected: (v) => setState(() => _selectedEmotionKey = v),
                options: _quickPositiveEmotions.map((key) => ChipOption(value: key, label: key.tr())).toList(),
              ),
            ),
            SizedBox(height: getVerticalSize(20)),
            CustomButton(
              text: 'save'.tr().toUpperCase(),
              onTap: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
