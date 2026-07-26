import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:riva_psy/core/models/event_model.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../core/utils/image_constant.dart';

class K27Repo {

  static const _eventTag1 = HiveDBTags.emotions1;
  static const _eventTag2 = HiveDBTags.emotions2;
  static const _eventTag3 = HiveDBTags.emotions3;

  String getTag (int number) {
    switch(number) {
      case 1:
        return _eventTag1;
      case 2:
        return _eventTag2;
      default:
        return _eventTag3;
    }
  }

  Future<List<EventModel>> getEvent(String tag) async {
    var listToReturn = (await HiveDB.getBox(tag)).map((e) =>
        EventModel.fromJson(jsonDecode(e))).toList();
    if(listToReturn.isEmpty) {
      switch (tag){
        case _eventTag1:
          await updateEvent(standardEventListOne, tag);
          listToReturn = standardEventListOne;
          break;
        case _eventTag2:
          await updateEvent(standardEventListTwo, tag);
          listToReturn = standardEventListTwo;
          break;
        default:
          await updateEvent(standardEventListThree, tag);
          listToReturn = standardEventListThree;
          break;
      }
    }
    return listToReturn;
  }

  Future<void> updateEvent(List<EventModel> events, String tag) async {
    // TODO: implement updateTasks
    await HiveDB.deleteBox(tag);
    List<EventModel> list = events.map((e) => EventModel(e.name, e.svgPath, e.key)).toList();
    for(var item in list) {
      HiveDB.setBox(item.toJson(), tag);
    }
  }

