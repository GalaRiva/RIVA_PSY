import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

class RetractableContainerWidget extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final String title;
  final String? subtitle;
  final String hintText;
  final VoidCallback? update;
  final Widget Function(String) child;
  final TextEditingController textController;

  const RetractableContainerWidget(
      {Key? key,
      required this.padding,
      required this.title,
      this.subtitle,
      required this.hintText,
      required this.child,
      this.update,
      required this.textController})
      : super(key: key);

  @override
  State<RetractableContainerWidget> createState() =>
      _RetractableContainerWidgetState();
}

class _RetractableContainerWidgetState extends State<RetractableContainerWidget>
    with TickerProviderStateMixin {
  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  bool wasTapped = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fadeController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.linear,
    ));

    // Visibility below stays mounted until the reverse animation actually
    // finishes (not just until wasTapped flips) — otherwise collapsing
    // unmounts the FadeTransition/SlideTransition on the same frame the
    // reverse animation starts, and the block just snaps shut instead of
    // animating closed.
    fadeController.addStatusListener(_handleFadeStatusChange);
  }

  void _handleFadeStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.dismissed ||
        status == AnimationStatus.completed) {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    fadeController.removeStatusListener(_handleFadeStatusChange);
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (wasTapped) {
      fadeController.reverse();
      slideController.reverse();
    } else {
      fadeController.forward();
      slideController.forward();
    }
    setState(() => wasTapped = !wasTapped);
    widget.update?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            // Whole row tappable (title + masked value + icon), not just a
            // small "Изменить" link — matches the login row above it. The
            // password-rules subtitle only shows once actually expanded
            // (below) — it was cluttering the summary row before, for a
            // rule that only matters while typing a new one.
            onTap: _toggle,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight16,
                      ),
                      Padding(
                        padding: getPadding(top: 8),
                        child: Text(
                          // Collapsed state used to render the real
                          // (disabled) text field here with an empty hint —
                          // visually a blank, seemingly-broken line with
                          // nothing to read or tap. A masked placeholder
                          // reads instead as "there is a password set, tap
                          // to change it" — the actual editable fields still
                          // only appear once expanded, below.
                          '••••••••',
                          style: AppStyle.txtSFProDisplayRegular14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  wasTapped ? Icons.close : Icons.edit_outlined,
                  color: ColorConstant.cyan700,
                  size: getSize(20),
                ),
              ],
            ),
          ),
          Visibility(
              visible: wasTapped || fadeController.status != AnimationStatus.dismissed,
              child: FadeTransition(
                  opacity: fadeController,
                  child: Padding(
                    padding: getPadding(top: 16),
                    child: SlideTransition(
                        position: slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.subtitle != null)
                              Padding(
                                padding: getPadding(bottom: 12),
                                child: Text(widget.subtitle!,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight12
                                        .copyWith(
                                            color: ColorConstant.gray500)),
                              ),
                            widget.child(widget.textController.text),
                          ],
                        )),
                  )))
        ],
      ),
    );
  }
}
