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
};

String? audioCoverAsset(String? ruTitle) {
  if (ruTitle == null) return null;
  return audioCoverAssets[ruTitle.trim()];
}

// Covers rendered as live, animated Flutter art instead of a bundled image
// — same lookup pattern as audioCoverAssets above.
final Map<String, WidgetBuilder> animatedAudioCovers = {
  'Сердце': (context) => const HeartCongruenceCover(),
  // Actual Firestore Audio.name for the meditation-tab track (confirmed via
  // a live query) — 'Сердце' above is kept in case another doc uses it.
  'Конгруэнтность сердца': (context) => const HeartCongruenceCover(),
};

WidgetBuilder? animatedAudioCoverBuilder(String? ruTitle) {
  if (ruTitle == null) return null;
  return animatedAudioCovers[ruTitle.trim()];
}
