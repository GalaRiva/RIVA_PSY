import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/size_utils.dart';

import '../../../../../core/db/firebase_firestore/models/backup_model.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_button.dart';

class RecoveryMessage {
  final BackupModel backupModel;
  final VoidCallback onConfirm;

  RecoveryMessage(this.backupModel,this.onConfirm);

  void show(BuildContext context) {
    showDialog(context: context, builder: (BuildContext context) => _widget(context));
  }

  Widget _widget(BuildContext context) {
    return  Center(
      child: Container(
        alignment: Alignment.center,
          height: getVerticalSize(256),
          width: getHorizontalSize(290),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
          ),
          child:Padding(
                padding: getPadding(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Подтвердите',
                      style: AppStyle.txtSFProDisplayLight16.copyWith(fontSize: 20),
                    ),
                    SizedBox(
                      height: getVerticalSize(10),
                    ),
                    Text(
                      '${backupModel.date_time}, ${backupModel.record}',
                      style: AppStyle.txtSFProDisplayLight14Black,
                    ),
                    SizedBox(
                      height: getVerticalSize(30),
                    ),
                    Text(
                      'Все существующие данные будут заменены данными копии, которую вы открыли. Вы уверены,что хотите восстановить?',
                      textAlign: TextAlign.center,
                      style: AppStyle.txtSFProDisplayLight14Black,
                    ),
                    SizedBox(
                      height: getVerticalSize(30),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          height: getVerticalSize(
                            32,
                          ),
                          width: getHorizontalSize(
                            104,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          text: "отменить".toUpperCase(),
                        ),
                        SizedBox(
                          width: getVerticalSize(10),
                        ),
                        CustomButton(
                          height: getVerticalSize(
                            32,
                          ),
                          width: getHorizontalSize(
                            128,
                          ),
                          onTap: () {
                            onConfirm();
                          },
                          text: "Восстановить".toUpperCase(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
