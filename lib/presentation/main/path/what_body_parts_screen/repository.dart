import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../core/models/body_parts_model.dart';
import '../../../../core/utils/image_constant.dart';

class K32Repo {
  static const _eventTag = HiveDBTags.bodyParts;

  Future<List<BodyPartsModel>> getEvent() async {
    var listToReturn = (await HiveDB.getBox(_eventTag))
        .map((e) => BodyPartsModel.fromJson(jsonDecode(e)))
        .toList();
    if (listToReturn.isEmpty) {
      await updateEvent(standardEventList);
      listToReturn = standardEventList;
    }
    return listToReturn;
  }

  Future<void> updateEvent(List<BodyPartsModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.openBox(_eventTag);
    await HiveDB.deleteBox(_eventTag);
    for (var item in events) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  final standardEventList = <BodyPartsModel>[
    BodyPartsModel(
        key: 'head_and_face',
        bodyPart: 'head_and_face'.tr(),
        whatHurts: [
          'headache'.tr(),
          'blushing_cheeks'.tr(),
          'tears'.tr(),
          'clenching_jaw'.tr(),
          'locking_jaw'.tr(),
          'stuttering'.tr(),
          'burning_ears'.tr(),
          'dizziness'.tr(),
          'relaxed'.tr(),
          'firm'.tr(),
          'soft'.tr(),
          'heavy'.tr(),
          'light'.tr(),
          'tense'.tr()
        ],
        marginTop: 16,
        marginLeft: 70),
    BodyPartsModel(
        key: 'throat',
        bodyPart: 'throat'.tr(),
        whatHurts: [
          'lump_in_throat'.tr(),
          'choking'.tr(),
          'nausea'.tr(),
          'tense4'.tr(),
          'relaxed5'.tr(),
          'clenched'.tr(),
          'dull'.tr(),
          'sharp'.tr(),
          'throat_firm'.tr(),
          'throat_soft'.tr(),
          'sweetness'.tr(),
          'bitterness2'.tr(),
          'spaciousness'.tr(),
        ],
        marginTop: 36,
        marginLeft: 70),
    BodyPartsModel(
        key: 'chest',
        bodyPart: 'chest'.tr(),
        whatHurts: [
          'rapid_heartbeat'.tr(),
          'stone_in_heart'.tr(),
          'shallow_breathing'.tr(),
          'rapid_breathing'.tr(),
          'heat_in_solar_plexus'.tr(),
          'emptiness'.tr(),
          'cold'.tr(),
          'spaciousness'.tr(),
          'sharp'.tr(),
          'chest_firm'.tr(),
          'chest_soft'.tr(),
          'clenched'.tr(),
          'deep_inhales'.tr(),
          'holding_breath'.tr(),
        ],
        marginTop: 70,
        marginLeft: 70),
    BodyPartsModel(
        key: 'shoulders_and_arms',
        bodyPart: 'shoulders_and_arms'.tr(),
        whatHurts: [
          'tense_shoulders'.tr(),
          'relaxed_shoulders'.tr(),
          'sweaty_palms'.tr(),
          'biting_cuticles'.tr(),
          'tingling_sensation'.tr(),
          'slumped_hunchbacked'.tr(),
          'clenched_fists'.tr(),
          'trembling_hands'.tr(),
          'folding_fingers'.tr(),
          'chills'.tr(),
          'chill'.tr(),
          'tense_hands'.tr(),
          'heavy_shoulders'.tr(),
          'light_shoulders'.tr(),
          'heat'.tr(),
        ],
        marginTop: 100,
        marginLeft: 110),
    BodyPartsModel(
        key: 'legs',
        bodyPart: 'legs'.tr(),
        whatHurts: [
          'heavy_legs'.tr(),
          'trembling_knees'.tr(),
          'cramps'.tr(),
          'clenching_toes'.tr(),
          'weakness_in_legs'.tr(),
          'firm3'.tr(),
          'soft2'.tr(),
          'lightness'.tr(),
          'tension'.tr(),
          'relaxed2'.tr(),
          'tingling_sensatio2'.tr(),
        ],
        marginTop: 280,
        marginLeft: 90),
    BodyPartsModel(
        key: 'stomach',
        bodyPart: 'stomach'.tr(),
        whatHurts: [
          'cold_in_stomach'.tr(),
          'tense2'.tr(),
          'relaxed3'.tr(),
          'warmth'.tr(),
          'soft3'.tr(),
          'firm2'.tr(),
          'nausea'.tr(),
          'nausea2'.tr(),
          'emptiness'.tr(),
          'fullness'.tr(),
          'clenched'.tr(),
          'spaciousness'.tr(),
          'bright'.tr(),
          'dark'.tr(),
        ],
        marginTop: 110,
        marginLeft: 70),
    BodyPartsModel(
        key: 'back',
        bodyPart: 'back'.tr(),
        whatHurts: [
          'rigid'.tr(),
          'relaxed4'.tr(),
          'tense3'.tr(),
          'warmth'.tr(),
          'chill'.tr(),
          'firm'.tr(),
          'soft'.tr(),
        ],
        marginTop: 70,
        marginLeft: 70),
  ];
}
