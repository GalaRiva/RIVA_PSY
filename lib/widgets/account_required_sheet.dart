import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_style.dart';
import '../core/utils/color_constant.dart';
import 'custom_button.dart';

/// Gate for actions that need a real account — subscription purchase,
/// Google Drive backup. Under the anonymous-first architecture an anonymous
/// user has no Firebase Auth session at all (see main.dart's routing), so
/// `currentUser == null` is exactly "hasn't registered yet".
class AccountRequiredSheet {
  /// Shows the explanation sheet if needed, and if the user proceeds, sends
  /// them through sign-up in "contextual" mode (skips the onboarding quiz,
  /// pops back here on success instead of restarting into the app). Returns
  /// true once a real account exists — either it already did, or the user
  /// just created/signed into one.
  static Future<bool> ensure(BuildContext context, {required String reason}) async {
    if (FirebaseAuth.instance.currentUser != null) return true;

    final proceed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AccountRequiredSheetContent(reason: reason),
    );
    if (proceed != true) return false;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.signUp,
      arguments: {'contextual': true},
    );
    return result == true;
  }
}

class _AccountRequiredSheetContent extends StatelessWidget {
  final String reason;
  const _AccountRequiredSheetContent({required this.reason});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFBFAF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('account_required_title'.tr(),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(reason, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
            const SizedBox(height: 20),
            CustomButton(
              height: 48,
              width: double.infinity,
              text: 'account_required_cta'.tr().toUpperCase(),
              bgColor: ColorConstant.cyan700,
              textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              onTap: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr(), style: const TextStyle(color: Colors.black54)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
