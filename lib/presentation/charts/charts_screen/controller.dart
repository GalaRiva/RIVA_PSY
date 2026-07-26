import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import '../../../core/utils/size_utils.dart';

import 'models/emotion_in_body.dart';
import 'models/emotion_model.dart';
import 'models/report_model.dart';

class K61Controller extends GetxController {
  bool loading = true;


  var pills = <PillModel>[];
  void init() async {
    loading = false;
    dataForChart = await getIntensity();
    emotions = await getEmotions();
    update();
  }

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
    EmotionModel(3, 'Радость', ColorConstant.cyan700),
    EmotionModel(2, 'Азарт', ColorConstant.gray100),
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
        if (emotionTypeInStr == 'Позитивные эмоции')
          positiveType!.bodyParts += _getBodyPartsType(positiveType!, event);
        if (emotionTypeInStr == 'Негативные эмоции')
          negativeType!.bodyParts += _getBodyPartsType(negativeType!, event);
        else
          neutralType!.bodyParts += _getBodyPartsType(negativeType!, event);

        _getBodyParts(emotion, event);
        bool listContainEmotion() {
          for (var item in listEventModels) {
            if (emotion.name == item.name) {
              return true;
            }
          }
          return false;
        }

        if (!listContainEmotion()) {
          listEventModels.add(emotion);
          list.add(
              EmotionModel(1, emotion.name, getColor(listEventModels.length)));
        } else {
          for (var _item in list) {
            if (_item.name == emotion.name) {
              _item.quantity++;
              break;
            }
          }
        }
      }
    }

    for (var item in _places) {
      for (var emotion in item.emotions){
        if(emotion.quantity > item.emotionMax) item.emotionMax = emotion.quantity;
      }
    }
    placesResult = _places;
    return emotions = list;
  }

  Color getColor(int length) {
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
    if (emotion.name[emotion.name.length - 1] == '+') {
      model = 'Нейтральные (позитивно окрашенные)';
    }
    if (emotion.name[emotion.name.length - 1] == '-') {
      model = 'Нейтральные (негативно окрашенные)';
    }
    bool positiveContains = false;
    for (var item in positive) {
      if (item.name == emotion.name) {
        positiveContains = true;
        break;
      }
    }
    if (positiveContains) {
      model = 'Позитивные эмоции';
    } else {
      model = 'Негативные эмоции';
    }
    return model;
  }

  Future<EmotionModel?> getEmotionTypes(
      DayEventModel dayEventModel, EventModel emotion) async {
    EmotionModel? model;

    if (positive.isEmpty) {
      positive = await _k27Repo.getEvent(HiveDBTags.emotions2);
    }
    if (emotion.name[emotion.name.length - 1] == '+') {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'Нейтральные (позитивно окрашенные)') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(1, 'Нейтральные (позитивно окрашенные)',
            getColor(emotionsTypes.length)));
    }
    if (emotion.name[emotion.name.length - 1] == '-') {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'Нейтральные (негативно окрашенные)') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(1, 'Нейтральные (негативно окрашенные)',
            getColor(emotionsTypes.length)));
    }
    bool positiveContains = false;
    for (var item in positive) {
      if (item.name == emotion.name) {
        positiveContains = true;
        break;
      }
    }
    if (positiveContains) {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'Позитивные эмоции') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(
            1, 'Позитивные эмоции', getColor(emotionsTypes.length)));
    } else {
      bool createNew = true;
      if (emotionsTypes.isNotEmpty)
        for (var item in emotionsTypes) {
          if (item.name == 'Негативные эмоции') {
            createNew = false;
            item.quantity++;
          }
        }
      if (createNew)
        model = (EmotionModel(
            1, 'Негативные эмоции', getColor(emotionsTypes.length)));
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

          if (item.emotionModel == emotion.name) {
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
              emotion.name,
              1,
              dayEventModel.whatBodyParts!.map((e) {
                index++;
                return BodyPartModel(e, 1, getColor(index - 1));
              }).toList()));
        }
      }
      if (emotionsInBody.isEmpty) {
        int index = 0;

        emotionsInBody.add(EmotionInBodyModel(
            emotion.name,
            1,
            dayEventModel.whatBodyParts!.map((e) {
              index++;
              return BodyPartModel(e, 1, getColor(index - 1));
            }).toList()));
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
      list.add(
    BodyPartModel(bodyParts, quantity, getColor(model.bodyParts.length)));
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
        if (emotion.name == listEventModels[i].name) {
          listEventModels[i].quantity++;
          return true;
        }
      }
      return false;
    }

    if(placeIsExist() != null) {
      for(var item in dayEventModel.whatEmotion!){
        var val = EmotionModel(1, item.name, getColor(placeIsExist()!.emotions.length));
        if(!listContainEmotion(placeIsExist()!.emotions, val)){
          placeIsExist()!.emotions.add(val);
        }
      }
    } else {
      _places.add(PlaceModel(dayEventModel.whereHappened!.name, List<EmotionModel>.generate(dayEventModel.whatEmotion!.length, (index) => EmotionModel(1, dayEventModel.whatEmotion![index].name, getColor(index))), placeKey: dayEventModel.whereHappened!.key));
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
       item.color = getColor(listToReturn.length);
       return true;
     }
     return false;
    }
    for(var item in list) {
      if(!contain(item)) listToReturn.add(item..color = getColor(listToReturn.length));
    }
    return listToReturn;
  }

  double getTabHeight() {
        return size.height - 214;
  }

}
