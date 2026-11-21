import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/db/hive_db.dart';
import 'package:riva_psy/core/models/event_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/repository.dart';
import '../../main/main_screen/repository.dart';
import '../../main/path/what_emotion_screen/repository.dart';
import '../../records/records_screen/repository.dart';
import '../../settings/settings_pills/models/pill_model.dart';
import '../../recomendation/recomendation_screen/controller.dart' show K70Controller;
import 'models/place_model.dart';
import '../../../core/models/day_event_model.dart';
import '../../../core/models/emotional_state_model.dart';
import '../../../core/services/dashboards/energy_matrix_service.dart';
import '../../../core/utils/size_utils.dart';

import 'models/emotion_in_body.dart';
import 'models/emotion_model.dart';
import 'models/report_model.dart';
import '../../../widgets/emotion_color_blob.dart';
import '../../../widgets/body_zone_colors.dart';

class K61Controller extends GetxController with GetSingleTickerProviderStateMixin {
  bool loading = true;

  static const int tabCount = 9;
  TabController? tabController;

  void initTabController() {
    if (tabController != null) return;
    tabController = TabController(length: tabCount, vsync: this, initialIndex: currentTab - 1);
    tabController!.addListener(() {
      if (!tabController!.indexIsChanging) {
        currentTab = tabController!.index + 1;
        // A portrait test left mid-way must not leave the chrome hidden.
        if (Get.isRegistered<K70Controller>()) Get.find<K70Controller>().setImmersiveMode(false);
        update();
      }
    });
  }

  var pills = <PillModel>[];
  // Each part is calculated on its own and the screen is refreshed after the
  // first one, so a problem in one tab's data can no longer leave every tab
  // (the first chart included) stuck on its empty starting state. Before, one
  // exception anywhere in here ended the function before update() ran.
  Future<void> init() async {
    loading = false;
    try {
      dataForChart = await getIntensity();
    } catch (e) {
      print('[CHARTS] state line failed: $e');
    }
    update();
    try {
      emotions = await getEmotions();
    } catch (e) {
      print('[CHARTS] emotions failed: $e');
    }
    try {
      // Unbounded (ignores the shared week-range date picker used by the
      // other tabs) — Экраны 1/2/3 are accumulated-pattern retrospectives,
      // not a snapshot of the current week, and a week window would almost
      // never clear their per-tag/per-cell minimum sample sizes.
      allDayEvents = (await _k49Repo.getEvent()).where((e) => e.showInCharts).toList();
      energyMatrixPoints = EnergyMatrixService.compute(allDayEvents);
    } catch (e) {
      print('[CHARTS] dashboards failed: $e');
    }
    update();
  }

  List<DayEventModel> allDayEvents = [];
  List<EnergyMatrixPoint> energyMatrixPoints = [];

  final reportModel = ReportModel();

  int currentTab = 1;
  var dateStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  var dateEnd = DateTime.now().add(Duration(days: 7 - DateTime.now().weekday));
  final List<String> fields = [
    'date',
    'situation',
    'emotions',
    'body',
    'actions',
    'thoughts'
  ];
  List<int> dataForChart = [];
  final _k27Repo = K27Repo();
  final _k49Repo = K49Repo();
  final _k20Repo = K20Repo();
  List<EmotionModel> emotions = [
    EmotionModel(3, 'joy'.tr(), ColorConstant.cyan700),
    EmotionModel(2, 'Азарт', ColorConstant.gray100), // TODO: no bare (non-suffixed) key for this word — dead placeholder, overwritten by init(), left untranslated
  ];
  List<EmotionInBodyModel> emotionsInBody = [];
  List<EmotionTypeInBodyModel> emotionTypesInBody = [];

  List<EmotionModel> emotionsTypes = [];
  final List<Color> palette = [
    Colors.white,
    ColorConstant.fromHex('#3B3B4A'),
    ColorConstant.fromHex('#5B4FA9'),
    ColorConstant.fromHex('#66C1BD'),
    ColorConstant.fromHex('#7F7F90')
  ];

  // The chosen period runs from the start of its first day to the end of its
  // last day. (It used to begin one whole day earlier, so a "week" showed
  // eight days of entries.)
  bool _dateInRange(DateTime date) {
    final start = DateTime(dateStart.year, dateStart.month, dateStart.day);
    final end = DateTime(dateEnd.year, dateEnd.month, dateEnd.day + 1);
    return !date.isBefore(start) && date.isBefore(end);
  }

  Future<List<DayEventModel>> getDayEventModel() async {
    final dayEvents = (await _k49Repo.getEvent()).where((element) => element.showInCharts).toList();
    final listForReturn = <DayEventModel>[];
    for (var event in dayEvents) {
      if (_dateInRange(event.date ?? DateTime.now())) listForReturn.add(event);
    }
    print(listForReturn.length);
    return listForReturn;
  }

