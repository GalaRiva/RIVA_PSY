import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

/// The "how to live through this emotion" popup (SelectButtonWidget, on the
/// negative-emotions tabs). A calm white card with a soft shadow: a green
/// title, a round close button, and the text as short paragraphs (one per
/// sentence) with generous line height.
///
/// Wrapped in its own transparent [Material]: `showDialog` gives the content no
/// Material ancestor, and the close button's ink splash needs one (in debug
/// builds its absence is a red "No Material widget found" error screen).
class ExerciseInstructionDialog extends StatelessWidget {
  final String title;
  final String content;

  const ExerciseInstructionDialog({Key? key, required this.title, required this.content}) : super(key: key);

  List<String> get _paragraphs =>
      content.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty && e != '.').toList();

  @override
  Widget build(BuildContext context) {
    final paragraphs = _paragraphs;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: getHorizontalSize(340),
            maxHeight: size.height * 0.72,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.16),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: getPadding(top: 22, left: 24, right: 14, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            title,
                            style: AppStyle.txtH1.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: getFontSize(22),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: getHorizontalSize(8)),
                      Semantics(
                        button: true,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
                              child: Icon(Icons.close_rounded, size: 18, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: getPadding(left: 24, right: 24, top: 8, bottom: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in paragraphs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              p,
                              style: AppStyle.txtSFProDisplayLight16.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
