import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../theme/app_icons.dart';

/// Replaces CustomMessageBox for the "how to live through this emotion"
/// popups (SelectButtonWidget, under the audio players on the negative-
/// emotions tabs) — CustomMessageBox itself is shared across ~25 other
/// call sites (subscription dialogs, error messages, etc.), so redesigning
/// it directly would have touched all of them. This is a standalone
/// widget instead, purpose-built for a short instructional paragraph:
/// rounded card, soft shadow, generous line height and a real heading
/// style instead of the flat cyan header bar + 14px black text.
class ExerciseInstructionDialog extends StatelessWidget {
  final String title;
  final String content;

  const ExerciseInstructionDialog(
      {Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: getHorizontalSize(340),
          maxHeight: size.height * 0.72,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ColorConstant.whiteA700,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.cyan700.withOpacity(0.18),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: getPadding(top: 26, left: 26, right: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyle.txtH1.copyWith(
                          color: ColorConstant.cyan700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          AppIcons.x,
                          size: getSize(16),
                          color: ColorConstant.gray800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: getPadding(left: 26, right: 26, top: 12, bottom: 28),
                  child: Text(
                    content,
                    style: AppStyle.txtSFProDisplayLight16.copyWith(
                      color: ColorConstant.gray800,
                      height: 1.65,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