  Future<List<int>> getIntensity() async {
    final List<EmotionalStateModel> list = [];
    // попадают только с кнопки сохранить
    //for (var event in await getDayEventModel()) list.add(EmotionalStateModel(event.howDoYouFeel!, event.date!));
    for (var event in await _k20Repo.getEvent()) {
      if (_dateInRange(event.date)) list.add(event);
    }
    list.sort((d1,d2) => d1.compareTo(d2));
    final listToReturn = list.map((e) => e.emotionalState).toList();
    return dataForChart = listToReturn;
  }


  EmotionTypeInBodyModel? positiveType =
  EmotionTypeInBodyModel([], 'Позитивные эмоции');
  EmotionTypeInBodyModel? negativeType =
  EmotionTypeInBodyModel([], 'Негативные эмоции');
  EmotionTypeInBodyModel? neutralType =
  EmotionTypeInBodyModel([], 'Нейтральные эмоции');

  List<PlaceModel> _places = [];
  List<PlaceModel> placesResult = [];

  Future<List<EmotionModel>> getEmotions() async {
    final list = <EmotionModel>[];
    final listEventModels = <EventModel>[];

    emotionsTypes = [];
    emotionsInBody = [];
    emotionTypesInBody = [];
    // Everything below is rebuilt from scratch on every call. The places list
    // used to be kept between calls, so each period change or return to the
    // tab added the same entries again and the counts doubled.
    _places = [];
    // Re-read the positive list too: a custom positive emotion added since the
    // screen was first opened must count as positive, not negative.
    positive = await _k27Repo.getEvent(HiveDBTags.emotions2);

    positiveType!.bodyParts = [];
    negativeType!.bodyParts = [];
    neutralType!.bodyParts = [];

    for (var event in await getDayEventModel()) {
      _getPlaces(event);
      for (var emotion in event.whatEmotion ?? const []) {
        // One category per emotion: positive, negative or one of the two
        // neutral kinds. Both the pie and the body map use the same answer,
        // so they can no longer disagree.
        final category = _categoryOf(emotion);
        _countEmotionType(category);
        final bucket = category == 'positive_emotions'
            ? positiveType!
            : category == 'negative_emotions'
                ? negativeType!
                : neutralType!;
        bucket.bodyParts += _getBodyPartsType(bucket, event);

        _getBodyParts(emotion, event);
        bool listContainEmotion() {
          for (var item in listEventModels) {
            if (emotion.identity == item.identity) {
              return true;
            }
          }
          return false;
        }

        if (!listContainEmotion()) {
          listEventModels.add(emotion);
          list.add(
              EmotionModel(1, emotion.localizedName, getColor(listEventModels.length, emotionKey: emotion.key), key: emotion.key));
        } else {
          for (var _item in list) {
            if (_item.identity == emotion.identity) {
              _item.quantity++;
              break;
            }
          }
        }
      }
    }

    for (var item in _places) {
      // Grouping down to the top few + a single "Other" bucket now happens
      // in WhereAndWhatEmotionsWidget itself (top-3 + fold-the-rest) — doing
      // it here too produced a second, nested "Other" bucket with an
      // inconsistent name.
      item.emotionMax = 0;
      for (var emotion in item.emotions){
        if(emotion.quantity > item.emotionMax) item.emotionMax = emotion.quantity;
      }
    }
    placesResult = _places;
    return emotions = list;
  }

  Color getColor(int length, {String? emotionKey}) {
    // Individual negative-spectrum emotions get their exact hand-picked
    // color (same one used for the blob on the Path screens) instead of a
    // position-based palette color, so the chart slice for e.g. "Гнев"
    // always reads as the same red no matter what order it was logged in.
    if (emotionKey != null) {
      final exact = emotionSpectrumColor(emotionKey);
      if (exact != null) return exact;
    }
    if (length < palette.length) {
      return palette[length];
    } else {
      return palette[length % palette.length];
    }
  }

  List<EventModel> positive = [];

  // positive_emotions / negative_emotions / neutral_positive_emotions /
  // neutral_negative_emotions. The neutral "+"/"-" pairs are their own
  // categories (the legend already has names for them in all three
  // languages); before, they fell through to "negative".
  String _categoryOf(EventModel emotion) {
    if (emotion.isNeutralPositive) return 'neutral_positive_emotions';
    if (emotion.isNeutralNegative) return 'neutral_negative_emotions';
    final isPositive = positive.any((item) => item.identity == emotion.identity);
    return isPositive ? 'positive_emotions' : 'negative_emotions';
  }

  static final Map<String, Color> _typeColors = {
    // Fixed colors per spec: white = positive, black = negative.
    'positive_emotions': Colors.white,
    'negative_emotions': Colors.black,
    'neutral_positive_emotions': ColorConstant.fromHex('#66C1BD'),
    'neutral_negative_emotions': ColorConstant.fromHex('#7F7F90'),
  };

  void _countEmotionType(String category) {
    for (final item in emotionsTypes) {
      if (item.name == category) {
        item.quantity++;
        return;
      }
    }
    emotionsTypes.add(EmotionModel(1, category, _typeColors[category] ?? getColor(emotionsTypes.length)));
  }

