import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

// The app's small pop-up window (emotion intensity, body sensations, notices).
// Soft rounded card instead of a green strip: the title reads as a heading, the
// cross is a quiet round button, and the window grows with its content (it used
// to be a fixed height, which overflowed on longer lists). [height] is now the
// minimum height of the content area.
class CustomMessageBox extends StatelessWidget {
  final String title;
  final dynamic content;
  final double width;
  final Color? bgColor;
  final double height;
  final VoidCallback? onPop;
  final bool canPop;
  const CustomMessageBox(
      {Key? key,
      required this.title,
      required this.content,
      this.height = 150,
      this.onPop,
      this.canPop = true,
      this.width = 340,
      this.bgColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = (media.size.width - 32).clamp(240.0, 360.0);
    final maxH = media.size.height * 0.84;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: w,
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.background,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(22, 14, canPop ? 8 : 22, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope'),
                      ),
                    ),
                    if (canPop)
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        onPressed: () => onPop != null ? onPop!() : Navigator.pop(context),
                        icon: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
                          child: Icon(Icons.close_rounded, size: 18, color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: getVerticalSize(height)),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 18),
                      child: content is String
                          ? Padding(
                              padding: getPadding(all: 6),
                              child: Text(
                                content ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    height: 1.45,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'Manrope'),
                              ),
                            )
                          : content ?? Container(),
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
