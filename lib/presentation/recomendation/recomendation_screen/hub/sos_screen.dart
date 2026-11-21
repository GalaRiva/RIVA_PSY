import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/helpline_link.dart';

import '../working_out/programs/pages/breathing_screen.dart';

/// "Мне тяжело сейчас": two quick, calm ways in (breathing with an on-screen
/// guide, or the audio and exercises for panic and affect) and the always
/// visible 112 line. Nothing here is behind a subscription or an account.
class SosScreen extends StatelessWidget {
  /// Opens the panic / affect tab of "Справиться с эмоцией" (supplied by the
  /// hub, which knows where that tab is).
  final VoidCallback onListen;
  const SosScreen({Key? key, required this.onListen}) : super(key: key);

  Widget _card(BuildContext context,
      {required String image,
      required String kicker,
      required String title,
      required String sub,
      required VoidCallback onTap}) {
    return Padding(
      padding: getPadding(bottom: 12),
      child: Semantics(
        button: true,
        label: '$title. $sub',
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: getVerticalSize(112)),
                child: Stack(
                  children: [
                    Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
                    Positioned.fill(child: Container(color: const Color(0xFF0A1C1E).withOpacity(0.5))),
                    Padding(
                      padding: getPadding(left: 16, right: 16, top: 14, bottom: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(kicker.toUpperCase(),
                                    style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                        fontSize: getFontSize(11), letterSpacing: 0.7, color: const Color(0xFFCFE3DF))),
                                SizedBox(height: getVerticalSize(2)),
                                Text(title,
                                    style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                        fontSize: getFontSize(18), fontWeight: FontWeight.w600, color: Colors.white)),
                                SizedBox(height: getVerticalSize(2)),
                                Text(sub,
                                    style: AppStyle.txtSFProDisplayRegular11
                                        .copyWith(fontSize: getFontSize(13), color: const Color(0xFFDBE7E5))),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: getPadding(left: 16, right: 16, top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('sos_sub'.tr(),
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textSecondary, height: 1.5)),
          SizedBox(height: getVerticalSize(14)),
          _card(context,
              image: 'assets/images/hub/star_13.jpg',
              kicker: 'sos_minutes_1'.tr(),
              title: 'sos_breathe'.tr(),
              sub: 'sos_breathe_sub'.tr(),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingScreen()))),
          _card(context,
              image: 'assets/images/hub/star_10.jpg',
              kicker: 'sos_minutes_5'.tr(),
              title: 'sos_listen'.tr(),
              sub: 'sos_listen_sub'.tr(),
              onTap: onListen),
          SizedBox(height: getVerticalSize(4)),
          const HelplineLink(),
        ],
      ),
    );
  }
}