  final standardEventListOne = <EventModel>[
    EventModel('anger_rage'.tr(), ImageConstant.eventEmotion1_1, 'anger_rage'),
    EventModel('hate'.tr(), ImageConstant.img047mad, 'hate'),
    EventModel('wrath'.tr(), ImageConstant.imgClockCyan70020x20, 'wrath'),
    EventModel('irritation'.tr(), ImageConstant.imgTwitter, 'irritation'),
    EventModel('contempt'.tr(), ImageConstant.imgTrophyCyan70021x21, 'contempt'),
    EventModel('outrage2'.tr(), ImageConstant.img013annoyance, 'outrage2'),
    EventModel('resentment'.tr(), ImageConstant.imgTrophy21x21, 'resentment'),
    EventModel('jealousy'.tr(), ImageConstant.imgCarCyan700, 'jealousy'),
    EventModel('vulnerability'.tr(), ImageConstant.imgClockCyan70021x21, 'vulnerability'),
    EventModel('annoyance'.tr(), ImageConstant.imgUserCyan70021x22, 'annoyance'),
    EventModel('envy'.tr(), ImageConstant.imgClock21x21, 'envy'),
    EventModel('antipathy'.tr(), ImageConstant.imgCarCyan70021x22, 'antipathy'),
    EventModel('outrage'.tr(), ImageConstant.imgTrophyCyan70021x19, 'outrage'),
    EventModel('disgust'.tr(), ImageConstant.imgAlarm, 'disgust'),
    EventModel('fear2'.tr(), ImageConstant.imgAlarmCyan700, 'fear2'),
    EventModel('horror'.tr(), ImageConstant.img016surprised, 'horror'),
    EventModel('desperation'.tr(), ImageConstant.imgAirplaneCyan70021x22, 'desperation'),
    EventModel('fear'.tr(), ImageConstant.imgClockCyan70022x20, 'fear'),
    EventModel('suspicion'.tr(), ImageConstant.imgMusicCyan70021x22, 'suspicion'),
    EventModel('anxiety'.tr(), ImageConstant.imgTrophy1, 'anxiety'),
    EventModel('worry'.tr(), ImageConstant.imgTrash1, 'worry'),
    EventModel('bitterness'.tr(), ImageConstant.imgTelevision, 'bitterness'),
    EventModel('humiliation'.tr(), ImageConstant.imgTrashCyan70022x22, 'humiliation'),
    EventModel('sadness'.tr(), ImageConstant.img005crying, 'sadness'),
    EventModel('guilt'.tr(), ImageConstant.imgMusicCyan70021x21, 'guilt'),
    EventModel('shame2'.tr(), ImageConstant.imgTrophy2, 'shame2'),
    EventModel('shyness'.tr(), ImageConstant.imgTrophy3, 'shyness'),
    EventModel('apprehension'.tr(), ImageConstant.imgClock1, 'apprehension'),
    EventModel('sorrow'.tr(), ImageConstant.img033sad, 'sorrow'),
    EventModel('melancholy'.tr(), ImageConstant.imgTrashCyan70021x21, 'melancholy'),
    EventModel('grief'.tr(), ImageConstant.imgTrash21x21, 'grief'),
    EventModel('laziness'.tr(), ImageConstant.imgClock2, 'laziness'),
    EventModel('pity'.tr(), ImageConstant.imgTrophyCyan70030x26, 'pity'),
    EventModel('agitation'.tr(), ImageConstant.imgAlarmCyan70030x31, 'agitation'),
    EventModel('helplessness'.tr(), ImageConstant.imgTrophyCyan70030x30, 'helplessness'),
    EventModel('disappointment'.tr(), ImageConstant.imgTrophy30x30, 'disappointment'),
    EventModel('regret2'.tr(), ImageConstant.imgTrash2, 'regret2'),
    EventModel('uncertainty'.tr(), ImageConstant.img046speechless, 'uncertainty'),
    EventModel('apathy'.tr(), ImageConstant.img013amazed, 'apathy'),
    EventModel('loneliness'.tr(), ImageConstant.img045sad, 'loneliness'),
    EventModel('abandonment'.tr(), ImageConstant.imgTrophy4, 'abandonment'),
    EventModel('lostness'.tr(), ImageConstant.imgTrophy21x19, 'lostness'),
    EventModel('desolation'.tr(), ImageConstant.imgTrophy5, 'desolation'),
    EventModel('busyness'.tr(), ImageConstant.imgTrophy6, 'busyness'),
    EventModel('powerlessness'.tr(), ImageConstant.img033sad, 'powerlessness'),
    EventModel('confusion2'.tr(), ImageConstant.imgCarCyan70030x30, 'confusion2'),
    EventModel('melancholia'.tr(), ImageConstant.imgAlarm30x31, 'melancholia'),
    EventModel('unworthiness'.tr(), ImageConstant.img009worried, 'unworthiness'),
    EventModel('doom'.tr(), ImageConstant.imgLocationCyan700, 'doom'),
    EventModel('detachment'.tr(), ImageConstant.imgLightbulbCyan70021x21, 'detachment'),
    EventModel('prostration'.tr(), ImageConstant.img013amazed, 'prostration'),
    EventModel('cruelty'.tr(), ImageConstant.imgUserCyan70030x28, 'cruelty'),
    EventModel('disgust_disappointment'.tr(), ImageConstant.imgTrophy7, 'disgust_disappointment'),
    EventModel('confusion'.tr(), ImageConstant.img042meh, 'confusion'),
    EventModel('disheartenment'.tr(), ImageConstant.imgCarCyan70031x31, 'disheartenment'),
    EventModel('regret'.tr(), ImageConstant.imgCar30x30, 'regret'),
    EventModel('bewilderment2'.tr(), ImageConstant.imgTrash2, 'bewilderment2'),
    EventModel('distrust'.tr(), ImageConstant.imgCar1, 'distrust'),
    EventModel('shame'.tr(), ImageConstant.img023regret, 'shame'),
    EventModel('repulsion'.tr(), ImageConstant.imgMegaphoneCyan700, 'repulsion'),
    EventModel('bewilderment'.tr(), ImageConstant.imgAlarmCyan70030x30, 'bewilderment'),
  ];

