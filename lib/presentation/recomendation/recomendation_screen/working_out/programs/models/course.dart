// Course content model. Courses are bundled JSON assets (assets/courses/) —
// not Firestore — on purpose: the safety tools (impulse / after-episode)
// must work offline, and a new collection would depend on Firestore rules.
// Any text may be a plain string (Russian) or a {ru,en,es} map.

String loc(dynamic v, String lang) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final x = v[lang];
    if (x != null && x.toString().trim().isNotEmpty) return x.toString();
    return (v['ru'] ?? '').toString();
  }
  return v.toString();
}

// How a 0-10 scale is written to the diary/analytics ("Записи"): the scale
// becomes an emotion of this name with the value as its intensity.
// [kind]: negative | positive | neutral.
class ScaleRecord {
  final String name;
  final String kind;
  ScaleRecord(this.name, this.kind);

  static ScaleRecord? fromJson(dynamic j, String lang) {
    if (j is! Map) return null;
    return ScaleRecord(loc(j['name'], lang), (j['kind'] as String?) ?? 'neutral');
  }
}

// A named section of a course's steps. Unnumbered groups (e.g. the support
// blocks) are always-available toolboxes that are never suggested as "today";
// the numbered group is the path itself.
class CourseGroup {
  final String id;
  final String title;
  final String subtitle;
  final bool numbered;
  final bool suggest;
  // Onboarding concern keys this block is the natural start for (e.g.
  // "breakup"); used to pick the block shown as "today" before anything is
  // started.
  final List<String> startConcerns;
  CourseGroup(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.numbered,
      required this.suggest,
      this.startConcerns = const []});
}

class CourseField {
  final String id;
  final String label;
  final String hint;
  final String type; // text | check | scale
  final List<String> chips;
  final String? defaultText;
  final bool optional;
  final ScaleRecord? record;
  // type 'time': optional one-off reminders for the next 7 days, this many
  // minutes before the chosen time (never repeating, no streaks).
  final int? notifyBefore;
  final String notifyBody;

  CourseField({
    required this.id,
    required this.label,
    required this.hint,
    required this.type,
    required this.chips,
    this.defaultText,
    required this.optional,
    this.record,
    this.notifyBefore,
    this.notifyBody = '',
  });

  factory CourseField.fromJson(Map<String, dynamic> j, String lang) => CourseField(
        id: j['id'] as String,
        label: loc(j['label'], lang),
        hint: loc(j['hint'], lang),
        type: (j['type'] as String?) ?? 'text',
        chips: ((j['chips'] as List?) ?? []).map((c) => loc(c, lang)).toList(),
        defaultText: j['default'] == null ? null : loc(j['default'], lang),
        optional: (j['optional'] as bool?) ?? false,
        record: ScaleRecord.fromJson(j['record'], lang),
        notifyBefore: (j['notify_before'] as num?)?.toInt(),
        notifyBody: loc(j['notify_body'], lang),
      );
}

class CourseTask {
  final String title;
  final String cardType;
  final String intro;
  final List<CourseField> fields;
  // Optional special rendering of the saved card in the library ('chain').
  final String? visual;

  CourseTask(
      {required this.title, required this.cardType, required this.intro, required this.fields, this.visual});

  factory CourseTask.fromJson(Map<String, dynamic> j, String lang) => CourseTask(
        title: loc(j['title'], lang),
        cardType: j['card_type'] as String,
        intro: loc(j['intro'], lang),
        visual: j['visual'] as String?,
        fields: ((j['fields'] as List?) ?? [])
            .map((f) => CourseField.fromJson(f as Map<String, dynamic>, lang))
            .toList(),
      );
}

class CourseMicro {
  final String id;
  final String title;
  final String body;
  CourseMicro({required this.id, required this.title, required this.body});
}

class CourseStep {
  final String id;
  final String title;
  final String card;
  final int minutes;
  final String? audioDocId;
  final CourseTask task;
  final List<CourseMicro> micro;
  // Never gated by the "2 new steps a day" pace and never locked.
  final bool alwaysAvailable;
  // Free steps open without a subscription; the rest need Orion.
  final bool free;
  final String groupId;
  // Built-in screen instead of the generic form ('night_box').
  final String? special;
  // Dark screen + sleep hint (the night-thoughts audio).
  final bool night;
  // One quiet local notification some minutes after the audio, e.g. the
  // 3-minute "sharp wave" practice.
  final int? followUpMinutes;
  final String followUpTitle;
  final String followUpBody;
  // Assigned by Course: position among the numbered steps, null if unnumbered.
  int? number;

  CourseStep({
    required this.id,
    required this.title,
    required this.card,
    required this.minutes,
    required this.audioDocId,
    required this.task,
    required this.micro,
    required this.alwaysAvailable,
    required this.free,
    required this.groupId,
    this.special,
    required this.night,
    this.followUpMinutes,
    this.followUpTitle = '',
    this.followUpBody = '',
  });

