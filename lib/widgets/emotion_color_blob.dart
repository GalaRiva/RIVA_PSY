import 'package:flutter/material.dart';

/// Premium redesign: emotions are shown as abstract color blobs instead of
/// face icons, and the same color drives the emotion's slice/bar in the
/// charts. Every negative emotion (standardEventListOne in
/// what_emotion_screen/repository.dart) has an explicit, hand-picked color
/// per the user's 2026-08-09 spec: 7 psychological families (red/purple/
/// blue/green/brown/yellow/gray), each a base hue with shades running from
/// mild discomfort to full affect. Anything not in that list (positive
/// emotions, and the neutral list's _positive/_negative-suffixed entries)
/// falls back to a color deterministically derived from its mood plus a
/// hash of its own key, so it's still visually distinct without needing a
/// hand-picked value.
enum EmotionMood { positive, negative }

// Base hue range for the positive-mood fallback (warm yellow-orange), used
// for every emotion not in _negativeSpectrum below.
const double _positiveHueStart = 30.0;
const double _positiveHueEnd = 55.0;
const double _negativeHueStart = 255.0;
const double _negativeHueEnd = 290.0;

enum _ColorFamily { red, purple, blue, green, brown, yellow, gray }

// Key -> exact hex color, per the user's spec (2026-08-09). Keys taken from
// what_emotion_screen/repository.dart's standardEventListOne, verified
// against ru-RU.json translations (not guessed from the English key names —
// e.g. 'shame'/'shame2' both translate to "Стыд", 'sorrow' -> "Грусть",
// 'sadness' -> "Печаль"). 'shame'/'shame2' (both "Стыд") and
// 'loneliness'/'abandonment' ("Одиночество (покинутость)") share one color
// each, per the spec grouping them as a single row.
const Map<String, Color> _negativeSpectrum = {
  // Красный спектр: Гнев и Агрессия
  'hate': Color(0xFF4A0404), // Ненависть
  'anger_rage': Color(0xFF8A0303), // Гнев (ярость)
  'cruelty': Color(0xFF901E1E), // Ожесточенность
  'outrage2': Color(0xFFB22222), // Негодование
  'wrath': Color(0xFFFF0000), // Злость
  'outrage': Color(0xFFFF2400), // Возмущение
  'irritation': Color(0xFFFF4500), // Раздражение

  // Фиолетовый спектр: Страх и Тревога
  'horror': Color(0xFF1A0022), // Ужас
  'desperation': Color(0xFF36013F), // Отчаяние
  'fear2': Color(0xFF4B0082), // Страх
  'fear': Color(0xFF9966CC), // Испуг
  'agitation': Color(0xFF8A2BE2), // Взвинченность
  'confusion2': Color(0xFF775C7A), // Смятение
  'anxiety': Color(0xFFC8A2C8), // Тревога
  'apprehension': Color(0xFFB19CD9), // Опасение
  'worry': Color(0xFFE6E6FA), // Беспокойство

  // Синий спектр: Печаль и Горе
  'grief': Color(0xFF191970), // Скорбь
  'melancholy': Color(0xFF00008B), // Тоска
  'bitterness': Color(0xFF4682B4), // Горечь
  'sadness': Color(0xFF4169E1), // Печаль
  'desolation': Color(0xFF778899), // Уныние
  'melancholia': Color(0xFF5F9EA0), // Меланхолия
  'sorrow': Color(0xFFB0C4DE), // Грусть
  'disgust_disappointment': Color(0xFF87CEEB), // Огорчение
  'pity': Color(0xFF6495ED), // Жалость

  // Зеленый спектр: Отвращение, Зависть и Неприятие
  'disgust': Color(0xFF556B2F), // Отвращение
  'contempt': Color(0xFF008B8B), // Презрение
  'antipathy': Color(0xFF808000), // Неприязнь
  'repulsion': Color(0xFFBDB76B), // Отторжение
  'envy': Color(0xFF7FFF00), // Зависть
  'jealousy': Color(0xFF32CD32), // Ревность

  // Коричневый спектр: Социальная боль, Стыд и Обида
  'humiliation': Color(0xFF654321), // Унижение
  'guilt': Color(0xFF5C4033), // Вина
  'shame2': Color(0xFF8A3324), // Стыд
  'shame': Color(0xFF8A3324), // Стыд (duplicate translation key)
  'regret': Color(0xFF635147), // Раскаяние
  'resentment': Color(0xFFB87333), // Обида
  'vulnerability': Color(0xFFE2725B), // Уязвленность
  'shyness': Color(0xFFD2B48C), // Застенчивость

  // Желто-охристый спектр: Сомнения, Хаос и Суета
  'suspicion': Color(0xFFDAA520), // Подозрение
  'distrust': Color(0xFFF0E68C), // Недоверие
  'confusion': Color(0xFFCC7722), // Недоумение
  'annoyance': Color(0xFFFF8C00), // Досада
  'bewilderment': Color(0xFFBDB76B), // Замешательство
  'busyness': Color(0xFFFFF700), // Суета
  'disappointment': Color(0xFFE4D96F), // Разочарование
  'regret2': Color(0xFFB8860B), // Сожаление
  'disheartenment': Color(0xFFF4A460), // Обескураженность
  'bewilderment2': Color(0xFFFAFAD2), // Растерянность
  'uncertainty': Color(0xFFFFFDD0), // Неуверенность

  // Серый спектр: Апатия, Истощение и Изоляция
  'prostration': Color(0xFF2F4F4F), // Прострация
  'doom': Color(0xFF36454F), // Обреченность
  'powerlessness': Color(0xFF696969), // Бессилие
  'apathy': Color(0xFF808080), // Апатия
  'detachment': Color(0xFFA9A9A9), // Отрешенность
  'lostness': Color(0xFFBEBEBE), // Потерянность
  'loneliness': Color(0xFFD3D3D3), // Одиночество (покинутость)
  'abandonment': Color(0xFFD3D3D3), // Покинутость (duplicate row)
  'laziness': Color(0xFFC0C0C0), // Лень
  'helplessness': Color(0xFFE5E4E2), // Беспомощность
  'unworthiness': Color(0xFFF5F5F5), // Ненужность
};

