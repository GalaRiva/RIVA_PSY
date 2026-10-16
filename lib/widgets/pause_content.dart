import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/size_utils.dart';
import '../theme/app_style.dart';

// "Getting very hard during an exercise": stop and come back to yourself —
// a pause instruction only (breathing + grounding). Helplines/crisis numbers
// are a separate thing and live on Settings -> "Мне сейчас тяжело"
// (HelpNowScreen); they are intentionally not mixed in here.
class PauseContent extends StatelessWidget {
  const PauseContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('helpnow_pause'.tr(), style: body),
        SizedBox(height: getVerticalSize(14)),
        Text('helpnow_pause_back'.tr(), style: body),
      ],
    );
  }
}

// Same shape as ScientificBasisSheet — grab handle, title, body, close.
void showPauseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Container(
      padding: getPadding(left: 20, right: 20, top: 24, bottom: 32),
      decoration: BoxDecoration(
        color: ColorConstant.whiteA700,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorConstant.gray50,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: getVerticalSize(18)),
            Text('helpnow_sheet_title'.tr(), style: AppStyle.txtH2),
            SizedBox(height: getVerticalSize(14)),
            const PauseContent(),
            SizedBox(height: getVerticalSize(16)),
            Center(
              child: Builder(
                builder: (ctx) => TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('close'.tr(),
                      style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
