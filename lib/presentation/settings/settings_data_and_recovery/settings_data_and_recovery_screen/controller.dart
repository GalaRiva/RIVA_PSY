import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';
import 'package:riva_psy/core/db/firebase_firestore/models/backup_model.dart';
import 'package:riva_psy/core/db/hive_db.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/widgets/custom_message_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/firebase/firebase_exception_exporter.dart';
import '../../../../core/services/google_drive_service.dart';
import '../../../../core/user_data/user.dart';

class DataAndRecoveryController extends GetxController {
  String service = 'Google Drive';

  static const String serviceCopyDataKey = 'serviceCopyData';
  static const String copyDataKey = 'copyData';

  DateTime? serviceCopyData;
  DateTime? copyData;

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((prefs.getString(serviceCopyDataKey)) != null) {
      serviceCopyData = DateTime.tryParse(prefs.getString(serviceCopyDataKey)!);
    }
    if ((prefs.getString(copyDataKey)) != null) {
      copyData = DateTime.tryParse(prefs.getString(copyDataKey)!);
    }
    update();
  }

  Future createServiceBackup(BuildContext context,
      {bool showErrorMessage = true}) async {
    if (service.toLowerCase() == 'google drive') {
      if (CurrentUser.repo.userId().isEmpty) {
        // addServiceBackup() below writes to .doc(userId()) directly — an
        // empty id throws a raw "document path must be a non-empty
        // string" Firestore error. Catching it here first turns that into
        // a message that actually tells the user what to do about it.
        if (showErrorMessage)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Не удалось определить учётную запись. Перезайдите в приложение и попробуйте снова.')));
        return;
      }
      final googleDrive = GoogleDriveService();
      try {
        final backupToUpload = await HiveDB.setHiveDBInFile();
        final fileId = await googleDrive.upload(backupToUpload);
        print('fileID - $fileId');
        final now = DateTime.now();
        final records = (await HiveDB.getBox(HiveDBTags.dayEvents)).length;
        final backup = BackupModel(
            fileId,
            '${now.day} ${now.month.monthInText()} ${now.year} г. ${now.hour.timeFormatted()}:${now.minute.timeFormatted()}',
            'Записей: $records',
            service,
            'riva_psy_backup_from_${now.toIso8601String()}');
        try {
          await FireStoreRepositoryImpl().addServiceBackup(backup);
          await setCopyData(serviceCopyDataKey, serviceCopyData, now);
          showDialog(
              context: context,
              builder: (context) => CustomMessageBox(
                  title: 'Данные и восстановление',
                  content:
                      'Вы успешно добавили резервную копию приложения в свой $service'));
        } catch (_) {
          FirebaseExceptionExporter.exportException(_);
          if (showErrorMessage)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Произошла ошибка, проверьте подключение к интернету или попробуйте позднее\nОписание ошибки - $_')));
        }
        update();
      } catch (_) {
        FirebaseExceptionExporter.exportException(_);
        print(_);
        if (showErrorMessage)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Произошла непредвиденная ошибка\nОписание ошибки - $_')));
      }
    }
  }

  Future setCopyData(String key, DateTime? data, DateTime dataForChange) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    data = dataForChange;
    await prefs.setString(key, data.toIso8601String());
  }

  String getDays(DateTime? date) {
    if (date == null) {
      return 'Никогда';
    }
    final days = DateTime.now().difference(date).inDays.abs();
    debugPrint('days $days');
    if (days > 365) {
      return 'Больше года назад';
    }
    if (days > 60) {
      return 'Больше ${days / 30} месяцев назад';
    }
    if (days > 30) {
      return 'Больше месяца назад';
    }
    if (days == 0) return 'Сегодня';

    return days < 2
        ? '$days день назад'
        : days < 5
            ? '$days дня назад'
            : '$days дней назад';
  }
}