  // Adds this entry's body zones to the emotion's own map, once each. (The
  // old version created the emotion with all of the entry's zones and then,
  // still inside the per-zone loop, counted every zone but the first a second
  // time, so e.g. "chest" showed 2 after a single entry.)
  void _getBodyParts(EventModel emotion, DayEventModel dayEventModel) {
    final zones = dayEventModel.whatBodyParts ?? const [];
    if (zones.isEmpty) return;

    EmotionInBodyModel? target;
    for (final item in emotionsInBody) {
      if (item.identity == emotion.identity) {
        target = item;
        break;
      }
    }
    if (target == null) {
      target = EmotionInBodyModel(emotion.localizedName, 1, [], emotionKey: emotion.key);
      emotionsInBody.add(target);
    }

    for (final zone in zones) {
      BodyPartModel? existing;
      for (final part in target.bodyParts) {
        if (part.bodyPart.bodyPartsModel.identity == zone.bodyPartsModel.identity) {
          existing = part;
          break;
        }
      }
      if (existing != null) {
        existing.quantity++;
      } else {
        target.bodyParts.add(BodyPartModel(zone, 1, getColor(target.bodyParts.length)));
      }
    }
  }

  List<BodyPartModel> _getBodyPartsType(
      EmotionTypeInBodyModel model, DayEventModel dayEventModel) {
    final list = <BodyPartModel>[];
    for (var bodyParts in dayEventModel.whatBodyParts ?? const []) {
      int quantity = 1;
      bool createNew = true;
      for (var item in model.bodyParts) {
        if (item.bodyPart.bodyPartsModel.identity ==
            bodyParts.bodyPartsModel.identity) {
          item.quantity++;
          createNew = false;
        }
      }
    if(createNew)
      // Was purely positional (getColor(index)) — palette[0] is white, so
      // whichever zone happened to be first in the list (e.g. "спина")
      // rendered as an invisible white marker/legend swatch instead of its
      // intended color. Zone color is now looked up by identity, same as
      // the marker circles on the body silhouette itself (body_widget.dart),
      // so the two always match and never depend on insertion order.
      list.add(
    BodyPartModel(bodyParts, quantity, bodyZoneColor(bodyParts.bodyPartsModel.key, getColor(model.bodyParts.length))));
    }

    return list;
  }


  void _getPlaces (DayEventModel dayEventModel) {

    // No place, no emotions — nothing meaningful to plot on the Places
    // chart for this entry (a "lightweight" record like a saved Guided
    // Journal reflection, which has no whereHappened at all).
    if (dayEventModel.whereHappened == null) return;
    final whatEmotion = dayEventModel.whatEmotion ?? const [];

    PlaceModel? placeIsExist () {
      for (var item in _places) {
        if (item.identity == dayEventModel.whereHappened!.identity) {
          return item;
        }
      }
      return null;
    }
    bool listContainEmotion(List<EmotionModel> listEventModels, EmotionModel emotion) {
      for ( int i = 0; i < listEventModels.length; i++) {
        if (emotion.identity == listEventModels[i].identity) {
          listEventModels[i].quantity++;
          return true;
        }
      }
      return false;
    }

    if(placeIsExist() != null) {
      for(var item in whatEmotion){
        var val = EmotionModel(1, item.name, getColor(placeIsExist()!.emotions.length, emotionKey: item.key), key: item.key);
        if(!listContainEmotion(placeIsExist()!.emotions, val)){
          placeIsExist()!.emotions.add(val);
        }
      }
    } else {
      _places.add(PlaceModel(dayEventModel.whereHappened!.localizedName, List<EmotionModel>.generate(whatEmotion.length, (index) => EmotionModel(1, whatEmotion[index].localizedName, getColor(index, emotionKey: whatEmotion[index].key), key: whatEmotion[index].key)), placeKey: dayEventModel.whereHappened!.key));
    }
  }

  void searchPlaces (String text) {
    placesResult = [];
    if(text.isNotEmpty)
    for(var item in _places){
      if(item.place.toLowerCase().contains(text.toLowerCase()))
        placesResult.add(item);
    }
    else placesResult = _places;
  }

  // Merges the same zone coming from several lists (positive + negative +
  // neutral) into one entry whose count is the SUM of theirs, on fresh copies.
  // It used to add 1 instead of the real count, and it edited the originals in
  // place, so the positive/negative maps changed every time the screen rebuilt.
  List<BodyPartModel> sortBodyPartsList(List<BodyPartModel> list) {
    final merged = <BodyPartModel>[];
    for (final item in list) {
      final id = item.bodyPart.bodyPartsModel.identity;
      final i = merged.indexWhere((m) => m.bodyPart.bodyPartsModel.identity == id);
      if (i >= 0) {
        merged[i].quantity += item.quantity;
      } else {
        merged.add(BodyPartModel(item.bodyPart, item.quantity, bodyZoneColor(id, getColor(merged.length))));
      }
    }
    return merged;
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
