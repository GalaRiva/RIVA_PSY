import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/db/firebase_firestore/models/backup_model.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../../../widgets/custom_bottom_bar.dart';
import '../../../../widgets/custom_pop_button.dart';
import '../settings_data_and_recovery_screen/widgets/card_data_and_recovery_button_widget.dart';
import 'controller.dart';
import 'widgets/card_recovery_button_widget.dart';
import '../../../../theme/app_icons.dart';

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Google Drive';
    final controller = Get.put(RecoveryController(context));
    return Scaffold(
      bottomNavigationBar:
      CustomBottomBar(onChanged: (BottomBarEnum type) {}),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: getPadding(left: 16, right: 16, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            CustomAppBar(
            widget: CustomPopButton(
            text: 'Настройки',
            ),
          ),
          Padding(
              padding: getPadding(top: 25),
              child: Text("Восстановить",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle.txtH1)),
          Padding(
              padding: getPadding(top: 42),
              child: Text("Выберите резервную копию",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle.txtSFProDisplayLight16)),
          Padding(
            padding: getPadding(top: 40),
            child: GetBuilder(
              builder: (RecoveryController _c) => FutureBuilder(
                  future: controller.getRecoveryData(service),
                  builder: (context, AsyncSnapshot<List<BackupModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        color: ColorConstant.cyan700,);
                    }
                    return Wrap(
                      direction: Axis.vertical,
                      spacing: 1,
                      children: (snapshot.data ?? [])
                          .map((e) => CardRecoveryButtonWidget(
                          context, controller: controller,
                          title: e.date_time,
                          subTitle: e.record,
                          suffixWidget: InkWell(
                            onTap: () async {
                              await controller.deleteBackup(e);
                            },
                            child: Center(child: Icon(AppIcons.x, size: getVerticalSize(18), color: ColorConstant.deepPurple600,)),
                          ),
                          onTap: () => controller.setUpRecoveryData(e, service, context)))
                          .toList(),

                    );
                  }),
            ),
          )
              ]),
        ),
    ),
      ));
  }
}
