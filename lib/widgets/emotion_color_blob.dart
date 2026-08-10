import 'package:flutter/material.dart';

/// Premium redesign: emotions are shown as abstract color blobs instead of
/// face icons, and the same color drives the emotion's slice/bar in the
/// charts. Every negative, positive, and neutral emotion (all three lists
/// in what_emotion_screen/repository.dart) has an explicit, hand-picked
/// color per the user's spec (negative: 2026-08-09, positive/neutral:
/// 2026-08-10): each is grouped into psychological families sharing a base
/// hue, with shades running from mild to full intensity. Anything not in
/// these lists (custom user-added emotions) falls back to a color
/// deterministically derived from its mood plus a hash of its own key, so
/// it's still visually distinct without needing a hand-picked value.
enum EmotionMood { positive, negative }

// Base hue range for the positive-mood fallback (warm yellow-orange), used
// for every emotion not in any of the spectrum maps below.
const double _positiveHueStart = 30.0;
const double _positiveHueEnd = 55.0;
const double _negativeHueStart = 255.0;
const double _negativeHueEnd = 290.0;

// Order matches the user's 2026-08-10 listing (Гнев, Отвращение, Страх,
// Стыд, Сомнения, Печаль, Апатия), which drives the selection-screen sort.
enum _NegativeColorFamily { red, green, purple, brown, yellow, blue, gray }

enum _PositiveColorFamily {
  yellowOrange,
  pinkPeach,
  emeraldGreen,
  blueOcean,
  lilacPurple,
  turquoiseCyan,
  goldBronze,
}

// Key -> exact hex color, per the user's revised spec (2026-08-10): muted,
// dark, "dusty"/earthy tones across the board (no bright/neon negative
// colors) so positives read as visually "glowing" by contrast against them.
// This also reshuffled which family several emotions belong to relative to
// the original 2026-08-09 spec (e.g. 'resentment'/'vulnerability' moved from
// brown into red; 'annoyance' moved from yellow into brown; 'uncertainty'
// and 'disgust_disappointment' moved into gray) — see _negativeKeyFamily
// below, which mirrors this new grouping. Keys verified against ru-RU.json
// translations, not guessed from the English key names. 'shame'/'shame2'
// (both "Стыд") and 'loneliness'/'abandonment' ("Одиночество (покинутость)")
// share one color each, per the spec grouping them as a single row.
const Map<String, Color> _negativeSpectrum = {
  // Гнев, Агрессия, Обида
  'anger_rage': Color(0xFF8B0000), // Гнев (ярость)
  'hate': Color(0xFF4A0000), // Ненависть
  'wrath': Color(0xFFB22222), // Злость
  'irritation': Color(0xFFA52A2A), // Раздражение
  'outrage2': Color(0xFF800000), // Негодование
  'cruelty': Color(0xFF5C1D1D), // Ожесточенность
  'outrage': Color(0xFFC04000), // Возмущение
  'vulnerability': Color(0xFF9E4747), // Уязвленность
  'resentment': Color(0xFF7B3F00), // Обида

  // Отвращение, Зависть, Отторжение
  'disgust': Color(0xFF354A21), // Отвращение
  'contempt': Color(0xFF1F4A4A), // Презрение
  'antipathy': Color(0xFF4A5320), // Неприязнь
  'repulsion': Color(0xFF2D3A27), // Отторжение
  'envy': Color(0xFF3B5323), // Зависть
  'jealousy': Color(0xFF2E4623), // Ревность

  // Страх, Тревога, Аффект
  'horror': Color(0xFF1A0A2A), // Ужас
  'desperation': Color(0xFF2D0A31), // Отчаяние
  'fear2': Color(0xFF3D1C55), // Страх
  'fear': Color(0xFF522B78), // Испуг
  'agitation': Color(0xFF5B2C6F), // Взвинченность
  'confusion2': Color(0xFF4A3B52), // Смятение
  'anxiety': Color(0xFF5E4B6B), // Тревога
  'apprehension': Color(0xFF6C5B7B), // Опасение
  'worry': Color(0xFF50405B), // Беспокойство

  // Стыд, Вина, Унижение
  'humiliation': Color(0xFF4A2E1B), // Унижение
  'guilt': Color(0xFF3D2817), // Вина
  'shame2': Color(0xFF6E3B3B), // Стыд
  'shame': Color(0xFF6E3B3B), // Стыд (duplicate translation key)
  'regret': Color(0xFF524035), // Раскаяние
  'annoyance': Color(0xFF7A4B1B), // Досада
  'shyness': Color(0xFF8C6D6D), // Застенчивость

  // Сомнения, Суета, Недоумение
  'suspicion': Color(0xFF6E5812), // Подозрение
  'distrust': Color(0xFF5C4D18), // Недоверие
  'confusion': Color(0xFF7A5217), // Недоумение
  'busyness': Color(0xFF6B6000), // Суета
  'disappointment': Color(0xFF665328), // Разочарование
  'regret2': Color(0xFF5E4B1D), // Сожаление
  'disheartenment': Color(0xFF735636), // Обескураженность
  'bewilderment2': Color(0xFF61513D), // Растерянность
  'bewilderment': Color(0xFF594F3B), // Замешательство

  // Печаль, Тоска, Скорбь
  'grief': Color(0xFF0B132B), // Скорбь
  'melancholy': Color(0xFF1C2541), // Тоска
  'bitterness': Color(0xFF2A4365), // Горечь
  'sadness': Color(0xFF1E3A8A), // Печаль
  'sorrow': Color(0xFF335C67), // Грусть
  'desolation': Color(0xFF344E41), // Уныние
  'melancholia': Color(0xFF2C3E50), // Меланхолия
  'pity': Color(0xFF4A6572), // Жалость

  // Апатия, Изоляция, Бессилие
  'prostration': Color(0xFF1F2937), // Прострация
  'doom': Color(0xFF2B2D42), // Обреченность
  'powerlessness': Color(0xFF374151), // Бессилие
  'apathy': Color(0xFF4B5563), // Апатия
  'detachment': Color(0xFF6B7280), // Отрешенность
  'lostness': Color(0xFF525252), // Потерянность
  'loneliness': Color(0xFF3F4E4F), // Одиночество (покинутость)
  'abandonment': Color(0xFF3F4E4F), // Покинутость (duplicate row)
  'laziness': Color(0xFF555B6E), // Лень
  'helplessness': Color(0xFF6C757D), // Беспомощность
  'unworthiness': Color(0xFF495057), // Ненужность
  'uncertainty': Color(0xFF5A6B7C), // Неуверенность
  'disgust_disappointment': Color(0xFF4C5C68), // Огорчение
};

