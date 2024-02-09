import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/theme/app_style.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../initial_setup/sign_in/presentation/sign_in_screen/text_input_login_formatter.dart';
import 'controller.dart';

class PillsAddBottomSheet extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    final controller = Get.put(PillsBottomSheetController(context));
    return Padding(
        padding: getPadding(left: 16, right: 16, top: 35, bottom: MediaQuery.of(context).viewInsets.bottom
        ),
        child: SizedBox(
            height: size.height - (size.height / 4),
            child: Container(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                        height: getVerticalSize(20),
                      ),

                        Text(
                          'Добавление препарата',
                          style: AppStyle.txtSFProDisplayLight16,
                        ),
                        SizedBox(
                          height: getVerticalSize(30),
                        ),
                        Text(
                          'Введите название лекарства или витамина',
                          style: AppStyle.txtSFProDisplayLight11.copyWith(
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.gray800),
                        ),
                        CustomTextFormField(
                          controller: controller.nameController,
                          counterText: '',
                          margin: getMargin(top: 11, bottom: 21),
                          variant: TextFormFieldVariant.FillGray200,
                          formatter: [TextInputLoginFormatter()],
                          hintText: 'Название',
                          validator: (text) {
                            if (text!.isEmpty)
                              return 'Введите название препарата';
                          },
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => CustomButton(
                              height: getVerticalSize(32),
                              width: getHorizontalSize(size.width - 32),
                              suffixWidget: CustomImageView(
                                svgPath: ImageConstant.imgCalendar,
                                color: Colors.black54,
                                height: getVerticalSize(23),
                                width: getVerticalSize(23),
                                margin: getMargin(left: 10),
                              ),
                              text: controller.getDurationText(),
                            fontStyle: ButtonFontStyle.SFProDisplayRegular12Gray,
                              padding: ButtonPadding.PaddingT8,
                              onTap: () =>
                                  controller.setDurationOfReception(context),
                              alignment: Alignment.center,
                          ),
                        ),
                        SizedBox(
                          height: getVerticalSize(21),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => SizedBox(
                            width: size.width - 32,
                            child: Wrap(

                              direction: Axis.horizontal,
                              spacing: getHorizontalSize(15),
                              children: List<Widget>.generate(controller.time.length, (index) {
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
                                        style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.gray800)),
                                    suffixWidget: Text(
                                      'ред',
                                      style: AppStyle
                                          .txtSFProDisplayLight11Deeppurple600,
                                    ),
                                    padding: ButtonPadding.PaddingT8,
                                    onTap: () => controller.addTime(
                                        context: context, itemIndex: index),);
                              }).toList(),
                            ),
                          ),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => controller
                                  .time.isNotEmpty
                              ? CustomButton(
                                  height: getVerticalSize(32),
                                  width: getHorizontalSize(180),
                                  onTap: () =>
                                      controller.addTime(context: context),
                                  suffixWidget: CustomImageView(
                                    margin: getMargin(left: 5),
                                    svgPath: ImageConstant.imgAdd,
                                    height: getVerticalSize(14),
                                    width: getVerticalSize(14),
                                  ),
                                  text: "Добавить время приёма".toUpperCase(),

                            fontStyle: ButtonFontStyle.SFProDisplayRegular12Gray,
                                  padding: ButtonPadding.PaddingT8,
                                  )
                              : CustomButton(
                                  height: getVerticalSize(32),
                                  width: getHorizontalSize(size.width - 32),
                                  suffixWidget: CustomImageView(
                                    margin: getMargin(left: 10),
                                    svgPath: ImageConstant.imageClock,
                                    height: getVerticalSize(23),
                                    width: getVerticalSize(23),
                                  ),
                                  onTap: () =>
                                      controller.addTime(context: context),
                                  text: "Установить время приёма".toUpperCase(),
                                  fontStyle: ButtonFontStyle.SFProDisplayRegular12Gray,
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
                                  onTap: () async {
                                      await controller.addPill(context);
                                  },
                                  text: "сохранить".toUpperCase(),
                                  padding: ButtonPadding.PaddingT8,
                                  alignment: Alignment.center),
                              CustomButton(
                                  height: getVerticalSize(32),
                                  width: getHorizontalSize(186),
                                  onTap: () => Navigator.pop(context),
                                  text: "отмена".toUpperCase(),

                                  padding: ButtonPadding.PaddingT8,
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
                        gradient: LinearGradient (
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ColorConstant.gray300,
                              ColorConstant.gray300.withOpacity(0)
                            ]

                        )
                    ),
                  )
                ],
              ),
            )));
  }
}
