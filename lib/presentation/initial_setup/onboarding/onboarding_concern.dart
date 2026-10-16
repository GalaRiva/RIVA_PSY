import 'package:shared_preferences/shared_preferences.dart';

// The single "what's hardest right now" answer collected on first launch.
// Stored locally only (SharedPreferences), same as the diary — never sent
// to Firestore, so the App Privacy label doesn't change.
//
// [audioDocIds] are Firestore `Audio` document ids. More than one means the
// person picks between them (only `unknown` does).
class OnboardingConcern {
  final String key;
  final String labelKey;
  final List<String> audioDocIds;
  final String? journalTopicId;

  const OnboardingConcern._(this.key, this.labelKey, this.audioDocIds, this.journalTopicId);

  static const anxious = OnboardingConcern._(
      'anxious', 'onb_concern_anxious', ['fear2__vozvrat_v_seychas'], 'catastrophizing');
  // "Обида" (hurt/resentment, resentment tab) and "Злость" (anger, wrath tab)
  // are different problems with different practices — kept as two options.
  // NOTE: the only resentment-tab audio ("Обида") is ~10.8 min, long for a
  // first step; the screen lets the person stop any time.
  static const resentment = OnboardingConcern._(
      'resentment', 'onb_concern_resentment', ['resentment__obida'], 'resentment');
  static const anger = OnboardingConcern._(
      'anger', 'onb_concern_anger', ['wrath__ohlazhdenie_reaktora'], 'anger_iceberg');
  static const exhausted = OnboardingConcern._(
      'exhausted', 'onb_concern_exhausted', ['laziness__pravo_na_pauzu'], 'apathy_burnout');
  static const lonely = OnboardingConcern._(
      'lonely', 'onb_concern_lonely', ['loneliness__ne_sloman'], 'loneliness');
  static const relationships = OnboardingConcern._('relationships', 'onb_concern_relationships',
      ['lostness__znakomoe_pravilnoe'], 'relationship_patterns');
  static const sadness = OnboardingConcern._(
      'sadness', 'onb_concern_sadness', ['sorrow__vremya_ne_sila_voli'], 'breakup_grief');
  static const lost = OnboardingConcern._(
      'lost', 'onb_concern_lost', ['lostness__odin_moment'], 'search_for_meaning');
  static const selfDoubt = OnboardingConcern._('self_doubt', 'onb_concern_self_doubt',
      ['uncertainty__vosstanovlenie_kontura'], 'emotional_fusion');
  // The "I don't know" branch: two universal practices to choose from; the
  // screen explains that naming the problem more precisely gives a more
  // precise exercise later.
  static const unknown = OnboardingConcern._('unknown', 'onb_concern_unknown',
      ['introduction__kak_prozhivat', 'introduction__snyatie_broni'], null);

  static const List<OnboardingConcern> values = [
    anxious,
    resentment,
    anger,
    exhausted,
    lonely,
    relationships,
    sadness,
    lost,
    selfDoubt,
    unknown,
  ];

  static OnboardingConcern? fromKey(String? key) {
    for (final c in values) {
      if (c.key == key) return c;
    }
    return null;
  }
}

class OnboardingPrefs {
  static const _concernKey = 'onboarding_concern_v1';
  static const _feelingKey = 'onboarding_feeling_after_v1';
  static const _practiceDoneKey = 'onboarding_first_practice_done_v1';
  static const _startedAtKey = 'onboarding_started_at_v1';
  static const _checklistDismissedKey = 'onboarding_checklist_dismissed_v1';
  static const _nextStepDoneKey = 'onboarding_next_step_done_v1';
  static const _nextStepDismissedKey = 'onboarding_next_step_dismissed_v1';

  static Future<void> saveConcern(OnboardingConcern concern) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_concernKey, concern.key);
  }

  static Future<OnboardingConcern?> concern() async {
    final p = await SharedPreferences.getInstance();
    return OnboardingConcern.fromKey(p.getString(_concernKey));
  }

  /// 'better' | 'same' | 'worse'
  static Future<void> saveFeeling(String feeling) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_feelingKey, feeling);
  }

  static Future<void> markFirstPracticeDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_practiceDoneKey, true);
  }

  static Future<void> markNextStepDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_nextStepDoneKey, true);
  }

  static Future<void> dismissNextStep() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_nextStepDismissedKey, true);
  }

  static Future<bool> nextStepHidden() async {
    final p = await SharedPreferences.getInstance();
    return (p.getBool(_nextStepDoneKey) ?? false) || (p.getBool(_nextStepDismissedKey) ?? false);
  }

  /// Set once when the new onboarding starts. Absent for users who installed
  /// before it existed — they never see the first-steps checklist.
  static Future<void> markStarted() async {
    final p = await SharedPreferences.getInstance();
    if (!p.containsKey(_startedAtKey)) {
      await p.setString(_startedAtKey, DateTime.now().toIso8601String());
    }
  }

  static Future<DateTime?> startedAt() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_startedAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static Future<bool> firstPracticeDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_practiceDoneKey) ?? false;
  }

  static Future<bool> nextStepDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_nextStepDoneKey) ?? false;
  }

  static Future<void> dismissChecklist() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_checklistDismissedKey, true);
  }

  static Future<bool> checklistDismissed() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_checklistDismissedKey) ?? false;
  }
}