// Key -> exact hex color, per the user's spec (2026-08-10). Keys taken from
// what_emotion_screen/repository.dart's standardEventListTwo. A few names in
// the spec don't literally match the English key names (e.g. 'acceptance2'
// -> "Принятие", 'acceptance' -> "Приятие"; 'inspiration2' -> "Вдохновение",
// 'inspiration' -> "Воодушевление"; 'anticipation2' -> "Предвкушение",
// 'anticipation' -> "Ожидание") — verified against ru-RU.json, not guessed.
// The spec's "Нежность" has no corresponding key in the repo (only
// 'tenderness' -> "Умиление" exists), so that row has no target and is
// omitted; 'reliability' ("Надежность") isn't in the spec, so it keeps the
// generic hash-based fallback color.
const Map<String, Color> _positiveSpectrum = {
  // Желто-оранжевый спектр: Радость, Энергия и Жизнелюбие
  'euphoria': Color(0xFFFDFF00), // Эйфория
  'joy2': Color(0xFFFFD922), // Ликование
  'delight': Color(0xFFF9A602), // Восторг
  'happiness': Color(0xFFFFB84D), // Счастье
  'joy': Color(0xFFFFEA00), // Радость
  'enthusiasm': Color(0xFFFF9933), // Энтузиазм
  'zeal': Color(0xFFFFAE42), // Задор
  'vitality': Color(0xFFF8D568), // Бодрость
  'animation': Color(0xFFFFCBA4), // Оживление
  'elevation': Color(0xFFFBE7A1), // Приподнятость

  // Розово-персиковый спектр: Любовь, Близость и Тепло
  'love': Color(0xFFF64A8A), // Любовь
  'infatuation': Color(0xFFFF3399), // Влюбленность
  'self-love': Color(0xFFF4A4C8), // Любовь к себе
  'tenderness': Color(0xFFFCEEEB), // Умиление
  'care': Color(0xFFFAD6A5), // Забота
  'sympathy': Color(0xFFF9C8D3), // Симпатия
  'friendliness': Color(0xFFFFB380), // Дружелюбие
  'kindness': Color(0xFFF8B8C8), // Доброта

  // Изумрудно-травяной спектр: Гармония, Баланс и Принятие
  'harmony': Color(0xFF40E0AF), // Гармония
  'liberation': Color(0xFF54FF9F), // Освобождение
  'acceptance2': Color(0xFF98FB98), // Принятие
  'acceptance': Color(0xFFB4EEB4), // Приятие
  'pacification': Color(0xFFA3E4D7), // Умиротворение
  'tranquility': Color(0xFFC1E1C1), // Спокойствие
  'humility': Color(0xFFD3ECA7), // Смирение

  // Сине-голубой спектр: Доверие, Духовность и Глубина
  'bliss': Color(0xFF00BFFF), // Блаженство
  'pleasure': Color(0xFF48D1CC), // Наслаждение
  'faith': Color(0xFF1CA9C9), // Вера
  'trust': Color(0xFF6CB4EE), // Доверие
  'hope': Color(0xFFB0E0E6), // Надежда

  // Сиренево-фиолетовый спектр: Уважение, Вдохновение и Возвышенность
  'reverence': Color(0xFF6A0DAD), // Благоговение
  'admiration': Color(0xFF9B30FF), // Восхищение
  'respect': Color(0xFF8F00FF), // Уважение
  'inspiration2': Color(0xFFC3B1E1), // Вдохновение
  'inspiration': Color(0xFFE0B0FF), // Воодушевление
  'enchantment': Color(0xFFF4E2FF), // Очарованность
  'gratitude': Color(0xFFDDA0DD), // Благодарность
  'gratitude2': Color(0xFFDCD0FF), // Признательность

  // Бирюзово-циановый спектр: Интерес, Свежесть и Предвкушение
  'excitement': Color(0xFF08E8DE), // Возбуждение
  'anticipation2': Color(0xFF48CCCD), // Предвкушение
  'anticipation': Color(0xFF7DF9FF), // Ожидание
  'interest': Color(0xFFE0F7FA), // Интерес

  // Золотисто-бронзовый спектр: Достоинство, Опора и Самобытность
  'self-worth': Color(0xFFE5A91E), // Самоценность
  'identity': Color(0xFFFFC82A), // Идентичность
  'pride': Color(0xFFD99058), // Гордость
  'patriotism': Color(0xFFCB6D51), // Патриотизм
};

