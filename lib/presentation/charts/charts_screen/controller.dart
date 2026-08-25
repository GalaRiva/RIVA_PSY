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

  static const int tabCount = 8;
  TabController? tabController;

  void initTabController() {
    if (tabController != null) return;
    tabController = TabController(length: tabCount, vsync: this, initialIndex: currentTab - 1);
    tabController!.addListener(() {
      if (!tabController!.indexIsChanging) {
        currentTab = tabController!.index + 1;
        update();
      }
    });
  }

  var pills = <PillModel>[];
  void init() async {
    loading = false;
    dataForChart = await getIntensity();
    emotions = await getEmotions();
    // Unbounded (ignores the shared week-range date picker used by the
    // other tabs) — Экраны 1/2/3 are accumulated-pattern retrospectives,
    // not a snapshot of the current week, and a week window would almost
    // never clear their per-tag/per-cell minimum sample sizes.
    allDayEvents = (await _k49Repo.getEvent()).where((e) => e.showInCharts).toList();
    energyMatrixPoints = EnergyMatrixService.compute(allDayEvents);
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

  bool _dateInRange(DateTime date) {
    var start = DateTime(dateStart.year, dateStart.month, dateStart.day -1 );
    var end = DateTime(dateEnd.year, dateEnd.month, dateEnd.day +1 );

    if (start.isBefore(date) && end.isAfter(date)) {
      return true;
    }
    return false;
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

    if(positiveType!.bodyParts.isNotEmpty)
    positiveType!.bodyParts.removeRange(0, positiveType!.bodyParts.length);
    if(negativeType!.bodyParts.isNotEmpty)
      negativeType!.bodyParts.removeRange(0, negativeType!.bodyParts.length );
    if(neutralType!.bodyParts.isNotEmpty)
      neutralType!.bodyParts.removeRange(0, neutralType!.bodyParts.length );

    for (var event in await getDayEventModel()) {
      _getPlaces(event);
      for (var emotion in event.whatEmotion!) {
        final emotionType = await getEmotionTypes(event, emotion);
        if (emotionType != null) {
          emotionsTypes.add(emotionType);
        }
        final emotionTypeInStr = await getEmotionTypesInString(event, emotion);
        // NOTE: pre-existing bug, left as-is per explicit instruction — the
        // `else` binds to the second `if`, so any non-negative (i.e. also
        // positive) emotion falls into neutralType too, and the dedup check
        // runs against negativeType!.bodyParts while appending to
        // neutralType!.bodyParts. See PROJECT_CONTEXT.md.
        if (emotionTypeInStr == 'positive_emotions')
          positiveType!.bodyParts += _getBodyPartsType(positiveType!, event);
        if (emotionTypeInStr == 'negative_emotions')
          negativeType!.bodyParts += _getBodyPartsType(negativeType!, event);
        else
          neutralType!.bodyParts += _getBodyPartsType(negativeType!, event);

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

  Future<String> getEmotionTypesInString(
      DayEventModel dayEventModel, EventModel emotion) async {
    String model;

    if (positive.isEmpty) {
      positive = await _k27Repo.getEvent(HiveDBTags.emotions2);
    }
    if (emotion.isNeutralPositive) {
      model = 'neutral_positive_emotions';
    }
    if (emotion.isNeutralNegative) {
      model = 'neutral_negative_emotions';
    }
    bool positiveContains = false;
    for (var item in positive) {
      if (item.identity == emotion.identity) {
        positiveContains = true;
        break;
      }
    }
    if (positiveContains) {
      model = 'positive_emotions';
    } else {
      model = 'negative_emotions';
    }
    return model;
  }

  Future<EmotionModel?> getEmotionTypes(
      DayEventModel dayEventModel, EventModel emotion) async {
    EmotionModel? model;

    if (positive.isEmpty) {
      positive = await _k27Repo.getEvent(HiveDBTags.emotions2);
    }
    if (emotion.isNeutralPositive) {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'neutral_positive_emotions') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(1, 'neutral_positive_emotions',
            getColor(emotionsTypes.length)));
    }
    if (emotion.isNeutralNegative) {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'neutral_negative_emotions') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(1, 'neutral_negative_emotions',
            getColor(emotionsTypes.length)));
    }
    bool positiveContains = false;
    for (var item in positive) {
      if (item.identity == emotion.identity) {
        positiveContains = true;
        break;
      }
    }
    if (positiveContains) {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'positive_emotions') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        // Fixed colors per spec (white = positive, black = negative) rather
        // than the positional palette — that was assigning palette[0]=white
        // to whichever of the two categories happened to be logged first,
        // so "negative" could just as easily end up white as "positive".
        model = (EmotionModel(1, 'positive_emotions', Colors.white));
    } else {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'negative_emotions') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(1, 'negative_emotions', Colors.black));
    }
    return model;
  }

  void _getBodyParts(EventModel emotion, DayEventModel dayEventModel) {
    for (var bodyParts in dayEventModel.whatBodyParts!) {
      if (emotionsInBody.isNotEmpty) {
        bool createNew = true;
        for (var item in emotionsInBody) {
          bool containBodyPart() {
            for (var _item in item.bodyParts) {
              if (_item.bodyPart.bodyPartsModel.identity ==
                  bodyParts.bodyPartsModel.identity) {
                _item.quantity++;
                return true;
              }
            }
            return false;
          }

          if (item.identity == emotion.identity) {
            createNew = false;
            if (!containBodyPart())
              item.bodyParts.add(
                  BodyPartModel(bodyParts, 1, getColor(item.bodyParts.length)));
          }
        }
//
        if (createNew) {
          int index = 0;
          emotionsInBody.add(EmotionInBodyModel(
              emotion.localizedName,
              1,
              dayEventModel.whatBodyParts!.map((e) {
                index++;
                return BodyPartModel(e, 1, getColor(index - 1));
              }).toList(), emotionKey: emotion.key));
        }
      }
      if (emotionsInBody.isEmpty) {
        int index = 0;

        emotionsInBody.add(EmotionInBodyModel(
            emotion.localizedName,
            1,
            dayEventModel.whatBodyParts!.map((e) {
              index++;
              return BodyPartModel(e, 1, getColor(index - 1));
            }).toList(), emotionKey: emotion.key));
      }
    }
  }

  List<BodyPartModel> _getBodyPartsType(
      EmotionTypeInBodyModel model, DayEventModel dayEventModel) {
    final list = <BodyPartModel>[];
    for (var bodyParts in dayEventModel.whatBodyParts!) {
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
      for(var item in dayEventModel.whatEmotion!){
        var val = EmotionModel(1, item.name, getColor(placeIsExist()!.emotions.length, emotionKey: item.key), key: item.key);
        if(!listContainEmotion(placeIsExist()!.emotions, val)){
          placeIsExist()!.emotions.add(val);
        }
      }
    } else {
      _places.add(PlaceModel(dayEventModel.whereHappened!.localizedName, List<EmotionModel>.generate(dayEventModel.whatEmotion!.length, (index) => EmotionModel(1, dayEventModel.whatEmotion![index].localizedName, getColor(index, emotionKey: dayEventModel.whatEmotion![index].key), key: dayEventModel.whatEmotion![index].key)), placeKey: dayEventModel.whereHappened!.key));
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

  List<BodyPartModel> sortBodyPartsList (List<BodyPartModel> list) {
    final listToReturn = <BodyPartModel>[];
    bool contain(BodyPartModel second) {
      for(var item in listToReturn)
     if (item.bodyPart.bodyPartsModel.identity == second.bodyPart.bodyPartsModel.identity){
       item.quantity++;
       // Was positional (getColor(listToReturn.length)) — this ran *after*
       // _getBodyPartsType already set the correct zone color, silently
       // overwriting it with palette[0]=white (or whatever else) whenever a
       // zone landed at that index. Zone identity determines the color now,
       // same as everywhere else this data is drawn.
       item.color = bodyZoneColor(item.bodyPart.bodyPartsModel.identity, getColor(listToReturn.length));
       return true;
     }
     return false;
    }
    for(var item in list) {
      if(!contain(item)) listToReturn.add(item..color = bodyZoneColor(item.bodyPart.bodyPartsModel.identity, getColor(listToReturn.length)));
    }
    return listToReturn;
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