  final standardEventListTwo = <EventModel>[
    EventModel('joy'.tr(), ImageConstant.img001happy, 'joy'),
    EventModel('happiness'.tr(), ImageConstant.imgClockCyan70021x19, 'happiness'),
    EventModel('delight'.tr(), ImageConstant.imgMusic21x21, 'delight'),
    EventModel('joy2'.tr(), ImageConstant.imgTicket, 'joy2'),
    EventModel('elevation'.tr(), ImageConstant.imgTrophy8, 'elevation'),
    EventModel('animation'.tr(), ImageConstant.imgFolder, 'animation'),
    EventModel('pacification'.tr(), ImageConstant.imgTrophy9, 'pacification'),
    EventModel('interest'.tr(), ImageConstant.img030silly, 'interest'),
    EventModel('care'.tr(), ImageConstant.imgSave, 'care'),
    EventModel('anticipation'.tr(), ImageConstant.imgMusic2, 'anticipation'),
    EventModel('excitement'.tr(), ImageConstant.eventEmotion2_11, 'excitement'),
    EventModel('anticipation2'.tr(), ImageConstant.imgClock21x19, 'anticipation2'),
    EventModel('hope'.tr(), ImageConstant.imgTrophy10, 'hope'),
    EventModel('gratitude'.tr(), ImageConstant.imgTrophy11, 'gratitude'),
    EventModel('liberation'.tr(), ImageConstant.imgClock3, 'liberation'),
    EventModel('acceptance'.tr(), ImageConstant.imgClock4, 'acceptance'),
    EventModel('acceptance2'.tr(), ImageConstant.imgLocationCyan70021x21, 'acceptance2'),
    EventModel('faith'.tr(), ImageConstant.imgCartCyan70021x19, 'faith'),
    EventModel('love'.tr(), ImageConstant.imgAlarmCyan70030x28, 'love'),
    EventModel('reliability'.tr(), ImageConstant.img037ill, 'reliability'),
    EventModel('trust'.tr(), ImageConstant.imgTrophy12, 'trust'),
    EventModel('tranquility'.tr(), ImageConstant.imgTwitterCyan700, 'tranquility'),
    EventModel('sympathy'.tr(), ImageConstant.imgMusic3, 'sympathy'),
    EventModel('identity'.tr(), ImageConstant.imgClockCyan70021x22, 'identity'),
    EventModel('pride'.tr(), ImageConstant.imgAirplaneCyan70021x21, 'pride'),
    EventModel('admiration'.tr(), ImageConstant.imgCartCyan70021x21, 'admiration'),
    EventModel('respect'.tr(), ImageConstant.imgTrophyCyan70030x28, 'respect'),
    EventModel('self-worth'.tr(), ImageConstant.img024sleeping, 'self-worth'),
    EventModel('infatuation'.tr(), ImageConstant.imgTrophyCyan70030x27, 'infatuation'),
    EventModel('self-love'.tr(), ImageConstant.imgTrophy13, 'self-love'),
    EventModel('enchantment'.tr(), ImageConstant.imgTrophy14, 'enchantment'),
    EventModel('humility'.tr(), ImageConstant.imgClock5, 'humility'),
    EventModel('friendliness'.tr(), ImageConstant.imgCarCyan70021x21, 'friendliness'),
    EventModel('kindness'.tr(), ImageConstant.img005laugh, 'kindness'),
    EventModel('harmony'.tr(), ImageConstant.imgMusic4, 'harmony'),
    EventModel('bliss'.tr(), ImageConstant.img050wink, 'bliss'),
    EventModel('euphoria'.tr(), ImageConstant.imgCarCyan70030x28, 'euphoria'),
    EventModel('inspiration'.tr(), ImageConstant.imgTrophy15, 'inspiration'),
    EventModel('vitality'.tr(), ImageConstant.imgClock6, 'vitality'),
    EventModel('pleasure'.tr(), ImageConstant.imgMusic21x22, 'pleasure'),
    EventModel('inspiration2'.tr(), ImageConstant.imgInstagram, 'inspiration2'),
    EventModel('enthusiasm'.tr(), ImageConstant.imgMusic5, 'enthusiasm'),
    EventModel('zeal'.tr(), ImageConstant.imgMusic6, 'zeal'),
    EventModel('tenderness'.tr(), ImageConstant.imgClock7, 'tenderness'),
    EventModel('reverence'.tr(), ImageConstant.imgAlarmCyan70021x21, 'reverence'),
    EventModel('gratitude2'.tr(), ImageConstant.img008happy, 'gratitude2'),
    EventModel('patriotism'.tr(), ImageConstant.imgMegaphoneCyan70021x21, 'patriotism'),
  ];

