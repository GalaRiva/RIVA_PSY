import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../models/course.dart';

// A saved "chain" card drawn as a chain of nodes (situation -> thoughts ->
// feelings -> body -> urge -> action -> after) so the person can literally
// see the sequence and where there was room for a different step.
class ChainVisual extends StatelessWidget {
  final List<CourseField> fields;
  final Map<String, String> values;

  const ChainVisual({Key? key, required this.fields, required this.values}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nodes = [for (final f in fields) if ((values[f.id] ?? '').isNotEmpty) f];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < nodes.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: getHorizontalSize(30),
                  child: Column(
                    children: [
                      Container(
                        width: getSize(22),
                        height: getSize(22),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstant.cyan700,
                        ),
                        child: Text('${i + 1}',
                            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white)),
                      ),
                      if (i != nodes.length - 1)
                        Expanded(
                          child: Container(width: 2, color: ColorConstant.cyan700.withOpacity(0.3)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: getPadding(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nodes[i].label,
                            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                        Text(values[nodes[i].id]!,
                            style: AppStyle.txtSFProDisplayLight16
                                .copyWith(color: ColorConstant.gray800, height: 1.35)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
