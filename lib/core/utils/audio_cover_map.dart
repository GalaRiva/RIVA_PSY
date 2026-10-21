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
  // New "Справиться с эмоцией" tracks added alongside the 6 new Guided
  // Journals topics (2026-09-15) — linked to breakup_grief/search_for_meaning/
  // relationship_patterns/loneliness. The breakup RU file was originally a
  // byte-identical duplicate of the loneliness RU file (real bug, caught via
  // MD5); user re-recorded/replaced it, both tracks confirmed distinct now.
  'Время, не сила воли': 'assets/images/audio_covers/sorrow_time_not_willpower.jpg',
  'Один момент': 'assets/images/audio_covers/lostness_one_moment.jpg',
  'Знакомое — не значит правильное': 'assets/images/audio_covers/lostness_familiar_patterns.jpg',
  'Не сломан(а)': 'assets/images/audio_covers/loneliness_not_broken.jpg',
  // Tracks 8-14 added 2026-10-07 (lostness / guilt / disgust
  // tabs) — covers assigned by mood match against 7 Midjourney abstracts.
  'Возвращение контакта': 'assets/images/audio_covers/lostness_returning_contact.jpg',
  'Право на бессилие': 'assets/images/audio_covers/lostness_right_to_powerlessness.jpg',
  'Опора в невесомости': 'assets/images/audio_covers/lostness_support_in_weightlessness.jpg',
  'Открытая дверь': 'assets/images/audio_covers/guilt_open_door.jpg',
  'Открытое пространство': 'assets/images/audio_covers/lostness_open_space.jpg',
  'Анатомия границы': 'assets/images/audio_covers/disgust_anatomy_of_boundary.jpg',
  'Свет сквозь тень': 'assets/images/audio_covers/disgust_light_through_shadow.jpg',
  // Course "Еда без автопилота" (2026-10-18) — covers from the blog art set.
  'Что происходит перед перееданием': 'assets/images/audio_covers/program_eating_s1_chain.jpg',
  'Выйти из цикла ограничений': 'assets/images/audio_covers/program_eating_s2_cycle.jpg',
  'Голод, эмоция или импульс': 'assets/images/audio_covers/program_eating_s3_signals.jpg',
  'Пережить импульс': 'assets/images/audio_covers/program_eating_s4_urge_wave.jpg',
  'Справиться с эмоцией иначе': 'assets/images/audio_covers/program_eating_s5_emotion.jpg',
  'Это шаг заботы о себе': 'assets/images/audio_covers/program_eating_s6_care.jpg',
  'План на трудные ситуации': 'assets/images/audio_covers/program_eating_s7_plan.jpg',
  'Устойчивое отношение к еде и себе': 'assets/images/audio_covers/program_eating_s8_resilience.jpg',
  // Course "Вернуться к себе" (2026-10-21) — covers from the blog art set.
  'Острая волна': 'assets/images/audio_covers/program_return_wave.jpg',
  'Место для потери': 'assets/images/audio_covers/program_return_loss.jpg',
  'Ночные мысли': 'assets/images/audio_covers/program_return_night.jpg',
  'После срыва': 'assets/images/audio_covers/program_return_slip.jpg',
  'Трудный вечер': 'assets/images/audio_covers/program_return_evening.jpg',
  'Когда меня тянет к нему или к ней': 'assets/images/audio_covers/program_return_urge.jpg',
  'Разорвать круг навязчивых мыслей': 'assets/images/audio_covers/program_return_thoughts.jpg',
  'Вернуть себе собственную ценность': 'assets/images/audio_covers/program_return_worth.jpg',
  'Принятие своих неудобных черт': 'assets/images/audio_covers/program_return_traits.jpg',
  'Сострадательное «я»': 'assets/images/audio_covers/program_return_compassion.jpg',
  'Отпустить контроль и вернуть границы': 'assets/images/audio_covers/program_return_control.jpg',
  'Моя жизнь больше этих отношений': 'assets/images/audio_covers/program_return_life.jpg',
  'Когда видеться неизбежно': 'assets/images/audio_covers/program_return_meeting.jpg',
  'Ревность и сравнение': 'assets/images/audio_covers/program_return_jealousy.jpg',
  'Новая близость': 'assets/images/audio_covers/program_return_intimacy.jpg',
  'Сказать прямо': 'assets/images/audio_covers/program_return_direct.jpg',
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

// Wide, dark version of a program step's cover (picture on the right, room
// for white text on the left). Only the course audios have one
// (assets/images/step_covers/, same file names as audio_covers); anything
// else falls back to the square cover.
String? wideStepCover(String? audioCover) {
  if (audioCover == null) return null;
  final name = audioCover.split('/').last;
  if (!name.startsWith('program_')) return audioCover;
  return 'assets/images/step_covers/$name';
}
