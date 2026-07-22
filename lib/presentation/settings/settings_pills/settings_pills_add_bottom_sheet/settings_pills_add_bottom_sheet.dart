import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_style.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../initial_setup/sign_in/presentation/sign_in_screen/text_input_login_formatter.dart';
import '../widget/top_icon_button.dart';
import 'controller.dart';

class PillsAddBottomSheet extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    final controller = Get.put(PillsBottomSheetController(context));
    return Material(
      color: Colors.transparent,
      child: Padding(
          padding: getPadding(left: 16, right: 16, top: 35,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40
          ),
          child: Container(
            color: ColorConstant.gray300.withOpacity(1),
              height: (size.height - (size.height / 4)) + MediaQuery.of(context).viewInsets.bottom,
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
                          style: AppStyle.txtSFProDisplayLight14.copyWith(
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.gray800),
                        ),
                        SizedBox(
                          height: getVerticalSize(10),
                        ),
                        CustomTextFormField(
                          height: 70,
                          controller: controller.nameController,
                          counterText: '',
                          variant: TextFormFieldVariant.FillGray200,
                          formatter: [TextInputLoginFormatter()],
                          hintText: 'Название',
                          validator: (text) {
                            if (text!.isEmpty)
                              return 'Введите название препарата';
                          },
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => TopIconButton(
                            icon: CustomImageView(
                              onTap: () =>
                                  controller.setDurationOfReception(context),
                              svgPath: ImageConstant.imgCalendar,
                              color: Colors.black,
                              height: getVerticalSize(23),
                              width: getVerticalSize(23),
                              margin: getMargin(left: 10),
                            ),
                              title: controller.getDurationText(),

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
                                    height: getVerticalSize(50),
                                    width: getHorizontalSize(160),
                                    centralWidget: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(e,
                                          style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
                                    ),
                                    prefixWidget: CustomImageView(
                                      svgPath: ImageConstant.imageClock,
                                      height: getVerticalSize(23),
                                      width: getVerticalSize(23),
                                    ),
                                    suffixWidget: Text(
                                      'ред',
                                      style: AppStyle
                                          .txtSFProDisplayLight16DeepPurple,
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
                            margin: EdgeInsets.only(top: 20),
                                  height: getVerticalSize(50),
                                  width: double.infinity,
                                  onTap: () =>
                                      controller.addTime(context: context),
                                  suffixWidget: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Icon(Icons.add, color: ColorConstant.deepPurple600, size: 20,),
                                  ),
                                  text: "Добавить время приёма".toUpperCase(),
                            textStyle: AppStyle.txtSFProDisplayLight16DeepPurple,
                            fontStyle: ButtonFontStyle.SFProDisplayRegular12Gray,
                                  padding: ButtonPadding.PaddingT8,
                                  )
                              : TopIconButton(title: "Установить\nвремя приёма".toUpperCase(),
                          onTap: () =>  controller.addTime(context: context), icon: CustomImageView(
                                margin: getMargin(left: 10),
                                svgPath: ImageConstant.imageClock,
                                color: Colors.black,
                                height: getVerticalSize(23),
                                width: getVerticalSize(23),
                              ),)
                        ),
                        Container(
                          margin: getMargin(bottom: 61),
                          padding: getPadding(top: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                  width: getHorizontalSize(186),
                                  onTap: () async {
                                      await controller.addPill(context);
                                  },
                                  text: "сохранить".toUpperCase(),
                                  padding: ButtonPadding.PaddingT8,
                                  alignment: Alignment.center),
                              SizedBox(height: 20,),
                              CustomButton(
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
              ))),
    );
  }
}
