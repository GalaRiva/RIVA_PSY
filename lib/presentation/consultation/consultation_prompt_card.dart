import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'consultation_screen.dart';

// RU-only nudge shown at the end of the Path — the moment the "иногда
// упражнений недостаточно" framing on ConsultationScreen itself is most
// relevant, right after someone has just worked through an emotion.
class ConsultationPromptCard extends StatelessWidget {
  const ConsultationPromptCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ConsultationScreen()),
      ),
      // Was a solid-white card with the same drop shadow as the practices
      // panel above it — same visual weight, so it read as another primary
      // content block instead of the secondary, footer-level nudge it
      // actually is. A soft tint + thin border (no shadow) keeps it
      // legible and tappable without competing.
      child: Container(
        padding: getPadding(left: 18, top: 14, right: 14, bottom: 14),
        decoration: BoxDecoration(
          color: ColorConstant.cyan700.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorConstant.cyan700.withOpacity(0.14), width: 1),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/consultation_therapist.jpg',
                width: getSize(44),
                height: getSize(44),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: getHorizontalSize(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'consultation_prompt_title'.tr(),
                    style: AppStyle.txtSFProDisplayRegular14
                        .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'consultation_prompt_subtitle'.tr(),
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ColorConstant.cyan700),
          ],
        ),
      ),
    );
  }
}
