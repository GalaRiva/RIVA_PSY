import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import 'course_ui.dart';

/// A folding block: one line when closed, the content when opened.
class CourseFold extends StatefulWidget {
  final IconData icon;
  final String title;
  final int? count;
  final Widget child;
  final bool initiallyOpen;
  const CourseFold(
      {Key? key, required this.icon, required this.title, required this.child, this.count, this.initiallyOpen = false})
      : super(key: key);

  @override
  State<CourseFold> createState() => _CourseFoldState();
}

class _CourseFoldState extends State<CourseFold> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            label: widget.title,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _open = !_open),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: getPadding(left: 16, right: 12),
                  child: Row(
                    children: [
                      Icon(widget.icon, size: getSize(20), color: AppColors.primary),
                      SizedBox(width: getHorizontalSize(10)),
                      Expanded(
                        child: Text(widget.title + (widget.count != null ? '  ·  ${widget.count}' : ''),
                            style: AppStyle.txtSFProDisplayLight16
                                .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(Icons.expand_more_rounded, color: courseMuted(false), size: getSize(26)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(padding: getPadding(left: 16, right: 16, bottom: 14), child: widget.child)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