// Neutral list (what_emotion_screen/repository.dart's standardEventListThree)
// pairs each concept as <key>_positive/<key>_negative (or the shorter _+/_-
// suffix). Per the user's spec (2026-08-10), each pair gets its own two
// colors — one per polarity — rather than a shared family hue.
const Map<String, Color> _neutralSpectrum = {
  'doubt_negative': Color(0xFF78725B), // Сомнение (-)
  'doubt_positive': Color(0xFFFCECA4), // Сомнение (+)
  'surprise_negative': Color(0xFF004B49), // Удивление (-)
  'surprise_positive': Color(0xFF00FFFF), // Удивление (+)
  'indifference_negative': Color(0xFF4D4D4D), // Равнодушие (-)
  'indifference_positive': Color(0xFFE6E8FA), // Равнодушие (+)
  'excitement_negative': Color(0xFF8A3300), // Азарт (-)
  'excitement_positive': Color(0xFFFF6600), // Азарт (+)
  'euphoria_negative': Color(0xFF4A0033), // Упоение (-)
  'euphoria_positive': Color(0xFFFF00FF), // Упоение (+)
  'excitement_down': Color(0xFF556600), // Ажиотаж (-)
  'excitement_over': Color(0xFFBFFF00), // Ажиотаж (+)
  'nervousness_negative': Color(0xFF453355), // Взволнованность (-)
  'nervousness_positive': Color(0xFFB57EDC), // Взволнованность (+)
  'excitement_down2': Color(0xFF1C2841), // Волнение (-)
  'excitement_up': Color(0xFF007FFF), // Волнение (+)
  'impatience_negative': Color(0xFF7A1F1F), // Нетерпение (-)
  'impatience_positive': Color(0xFFFF7F50), // Нетерпение (+)
  'nostalgia_negative': Color(0xFF3E3222), // Ностальгия (-)
  'nostalgia_positive': Color(0xFFFFDAB9), // Ностальгия (+)
  'curiosity_-': Color(0xFF2F4F2F), // Любопытство (-)
  'curiosity_+': Color(0xFF3EB489), // Любопытство (+)
  'embarrassment_-': Color(0xFF8C5A65), // Смущение (-)
  'embarrassment_+': Color(0xFFFFC0CB), // Смущение (+)
  'adoration_-': Color(0xFF5E1914), // Обожание (-)
  'adoration_+': Color(0xFFFF007F), // Обожание (+)
  'compassion_-': Color(0xFF2F4F4F), // Сострадание (-)
  'compassion_+': Color(0xFF7FFFD4), // Сострадание (+)
  'empathy_-': Color(0xFF000033), // Сопричастность (-)
  'empathy_+': Color(0xFF6495ED), // Сопричастность (+)
  'sympathy_-': Color(0xFF46596D), // Сочувствие (-)
  'sympathy_+': Color(0xFF87CEEB), // Сочувствие (+)
};

