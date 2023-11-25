import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/db/firebase_firestore/data/repository.dart';
import 'package:listenmebaby71_s_application17/core/db/firebase_firestore/models/backup_model.dart';
import 'package:listenmebaby71_s_application17/core/db/hive_db.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_message_box.dart';
import '../../../../core/services/google_drive_service.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_button.dart';
import 'widgets/card_recovery_button_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/recovery_message.dart';

class RecoveryController extends GetxController {
  final BuildContext context;

  RecoveryController(this.context);

  final fireStoreRepo = FireStoreRepositoryImpl();

  Future<List<BackupModel>> getRecoveryData(String service) async {
    return fireStoreRepo.getServiceBackups(service);
  }

  Future deleteBackup (BackupModel data) async {
    try {
      if(await GoogleDriveService().deleteFile(data.file_ID)) {
        await fireStoreRepo.deleteBackupFromFireStore(data);
        showDialog(context: context,
            builder: (context) =>
                CustomMessageBox(title: 'Восстановление резервной копии',
                    content: 'Резервная копия была удалена'));
      } else {
        showDialog(context: context,
            builder: (context) =>
                CustomMessageBox(title: 'Восстановление резервной копии',
                    content: 'Ошибка, не удалось удалить резервную копию'));

      }
      update();

    } catch (_) {
      showDialog(context: context,
          builder: (context) =>
              CustomMessageBox(title: 'Восстановление резервной копии',
                  content: 'Ошибка, не удалось удалить резервную копию'));
    }
  }

  Future setUpRecoveryData(
      BackupModel data, String service, BuildContext context) async {
    if (service.toLowerCase() == 'google drive') {
      final googleDrive = GoogleDriveService();
      final fileWithBackup = File(
          (await getApplicationDocumentsDirectory()).path +
              '/' +
              'backups/' +
              data.file_name +
              '.json');
      await googleDrive.downloadFile(data.file_ID, fileWithBackup.path, ).then(
          (value) async {
            if(value == null) {

              //await fireStoreRepo.deleteBackupFromFireStore(data);
              showDialog(context: context, builder: (context) => CustomMessageBox(title: 'Восстановление резервной копии', content: 'Данной резервной копии нет на диске'));

            }
            else
            RecoveryMessage(
              data,
              () async =>
                  HiveDB.getHiveDBFromFile(fileWithBackup.path).then((value) {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => CustomMessageBox(
                            title: 'Восстановление резервной копии',
                            height: getVerticalSize(180),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: getPadding(left: 40, right: 40),
                                  child: Text(
                                    'Версия от ${data.date_time} успешно востановлена',
                                    style:
                                        AppStyle.txtSFProDisplayLight14Gray800,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                CustomButton(
                                  height: getVerticalSize(
                                    32,
                                  ),
                                  width: getHorizontalSize(
                                    77,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  text: "ок".toUpperCase(),
                                ),
                              ],
                            )));
                  })).show(context);});
    }
  }
}
