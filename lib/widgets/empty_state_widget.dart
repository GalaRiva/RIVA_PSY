import 'package:flutter/material.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/size_utils.dart';
import '../theme/app_style.dart';

/// One shared "no data yet" placeholder — was previously plain centered
/// text, reimplemented slightly differently in each dashboard widget and
/// library screen. `dark` switches the title/subtitle tone for the app's
/// few dark-background modules (Хлебные крошки, Проекция Я); the icon
/// badge itself stays the same cyan-tinted circle everywhere, matching the
/// badge treatment already used for cards across the app.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool dark;
  final EdgeInsetsGeometry? padding;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.dark = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleColor = dark ? Colors.white.withOpacity(0.85) : ColorConstant.gray800;
    final subtitleColor = dark ? Colors.white.withOpacity(0.55) : ColorConstant.gray500;

    return Padding(
      padding: padding ?? getPadding(top: 32, bottom: 32, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: getSize(52),
            height: getSize(52),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorConstant.cyan700.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: getSize(24), color: ColorConstant.cyan700),
          ),
          SizedBox(height: getVerticalSize(12)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyle.txtSFProDisplayLight14.copyWith(color: titleColor, fontWeight: FontWeight.w600),
          ),
          if ((subtitle ?? '').trim().isNotEmpty) ...[
            SizedBox(height: getVerticalSize(6)),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: subtitleColor),
            ),
          ],
        ],
      ),
    );
  }
}