// Which of the 7 families each negative key belongs to, for grouping/sorting
// on the selection screen — matches the new 2026-08-10 grouping (some
// emotions moved families relative to the original spec, e.g.
// 'resentment'/'vulnerability' red now instead of brown).
final Map<String, _NegativeColorFamily> _negativeKeyFamily = {
  for (final k in [
    'anger_rage', 'hate', 'wrath', 'irritation', 'outrage2', 'cruelty',
    'outrage', 'vulnerability', 'resentment'
  ]) k: _NegativeColorFamily.red,
  for (final k in [
    'disgust', 'contempt', 'antipathy', 'repulsion', 'envy', 'jealousy'
  ]) k: _NegativeColorFamily.green,
  for (final k in [
    'horror', 'desperation', 'fear2', 'fear', 'agitation', 'confusion2',
    'anxiety', 'apprehension', 'worry'
  ]) k: _NegativeColorFamily.purple,
  for (final k in [
    'humiliation', 'guilt', 'shame2', 'shame', 'regret', 'annoyance', 'shyness'
  ]) k: _NegativeColorFamily.brown,
  for (final k in [
    'suspicion', 'distrust', 'confusion', 'busyness', 'disappointment',
    'regret2', 'disheartenment', 'bewilderment2', 'bewilderment'
  ]) k: _NegativeColorFamily.yellow,
  for (final k in [
    'grief', 'melancholy', 'bitterness', 'sadness', 'sorrow', 'desolation',
    'melancholia', 'pity'
  ]) k: _NegativeColorFamily.blue,
  for (final k in [
    'prostration', 'doom', 'powerlessness', 'apathy', 'detachment',
    'lostness', 'loneliness', 'abandonment', 'laziness', 'helplessness',
    'unworthiness', 'uncertainty', 'disgust_disappointment'
  ]) k: _NegativeColorFamily.gray,
};

// Same idea for the 7 positive families, in the order the user listed them
// (yellow-orange, pink-peach, emerald-green, blue-ocean, lilac-purple,
// turquoise-cyan, gold-bronze).
final Map<String, _PositiveColorFamily> _positiveKeyFamily = {
  for (final k in [
    'euphoria', 'joy2', 'delight', 'happiness', 'joy', 'enthusiasm', 'zeal',
    'vitality', 'animation', 'elevation'
  ]) k: _PositiveColorFamily.yellowOrange,
  for (final k in [
    'love', 'infatuation', 'self-love', 'tenderness', 'care', 'sympathy',
    'friendliness', 'kindness'
  ]) k: _PositiveColorFamily.pinkPeach,
  for (final k in [
    'harmony', 'liberation', 'acceptance2', 'acceptance', 'pacification',
    'tranquility', 'humility'
  ]) k: _PositiveColorFamily.emeraldGreen,
  for (final k in [
    'bliss', 'pleasure', 'faith', 'trust', 'hope'
  ]) k: _PositiveColorFamily.blueOcean,
  for (final k in [
    'reverence', 'admiration', 'respect', 'inspiration2', 'inspiration',
    'enchantment', 'gratitude', 'gratitude2'
  ]) k: _PositiveColorFamily.lilacPurple,
  for (final k in [
    'excitement', 'anticipation2', 'anticipation', 'interest'
  ]) k: _PositiveColorFamily.turquoiseCyan,
  for (final k in [
    'self-worth', 'identity', 'pride', 'patriotism'
  ]) k: _PositiveColorFamily.goldBronze,
};

