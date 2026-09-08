import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_radio_button.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_pop_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'controller.dart';
import 'widgets/retractable_container_widget.dart';
import '../../../theme/app_colors.dart';

class K18Screen extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K18Controller());
    final key = GlobalKey<FormState>();

    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: getPadding(left: 16, right: 16, bottom: 100),
                child: Form(
                  key: key,
                  // Anonymous (local-UUID-only) users have no Firebase Auth
                  // session — the form below assumes a real account at every
                  // save/password/logout action, so it's swapped for a plain
                  // "sign in / create an account" prompt instead of being
                  // left to silently fail or crash. On successful sign-in the
                  // onTap below navigates straight to AppRoutes.main instead
                  // of relying on this screen to refresh itself in place, so
                  // a plain one-off check here (like before) is enough — a
                  // GetBuilder wrapping the whole screen was tried instead
                  // and caused a live rebuild-loop crash on device (repeated
                  // "Looking up a deactivated widget's ancestor is unsafe" /
                  // RenderFlex overflow), so that's out.
                  child: Builder(
                    builder: (context) {
                      final isAnonymous = FirebaseAuth.instance.currentUser == null;
                      return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomAppBar(
                          widget: CustomPopButton(
                            text: 'settings'.tr(),
                          ),
                        ),
                        Padding(
                            padding: getPadding(top: 26),
                            child: Text('profile'.tr(),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtH1)),
                        if (isAnonymous) ...[
                          Padding(
                            padding: getPadding(top: 24),
                            child: Text(
                              'anonymous_profile_notice'.tr(),
                              textAlign: TextAlign.left,
                              style: AppStyle.txtSFProDisplayLight14Gray800,
                            ),
                          ),
                          CustomButton(
                            height: getVerticalSize(47),
                            width: double.infinity,
                            margin: getMargin(top: 24, bottom: 40),
                            text: 'account_required_cta'.tr().toUpperCase(),
                            variant: ButtonVariant.Cyan,
                            fontStyle: ButtonFontStyle.White16,
                            onTap: () {
                              // The sign-up/sign-in screens navigate to
                              // AppRoutes.main themselves on success (see
                              // K2Controller.goToMainOnSuccess) — checking
                              // FirebaseAuth's session state back here after
                              // the pop was unreliable (its authStateChanges
                              // stream briefly toggled null/non-null right
                              // around this moment on-device, 2026-09-06),
                              // so the screen that actually knows sign-in
                              // succeeded handles the navigation directly
                              // instead.
                              Navigator.pushNamed(
                                  context, AppRoutes.signUp,
                                  arguments: {
                                    'contextual': true,
                                    'goToMainOnSuccess': true,
                                  });
                            },
                          ),
                        ] else ...[
                        Padding(
                          padding: getPadding(top: 24),
                          child: Container(
                            width: double.infinity,
                            padding: getPadding(
                                left: 16, top: 18, right: 16, bottom: 4),
                            decoration: AppDecoration.outlineBluegray80014
                                .copyWith(
                                    borderRadius:
                                        BorderRadiusStyle.roundedBorder3,
                                    color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                        InkWell(
                          // The whole row is tappable now, not just a small
                          // text link — per feedback, "Изменить" text links
                          // read as visual noise; a trailing chevron plus a
                          // full-row tap target is the more modern pattern.
                          onTap: () async {
                            String result = await controller
                                .showLoginDialog(context, controller);
                            if (result != null) {
                              controller.update();
                            }
                          },
                          child: Padding(
                            padding: getPadding(top: 2, bottom: 18),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('login'.tr(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: AppStyle
                                                .txtSFProDisplayLight16),
                                        Padding(
                                          padding: getPadding(top: 8),
                                          child: GetBuilder(
                                            builder: (K18Controller _c) => Text(
                                                // A custom in-app
                                                // login/username can be unset
                                                // (never falls back to
                                                // anything on its own) —
                                                // showing nothing here read
                                                // as a blank, broken row
                                                // rather than "no custom
                                                // login set yet", so this
                                                // falls back to the actual
                                                // sign-in email, which is
                                                // never empty for a
                                                // non-anonymous account (this
                                                // whole section only shows
                                                // when !isAnonymous).
                                                controller.loginController.text
                                                        .isNotEmpty
                                                    ? controller
                                                        .loginController.text
                                                    : (FirebaseAuth.instance
                                                            .currentUser
                                                            ?.email ??
                                                        ''),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtSFProDisplayRegular14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: ColorConstant.cyan700,
                                      size: getSize(22)),
                                ]),
                          ),
                        ),
                        /*Padding(
                            padding: getPadding(top: 39),
                            child: Text("Номер телефона",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16)),*/

                        /*GetBuilder(
                          builder: (K18Controller _c) => Padding(
                              padding: getPadding(left: 3, top: 14),
                              child: Row(children: [
                                Text(controller.numberController.text,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayRegular14),
                                Spacer(),
                                InkWell(
                                  onTap: () async {
                                    String result = await controller
                                        .showNumberDialog(context, controller);
                                    if (result != null) {
                                      await controller.updateNumber(
                                          context, result);
                                      controller.update();
                                    }
                                  },
                                  child: Text("Изменить",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight12Deeppurple600.copyWith(
                                          decoration: TextDecoration.underline
                                      ))
                                ),
                              ])),
                        ),*/
                        /*Padding(
                            padding: getPadding(top: 9),
                            child: Divider(
                                height: getVerticalSize(1),
                                thickness: getVerticalSize(1),
                                color: ColorConstant.gray8008c)),*/
                        Visibility(
                          visible: CurrentUser.repo.authService.trim() == '',
                          child: GetBuilder(
                            builder: (K18Controller _c) => RetractableContainerWidget(
                              update: controller.update,
                              padding: getPadding(top: 39),
                              title: 'passwprd'.tr(),
                              subtitle:
                                  'password_should'.tr(),
                              hintText: '',
                              textController: controller.oldPasswordController,
                              child: (password) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'old_password'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16,
                                  ),
                                  Padding(
                                      padding: getPadding(left: 3, top: 16, bottom: 16),
                                      child:
                                      CustomTextFormField(
                                        focusNode: FocusNode(),
                                        isObscureText: false,
                                        controller: controller.newPasswordController,
                                        margin: getMargin(top: 16),
                                        maxLength: 26,
                                        variant: TextFormFieldVariant
                                            .UnderLineWhiteA700,
                                        counterText: '',
                                        fontStyle: TextFormFieldFontStyle
                                            .SFProDisplayRegular14,
                                        validator: (text) {
                                          if (text!.trim() != "")

                                          if(text.trim() != controller.newPasswordController.text) {
                                            return 'passwords_do_not_match'.tr();
                                          }
                                        },

                                      )),

                                  Text(
                                    'new_password'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16,
                                  ),
                                  Padding(
                                      padding: getPadding(left: 3, top: 16,bottom: 16),
                                      child:
                                      CustomTextFormField(
                                        focusNode: FocusNode(),
                                        isObscureText: false,
                                        controller: controller.passwordRepeatController,
                                        margin: getMargin(top: 16),
                                        maxLength: 26,
                                        variant: TextFormFieldVariant
                                            .UnderLineWhiteA700,
                                        counterText: '',
                                        fontStyle: TextFormFieldFontStyle
                                            .SFProDisplayRegular14,
                                        validator: (text) {
                                          if (controller.newPasswordController.text != '' || controller.passwordRepeatController.text.isNotEmpty || text!.trim() == "") return 'fill_the_field'.tr();

                                        },

                                      )),
                                  Text(
                                    'password_confirmation'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16,
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: getPadding(top: 16),
                          child: Container(
                            width: double.infinity,
                            padding: getPadding(
                                left: 16, top: 18, right: 16, bottom: 18),
                            decoration: AppDecoration.outlineBluegray80014
                                .copyWith(
                                    borderRadius:
                                        BorderRadiusStyle.roundedBorder3,
                                    color: Colors.white),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      int returnedValue = await controller
                                          .showOldDialog(context, controller);
                                      if (returnedValue != null) {
                                        controller.update();
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text('age'.tr(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.left,
                                                  style: AppStyle
                                                      .txtSFProDisplayLight16),
                                            ),
                                            Icon(Icons.edit_outlined,
                                                color: ColorConstant.cyan700,
                                                size: getSize(18)),
                                          ],
                                        ),
                                        Padding(
                                          padding: getPadding(top: 8),
                                          child: GetBuilder(
                                            builder: (K18Controller _c) => Text(
                                                controller.oldController.text,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtSFProDisplayRegular14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: getHorizontalSize(24)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('gender'.tr(),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style:
                                              AppStyle.txtSFProDisplayLight16),
                                      Padding(
                                        padding: getPadding(top: 12),
                                        child: GetBuilder(
                                          builder: (K18Controller _c) =>
                                              // Was a Row — "Мужской"/"Женский"
                                              // side by side could run past
                                              // this half-card's width
                                              // (especially on a narrower
                                              // phone or a longer
                                              // translation) and clip
                                              // "Женский" with no ellipsis.
                                              // Wrap lets the second option
                                              // drop to its own line instead
                                              // of being cut off.
                                              Wrap(runSpacing: 6, children: [
                                            CustomRadioButton(
                                                text: 'male'.tr(),
                                                isTrue: CurrentUser.user.male,
                                                value: '',
                                                fontStyle: CurrentUser
                                                        .user.male!
                                                    ? RadioFontStyle
                                                        .SFProDisplayBlack12
                                                    : RadioFontStyle
                                                        .SFProDisplayLight12,
                                                onChange: (value) async {
                                                  CurrentUser.user.male = true;
                                                  controller.update();
                                                }),
                                            CustomRadioButton(
                                                text: 'female'.tr(),
                                                value: '',
                                                isTrue: !CurrentUser.user.male!,
                                                iconSize:
                                                    getHorizontalSize(15),
                                                margin: getMargin(
                                                    left: 10, bottom: 1),
                                                fontStyle: !CurrentUser
                                                        .user.male!
                                                    ? RadioFontStyle
                                                        .SFProDisplayBlack12
                                                    : RadioFontStyle
                                                        .SFProDisplayLight12,
                                                onChange: (value) async {
                                                  CurrentUser.user.male =
                                                      false;
                                                  controller.update();
                                                })
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // Secondary action — outlined, no fill, so it
                            // doesn't visually compete with Save for
                            // attention.
                            Expanded(
                              child: CustomButton(
                                  height: getVerticalSize(47),
                                  text: 'cancel'.tr().toUpperCase(),
                                  margin: getMargin(top: 28),
                                  variant: ButtonVariant.OutlineGray,
                                  fontStyle: ButtonFontStyle.Gray16,
                                  onTap: () => onTaptf(context)),
                            ),
                            SizedBox(width: getHorizontalSize(12)),
                            // Primary action — the one clear visual leader
                            // on this screen: solid brand fill, white text.
                            Expanded(
                              child: CustomButton(
                                  height: getVerticalSize(47),
                                  text: 'save'.tr().toUpperCase(),
                                  margin: getMargin(top: 28),
                                  variant: ButtonVariant.Cyan,
                                  fontStyle: ButtonFontStyle.White16,
                                  onTap: () async =>
                                      key.currentState!.validate()
                                          ? await controller.saveData(context)
                                          : null),
                            ),
                          ],
                        ),
                        // Account actions live below the save/cancel pair,
                        // visually de-emphasized (text-only) so neither
                        // reads as a "confirm" action at a glance — logout
                        // is reversible and common enough to need no
                        // confirmation dialog, but shouldn't look like Save.
                        Padding(
                          padding: getPadding(top: 32),
                          child: Center(
                            child: InkWell(
                              onTap: () async => await controller.signOut(context),
                              child: Text(
                                'logout'.tr(),
                                textAlign: TextAlign.center,
                                style: AppStyle.txtSFProDisplayLight14Gray800
                                    .copyWith(
                                        decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: getPadding(top: 24, bottom: 8),
                          child: Center(
                            child: InkWell(
                              onTap: () => controller.deleteAccount(context),
                              child: Text(
                                'delete_account'.tr(),
                                textAlign: TextAlign.center,
                                style: AppStyle.txtSFProDisplayLight12Deeppurple600
                                    .copyWith(
                                        color: Colors.red,
                                        decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ]);
                    },
                  ),
                )),
          ),
        ),
        bottomNavigationBar:
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTaptf(BuildContext context) {
    Navigator.pop(context);
  }
}
