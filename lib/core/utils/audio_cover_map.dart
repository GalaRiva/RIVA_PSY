import 'package:flutter/widgets.dart';

import '../../widgets/animated_meditation_cover.dart';

// Maps a track's Russian title (Audio.name in Firestore — stable across
// locales, unlike the already-localized display title) to a bundled cover
// asset. Tracks with no entry here render a generated accent-color card
// instead of crashing/blanking — see HeroAudioCarousel's fallback cover.
const Map<String, String> audioCoverAssets = {
  'Апатия': 'assets/images/audio_covers/apathy.jpg',
  'Архитектура тревоги': 'assets/images/audio_covers/anxiety_architecture.jpg',
  'Аффект 1': 'assets/images/audio_covers/affect_1.jpg',
  'Аффект 2': 'assets/images/audio_covers/affect_2.jpg',
  'Вина': 'assets/images/audio_covers/guilt.jpg',
  'Зависть': 'assets/images/audio_covers/envy.jpg',
  'Лев': 'assets/images/audio_covers/angry_lion.jpg',
  'Злость': 'assets/images/audio_covers/anger.jpg',
  'Неуверенность': 'assets/images/audio_covers/uncertainty.jpg',
  'Неуверенность1': 'assets/images/audio_covers/uncertainty_2.jpg',
  'Обида': 'assets/images/audio_covers/resentment.jpg',
  'Обреченность': 'assets/images/audio_covers/doom.jpg',
  'Одиночество': 'assets/images/audio_covers/loneliness.jpg',
  'Паника 1': 'assets/images/audio_covers/panic_1.jpg',
  'Паника 2': 'assets/images/audio_covers/panic_2.jpg',
  'Печаль': 'assets/images/audio_covers/sadness2.jpg',
  'Поговорим': 'assets/images/audio_covers/lets_talk.jpg',
  'Поезд страхов': 'assets/images/audio_covers/train_of_fears.jpg',
  'Реалистичная надежда': 'assets/images/audio_covers/realistic_hope.jpg',
  'Рисуя грусть': 'assets/images/audio_covers/drawing_sadness.jpg',
  'Рюкзак с виной': 'assets/images/audio_covers/backpack_of_guilt.jpg',
  'Скорбь': 'assets/images/audio_covers/grief.jpg',
  'Страх Арт': 'assets/images/audio_covers/fear_art.jpg',
  'Страх': 'assets/images/audio_covers/fear.jpg',
  'Тень грусти': 'assets/images/audio_covers/shadow_of_sadness.jpg',
  'Хорошее для себя': 'assets/images/audio_covers/good_for_myself.jpg',
  'Чувство вины': 'assets/images/audio_covers/sense_of_guilt.jpg',
  'Шторм гнева': 'assets/images/audio_covers/storm_of_anger.jpg',
  // "Портрет" tracks (see PROJECT_CONTEXT.md §63) — covers matched by their
  // Firestore Audio.name field, not by the source image filenames (one of
  // the 7 source files was named "Тормоз Прокрастинация.png", confirmed
  // against the live Firestore doc to be the cover for "Право на паузу").
  'Снятие брони': 'assets/images/audio_covers/removing_armor.jpg',
  'Право на паузу': 'assets/images/audio_covers/right_to_pause.jpg',
  'Охлаждение реактора': 'assets/images/audio_covers/reactor_cooling.jpg',
  'Восстановление контура': 'assets/images/audio_covers/contour_restoration.jpg',
  'Снятие обвинений': 'assets/images/audio_covers/dropping_charges.jpg',
  'Возврат в сейчас': 'assets/images/audio_covers/return_to_present.jpg',
  'Сброс кэша': 'assets/images/audio_covers/cache_reset.jpg',
  // The actual Midjourney art for this meditation (same image the welcome
  // quiz's own MeditationPlayerScreen uses as its background) — preferred
  // by the user over the generated HeartCongruenceCover animation.
  'Конгруэнтность сердца': 'assets/images/quiz/love.jpg',
  // "Депрессия" tracks — assigned by mood/theme match against a batch of
  // 27 abstract art pieces the user provided (2026-09-15), not by any
  // source filename (all were generic Midjourney export names with no
  // connection to a specific track).
  'Ангедония': 'assets/images/audio_covers/depr_anhedonia.jpg',
  'Вернуть вкусы': 'assets/images/audio_covers/depr_bring_back_tastes.jpg',
  'Симптомы послеродовой депрессии': 'assets/images/audio_covers/depr_postpartum_symptoms.jpg',
  'Рациональные убеждения': 'assets/images/audio_covers/depr_rational_beliefs.jpg',
  'Ценности': 'assets/images/audio_covers/depr_values.jpg',
  // NOTE: 'Введение' is not unique — both the depression tab
  // (depression__vvedenie) and the introduction tab (introduction__vvedenie)
  // have a track with this exact name, and this map is keyed by name alone
  // (not name+tab), so they're stuck sharing one cover. Picked a fairly
  // neutral "beginning" image that works reasonably for both rather than
  // rearchitecting AudioCardModel/audioCoverAsset to also take a tab.
  'Введение': 'assets/images/audio_covers/intro_beginning.jpg',
  'Бессонница': 'assets/images/audio_covers/depr_insomnia.jpg',
  'Отмена антидепрессантов': 'assets/images/audio_covers/depr_stopping_antidepressants.jpg',
  'Мысли иррациональные': 'assets/images/audio_covers/depr_irrational_thoughts.jpg',
  'Иррациональные убеждения': 'assets/images/audio_covers/depr_irrational_beliefs.jpg',
  'Симптомы депрессии': 'assets/images/audio_covers/depr_symptoms.jpg',
  'Самооценка и самоценность': 'assets/images/audio_covers/depr_self_esteem.jpg',
  'Рекомендации физическая сфера': 'assets/images/audio_covers/depr_physiological_recommendations.jpg',
  'Причины депрессии (нейробиологические и социальные)': 'assets/images/audio_covers/depr_causes.jpg',
  'Рекомендации психологическая сфера': 'assets/images/audio_covers/depr_psychological_recommendations.jpg',
  'Реактивная депрессия': 'assets/images/audio_covers/depr_reactive.jpg',
  'Помощь близкому в депрессии': 'assets/images/audio_covers/depr_helping_loved_one.jpg',
  'Послеродовая депрессия': 'assets/images/audio_covers/depr_postpartum.jpg',
  'Гнев во время депрессии': 'assets/images/audio_covers/depr_anger.jpg',
  'Заблуждения о депрессии': 'assets/images/audio_covers/depr_misconceptions.jpg',
  'Чувство ненужности в послеродовой депрессии': 'assets/images/audio_covers/depr_postpartum_uselessness.jpg',
  'Утро': 'assets/images/audio_covers/depr_morning.jpg',
  'Эмоции при отмене антидепрессантов': 'assets/images/audio_covers/depr_withdrawal_emotions.jpg',
  'Дни просветления': 'assets/images/audio_covers/depr_days_of_clarity.jpg',
  'Злость на ребенка при послеродовой депрессии': 'assets/images/audio_covers/depr_postpartum_anger_at_child.jpg',
  'Кататония': 'assets/images/audio_covers/depr_catatonia.jpg',
  // "Введение" tab tracks, plus a few strays from other tabs that also had
  // no cover — same source batch as above (2026-09-15), different folder.
  'Адаптируй': 'assets/images/audio_covers/intro_adapt.jpg',
  'Физиология': 'assets/images/audio_covers/intro_physiology.jpg',
  'Как проживать?': 'assets/images/audio_covers/intro_how_to_live_through.jpg',
  'Мыльный пузырь': 'assets/images/audio_covers/intro_soap_bubble.jpg',
  'Шевелимся': 'assets/images/audio_covers/intro_lets_move.jpg',
  'Универсальный Арт': 'assets/images/audio_covers/intro_universal_art.jpg',
  'Поговорим?': 'assets/images/audio_covers/loneliness_lets_talk_q.jpg',
  'Дыхание': 'assets/images/audio_covers/meditation_breathing.jpg',
  'Расслабление зажимов': 'assets/images/audio_covers/meditation_releasing_tension.jpg',
  'Регулятор громкости': 'assets/images/audio_covers/panic_volume_regulator.jpg',
};

String? audioCoverAsset(String? ruTitle) {
  if (ruTitle == null) return null;
  return audioCoverAssets[ruTitle.trim()];
}

// Covers rendered as live, animated Flutter art instead of a bundled image
// — same lookup pattern as audioCoverAssets above.
final Map<String, WidgetBuilder> animatedAudioCovers = {
  'Сердце': (context) => const HeartCongruenceCover(),
};

WidgetBuilder? animatedAudioCoverBuilder(String? ruTitle) {
  if (ruTitle == null) return null;
  return animatedAudioCovers[ruTitle.trim()];
}
