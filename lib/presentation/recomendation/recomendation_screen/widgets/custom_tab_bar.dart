import 'package:flutter/material.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../theme/app_style.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> labels;
  final List<Widget> tabs;
  final PageController controller;
  const CustomTabBar({Key? key, this.labels = const [], this.tabs = const [], required this.controller})
      : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int currentPos = 0;
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _tabKeys;

  void animate(int pos) {
    widget.controller.animateToPage(pos, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  // Brings a newly-selected tab into view when it was scrolled off — needed
  // once the tab row scrolls instead of splitting the screen into fixed
  // equal-width columns (that division was what forced long labels like
  // "Справиться с эмоцией" to shrink once a 3rd tab was added).
  void _scrollToTab(int index) {
    final ctx = _tabKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0.5);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(widget.labels.length, (_) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 11),
          child: SizedBox(
            height: 42,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(height: 1, color: ColorConstant.cyan700),
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 3),
                  child: Row(
                    children: List.generate(widget.labels.length, (index) {
                      final isActive = currentPos == index;
                      return Padding(
                        key: _tabKeys[index],
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => animate(index),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : ColorConstant.fromHex('#C5D2D2'),
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                            ),
                            child: Text(
                              widget.labels[index],
                              maxLines: 1,
                              style: AppStyle.txtSFProDisplayLight14.copyWith(
                                color: isActive ? ColorConstant.cyan700 : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: widget.controller,
            onPageChanged: (pos) {
              setState(() => currentPos = pos);
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTab(pos));
            },
            children: widget.tabs,
          ),
        ),
      ],
    );
  }
}
