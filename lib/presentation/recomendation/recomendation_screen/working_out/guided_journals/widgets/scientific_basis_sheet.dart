import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// Same bottom-sheet shape as AudioTrackSheet (portrait module) — grab
// handle, title, body, close button — reused here so the "[i]" info
// affordance on a Guided Journal topic looks like the rest of the app,
// not a one-off new pattern.
class ScientificBasisSheet extends StatelessWidget {
  final String text;

  const ScientificBasisSheet({Key? key, required this.text}) : super(key: key);

  static void show(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ScientificBasisSheet(text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(left: 20, right: 20, top: 24, bottom: 32),
      decoration: BoxDecoration(
        color: ColorConstant.whiteA700,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          Text('guided_journal_scientific_basis_title'.tr(), style: AppStyle.txtH2),
          SizedBox(height: getVerticalSize(14)),
          Text(text, style: AppStyle.txtSFProDisplayLight16.copyWith(height: 1.5)),
          SizedBox(height: getVerticalSize(20)),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr(), style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
            ),
          ),
        ],
      ),
    );
  }
}
