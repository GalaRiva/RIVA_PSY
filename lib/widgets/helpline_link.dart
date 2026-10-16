import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/crisis_links.dart';
import '../core/utils/size_utils.dart';
import '../theme/app_style.dart';

// Small, quiet "if it's hard right now" link — same type size and colour as
// the medical disclaimer it sits under, underlined so it reads as a link.
// No red, no alarm wording. The static "112" line is always visible so it
// still helps with no internet (the page itself opens in the browser).
class HelplineLink extends StatelessWidget {
  final Color? color;
  final bool center;

  const HelplineLink({Key? key, this.color, this.center = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? ColorConstant.gray500;
    final align = center ? TextAlign.center : TextAlign.left;
    return Padding(
      padding: getPadding(top: 6),
      child: Column(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            link: true,
            label: 'helpline_link'.tr(),
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => openHelplines(context),
              child: Padding(
                padding: getPadding(top: 4, bottom: 4),
                child: Text(
                  'helpline_link'.tr(),
                  textAlign: align,
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(
                    color: resolved,
                    decoration: TextDecoration.underline,
                    decorationColor: resolved,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'helpline_emergency'.tr(),
            textAlign: align,
            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: resolved),
          ),
        ],
      ),
    );
  }
}