// Each neutral pair (e.g. 'doubt_positive'/'doubt_negative') shares one
// concept-order index, in the order the user listed the 16 concepts, so the
// positive and negative columns on the neutral tab stay in the same
// thematic order as each other instead of an arbitrary original-list order.
final Map<String, int> _neutralConceptOrder = {
  'doubt_negative': 0, 'doubt_positive': 0,
  'surprise_negative': 1, 'surprise_positive': 1,
  'indifference_negative': 2, 'indifference_positive': 2,
  'excitement_negative': 3, 'excitement_positive': 3, // Азарт
  'euphoria_negative': 4, 'euphoria_positive': 4, // Упоение
  'excitement_down': 5, 'excitement_over': 5, // Ажиотаж
  'nervousness_negative': 6, 'nervousness_positive': 6, // Взволнованность
  'excitement_down2': 7, 'excitement_up': 7, // Волнение
  'impatience_negative': 8, 'impatience_positive': 8,
  'nostalgia_negative': 9, 'nostalgia_positive': 9,
  'curiosity_-': 10, 'curiosity_+': 10,
  'embarrassment_-': 11, 'embarrassment_+': 11,
  'adoration_-': 12, 'adoration_+': 12,
  'compassion_-': 13, 'compassion_+': 13,
  'empathy_-': 14, 'empathy_+': 14,
  'sympathy_-': 15, 'sympathy_+': 15,
};

int _hash(String key) =>
    key.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);

/// Sort key for grouping negative emotions by color family on the selection
/// screen. Keys with an explicit family (the negative spectrum above) sort
/// together by family in the order the user specified (red, purple, blue,
/// green, brown, yellow, gray); everything else sorts after all of them,
/// keeping its original relative order.
int emotionFamilySortKey(String key) =>
    _negativeKeyFamily[key]?.index ?? _NegativeColorFamily.values.length;

/// Same idea for positive emotions (yellow-orange, pink-peach, emerald-green,
/// blue-ocean, lilac-purple, turquoise-cyan, gold-bronze).
int positiveEmotionFamilySortKey(String key) =>
    _positiveKeyFamily[key]?.index ?? _PositiveColorFamily.values.length;

/// Sort key for the neutral tab's two columns, grouping each +/- pair by the
/// concept order the user listed them in, so both columns read in the same
/// thematic order.
int neutralConceptSortKey(String key) =>
    _neutralConceptOrder[key] ?? _neutralConceptOrder.length;

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

/// The exact spec color for an emotion in any of the three hand-picked
/// spectrums, or null if this key isn't one of them (custom user-added
/// emotions).
Color? emotionSpectrumColor(String key) =>
    _negativeSpectrum[key] ?? _positiveSpectrum[key] ?? _neutralSpectrum[key];

/// Which spectrum a key belongs to (for grouping widgets like the emotion
/// bubble chart, which sorts into a positive/negative gravity zone). Neutral
/// keys resolve via their own _positive/_negative suffix, since every
/// individual neutral entry already leans one way or the other — there's no
/// true third "neutral" bucket in the underlying data. Returns null for
/// anything not in any spectrum (custom user-added emotions).
EmotionMood? emotionSpectrumMood(String key) {
  if (_negativeSpectrum.containsKey(key)) return EmotionMood.negative;
  if (_positiveSpectrum.containsKey(key)) return EmotionMood.positive;
  if (_neutralSpectrum.containsKey(key)) {
    if (key.endsWith('_positive') || key.endsWith('_+')) return EmotionMood.positive;
    if (key.endsWith('_negative') || key.endsWith('_-')) return EmotionMood.negative;
  }
  return null;
}

Color emotionBlobColor(String key, EmotionMood mood) {
  final exact = emotionSpectrumColor(key);
  if (exact != null) return exact;

  final hash = _hash(key);
  final hueStart =
      mood == EmotionMood.positive ? _positiveHueStart : _negativeHueStart;
  final hueEnd =
      mood == EmotionMood.positive ? _positiveHueEnd : _negativeHueEnd;
  final hue = hueStart + (hash % 1000) / 1000 * (hueEnd - hueStart);
  return HSLColor.fromAHSL(1, hue, 0.65, 0.62).toColor();
}