  factory CourseStep.fromJson(Map<String, dynamic> j, String lang) => CourseStep(
        id: j['id'] as String,
        title: loc(j['title'], lang),
        card: loc(j['card'], lang),
        minutes: (j['minutes'] as num?)?.toInt() ?? 0,
        audioDocId: j['audio_doc_id'] as String?,
        task: CourseTask.fromJson(j['task'] as Map<String, dynamic>, lang),
        micro: ((j['micro'] as List?) ?? [])
            .map((m) => CourseMicro(
                id: m['id'] as String, title: loc(m['title'], lang), body: loc(m['body'], lang)))
            .toList(),
        alwaysAvailable: (j['always_available'] as bool?) ?? false,
        free: (j['free'] as bool?) ?? false,
        groupId: (j['group'] as String?) ?? 'main',
        special: j['special'] as String?,
        night: (j['night'] as bool?) ?? false,
        followUpMinutes: j['follow_up'] == null ? null : ((j['follow_up'] as Map)['minutes'] as num?)?.toInt(),
        followUpTitle: j['follow_up'] == null ? '' : loc((j['follow_up'] as Map)['title'], lang),
        followUpBody: j['follow_up'] == null ? '' : loc((j['follow_up'] as Map)['body'], lang),
      );
}

class ToolButton {
  final String label;
  final String action; // close | tool:<id>
  ToolButton(this.label, this.action);
}

// A one-field card the person can write (or pick a ready phrase for) right on
// a tool page, when they have not made it in the course yet.
class InlineCard {
  final String field;
  final String label;
  final List<String> chips;
  InlineCard(this.field, this.label, this.chips);
}

class ToolPage {
  final String title;
  final String body;
  // "cardType:field1,field2" — shows those fields of the person's most
  // recent saved card of that type; [cardFallback] is shown when none exists.
  final String? showCard;
  final String cardFallback;
  final int? timerMinutes;
  // Optional 0-10 slider ("before"/"after" feed the "impulse wave" summary).
  final String? scaleId;
  final String scaleLabel;
  final ScaleRecord? scaleRecord;
  // Guided breathing circle: seconds in / out and how many breaths.
  final int? breathIn;
  final int? breathOut;
  final int? breathCycles;
  final InlineCard? inline;
  final List<ToolButton> buttons;
  final bool helpline;

  ToolPage({
    required this.title,
    required this.body,
    this.showCard,
    this.cardFallback = '',
    this.timerMinutes,
    this.scaleId,
    this.scaleLabel = '',
    this.scaleRecord,
    this.breathIn,
    this.breathOut,
    this.breathCycles,
    this.inline,
    required this.buttons,
    required this.helpline,
  });
}

class CourseTool {
  final String id;
  final String title;
  final String subtitle;
  final List<ToolPage> pages;
  CourseTool({required this.id, required this.title, required this.subtitle, required this.pages});
}

class WeeklyQuestion {
  final String id;
  final String label;
  final ScaleRecord? record;
  WeeklyQuestion(this.id, this.label, [this.record]);
}

class ScreeningQuestion {
  final String id;
  final String level; // stop | specialist
  final String q;
  ScreeningQuestion({required this.id, required this.level, required this.q});
}

// One page of the short "how this program works" introduction shown once.
class WelcomePage {
  final String title;
  final String body;
  final String icon;
  // Shown only on Android (e.g. the app-icon shortcut, which iOS lacks here).
  final bool androidOnly;
  WelcomePage(this.title, this.body, this.icon, {this.androidOnly = false});
}

class Course {
  final String id;
  final int order;
  final List<String> languages;
  final String title;
  final String subtitle;
  final String intro;
  final String paceNote;
  final String freeNote;
  final String? cover; // asset path
  final String? specialistTitle;
  final String? specialistBody;
  final List<WeeklyQuestion> weekly;
  // Card types that make up "Мой план" (PDF), in order.
  final List<String> planTypes;
  final String? introAudioDocId;
  final List<CourseStep> steps;
  final List<CourseTool> tools;
  final List<ScreeningQuestion> screening;
  final List<CourseGroup> groups;
  // New steps per day (the pace); the doc for "Вернуться к себе" asks for one.
  final int maxNewPerDay;
  // Step offered first when someone answers "worse" after an audio.
  final String? calmStepId;
  final List<WelcomePage> welcome;

  Course({
    required this.id,
    required this.order,
    required this.languages,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.paceNote,
    required this.freeNote,
    this.cover,
    this.specialistTitle,
    this.specialistBody,
    required this.weekly,
    required this.planTypes,
    required this.introAudioDocId,
    required this.steps,
    required this.tools,
    required this.screening,
    required this.groups,
    required this.maxNewPerDay,
    this.calmStepId,
    this.welcome = const [],
  });

  CourseGroup groupOf(CourseStep step) =>
      groups.firstWhere((g) => g.id == step.groupId, orElse: () => groups.first);

