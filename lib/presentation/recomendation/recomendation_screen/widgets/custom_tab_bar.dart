import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_button.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> labels;
  final List<Widget> tabs;
  final PageController controller;
  const CustomTabBar({Key? key, this.labels = const [], this.tabs = const [], required this.controller})
      : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {


  int currentPos = 0;
  late Animation<Offset> _animationLabel;
  late final AnimationController _animationController;

  void animate(int pos) {
    print('new pos = $pos');
    widget.controller.animateToPage(pos, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationLabel = Tween<Offset>(
        begin: Offset(currentPos * 1, 0), end: Offset(0 * 1, 0.0))
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
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.labels[index],
                                      maxLines: 1,
                                      style: AppStyle.txtSFProDisplayLight14
                                          .copyWith(
                                              color: currentPos == index
                                                  ? ColorConstant.cyan700
                                                  : Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )))).toList(),
                  ),
                ],
              ),
            ),
          ),

                Expanded(
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(0),
                      width: size.width,
                      child: Center(
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: widget.controller,
                          onPageChanged: (pos) {
                                  print(pos);
                            _animationController.reset();
                            _animationLabel = Tween<Offset>(
                                begin: Offset(currentPos.toDouble() , 0),
                                end: Offset(pos.toDouble(), 0.0))
                                .animate(_animationController);
                            setState(() {
                              currentPos = pos;
                            });
                            _animationController.forward();
                          },
                          children: widget.tabs,
                        ),
                      ),
                    ),
                  ),
                ),


        ],
    );
  }
}