  final standardEventListThree = <EventModel>[
    EventModel('doubt_positive'.tr(), ImageConstant.imgBagCyan700, 'doubt_positive'),
    EventModel('surprise_positive'.tr(), ImageConstant.imgUserCyan70030x27, 'surprise_positive'),
    EventModel('doubt_negative'.tr(), ImageConstant.imgBagCyan700, 'doubt_negative'),
    EventModel('surprise_negative'.tr(), ImageConstant.imgUserCyan70030x27, 'surprise_negative'),
    EventModel('indifference_positive'.tr(), ImageConstant.imgFloatingicon, 'indifference_positive'),
    EventModel('excitement_positive'.tr(), ImageConstant.imgTwitterCyan70021x21, 'excitement_positive'),
    EventModel('indifference_negative'.tr(), ImageConstant.imgFloatingicon, 'indifference_negative'),
    EventModel('excitement_negative'.tr(), ImageConstant.imgTwitterCyan70021x21, 'excitement_negative'),
    EventModel('euphoria_positive'.tr(), ImageConstant.imgTrophy10, 'euphoria_positive'),
    EventModel('excitement_over'.tr(), ImageConstant.imgTrophy16, 'excitement_over'),
    EventModel('euphoria_negative'.tr(), ImageConstant.imgTrophy10, 'euphoria_negative'),
    EventModel('excitement_down'.tr(), ImageConstant.imgTrophy16, 'excitement_down'),
    EventModel('nervousness_positive'.tr(), ImageConstant.imgFileCyan700, 'nervousness_positive'),
    EventModel('excitement_up'.tr(), ImageConstant.imgTrophy18, 'excitement_up'),
    EventModel('nervousness_negative'.tr(), ImageConstant.imgFileCyan700, 'nervousness_negative'),
    EventModel('excitement_down2'.tr(), ImageConstant.imgTrophy18, 'excitement_down2'),
    EventModel('impatience_positive'.tr(), ImageConstant.img050dizzy, 'impatience_positive'),
    EventModel('nostalgia_positive'.tr(), ImageConstant.imgTrash4, 'nostalgia_positive'),
    EventModel('impatience_negative'.tr(), ImageConstant.img050dizzy, 'impatience_negative'),
    EventModel('nostalgia_negative'.tr(), ImageConstant.imgTrash4, 'nostalgia_negative'),
    EventModel('curiosity_+'.tr(), ImageConstant.imgAlarm21x21, 'curiosity_+'),
    EventModel('embarrassment_+'.tr(), ImageConstant.img005laugh, 'embarrassment_+'),
    EventModel('curiosity_-'.tr(), ImageConstant.imgAlarm21x21, 'curiosity_-'),
    EventModel('embarrassment_-'.tr(), ImageConstant.img005laugh, 'embarrassment_-'),
    EventModel('adoration_+'.tr(), ImageConstant.imgSettings21x21, 'adoration_+'),
    EventModel('compassion_+'.tr(), ImageConstant.imgCutCyan70021x19, 'compassion_+'),
    EventModel('adoration_-'.tr(), ImageConstant.imgSettings21x21, 'adoration_-'),
    EventModel('compassion_-'.tr(), ImageConstant.imgCutCyan70021x19, 'compassion_-'),
    EventModel('empathy_+'.tr(), ImageConstant.imgCutCyan70034x34, 'empathy_+'),
    EventModel('sympathy_+'.tr(), ImageConstant.imgClock21x22, 'sympathy_+'),
    EventModel('empathy_-'.tr(), ImageConstant.imgCutCyan70034x34, 'empathy_-'),
    EventModel('sympathy_-'.tr(), ImageConstant.imgClock21x22, 'sympathy_-'),
  ];
}

