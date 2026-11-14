import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/event_model.dart';
import 'package:riva_psy/core/services/dashboards/social_battery_service.dart';

DayEventModel e(int h, int mood, String who) => DayEventModel(
    date: DateTime(2026, 11, 10, 8 + h),
    howDoYouFeel: mood,
    showInCharts: true,
    whoDidItHappen: EventModel(who, 'x', who));

void main() {
  test('break point is flagged once per social session', () {
    final r = SocialBatteryService.compute([
      e(0, 8, 'friend'), e(1, 8, 'friend'), e(2, 2, 'friend'), e(3, 2, 'friend'), e(4, 2, 'friend'),
    ]);
    print('limit ${r.breakPointHours}h; flagged: ${r.moodTimeline.map((p) => p.isBreakPoint ? 1 : 0).toList()}');
    expect(r.moodTimeline.where((p) => p.isBreakPoint).length, 1);
  });
}