  factory Course.fromJson(Map<String, dynamic> j, String lang) {
    final course = Course._parse(j, lang);
    // Numbering restarts in every numbered block ("урок 1…").
    final counters = <String, int>{};
    for (final st in course.steps) {
      final g = course.groupOf(st);
      if (g.numbered) st.number = counters[g.id] = (counters[g.id] ?? 0) + 1;
    }
    return course;
  }

  factory Course._parse(Map<String, dynamic> j, String lang) => Course(
        id: j['id'] as String,
        order: (j['order'] as num?)?.toInt() ?? 0,
        languages: ((j['languages'] as List?) ?? ['ru']).map((e) => e.toString()).toList(),
        title: loc(j['title'], lang),
        subtitle: loc(j['subtitle'], lang),
        intro: loc(j['intro'], lang),
        paceNote: loc(j['pace_note'], lang),
        freeNote: loc(j['free_note'], lang),
        cover: j['cover'] as String?,
        specialistTitle: j['specialist_title'] == null ? null : loc(j['specialist_title'], lang),
        specialistBody: j['specialist_body'] == null ? null : loc(j['specialist_body'], lang),
        weekly: ((j['weekly'] as List?) ?? [])
            .map((w) => WeeklyQuestion(w['id'] as String, loc(w['label'], lang), ScaleRecord.fromJson(w['record'], lang)))
            .toList(),
        planTypes: ((j['plan_types'] as List?) ?? []).map((e) => e.toString()).toList(),
        introAudioDocId: j['intro_audio_doc_id'] as String?,
        steps: ((j['steps'] as List?) ?? [])
            .map((s) => CourseStep.fromJson(s as Map<String, dynamic>, lang))
            .toList(),
        tools: ((j['tools'] as List?) ?? []).map((t) {
          final tm = t as Map<String, dynamic>;
          return CourseTool(
            id: tm['id'] as String,
            title: loc(tm['title'], lang),
            subtitle: loc(tm['subtitle'], lang),
            pages: ((tm['pages'] as List?) ?? []).map((p) {
              final pm = p as Map<String, dynamic>;
              return ToolPage(
                title: loc(pm['title'], lang),
                body: loc(pm['body'], lang),
                showCard: pm['show_card'] as String?,
                cardFallback: loc(pm['show_card_fallback'], lang),
                scaleId: pm['scale'] == null ? null : (pm['scale'] as Map)['id'] as String?,
                scaleLabel: pm['scale'] == null ? '' : loc((pm['scale'] as Map)['label'], lang),
                scaleRecord: pm['scale'] == null ? null : ScaleRecord.fromJson((pm['scale'] as Map)['record'], lang),
                timerMinutes: (pm['timer_minutes'] as num?)?.toInt(),
                inline: pm['inline'] == null
                    ? null
                    : InlineCard(
                        (pm['inline'] as Map)['field'] as String,
                        loc((pm['inline'] as Map)['label'], lang),
                        (((pm['inline'] as Map)['chips'] as List?) ?? []).map((c) => loc(c, lang)).toList()),
                breathIn: pm['breath'] == null ? null : ((pm['breath'] as Map)['in'] as num?)?.toInt(),
                breathOut: pm['breath'] == null ? null : ((pm['breath'] as Map)['out'] as num?)?.toInt(),
                breathCycles: pm['breath'] == null ? null : ((pm['breath'] as Map)['cycles'] as num?)?.toInt(),
                helpline: (pm['helpline'] as bool?) ?? false,
                buttons: ((pm['buttons'] as List?) ?? [])
                    .map((b) => ToolButton(loc(b['label'], lang), b['action'] as String))
                    .toList(),
              );
            }).toList(),
          );
        }).toList(),
        screening: ((j['screening'] as List?) ?? [])
            .map((q) => ScreeningQuestion(
                id: q['id'] as String, level: q['level'] as String, q: loc(q['q'], lang)))
            .toList(),
        groups: ((j['groups'] as List?) ?? []).isEmpty
            ? [CourseGroup(id: 'main', title: '', subtitle: '', numbered: true, suggest: true)]
            : (j['groups'] as List)
                .map((g) => CourseGroup(
                      id: g['id'] as String,
                      title: loc(g['title'], lang),
                      subtitle: loc(g['subtitle'], lang),
                      numbered: (g['numbered'] as bool?) ?? true,
                      suggest: (g['suggest'] as bool?) ?? true,
                      startConcerns: ((g['start_concerns'] as List?) ?? []).map((e) => e.toString()).toList(),
                    ))
                .toList(),
        maxNewPerDay: (j['max_new_per_day'] as num?)?.toInt() ?? 2,
        calmStepId: j['calm_step_id'] as String?,
        welcome: ((j['welcome'] as List?) ?? [])
            .map((w) => WelcomePage(loc(w['title'], lang), loc(w['body'], lang), (w['icon'] as String?) ?? 'route',
                androidOnly: (w['android_only'] as bool?) ?? false))
            .toList(),
      );
}
