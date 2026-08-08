import 'package:flutter/material.dart';

/// Premium redesign: emotions are shown as abstract color blobs instead of
/// face icons (141 individual emotions in the data — see
/// what_emotion_screen/repository.dart — far too many to hand-pick a color
/// per emotion without real design input for most of them). A specific
/// subset the user explicitly grouped by feeling family gets its own hue
/// family below (_familyOverrides); everything else falls back to a color
/// deterministically derived from its mood (positive/negative) plus a hash
/// of its own key, so different emotions within the same mood are still
/// visually distinct from each other, not all identical.
enum EmotionMood { positive, negative }

// Base hue ranges per mood, per the spec's own examples (joy: warm
// yellow-orange, anxiety: purple-blue) — used for every emotion not in
// _familyOverrides below.
const double _positiveHueStart = 30.0;
const double _positiveHueEnd = 55.0;
const double _negativeHueStart = 255.0;
const double _negativeHueEnd = 290.0;

enum _ColorFamily { red, green, black, blue, brown, gray }

// User-specified groupings (2026-08-07): "Оттенки красного для Гнев
// (ярость), Ненависть, Злость, возмущение, раздражение..." — keys taken
// from what_emotion_screen/repository.dart, verified against the actual
// ru-RU.json translations rather than guessed from the English key names
// (sorrow -> "Грусть", sadness -> "Печаль" — the reverse of what the key
// names alone would suggest).
const Map<String, _ColorFamily> _familyOverrides = {
  // Красный: Гнев (ярость), Ненависть, Злость, возмущение, раздражение.
  'anger_rage': _ColorFamily.red,
  'hate': _ColorFamily.red,
  'wrath': _ColorFamily.red,
  'irritation': _ColorFamily.red,
  'outrage': _ColorFamily.red,
  // Зелёный: Ревность, Уязвленность, Досада, Зависть, Неприязнь, Отвращение.
  'jealousy': _ColorFamily.green,
  'vulnerability': _ColorFamily.green,
  'annoyance': _ColorFamily.green,
  'envy': _ColorFamily.green,
  'antipathy': _ColorFamily.green,
  'disgust': _ColorFamily.green,
  // Чёрный: Горечь, Скорбь.
  'bitterness': _ColorFamily.black,
  'grief': _ColorFamily.black,
  // Синий: Грусть, Печаль, Тоска.
  'sorrow': _ColorFamily.blue, // "Грусть"
  'sadness': _ColorFamily.blue, // "Печаль"
  'melancholy': _ColorFamily.blue, // "Тоска"
  // Коричневый: Стыд, Застенчивость, Разочарование, Неуверенность.
  'shame': _ColorFamily.brown,
  'shame2': _ColorFamily.brown, // also "Стыд" — duplicate translation key
  'shyness': _ColorFamily.brown,
  'disappointment': _ColorFamily.brown,
  'uncertainty': _ColorFamily.brown,
  // Серые: Апатия, Уныние, Меланхолия, Отрешенность.
  'apathy': _ColorFamily.gray,
  'desolation': _ColorFamily.gray, // "Уныние"
  'melancholia': _ColorFamily.gray, // "Меланхолия"
  'detachment': _ColorFamily.gray,
};

int _hash(String key) =>
    key.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);

/// Sort key for grouping emotions by color family (2026-08-07: "сгруппировать
/// негативные эмоции по цвету: коричневые вместе, красные вместе..."). Keys
/// with an explicit family override sort together by family, in a stable
/// order; everything else (no override — colored by the generic mood hash)
/// sorts after all of them, keeping its original relative order.
int emotionFamilySortKey(String key) =>
    _familyOverrides[key]?.index ?? _ColorFamily.values.length;

/// Individual _positive/_negative (and the shorter _+/_-) suffix used by
/// what_emotion_screen/repository.dart's "neutral" list (e.g.
/// 'doubt_positive', 'curiosity_+') encodes its own mood regardless of
/// which screen/category batch it's being displayed in. Keys without that
/// suffix (the plain negative/positive lists — 'anger_rage', 'joy', ...)
/// don't self-encode a mood, so `categoryFallback` (the EmotionInDayEvent
/// category the whole batch was fetched under) is used instead.
EmotionMood moodForKey(String key, EmotionMood categoryFallback) {
  if (key.endsWith('_positive') || key.endsWith('_+')) return EmotionMood.positive;
  if (key.endsWith('_negative') || key.endsWith('_-')) return EmotionMood.negative;
  return categoryFallback;
}

Color emotionBlobColor(String key, EmotionMood mood) {
  final family = _familyOverrides[key];
  final hash = _hash(key);
  if (family != null) {
    switch (family) {
      case _ColorFamily.red:
        return HSLColor.fromAHSL(1, 0 + (hash % 1000) / 1000 * 12, 0.68, 0.55)
            .toColor();
      case _ColorFamily.green:
        return HSLColor.fromAHSL(
                1, 115 + (hash % 1000) / 1000 * 25, 0.5, 0.5)
            .toColor();
      case _ColorFamily.black:
        // Not a hue family — a near-black neutral, slight lightness jitter
        // so the two emotions in it aren't pixel-identical.
        final lightness = 0.12 + (hash % 1000) / 1000 * 0.08;
        return HSLColor.fromAHSL(1, 0, 0, lightness).toColor();
      case _ColorFamily.blue:
        return HSLColor.fromAHSL(
                1, 205 + (hash % 1000) / 1000 * 25, 0.55, 0.52)
            .toColor();
      case _ColorFamily.brown:
        return HSLColor.fromAHSL(
                1, 25 + (hash % 1000) / 1000 * 15, 0.45, 0.38)
            .toColor();
      case _ColorFamily.gray:
        final lightness = 0.45 + (hash % 1000) / 1000 * 0.15;
        return HSLColor.fromAHSL(1, 0, 0, lightness).toColor();
    }
  }
  final hueStart =
      mood == EmotionMood.positive ? _positiveHueStart : _negativeHueStart;
  final hueEnd =
      mood == EmotionMood.positive ? _positiveHueEnd : _negativeHueEnd;
  final hue = hueStart + (hash % 1000) / 1000 * (hueEnd - hueStart);
  return HSLColor.fromAHSL(1, hue, 0.65, 0.62).toColor();
}
