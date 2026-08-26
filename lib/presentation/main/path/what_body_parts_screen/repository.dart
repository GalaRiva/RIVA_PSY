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
        whatHurtsKeys: ['headache', 'blushing_cheeks', 'tears', 'clenching_jaw', 'locking_jaw', 'stuttering', 'burning_ears', 'dizziness', 'relaxed', 'firm', 'soft', 'heavy', 'light', 'tense'],
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
        whatHurtsKeys: ['lump_in_throat', 'choking', 'nausea', 'tense4', 'relaxed5', 'clenched', 'dull', 'sharp', 'throat_firm', 'throat_soft', 'sweetness', 'bitterness2', 'spaciousness'],
        // Was 36 — too close to head_and_face's marginTop:16, so both
        // markers landed on the head instead of the throat sitting below it.
        marginTop: 65,
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
        whatHurtsKeys: ['rapid_heartbeat', 'stone_in_heart', 'shallow_breathing', 'rapid_breathing', 'heat_in_solar_plexus', 'emptiness', 'cold', 'spaciousness', 'sharp', 'chest_firm', 'chest_soft', 'clenched', 'deep_inhales', 'holding_breath'],
        // Was 70 — nudged down for more separation from throat.
        marginTop: 95,
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
        whatHurtsKeys: ['tense_shoulders', 'relaxed_shoulders', 'sweaty_palms', 'biting_cuticles', 'tingling_sensation', 'slumped_hunchbacked', 'clenched_fists', 'trembling_hands', 'folding_fingers', 'chills', 'chill', 'tense_hands', 'heavy_shoulders', 'light_shoulders', 'heat'],
        // Was 100 (shoulder height) — several whatHurts entries are hand-
        // specific ("trembling_hands", "clenched_fists", "sweaty_palms"),
        // so the marker reads better lower, roughly at hand/wrist level.
        marginTop: 190,
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
        whatHurtsKeys: ['heavy_legs', 'trembling_knees', 'cramps', 'clenching_toes', 'weakness_in_legs', 'firm3', 'soft2', 'lightness', 'tension', 'relaxed2', 'tingling_sensatio2'],
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
        whatHurtsKeys: ['cold_in_stomach', 'tense2', 'relaxed3', 'warmth', 'soft3', 'firm2', 'nausea', 'nausea2', 'emptiness', 'fullness', 'clenched', 'spaciousness', 'bright', 'dark'],
        marginTop: 140,
        marginLeft: 70),
    BodyPartsModel(
        key: 'back',
        // 'back' collided with the navigation "Назад"/"Back"/"Atrás" string
        // already used elsewhere (duplicate JSON key, second definition
        // silently wins), so the translation key had to be renamed to
        // back_body_part. `key: 'back'` stays as the stable identity
        // (messageBoxHeight lookup etc.) — bodyPartKey below is what
        // localizedBodyPart actually re-translates from, so it doesn't
        // fall back to re-running `'back'.tr()` and reintroducing the bug.
        bodyPartKey: 'back_body_part',
        bodyPart: 'back_body_part'.tr(),
        whatHurts: [
          'rigid'.tr(),
          'relaxed4'.tr(),
          'tense3'.tr(),
          'warmth'.tr(),
          'chill'.tr(),
          'firm'.tr(),
          'soft'.tr(),
        ],
        whatHurtsKeys: ['rigid', 'relaxed4', 'tense3', 'warmth', 'chill', 'firm', 'soft'],
        marginTop: 70,
        marginLeft: 70),
  ];
}