// Which of the 7 families each key belongs to, for grouping/sorting on the
// selection screen — matches the order the user listed the families in.
final Map<String, _ColorFamily> _keyFamily = {
  for (final k in [
    'hate', 'anger_rage', 'cruelty', 'outrage2', 'wrath', 'outrage', 'irritation'
  ]) k: _ColorFamily.red,
  for (final k in [
    'horror', 'desperation', 'fear2', 'fear', 'agitation', 'confusion2',
    'anxiety', 'apprehension', 'worry'
  ]) k: _ColorFamily.purple,
  for (final k in [
    'grief', 'melancholy', 'bitterness', 'sadness', 'desolation',
    'melancholia', 'sorrow', 'disgust_disappointment', 'pity'
  ]) k: _ColorFamily.blue,
  for (final k in [
    'disgust', 'contempt', 'antipathy', 'repulsion', 'envy', 'jealousy'
  ]) k: _ColorFamily.green,
  for (final k in [
    'humiliation', 'guilt', 'shame2', 'shame', 'regret', 'resentment',
    'vulnerability', 'shyness'
  ]) k: _ColorFamily.brown,
  for (final k in [
    'suspicion', 'distrust', 'confusion', 'annoyance', 'bewilderment',
    'busyness', 'disappointment', 'regret2', 'disheartenment',
    'bewilderment2', 'uncertainty'
  ]) k: _ColorFamily.yellow,
  for (final k in [
    'prostration', 'doom', 'powerlessness', 'apathy', 'detachment',
    'lostness', 'loneliness', 'abandonment', 'laziness', 'helplessness',
    'unworthiness'
  ]) k: _ColorFamily.gray,
};

int _hash(String key) =>
    key.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);

/// Sort key for grouping emotions by color family on the selection screen.
/// Keys with an explicit family (the negative spectrum above) sort together
/// by family in the order the user specified (red, purple, blue, green,
/// brown, yellow, gray); everything else (no override — colored by the
/// generic mood hash) sorts after all of them, keeping its original
/// relative order.
int emotionFamilySortKey(String key) =>
    _keyFamily[key]?.index ?? _ColorFamily.values.length;

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

/// The exact spec color for a negative-spectrum emotion, or null if this key
/// isn't one of them (positive emotions, neutral +/- entries, custom
/// user-added emotions).
Color? emotionSpectrumColor(String key) => _negativeSpectrum[key];

Color emotionBlobColor(String key, EmotionMood mood) {
  final exact = _negativeSpectrum[key];
  if (exact != null) return exact;

  final hash = _hash(key);
  final hueStart =
      mood == EmotionMood.positive ? _positiveHueStart : _negativeHueStart;
  final hueEnd =
      mood == EmotionMood.positive ? _positiveHueEnd : _negativeHueEnd;
  final hue = hueStart + (hash % 1000) / 1000 * (hueEnd - hueStart);
  return HSLColor.fromAHSL(1, hue, 0.65, 0.62).toColor();
}
