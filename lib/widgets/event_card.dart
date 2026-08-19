import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import '../../../core/utils/color_constant.dart';
import '../../../core/utils/size_utils.dart';
import '../../../theme/app_decoration.dart';
import '../../../theme/app_style.dart';
import '../../../widgets/custom_image_view.dart';
import 'emotion_color_blob.dart';

class EventCard extends StatelessWidget {
  final EventModel model;
  final double? cardWidth;
  final double? cardHeight;
  final VoidCallback? onTap;
  final String? suffix;
  final Color? iconColor;
  final bool isSelect;
  final bool? textIsFitted;
  // Explicit overrides for callers that want an icon/font size independent
  // of the cardHeight-proportional default (e.g. the main Path screens
  // wanting a modest bump without inflating the whole card). Leave null to
  // keep the normal proportional-to-cardHeight behavior.
  final double? iconSizeOverride;
  final double? fontSizeOverride;
  // Premium redesign: only the emotion-selection screens opt into this —
  // every other Path screen (places, people, activities) that also renders
  // through EventCard keeps its normal SVG icon.
  final EmotionMood? emotionMood;
  // Opt-in per call site: swaps the card's border outline for the soft
  // drop-shadow look used by the rest of the app's cards/buttons
  // (AppDecoration.outlineBluegray600143 et al.), without touching the many
  // other EventCard call sites that still rely on the bordered look.
  final bool useShadowStyle;
  // Opt-in per call site (like iconSizeOverride/fontSizeOverride) — the
  // corner radius was a flat 3px shared by all 17+ EventCard call sites
  // across the app. Left null keeps that exact existing look everywhere;
  // only screens that explicitly pass this get rounder corners.
  final double? borderRadiusOverride;
  const EventCard({Key? key, required this.model, this.onTap, this.suffix = '', this.cardHeight = 150, this.iconColor, required this.isSelect, this.textIsFitted, this.cardWidth, this.iconSizeOverride, this.fontSizeOverride, this.emotionMood, this.useShadowStyle = false, this.borderRadiusOverride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3.6;
    // Icon width is capped to the card's own width (minus padding) rather
    // than a flat screen-width fraction, so doubling the icon size below
    // doesn't overflow narrower cards.
    final iconWidth = (cardWidth ?? width) - 20;
    // Icon height scales with cardHeight (66 at the default 150) instead of
    // being a flat constant — compact cards (cardHeight: 44, used by
    // neutral_tab.dart and exercise_content_widget.dart) were getting the
    // same 66px icon as a full-size 150-tall card and blowing way past
    // their own bounds, wrecking the whole grid.
    final iconHeight = iconSizeOverride ?? ((cardHeight ?? 150) * 66 / 150);
    return InkWell(
      onTap: onTap,
      child: Container(
        // Was a fixed `height: cardHeight` — with iconSizeOverride pushing
        // the icon well past the size that formula originally budgeted
        // for, and up to 3 lines of wrapped text below it, the natural
        // content height regularly exceeded the fixed card height. Flutter
        // doesn't clip a Column that overflows its parent's tight height
        // constraint; it just renders past the box, so the "increase"
        // was actually happening but invisible/overlapping neighboring
        // cards instead of growing the card. minHeight lets the card grow
        // to fit its content instead, while keeping the same size for
        // cards whose content already fits.
        constraints: BoxConstraints(minHeight: cardHeight ?? 150),
        width:
          cardWidth ?? width
        ,
        decoration: BoxDecoration(
          color: ColorConstant.fromHex('#F6F5F6').withOpacity(0.77),
          borderRadius: BorderRadius.circular(
            getHorizontalSize(
              borderRadiusOverride ?? 3,
            ),
        ),
          border: useShadowStyle
              ? (isSelect
                  ? Border.all(color: ColorConstant.cyan700, width: 2)
                  : null)
              : Border.all(
                  color: isSelect
                      ? ColorConstant.cyan700
                      : ColorConstant.fromHex('#403875').withOpacity(0.22),
                  width: 1),
          boxShadow: useShadowStyle ? [
            BoxShadow(
              // Was a flat blueGray6001 4 shadow regardless of selection —
              // useShadowStyle cards had no persistent selected look at
              // all (no border either), so a tap only flashed the InkWell
              // ripple and then looked identical to unselected again.
              color: isSelect
                  ? ColorConstant.cyan700.withOpacity(0.35)
                  : ColorConstant.blueGray60014,
              spreadRadius: getHorizontalSize(isSelect ? 1 : 2),
              blurRadius: getHorizontalSize(isSelect ? 8 : 2),
              offset: Offset(0, isSelect ? 3 : 5),
            ),
          ] : null,
      ),
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            emotionMood == null
                ? CustomImageView(
                    alignment: Alignment.center,
                    svgPath: model.svgPath,
                    color: iconColor ?? ColorConstant.cyan700,
                    // BoxFit.scaleDown never scales an SVG past its own
                    // viewBox size — so raising iconSizeOverride/iconHeight
                    // had no visible effect, the icon was capped at its
                    // intrinsic size no matter how big the box got.
                    // BoxFit.contain scales up to fill the box too.
                    fit: BoxFit.contain,
                    height: getVerticalSize(
                      iconHeight,
                    ),
                    width:
                    iconWidth,
                    radius: BorderRadius.circular(
                      getHorizontalSize(
                        3,
                      ),
                    ),
                  )
                : EmotionBlob(
                    color: emotionBlobColor(model.identity, emotionMood!),
                    size: getVerticalSize(iconHeight).clamp(0, iconWidth),
                    pulse: isSelect,
                  ),
            SizedBox(
              height: getVerticalSize(model.localizedName.isEmpty ? 23 : 5),
            ),
            Visibility(
              visible: model.localizedName.isNotEmpty,
              child: text(),
            ),
          ],
        ),
      ),
    );
  }
  Widget text () {
    if(textIsFitted != null && textIsFitted! )
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
            model.localizedName + suffix!,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: AppStyle
                .txtSFProDisplayLight11Gray800
                .copyWith(fontSize: getFontSize(fontSizeOverride ?? 15))
        ),
      );
    else return Text(
        model.localizedName + suffix!,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: AppStyle
            .txtSFProDisplayLight11Gray800
            .copyWith(fontSize: getFontSize(fontSizeOverride ?? 15))

    );
  }

}

/// Abstract "color blob" standing in for an emotion's face icon — a soft
/// circle with a glow (per spec: BoxShape.circle + a wide-blur BoxShadow),
/// colored per emotionBlobColor(). When [pulse] is true (the emotion is
/// currently selected) it slowly breathes — grows and glows a touch more,
/// then eases back — instead of sitting static.
class EmotionBlob extends StatefulWidget {
  final Color color;
  final double size;
  final bool pulse;

  const EmotionBlob({required this.color, required this.size, this.pulse = false});

  @override
  State<EmotionBlob> createState() => EmotionBlobState();
}

class EmotionBlobState extends State<EmotionBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    if (widget.pulse) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant EmotionBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && oldWidget.pulse) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blobSize = widget.size <= 0 ? 40.0 : widget.size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = widget.pulse ? Curves.easeInOut.transform(_controller.value) : 0.0;
        final scale = 1.0 + (t * 0.1);
        final glow = 24 + (t * 12);
        final spread = 4 + (t * 3);
        return SizedBox(
          width: blobSize,
          height: blobSize,
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: blobSize * 0.72,
                height: blobSize * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.55),
                      blurRadius: glow,
                      spreadRadius: spread,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
