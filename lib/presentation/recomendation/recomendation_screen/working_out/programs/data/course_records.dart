import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/event_model.dart';
import 'package:riva_psy/core/utils/image_constant.dart';
import 'package:riva_psy/core/models/insight_model.dart';
import 'package:riva_psy/core/services/insights/insight_engine.dart';
import 'package:riva_psy/presentation/main/path/path_final_screen/repository.dart';

import '../models/course.dart';

// What a person does in a course also lands in "Записи" (and, for the 0-10
// scales, in the analytics charts), so the diary is one place:
//  * a saved task            -> a diary entry with the person's own words
//                               (not counted in charts — it has no emotion);
//  * a 0-10 scale (urge, pain, support…) -> an entry whose emotion is the
//                               scale's name and whose intensity is the value.
// Both are written the same way the Guided Journals write their entry (all
// the non-null fields the Records / Charts screens read are filled in, the
// mood slider stays empty so mood statistics are not touched). Never throws:
// a diary hiccup must not break a course.
class CourseRecords {
  static EventModel _blank() => EventModel('', '');

  static Future<void> _add(DayEventModel event) async {
    try {
      final repo = K39Repo();
      final events = await repo.getEvent();
      events.add(event);
      await repo.updateEvent(events);
      InsightEngine().run().catchError((_) => <InsightModel>[]);
    } catch (_) {}
  }

  /// A saved course task as a diary entry.
  static Future<void> task({
    required Course course,
    required String stepTitle,
    required CourseTask task,
    required Map<String, String> values,
  }) async {
    final lines = <String>[];
    for (final f in task.fields) {
      final v = values[f.id];
      if (v == null || v.isEmpty || f.type != 'text') continue;
      lines.add('${f.label}\n$v');
    }
    if (lines.isEmpty) return;
    await _add(DayEventModel(
      date: DateTime.now(),
      showInCharts: false,
      firstThoughts: '${course.title} · $stepTitle\n\n${lines.join('\n\n')}',
      whatHappened: EventModel('${course.title} · $stepTitle', ImageConstant.imgProgram),
      whereHappened: EventModel(course.title, ''),
      whoDidItHappen: _blank(),
      whatEmotion: [EventModel(task.title, '')],
      whatBodyParts: const [],
    ));
    // The task's own 0-10 fields (e.g. hunger) are charted separately.
    for (final f in task.fields) {
      if (f.type != 'scale' || f.record == null) continue;
      final v = int.tryParse(values[f.id] ?? '');
      if (v == null) continue;
      await scale(course: course, context: stepTitle, record: f.record!, value: v);
    }
  }

  /// One 0-10 value as an emotion with an intensity (shows up in Записи and
  /// in the emotion charts).
  static Future<void> scale({
    required Course course,
    required String context,
    required ScaleRecord record,
    required int value,
    String? note,
  }) async {
    final kind = record.kind == 'negative'
        ? EmotionInDayEvent.NEGATIVE
        : record.kind == 'positive'
            ? EmotionInDayEvent.POSITIVE
            : EmotionInDayEvent.NEUTRAL;
    await _add(DayEventModel(
      date: DateTime.now(),
      showInCharts: true,
      emotionIntensity: value.clamp(0, 10),
      emotionInDayEvent: kind,
      firstThoughts: [course.title, context, if (note != null) note].join(' · '),
      whatHappened: EventModel(context, ImageConstant.imgProgram),
      whereHappened: EventModel(course.title, ''),
      whoDidItHappen: _blank(),
      whatEmotion: [EventModel(record.name, '')],
      whatBodyParts: const [],
    ));
  }

  /// A free text note (e.g. a resolved night thought) as a diary entry.
  static Future<void> note({required Course course, required String title, required String text}) async {
    await _add(DayEventModel(
      date: DateTime.now(),
      showInCharts: false,
      firstThoughts: '${course.title} · $title\n\n$text',
      whatHappened: EventModel('${course.title} · $title', ImageConstant.imgProgram),
      whereHappened: EventModel(course.title, ''),
      whoDidItHappen: _blank(),
      whatEmotion: [EventModel(title, '')],
      whatBodyParts: const [],
    ));
  }
}
