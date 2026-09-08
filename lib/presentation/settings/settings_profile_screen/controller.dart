import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';
import 'package:riva_psy/core/utils/string_extension.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../core/services/datasource_service.dart';
import '../../../core/user_data/user.dart';
import '../../../core/utils/color_constant.dart';
import '../../../core/utils/size_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_message_box.dart';
import '../../initial_setup/sign_in/services/services_auth_service.dart';
import 'text_field_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/db/firebase_firestore/data/repository.dart';

class K18Controller extends GetxController {
  final oldController =
      TextEditingController(text: CurrentUser.user.old.toString());
  final loginController = TextEditingController(text: CurrentUser.user.login!);
  final newPasswordController = TextEditingController();
  final passwordRepeatController = TextEditingController();
  final oldPasswordController = TextEditingController();

  final instance = FirebaseFirestore.instance;
  final _authInstance =           FirebaseAuth.instance;

  Future saveData(context) async {
    try {
      final fireStoreRepo = FireStoreRepositoryImpl();
      bool goNext = true;
      if (newPasswordController.text != '' &&
          passwordRepeatController.text != '' &&
          oldPasswordController.text != '')
        goNext = await _checkPassword(context);
      if (goNext) {
        if (newPasswordController.text != '' &&
            passwordRepeatController.text != '' &&
            oldPasswordController.text != '') {

          final credential = EmailAuthProvider.credential(email: CurrentUser.repo.userId(), password: newPasswordController.text);
          _authInstance.currentUser!.reauthenticateWithCredential(credential).catchError(() async {
            showDialog(
                context: context,
                builder: (context) => CustomMessageBox(
                    title: 'profile'.tr(),
                    content: 'couldnt_change_password'.tr()));
          }).then((value) async {
            await fireStoreRepo.updateUserDataPassword(
                password: newPasswordController.text);
          });

        }
        String? login;
        int? old;
        bool? gender;
        if (loginController.text != CurrentUser.user.login!)
          login = loginController.text;
        if (int.parse(oldController.text) != CurrentUser.user.old!)
          old = int.parse(oldController.text);
        gender = CurrentUser.user.male;
        CurrentUser.repo.setLocalUserData(login: login, male: gender, old: old);
        FireStoreRepositoryImpl().updateUser(userId: CurrentUser.repo.userId() ,login: login, male: gender, old: old, create: false);
        showDialog(
                context: context,
                builder: (context) => CustomMessageBox(
                    title: 'profile'.tr(),
                    content: 'profile_data_changed'.tr()))
            .then((value) => Navigator.pop(context));
      }
    } catch (_) {
      print(_.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'network_error_try_later'.tr())));
    }
  }

  Future<bool> _checkPassword(context) async {
    final hash = (await instance
            .collection('UsersData')
            .doc(CurrentUser.repo.userId())
            .get())
        .data()!['password'];
    print(hash);
    print(oldPasswordController.text.md5());
    if (oldPasswordController.text.md5() != hash) {
      showDialog(
          context: context,
          builder: (context) => CustomMessageBox(
              title: 'profile'.tr(), content: 'wrong_old_password'.tr()));
      return false;
    }
    return true;
  }

  Future signOut(context) async {
    await FirebaseAuth.instance.signOut();
    CurrentUser.reset();
    DataSourceService.setRemoteDataSource();
    // Signing out drops back to the anonymous state, not a forced
    // registration screen — the app works the same way for a signed-out
    // user as it does for someone who never registered (splashScreen ->
    // K1Controller already handles "no Firebase Auth session" safely).
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.splashScreen, (route) => false);
    AppRoutes.currentRoute = AppRoutes.main;
  }

  Future showLoginDialog(BuildContext context, K18Controller controller) =>
      showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            Color lineColor = ColorConstant.fromHex('#3B3B4A');
            return GetBuilder(
              builder: (K18Controller _c) => CustomMessageBox(
                // Was 200 — too tight for the title + current-login hint +
                // input field + divider + Cancel/Save button row, which
                // overflowed the fixed-height box (see CustomMessageBox)
                // and left everything cramped/overlapping.
                height: 280,
                title: 'profile'.tr(),
                content: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: getVerticalSize(44),
                      ),
                      Text(
                        'change_login'.tr(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Manrope'),
                      ),
                      Padding(
                        padding: getPadding(top: 20, left: 24, right: 24),
                        // Was wrapped in a fixed `SizedBox(height: 17)` — too
                        // tight for 14sp text to render without clipping
                        // descenders (е.g. "р"/"у" tails cut off, reading as
                        // mangled/different letters). Sized naturally now,
                        // with isDense + a small contentPadding to stay
                        // compact instead of pulling in TextFormField's
                        // normal (much taller) default padding.
                        child: TextFormField(
                          inputFormatters: [TextInputLoginFormatter()],
                          onFieldSubmitted: (text) {
                            if (text.isEmpty)
                              lineColor = Colors.red;
                            else {
                              lineColor = ColorConstant.fromHex('#3B3B4A');
                              Navigator.pop(context, text);
                            }
                            controller.update();
                          },
                          textAlign: TextAlign.center,
                          maxLength: 20,
                          style: TextStyle(
                              color: ColorConstant.fromHex('#3B3B4A'),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Manrope'),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: getVerticalSize(6)),
                              hintText: CurrentUser.user.login,
                              counterText: "",
                              border: OutlineInputBorder(
                                  gapPadding: 0,
                                  borderSide: BorderSide.none)),
                          controller: controller.loginController,
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'cancel'.tr(),
                                variant: ButtonVariant.White,

                                onTap: () {
                                 Navigator.pop(context);
                                },),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: CustomButton(
                                text: 'save'.tr(),
                                variant: ButtonVariant.White,
                                onTap: () {
                                  if (loginController.text.isEmpty)
                                    lineColor = Colors.red;
                                  else {
                                    lineColor = ColorConstant.fromHex('#3B3B4A');
                                    Navigator.pop(context, loginController.text);
                                  }
                                  controller.update();
                                },),
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });

  Future showOldDialog(BuildContext context, K18Controller controller) =>
      showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            Color lineColor = ColorConstant.fromHex('#3B3B4A');
            return GetBuilder(
              builder: (K18Controller _c) => CustomMessageBox(
                height: 200,
                title: 'profile'.tr(),
                content: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: getVerticalSize(44),
                      ),
                      Text(
                        'change_age'.tr(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Manrope'),
                      ),
                      Padding(
                        padding: getPadding(top: 20),
                        child: SizedBox(
                          height: getVerticalSize(17),
                          child: TextFormField(
                            onFieldSubmitted: (text) {
                              if (text.isEmpty)
                                lineColor = Colors.red;
                              else {
                                lineColor = ColorConstant.fromHex('#3B3B4A');
                                Navigator.pop(context, int.parse(text));
                              }
                              controller.update();
                            },
                            textAlign: TextAlign.center,
                            maxLength: 3,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: ColorConstant.fromHex('#3B3B4A'),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Manrope'),
                            decoration: InputDecoration(
                                hintText: CurrentUser.user.old.toString(),
                                counterText: "",
                                border: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: BorderSide.none)),
                            controller: controller.oldController,
                          ),
                        ),
                      ),
                      Padding(
                        padding: getPadding(top: 6, bottom: 20),
                        child: Container(
                          color: lineColor,
                          width: getHorizontalSize(102),
                          height: 1,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'cancel'.tr(),
                                variant: ButtonVariant.White,

                                onTap: () {
                                  Navigator.pop(context);
                                },),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: CustomButton(
                                text: 'save'.tr(),
                                variant: ButtonVariant.White,

                                onTap: () {
                                  if (controller.oldController.text.isEmpty)
                                    lineColor = Colors.red;
                                  else {
                                    lineColor = ColorConstant.fromHex('#3B3B4A');
                                    Navigator.pop(context, int.parse(controller.oldController.text));
                                  }
                                  controller.update();
                              },),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });

  Future<bool?> _showDeleteAccountConfirmDialog(BuildContext context) =>
      showDialog<bool>(
          context: context,
          builder: (context) => CustomMessageBox(
                height: 170,
                title: 'delete_account'.tr(),
                content: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: getPadding(left: 16, right: 16, top: 16),
                        child: Text(
                          'delete_account_confirm_body'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Manrope'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'cancel'.tr(),
                                variant: ButtonVariant.White,
                                onTap: () => Navigator.pop(context, false),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: CustomButton(
                                text: 'delete_account_confirm_cta'.tr(),
                                variant: ButtonVariant.White,
                                onTap: () => Navigator.pop(context, true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));

  Future<String?> _promptPasswordForDeletion(BuildContext context) {
    final passwordController = TextEditingController();
    return showDialog<String>(
        context: context,
        builder: (context) => CustomMessageBox(
              height: 170,
              title: 'delete_account'.tr(),
              content: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: getPadding(left: 16, right: 16, top: 16),
                      child: Text(
                        'delete_account_enter_password'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Manrope'),
                      ),
                    ),
                    Padding(
                      padding: getPadding(left: 16, right: 16, top: 12),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorConstant.fromHex('#3B3B4A'),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Manrope'),
                        decoration: InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(
                                gapPadding: 0, borderSide: BorderSide.none)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'cancel'.tr(),
                              variant: ButtonVariant.White,
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomButton(
                              text: 'ok'.tr(),
                              variant: ButtonVariant.White,
                              onTap: () =>
                                  Navigator.pop(context, passwordController.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  void _showSimpleError(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) =>
            CustomMessageBox(title: 'profile'.tr(), content: message));
  }

  Future<bool> _reauthenticateForDeletion(BuildContext context) async {
    final authService = CurrentUser.repo.authService;
    if (authService == 'apple') {
      return await ServicesAuthService().authWithApple();
    } else if (authService == 'google') {
      return await ServicesAuthService().authWithGoogle();
    }
    final password = await _promptPasswordForDeletion(context);
    if (password == null || password.trim().isEmpty) return false;
    final email = _authInstance.currentUser?.email ?? '';
    if (email.isEmpty) return false;
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await _authInstance.currentUser!.reauthenticateWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _performAccountDeletion(User user) async {
    await FireStoreRepositoryImpl()
        .deleteAccountData(userId: CurrentUser.repo.userId());
    await user.delete();
  }

  // App Store Guideline 5.1.1(v): since Sign in with Apple is offered, the
  // account and its data must be deletable from inside the app, not only via
  // support. Firebase requires a *recent* sign-in for currentUser.delete() —
  // re-running the same provider's sign-in flow (rather than
  // reauthenticateWithCredential for Apple, whose native credential
  // verification Firebase itself rejects — see authWithApple's own comment)
  // refreshes that recency for the same account before retrying.
  Future<void> deleteAccount(BuildContext context) async {
    final confirmed = await _showDeleteAccountConfirmDialog(context);
    if (confirmed != true) return;

    final user = _authInstance.currentUser;
    if (user == null) return;

    try {
      await _performAccountDeletion(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final reauthed = await _reauthenticateForDeletion(context);
        final freshUser = _authInstance.currentUser;
        if (!reauthed || freshUser == null) {
          _showSimpleError(context, 'delete_account_failed'.tr());
          return;
        }
        try {
          await _performAccountDeletion(freshUser);
        } catch (_) {
          _showSimpleError(context, 'delete_account_failed'.tr());
          return;
        }
      } else {
        _showSimpleError(context, 'delete_account_failed'.tr());
        return;
      }
    } catch (_) {
      _showSimpleError(context, 'delete_account_failed'.tr());
      return;
    }

    CurrentUser.reset();
    DataSourceService.setRemoteDataSource();
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.splashScreen, (route) => false);
    AppRoutes.currentRoute = AppRoutes.main;
  }

}
