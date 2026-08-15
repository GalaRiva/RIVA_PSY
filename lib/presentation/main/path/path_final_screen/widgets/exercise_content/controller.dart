import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/models/audio/audio.dart';
import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/models/event_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/ru_canonical_name.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseContentController extends GetxController {
  ExerciseContentController();

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    audioInstance.dispose();
  }

  int currentAudioIndex = 0;

  AudioPlayer audioInstance = AudioPlayer(
      audioLoadConfiguration: AudioLoadConfiguration(
          androidLoadControl: AndroidLoadControl(

  )));

  List<AudioCardModel> mainAudios = [];
  EventModel? mainEmotion;
  List<AudioCardModel> additionalAudios = [];
  List<EventModel>? additionalEmotions;
  DayEventModel? dayEvent;

  // ExerciseContentWidget passes `future: controller.ensureAudiosLoaded()`
  // straight into a FutureBuilder inside build() — any rebuild of that
  // widget (e.g. from an ancestor's setState, not just navigating to a
  // new dayEvent) used to call getAudios() again with the previous call
  // possibly still in flight (it awaits several Firestore round-trips).
  // Both calls mutated the same mainAudios/additionalAudios instance
  // fields, so an interleaved second run didn't just replace the first
  // one's results — it appended a second full copy on top of them,
  // producing exact duplicates. Caching the Future per dayEvent means the
  // underlying work only actually runs once.
  Future<void>? _audiosFuture;
  DayEventModel? _audiosFutureFor;
  Future<void> ensureAudiosLoaded() {
    if (_audiosFuture != null && identical(_audiosFutureFor, dayEvent)) {
      return _audiosFuture!;
    }
    _audiosFutureFor = dayEvent;
    return _audiosFuture = getAudios();
  }

  // Same `<field>_<langCode>` fallback-to-Russian convention already used by
  // NegativeEmotionsModel._localizedField — read the locale
  // easy_localization persisted (main.dart) directly from SharedPreferences,
  // since this is a plain GetxController with no BuildContext to read
  // context.locale from.
  Future<String> _currentLangCode() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('locale') ?? 'ru_RU').split('_').first;
  }

  Future<String> _audioPath(Audio audio, String langCode) async {
    final fileName = audio.localizedFileName(langCode);
    return DataSourceService.dataSourceIsRemote()
        ? 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/' +
            audio.folder +
            '/' +
            fileName +
            '.' +
            audio.format
        : '${(await getApplicationDocumentsDirectory()).path}/${audio.folder}/${fileName}.${audio.format}';
  }

  // The 11 official "Негативные эмоции" tab categories (see
  // NegativeEmotionTabs/negative_emotions_model.dart) already have a fixed,
  // known tab tag — no need to go through Firestore to find it. Checked
  // first, before the Text_Recommendation lookup below, so this screen's
  // audio matching doesn't silently come up empty for one of these (e.g.
  // "Одиночество") just because no Text_Recommendation doc happens to be
  // titled exactly that, or lacks a `tab` field.
  static const Map<String, String> _knownEmotionTabs = {
    'Злость': 'wrath',
    'Паника': 'panic',
    'Страх': 'fear2',
    'Грусть': 'sorrow',
    'Обида': 'resentment',
    'Неуверенность': 'uncertainty',
    'Отвращение': 'disgust',
    'Вина': 'guilt',
    'Лень': 'laziness',
    'Одиночество': 'loneliness',
    'Потерянность': 'lostness',
  };

  // Audio.emotions is an empty string on every current Audio document (see
  // PROJECT_CONTEXT.md §57) — the per-emotion match below always comes up
  // empty right now, regardless of tariff/locale/anything else. Falls back
  // to every audio tagged with the same Path "tab" (wrath/panic/...) as
  // this specific emotion — coarser than per-emotion matching, but real.
  // The tab isn't stored anywhere on DayEventModel/EventModel, so for
  // anything outside the known 11 it's looked up via Text_Recommendation,
  // whose docs are already grouped by tab and titled with each emotion's
  // Russian canonical name.
  final Map<String, String?> _tabCache = {};
  Future<String?> _tabForEmotionRuName(String ruName) async {
    if (_knownEmotionTabs.containsKey(ruName)) return _knownEmotionTabs[ruName];
    if (_tabCache.containsKey(ruName)) return _tabCache[ruName];
    String? tab;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Text_Recommendation')
          .where('title', isEqualTo: ruName)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      if (snap.docs.isNotEmpty) tab = snap.docs.first.data()['tab'] as String?;
    } catch (_) {}
    _tabCache[ruName] = tab;
    return tab;
  }

  Future getAudios() async {
    audioInstance = AudioPlayer(

        audioLoadConfiguration: AudioLoadConfiguration(
            androidLoadControl: AndroidLoadControl(
              maxBufferDuration: Duration(seconds: 300),
              bufferForPlaybackDuration: Duration(seconds: 5),
              bufferForPlaybackAfterRebufferDuration: Duration(seconds: 10),
            )
        ));
    mainAudios = [];
    final langCode = await _currentLangCode();
    var collectionAudio =
        await FirebaseFirestore.instance.collection('Audio').get();
    var audios =
        collectionAudio.docs.map((e) => Audio.fromJson(e.data())).toList();
    mainEmotion = dayEvent!.whatEmotion![0];
    print(dayEvent!.whatEmotion!.map((e) => e.name).toList());
    additionalEmotions = dayEvent!.whatEmotion!
        .getRange(1, dayEvent!.whatEmotion!.length)
        .toList();
    additionalAudios = [];

    // Match against each emotion's canonical Russian name (read from
    // ru-RU.json by stable key via RuCanonicalName), not the live-locale
    // .name — Firestore's Audio.emotions field still tags audio tracks with
    // Russian emotion names, and .name reflects whatever locale the user's
    // Hive data happened to be seeded in (see PROJECT_CONTEXT.md). Falls
    // back to .name for custom emotions, which have no stable key.
    final mainEmotionRuName =
        await RuCanonicalName.forKey(mainEmotion!.key) ?? mainEmotion!.name;
    final additionalEmotionsRuNames = <String>[
      for (var item in additionalEmotions!)
        await RuCanonicalName.forKey(item.key) ?? item.name
    ];

    for (var audio in audios) {
      try {
        if ((audio.emotions ?? [])
            .map((e) => e.toLowerCase())
            .contains(mainEmotionRuName.toLowerCase())) {
          mainAudios.add(AudioCardModel(
              audio.localizedName(langCode),
              await _audioPath(audio, langCode),
              ruTitle: audio.name));
        }
        if (additionalEmotions != null) {
          for (var i = 0; i < additionalEmotions!.length; i++) {
            if ((audio.emotions ?? [])
                    .map((e) => e.toLowerCase())
                    .toList()
                    .contains(additionalEmotionsRuNames[i].toLowerCase()) &&
                !additionalAudios
                    .map((e) => e.title.toLowerCase())
                    .toList()
                    .contains(audio.localizedName(langCode).toLowerCase())) {
              additionalAudios.add(AudioCardModel(
                  audio.localizedName(langCode),
                  await _audioPath(audio, langCode),
                  ruTitle: audio.name));
            }
          }
        }
      } catch (_) {
        print(_);
      }
    }

    if (mainAudios.isEmpty) {
      final tab = await _tabForEmotionRuName(mainEmotionRuName);
      print('[EXERCISE-DIAG] mainAudios empty, tab fallback for "$mainEmotionRuName" -> tab="$tab"');
      if (tab != null) {
        for (var audio in audios.where((a) => a.tab == tab)) {
          mainAudios.add(AudioCardModel(audio.localizedName(langCode), await _audioPath(audio, langCode), ruTitle: audio.name));
        }
      }
    }
    if (additionalAudios.isEmpty && (additionalEmotions?.isNotEmpty ?? false)) {
      for (var i = 0; i < additionalEmotions!.length; i++) {
        final tab = await _tabForEmotionRuName(additionalEmotionsRuNames[i]);
        if (tab == null) continue;
        for (var audio in audios.where((a) => a.tab == tab)) {
          final localizedTitle = audio.localizedName(langCode);
          final alreadyAdded = additionalAudios
                  .map((e) => e.title.toLowerCase())
                  .contains(localizedTitle.toLowerCase()) ||
              mainAudios
                  .map((e) => e.title.toLowerCase())
                  .contains(localizedTitle.toLowerCase());
          if (!alreadyAdded) {
            additionalAudios.add(AudioCardModel(localizedTitle, await _audioPath(audio, langCode), ruTitle: audio.name));
          }
        }
      }
    }
    // Defensive dedup by the resolved audio path/URL (the actual unique
    // identity of a track — two different files never resolve to the same
    // path) — belt-and-suspenders alongside the future-caching fix above,
    // in case the same doc is ever legitimately reachable through more
    // than one matching path.
    mainAudios = _dedupByAsset(mainAudios);
    additionalAudios = _dedupByAsset(additionalAudios);
    print('[EXERCISE-DIAG] final mainAudios=${mainAudios.length} additionalAudios=${additionalAudios.length}');
  }

  List<AudioCardModel> _dedupByAsset(List<AudioCardModel> list) {
    final seen = <String>{};
    return list.where((a) => seen.add(a.audioAsset)).toList();
  }
}
