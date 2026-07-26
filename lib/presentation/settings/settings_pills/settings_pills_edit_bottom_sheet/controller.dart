import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/text_field_formatters/text_field_time_formatter.dart';

import '../../../../core/services/workmanager/workmanager_service.dart';
import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_message_box.dart';
import '../models/pill_model.dart';
import '../repository.dart';
import '../../../../core/utils/date_extension.dart';

class PillsEditBottomSheetController extends GetxController {

  @override
  void init(PillModel pill) {
    pillModel = pill;
    nameController.text = pillModel.name;
    _startDate = pillModel.startDate;
    _endDate = pillModel.endDate;
    actual = pillModel.actual();
    time = pillModel.hoursOfTakingPills.getRange(0, pillModel.hoursOfTakingPills.length).toList();
  }

  late PillModel pillModel;

  bool loading = true;

  final _repo = PillsRepo();
  final nameController = TextEditingController();
  List<String> time = [];

  DateTime? _startDate;
  DateTime? _endDate;
  late bool actual;

  String getDurationText () {
    if(_startDate == null || _endDate == null) return 'set_reception_duration'.tr().toUpperCase();
    return '${(_startDate!).dateInText()} - ${_endDate!.dateInText()}'.toUpperCase();
  }

  void addTime({int? itemIndex, required BuildContext context}) {
    final timeController = itemIndex == null
        ? TextEditingController()
        : TextEditingController(text: time[itemIndex]);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Color lineColor = ColorConstant.fromHex('#3B3B4A');
          return GetBuilder(
            builder: (PillsEditBottomSheetController _c) => CustomMessageBox(
              height: getVerticalSize(300),
              title: 'reminder_n'.tr(args: ['${time.length + 1}']),
              content: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: getVerticalSize(44),
                    ),
                    Text(
                      'set_reception_time'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'SF Pro Display'),
                    ),
                    Padding(
                      padding: getPadding(top: 20),
                      child: SizedBox(
                        height: getVerticalSize(17),
                        child: TextFormField(
                          onChanged: (text) {},
                          textAlign: TextAlign.center,
                          maxLength: 5,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [TextFieldTimeFormatter()],
                          style: TextStyle(
                              color: ColorConstant.fromHex('#3B3B4A'),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'SF Pro Display'),
                          decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                  gapPadding: 0, borderSide: BorderSide.none)),
                          controller: timeController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: getPadding(top: 6),
                      child: Container(
                        color: lineColor,
                        width: getHorizontalSize(102),
                        height: 1,
                      ),
                    ),
                    CustomButton(
                        height: getVerticalSize(32),
                        width: getHorizontalSize(186),
                        onTap: () async {
                          final text = timeController.text;
                          if (text.length < 5 ||
                              int.parse(text[0] + text[1]) > 24 ||
                              int.parse(text[3] + text[4]) > 60)
                            lineColor = Colors.red;
                          else {
                            lineColor = ColorConstant.fromHex('#3B3B4A');
                            if (itemIndex != null) {
                              time[itemIndex] = text;
                            } else {
                              time.add(text);
                            }
                            Navigator.pop(context, text);
                          }
                          update();
                        },
                        text: 'save'.tr().toUpperCase(),
                        padding: ButtonPadding.PaddingT8,
                        alignment: Alignment.center),
                  ],
                ),
              ),
            ),
          );
        });
    update();
  }

  void setDurationOfReception(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.pills_calendar).then((value) {
      value as Map<String, dynamic>?;
      try {
        if (value != null) {
          _startDate = value['start'];
          _endDate = value['end'];
          update();
        }
      } catch (_) {
        print(_.toString());
      }
    });
  }

  Future editPill(BuildContext context) async {
    final newPill = PillModel(
        name: nameController.text,
        hoursOfTakingPills: time,
        createDate: pillModel.createDate,
        startDate: _startDate!, endDate: !actual && _endDate!.isAfter(DateTime.now()) ? DateTime.now().add(Duration(seconds: -1)) : _endDate!, adoptions: pillModel.adoptions);
    final list = await _repo.getEvent();
    for (int i = 0; i < list.length; i++) {

      if (list[i].toJson().toString() == pillModel.toJson().toString()) {
        list.insert(i, newPill);
        list.removeAt(i + 1);
        print('was updated');
      }
    }
    print(list.map((e) => e.toJson()).toList());
    await _repo.updateEvent(list);

    WorkManagerService().initService();
    Navigator.pop(context);
  }

  void actualChange() {
    actual = !actual;
    update();
  }
}
