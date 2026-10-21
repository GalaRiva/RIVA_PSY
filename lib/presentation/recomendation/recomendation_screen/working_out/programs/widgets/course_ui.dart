import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

// Small design kit shared by the Programs screens: quiet surfaces, soft
// shadows, capsule buttons, a cover header. Everything takes `dark` so the
// night screens (the night-thoughts audio and its box) use the same pieces.

const Color kNightBg = Color(0xFF0B1917);
const Color kNightAccent = Color(0xFF7FBDBA);

Color courseText(bool dark) => dark ? Colors.white : AppColors.textPrimary;
Color courseSoft(bool dark) => dark ? Colors.white70 : AppColors.textPrimary.withOpacity(0.78);
Color courseMuted(bool dark) => dark ? Colors.white54 : AppColors.textSecondary;
Color courseAccent(bool dark) => dark ? kNightAccent : AppColors.primary;

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool dark;
  final Color? color;
  final double radius;

  const SoftCard(
      {Key? key, required this.child, this.padding, this.onTap, this.dark = false, this.color, this.radius = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding ?? getPadding(left: 16, top: 14, right: 16, bottom: 14),
      decoration: BoxDecoration(
        color: color ?? (dark ? Colors.white.withOpacity(0.06) : AppColors.surface),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: dark ? Colors.white.withOpacity(0.08) : AppColors.divider),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: box),
    );
  }
}

class CapsuleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool dark;
  final IconData? icon;

  const CapsuleButton(
      {Key? key, required this.label, required this.onTap, this.outlined = false, this.dark = false, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = courseAccent(dark);
    final enabled = onTap != null;
    final fill = outlined ? Colors.transparent : accent;
    final fg = outlined ? accent : (dark ? kNightBg : Colors.white);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: fill,
          shape: StadiumBorder(side: outlined ? BorderSide(color: accent.withOpacity(0.55)) : BorderSide.none),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Container(
              height: getVerticalSize(52),
              width: double.infinity,
              alignment: Alignment.center,
              padding: getPadding(left: 20, right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: getSize(20), color: fg), SizedBox(width: getHorizontalSize(8))],
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: fg, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final bool dark;
  const SectionLabel(this.text, {Key? key, this.dark = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: AppStyle.txtSFProDisplayRegular11
            .copyWith(color: courseMuted(dark), letterSpacing: 1.1, fontWeight: FontWeight.w600));
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool onImage;

  const RoundIconButton(
      {Key? key, required this.icon, required this.onTap, required this.tooltip, this.onImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: getSize(40),
          height: getSize(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onImage ? Colors.black.withOpacity(0.28) : AppColors.surface,
          ),
          child: Icon(icon, size: getSize(22), color: onImage ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}

// Cover image fading into the page, with back/menu buttons on top and the
// title block sitting on the picture. [coverAsset] null -> a soft green gradient.
class CoverHeader extends StatelessWidget {
  final String? coverAsset;
  final double height;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget child;
  final bool dark;
  // Cover with the picture on the right (e.g. a bubble): darken only the
  // left, where the title sits, instead of the bottom.
  final bool leftScrim;

  const CoverHeader({
    Key? key,
    this.coverAsset,
    required this.height,
    this.onBack,
    this.actions = const [],
    required this.child,
    this.dark = false,
    this.leftScrim = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageBg = dark ? kNightBg : AppColors.background;
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (coverAsset != null)
                Image.asset(coverAsset!, fit: BoxFit.cover)
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary.withOpacity(0.85), AppColors.primary.withOpacity(0.55)],
                    ),
                  ),
                ),
              if (leftScrim) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black.withOpacity(0.62), Colors.black.withOpacity(0.0)],
                      stops: const [0.0, 0.66],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.28), Colors.black.withOpacity(0.0)],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              ] else
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.62),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              // Fade into the page so the cover doesn't end on a hard edge.
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: getVerticalSize(26),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [pageBg.withOpacity(0), pageBg],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // The title block decides the height (never less than [height]) and
        // always starts below the button row, so a long title can't run
        // under the back button.
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: getVerticalSize(height)),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  getHorizontalSize(20), top + getVerticalSize(64), getHorizontalSize(20), getVerticalSize(30)),
              child: child,
            ),
          ),
        ),
        // Buttons last = on top, so they always take the tap.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: getPadding(left: 14, right: 14, top: 6),
              child: Row(
                children: [
                  if (onBack != null)
                    RoundIconButton(icon: Icons.arrow_back_rounded, onTap: onBack!, tooltip: 'back'.tr()),
                  const Spacer(),
                  ...actions,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MetaPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  const MetaPill(this.text, {Key? key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(left: 10, right: 12, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: getSize(13), color: Colors.white), SizedBox(width: getHorizontalSize(5))],
          Text(text, style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

// Large system fonts are respected up to 1.3x so fixed-size pieces (covers,
// capsules, cards) never break the layout.
class CourseTextScale extends StatelessWidget {
  final Widget child;
  const CourseTextScale({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scale = mq.textScaler.scale(1.0).clamp(0.9, 1.3).toDouble();
    return MediaQuery(data: mq.copyWith(textScaler: TextScaler.linear(scale)), child: child);
  }
}
