import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/models/desire/desire.dart';

class DesireReportPath extends StatelessWidget {
  final List<Desire> desires;
  final Function()? onAdd;
  final Widget Function(Desire desire)? buildWidget;

  const DesireReportPath(
      {Key? key, required this.desires, this.onAdd, this.buildWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _desires = [...desires]..sort((d1, d2) => d2.dateOfExecution.compareTo(d1.dateOfExecution));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
          children: [
                SizedBox(
                  height: 70,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SvgPicture.asset(ImageConstant.desirePathStartSVG),
                      Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                            onTap: onAdd,
                            child: SvgPicture.asset(
                              ImageConstant.desireAddButtonSVG,
                              height: 60,
                            )),
                      ),
                    ],
                  ),
                ),
              ] +
              List.generate(
                  _desires.length,
                  (index) => SizedBox(
                      height: 109,
                      width: size.width - 20,

                      child: Stack(alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: index % 2 == 0
                                  ? 0
                                  : -4,
                              child: SvgPicture.asset(
                                index % 2 == 0
                                    ? ImageConstant.desirePath1SVG
                                    : ImageConstant.desirePath2SVG,
                                fit: BoxFit.contain,

                              ),
                            ),
                            if(buildWidget != null)
                              buildWidget!(_desires[index])

                          ]
                      ))) + List.generate(
              _desires.length > 6 ? 0 : 6 - _desires.length,
                  (index) => SizedBox(
                  height: 109,
                      width: size.width - 20,

                      child: Stack(alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: (_desires.length + index) % 2 == 0
                            ? 0
                            : -4,
                        child: SvgPicture.asset(
                          (_desires.length + index) % 2 == 0
                              ? ImageConstant.desirePath1SVG
                              : ImageConstant.desirePath2SVG,
                          fit: BoxFit.contain,

                        ),
                      ),

                    ]
                  )))),
    );
  }
}
