import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_button.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> labels;
  final List<Widget> tabs;
  final int initialPos;

  const CustomTabBar({Key? key, this.labels = const [], this.tabs = const [], this.initialPos = 0})
      : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<Offset> _animationLabel;

  late Animation<Offset> _animationTab1;
  late Animation<Offset> _animationTab2;

  int currentPos = 0;

  Widget? currentWidget;
  Widget? otherWidget;

  void animate(int pos) {
    print('new pos = $pos');
    if (!_animationController.isAnimating && pos != currentPos) {
      _animationController.reset();
      otherWidget = widget.tabs[pos];
      setState(() {});
      _animationLabel = Tween<Offset>(
              begin: Offset(currentPos * 1, 0),
              end: Offset((pos * 1).toDouble(), 0.0))
          .animate(_animationController);
      _animationTab1 = Tween<Offset>(
              begin: Offset(0, 0), end: Offset(currentPos > pos ? 1 : -1, 0.0))
          .animate(_animationController);
      _animationTab2 = Tween<Offset>(
              begin: Offset(currentPos > pos ? -1 : 1, 0), end: Offset(0, 0.0))
          .animate(_animationController);
      currentPos = pos;
      _animationController.forward().then((value) => setState(() {
        currentWidget = widget.tabs[currentPos];
      }));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPos = widget.initialPos;
    currentWidget = widget.tabs[widget.initialPos];
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationLabel = Tween<Offset>(
            begin: Offset(currentPos * 1, 0), end: Offset(1 * 1, 0.0))
        .animate(_animationController);
    _animationTab1 =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(currentPos * 1, 0.0))
            .animate(_animationController);
    _animationTab2 =
        Tween<Offset>(begin: Offset(currentPos * 1, 0), end: Offset(0, 0.0))
            .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    final labelWidth =
        (size.width / widget.labels.length) - (52 / widget.labels.length);
    final labelWidthWithoutPadding = (size.width / widget.labels.length);

    return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 11),
            child: SizedBox(
              height: 46,
              width: size.width,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Wrap(
                    children: List.generate(
                        widget.labels.length,
                        (index) => SizedBox(
                            height: 46,
                            width: labelWidthWithoutPadding,
                            child: Center(
                                child: InkWell(
                              onTap: () => animate(index),
                              child: Container(
                                height: 46,
                                width: labelWidth,
                                decoration: BoxDecoration(
                                  color: ColorConstant.fromHex('#C5D2D2'),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10)),
                                ),
                              ),
                            )))).toList(),
                  ),
                  Container(
                    height: 1,
                    width: size.width,
                    color: ColorConstant.cyan700,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IgnorePointer(
                      child: SlideTransition(
                        position: _animationLabel,
                        child: SizedBox(
                          height: 46,
                          width: labelWidthWithoutPadding,
                          child: Center(
                            child: Container(
                              height: 46,
                              width: labelWidth,
                              decoration: BoxDecoration(
                                  color: ColorConstant.cyan700,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10)),
                              ),
                              child:Container(
                                margin: const EdgeInsetsDirectional.only(start: 1, end: 1, top: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(10),
                                    topRight: const Radius.circular(10),
                                  ),// BorderRadius

                                ),// BoxDecoration
                              )
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Wrap(
                    children: List.generate(
                        widget.labels.length,
                        (index) => SizedBox(
                            height: 46,
                            width: labelWidthWithoutPadding,
                            child: Center(
                                child: IgnorePointer(
                              child: Container(
                                height: 46,
                                width: labelWidth,
                                child: Center(
                                  child: Text(
                                    widget.labels[index],
                                    style: AppStyle.txtSFProDisplayLight14
                                        .copyWith(
                                            color: currentPos == index
                                                ? ColorConstant.cyan700
                                                : Colors.white),
                                  ),
                                ),
                              ),
                            )))).toList(),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Stack(
              children: [
                if(otherWidget != null)
                  SlideTransition(position: _animationTab2,
                  child: otherWidget!,
                  ),
                if(currentWidget != null)
                  SlideTransition(position: _animationTab1,
                    child: currentWidget!,
                  ),
              ],
            ),
          )

        ],
    );
  }
}
