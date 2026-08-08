import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../core/models/tariff_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
import '../../../theme/app_colors.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K16Screen extends StatelessWidget {
  TextEditingController languageController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: getPadding(left: 16, right: 16, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomAppBar(widget: Row(
                              children: [
                                CustomPopButton(text: 'settings'.tr()),
                                Text('promo_breadcrumb'.tr(), style: AppStyle.txtSFProDisplayLight10Gray800,)
                              ],
                            ),),
                            Padding(
                                padding: getPadding(top: 26),
                                child: Text('promo_code'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Padding(
                                padding: getPadding(top: 27),
                                child: Text('enter_gift_code'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16)),
                            CustomTextFormField(
                                focusNode: FocusNode(),
                                controller: passwordController,
                                hintText: "*******",
                                margin: getMargin(left: 1, top: 56),
                                variant:
                                    TextFormFieldVariant.UnderLineGray8008c,
                                fontStyle: TextFormFieldFontStyle
                                    .SFProDisplayLight12,
                                textInputAction: TextInputAction.done),
                            CustomButton(
                                height: getVerticalSize(54),
                                width: getHorizontalSize(201),
                                text: 'send_code'.tr().toUpperCase(),
                                margin: getMargin(top: 61),
                                variant: ButtonVariant.OutlineBluegray60014,
                                padding: ButtonPadding.PaddingAll19,
                                fontStyle: ButtonFontStyle
                                    .SFProDisplayRegular12Cyan700,
                                onTap: () => onTaptf(context),
                                alignment: Alignment.center),
                            CustomButton(
                                width: getHorizontalSize(146),
                                text: 'subscription'.tr().toUpperCase(),
                                margin: getMargin(top: 61),
                                padding: ButtonPadding.PaddingT8,
                                prefixWidget: CustomImageView(
                                  margin: getMargin(right: 12),
                                  svgPath: ImageConstant.leftArrow,
                                ),
                                onTap: () => onTaptf1(context),
                                alignment: Alignment.center)
                          ])))),
        ),
        bottomNavigationBar:
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTaptf(BuildContext context) async {
    await K16Controller().submitPromo(passwordController.text, context);
  }

  onTaptf1(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.subscription);
  }
}
