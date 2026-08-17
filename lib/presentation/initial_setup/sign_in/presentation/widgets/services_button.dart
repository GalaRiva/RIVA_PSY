import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// Premium redesign: same glassCard surface language used elsewhere in the
// app (voice diary, audio carousel) instead of a bare sharp-cornered
// OutlinedButton — icon moved to the leading position, which reads more
// like a standard social-sign-in row.
Widget ServicesButton(
    {required String svgIcon,
    required String serviceName,
    required VoidCallback onTap}) {
  return Container(
    height: 56,
    decoration: AppDecoration.glassCard.copyWith(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImageView(
                svgPath: svgIcon,
                height: getSize(24),
                width: getSize(24),
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12,),
              Text(
                'continue_with_service'.tr(args: [serviceName]),
                style: AppStyle.txtSFProDisplayLight16.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.gray800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
