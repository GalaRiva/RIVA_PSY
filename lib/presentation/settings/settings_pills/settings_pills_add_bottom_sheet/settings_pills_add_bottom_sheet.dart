import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_style.dart';
import 'package:riva_psy/widgets/chip_selector.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_button.dart';
import '../../../initial_setup/sign_in/presentation/sign_in_screen/text_input_login_formatter.dart';
import '../widget/duration_selector.dart';
import '../widget/medication_icon_color_picker.dart';
import '../widget/medication_name_field.dart';
import '../widget/medication_time_presets.dart';
import '../widget/top_icon_button.dart';
import 'controller.dart';
import '../../../../theme/app_icons.dart';

class PillsAddBottomSheet extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    final controller = Get.put(PillsBottomSheetController(context));
    return Material(
      color: Colors.transparent,
      child: Padding(
          // Left/right stay 0 here — this padding was pushing the whole
          // gray sheet in from the screen edges (shrinking it), when the
          // actual ask was room *inside* it. The inset below now lives on
          // the content itself instead.
          padding: getPadding(top: 35,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40
          ),
          child: Container(
            color: ColorConstant.gray300.withOpacity(1),
              height: (size.height - (size.height / 6)) + MediaQuery.of(context).viewInsets.bottom,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: getPadding(left: 24, right: 24),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                        height: getVerticalSize(20),
                      ),

                        Text(
                          'add_pill_dialog_title'.tr(),
                          style: AppStyle.txtH1,
                        ),
                        SizedBox(
                          height: getVerticalSize(30),
                        ),
                        Text(
                          'enter_medication_name'.tr(),
                          style: AppStyle.txtSFProDisplayLight16.copyWith(
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.gray800),
                        ),
                        SizedBox(
                          height: getVerticalSize(10),
                        ),
                        MedicationNameField(
                          controller: controller.nameController,
                          suggestions: medicationSuggestions(context.locale.languageCode),
                          hintText: 'medication_name_hint'.tr(),
                          validator: (text) {
                            if (text!.isEmpty)
                              return 'enter_medication_name_full'.tr();
                          },
                        ),
                        SizedBox(
                          height: getVerticalSize(21),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => MedicationIconColorPicker(
                            selectedIconType: controller.iconType,
                            selectedColor: controller.color,
                            onIconSelected: controller.setIconType,
                            onColorSelected: controller.setColor,
                          ),
                        ),
                        SizedBox(
                          height: getVerticalSize(30),
                        ),
                        Text(
                          'dosage_and_instructions'.tr(),
                          style: AppStyle.txtSFProDisplayLight16.copyWith(
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.gray800),
                        ),
                        SizedBox(
                          height: getVerticalSize(10),
                        ),
                        CustomTextFormField(
                          height: 50,
                          controller: controller.dosageController,
                          counterText: '',
                          variant: TextFormFieldVariant.FillGray200,
                          hintText: 'dosage_hint'.tr(),
                        ),
                        SizedBox(
                          height: getVerticalSize(14),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => ChipSelector<String>(
                            selected: controller.instructionTiming,
                            onSelected: controller.setInstructionTiming,
                            options: [
                              ChipOption(value: 'before_food', label: 'before_food'.tr()),
                              ChipOption(value: 'during_food', label: 'during_food'.tr()),
                              ChipOption(value: 'after_food', label: 'after_food'.tr()),
                              ChipOption(value: 'regardless_of_food', label: 'regardless_of_food'.tr()),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: getVerticalSize(30),
                        ),
                        Text(
                          'duration_label'.tr(),
                          style: AppStyle.txtSFProDisplayLight16.copyWith(
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.gray800),
                        ),
                        SizedBox(
                          height: getVerticalSize(10),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => DurationSelector(
                            selected: controller.durationType,
                            onSelected: controller.setDurationType,
                          ),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => controller.durationType != null
                              ? Padding(
                                  padding: getPadding(top: 10),
                                  child: Text(
                                    controller.getDurationText(),
                                    style: AppStyle.txtSFProDisplayLight14
                                        .copyWith(color: ColorConstant.gray800),
                                  ),
                                )
                              : SizedBox(),
                        ),
                        SizedBox(
                          height: getVerticalSize(30),
                        ),
                        Text(
                          'set_reception_time'.tr(),
                          style: AppStyle.txtSFProDisplayLight14.copyWith(
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.gray800),
                        ),
                        SizedBox(
                          height: getVerticalSize(10),
                        ),
                        GetBuilder(
                          builder: (PillsBottomSheetController _c) => ChipSelector<String>(
                            selected: null,
                            onSelected: (key) => controller.addPresetTime(medicationTimePresets[key]!),
                            options: medicationTimePresets.keys
                                .map((key) => ChipOption(
                                      value: key,
                                      label: '${key.tr()} (${medicationTimePresets[key]})',
                                    ))
                                .toList(),
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
                                      'edit_abbrev'.tr(),
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
                          builder: (PillsBottomSheetController _c) => CustomButton(
                            margin: EdgeInsets.only(top: 20),
                                  height: getVerticalSize(50),
                                  width: double.infinity,
                                  onTap: () =>
                                      controller.addTime(context: context),
                                  suffixWidget: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Icon(AppIcons.plus, color: ColorConstant.deepPurple600, size: 20,),
                                  ),
                                  text: 'add_appointment'.tr().toUpperCase(),
                            textStyle: AppStyle.txtSFProDisplayLight16DeepPurple,
                            fontStyle: ButtonFontStyle.SFProDisplayRegular12Gray,
                                  padding: ButtonPadding.PaddingT8,
                                  ),
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
                                  text: 'save'.tr().toUpperCase(),
                                  padding: ButtonPadding.PaddingT8,
                                  bgColor: ColorConstant.cyan700,
                                  textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                                  alignment: Alignment.center),
                              SizedBox(height: 20,),
                              CustomButton(
                                  width: getHorizontalSize(186),
                                  onTap: () => Navigator.pop(context),
                                  text: 'cancel_noun'.tr().toUpperCase(),
                                  showBorder: false,
                                  bgColor: Colors.transparent,
                                  padding: ButtonPadding.PaddingT8,
                                  alignment: Alignment.center),
                            ],
                          ),
                        )
                      ],
                      ),
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
