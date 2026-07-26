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
          'Головная боль',
          'Краснеют щёки',
          'Слёзы',
          'Сжимаю челюсть',
          'Сводит челюсть',
          'Заикание',
          'Горят уши',
          'Головокружение',
          'Расслабленная',
          'Твёрдая',
          'Мягкая',
          'Тяжёлая',
          'Лёгкая',
          'Напряжённая'
        ],
        marginTop: 16,
        marginLeft: 70),
    BodyPartsModel(
        key: 'throat',
        bodyPart: 'throat'.tr(),
        whatHurts: [
          'Ком в горле',
          'Першит',
          'Тошнота',
          'Напряженно',
          'Раслабленно',
          'Сжато',
          'Тупо',
          'Остро',
          'Твёрдое',
          'Мягкое',
          'Сладость',
          'Горечь',
          'Пространство',
        ],
        marginTop: 36,
        marginLeft: 70),
    BodyPartsModel(
        key: 'chest',
        bodyPart: 'chest'.tr(),
        whatHurts:
            'Частое сердцебиение.Камень на сердце.Поверхностное дыхание.Частое дыхание.Жар в солнечном сплетении.Пустота.Холодно.Пространство.Остро.Твёрдо.Мягко.Сжато.Глубокие вдохи.Сдерживание дыхания'
                .split('.'),
        marginTop: 70,
        marginLeft: 70),
    BodyPartsModel(
        key: 'shoulders_and_arms',
        bodyPart: 'shoulders_and_arms'.tr(),
        whatHurts:
            'Плечи напряжены. Плечи расслаблены. Потеют ладони. Кусаю заусенцы. Мурашки. Опущены, Сутулость. Руки в кулаки. Трясуться ладони. Заламываю пальца. Озноб. Холод. Руки напряжены. Тяжёлые плечи. Лёгкие плечи. Жар'
                .split('. '),
        marginTop: 100,
        marginLeft: 110),
    BodyPartsModel(
        key: 'legs',
        bodyPart: 'legs'.tr(),
        whatHurts:
            'Тяжёлые ноги.Трясуться колени.Судороги.Поджимаю пальцы.Слабость в ногах.Твёрдые.Мягкие.Лёгкость.Напряжение.Расслаблены.Мурашки'
                .split('.'),
        marginTop: 280,
        marginLeft: 90),
    BodyPartsModel(
        key: 'stomach',
        bodyPart: 'stomach'.tr(),
        whatHurts:
            'Холод в животе.Напряжён.Расслаблен.Тепло.Мягкий.Твёрдый.Тошнота.Рвота.Пустота.Наполненность.Сжато.Пространство.Светло.Темно'
                .split('.'),
        marginTop: 110,
        marginLeft: 70),
    BodyPartsModel(
        key: 'back',
        bodyPart: 'back'.tr(),
        whatHurts: 'Скована.Расслаблена.Напряжена.Тепло.Холод.Твёрдая.Мягкая'
            .split('.'),
        marginTop: 70,
        marginLeft: 70),
  ];
}
