import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/models/pill_model.dart';
import 'package:listenmebaby71_s_application17/theme/app_style.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../initial_setup/sign_in/presentation/sign_in_screen/text_input_login_formatter.dart';
import 'controller.dart';

class PillsEditBottomSheet extends StatelessWidget {
  final PillModel pill;

  const PillsEditBottomSheet({Key? key, required this.pill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PillsEditBottomSheetController());
    controller.init(pill);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: size.height - (size.height / 3),
        child: Card(
          color: ColorConstant.gray300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: getPadding(left: 16, right: 16, top: 35),
            child: Stack(
                children: [
            SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(
                height: getVerticalSize(20),
          ),
          Text(
            'Редактирование напоминания',
            style: AppStyle.txtSFProDisplayLight16
                .copyWith(color: ColorConstant.gray800),
          ),
          SizedBox(
            height: getVerticalSize(30),
          ),
          Text(
            'Редактировать название лекарства или витамина',
            style: AppStyle.txtSFProDisplayLight11
                .copyWith(color: ColorConstant.gray800)
                .copyWith(fontWeight: FontWeight.w300),
          ),
          SizedBox(
            height: getVerticalSize(11),
          ),
          CustomTextFormField(
            controller: controller.nameController,
            counterText: '',
            variant: TextFormFieldVariant.FillGray200,
            hintText: pill.name,
            formatter: [TextInputLoginFormatter()],
            validator: (text) {
              if (text!.isEmpty)
                return 'Введите название препарата';
            },
          ),
          SizedBox(
            height: getVerticalSize(21),
          ),
          GetBuilder(
            builder: (PillsEditBottomSheetController _c) =>
                CustomButton(
                    height: getVerticalSize(32),
                    width: getHorizontalSize(size.width - 32),
                    fontStyle:
                    ButtonFontStyle.SFProDisplayRegular12Gray,
                    suffixWidget: CustomImageView(
                      svgPath: ImageConstant.imgCalendar,
                      height: getVerticalSize(23),
                      margin: getMargin(left: 10),
                      width: getVerticalSize(23),
                    ),
                    onTap: () =>
                        controller
                            .setDurationOfReception(context),
                    text: controller.getDurationText(),
                    padding: ButtonPadding.PaddingT8,
                    alignment: Alignment.center),
          ),
          SizedBox(
            height: getVerticalSize(21),
          ),
          GetBuilder(
            builder: (PillsEditBottomSheetController _c) =>
                Wrap(
                  direction: Axis.horizontal,
                  spacing: getHorizontalSize(15),
                  children: List<Widget>.generate(
                      controller.time.length, (index) {
                    final e = controller.time[index];
                    return CustomButton(
                      height: getVerticalSize(32),
                      width: getHorizontalSize(100),
                      centralWidget: CustomImageView(
                        svgPath: ImageConstant.imageClock,
                        height: getVerticalSize(23),
                        width: getVerticalSize(23),
                      ),
                      prefixWidget: Text(e,
                          style: AppStyle.txtSFProDisplayLight11
                              .copyWith(
                              color: ColorConstant.gray800)),
                      suffixWidget: Text(
                        'ред',
                        style: AppStyle
                            .txtSFProDisplayLight11Deeppurple600,
                      ),
                      padding: ButtonPadding.PaddingT8,
                      margin: getMargin(bottom: 21),
                      onTap: () =>
                          controller.addTime(
                              context: context, itemIndex: index),
                    );
                  }),
                ),
          ),
          GetBuilder(
            builder: (PillsEditBottomSheetController _c) =>
            controller.time.isNotEmpty
                ? CustomButton(
                height: getVerticalSize(32),
                onTap: () =>
                    controller.addTime(context: context),
                width: getHorizontalSize(180),
                fontStyle: ButtonFontStyle
                    .SFProDisplayRegular12Gray,
                suffixWidget: CustomImageView(
                  svgPath: ImageConstant.imgAdd,
                  height: getHorizontalSize(14),
                  width: getHorizontalSize(14),
                  margin: getMargin(left: 5),
                ),
                text: "Добавить время приёма"
                    .toUpperCase(),
                padding: ButtonPadding.PaddingT8,
                alignment: Alignment.center)
                : CustomButton(
                height: getVerticalSize(32),
                width: getHorizontalSize(size.width - 32),
                fontStyle: ButtonFontStyle
                    .SFProDisplayRegular12Gray,
                suffixWidget: CustomImageView(
                  svgPath: ImageConstant.imageClock,
                  onTap: () =>
                      controller.addTime(
                          context: context),
                  height: getHorizontalSize(23),
                  width: getHorizontalSize(23),
                ),
                text:
                "Установить время приёма".toUpperCase(),
                padding: ButtonPadding.PaddingT8,
                alignment: Alignment.center),
          ),
          Padding(
            padding: getPadding(top: 21),
            child: GetBuilder(
              builder: (PillsEditBottomSheetController _c) => Text(pill.actual
                  ?
              'Убрать напоминание из актуальных препаратов для приема'
                  : 'Добавить напоминание в список актуальных препаратов для приема',
                  style: AppStyle.txtSFProDisplayLight11
                      .copyWith(color: ColorConstant.gray800)
                  .copyWith(fontWeight: FontWeight.w300),
          ),
            ),
        ),
        GetBuilder(
          builder: (PillsEditBottomSheetController _c) =>
              CustomButton(
                height: getVerticalSize(32),
                width: getHorizontalSize(186),
                onTap: controller.actualChange,
                fontStyle:
                ButtonFontStyle.SFProDisplayRegular12Gray,
                text:
                "${controller.actual ? 'отменить приём -' : 'возобновить приём'}"
                    .toUpperCase(),
                padding: ButtonPadding.PaddingT8,
                alignment: Alignment.center,
              ),
        ),
        Container(
          margin: getMargin(bottom: 61),
          padding: getPadding(top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                  height: getVerticalSize(32),
                  width: getHorizontalSize(186),
                  onTap: () async =>
                  await controller.editPill(context),
                  text: "сохранить".toUpperCase(),
                  padding: ButtonPadding.PaddingT8,
                  variant: ButtonVariant.White24,
                  alignment: Alignment.center),
              CustomButton(
                  height: getVerticalSize(32),
                  width: getHorizontalSize(186),
                  onTap: () => Navigator.pop(context),
                  text: "отменить".toUpperCase(),
                  padding: ButtonPadding.PaddingT8,
                  variant: ButtonVariant.White24,
                  alignment: Alignment.center),
            ],
          ),
        )
        ],
      ),
      ),
      Container(
      height: getVerticalSize(20),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
      ColorConstant.gray300,
      ColorConstant.gray300.withOpacity(0)
      ])),
      )
      ],
      ),
      )
      )
      ),
    );
  }
}
