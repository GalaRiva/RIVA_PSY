import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../../../core/utils/color_constant.dart';
import '../../../../theme/app_style.dart';
import '../controller.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> labels;
  final List<Widget> tabs;
  final PageController controller;
  // Hides the top tab-selector row (not the page content) — driven by
  // K70Controller.immersiveMode so a nested exercise screen can claim the
  // full height.
  final bool showTabs;
  const CustomTabBar(
      {Key? key, this.labels = const [], this.tabs = const [], required this.controller, this.showTabs = true})
      : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int currentPos = 0;
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _tabKeys;

  void animate(int pos) {
    // Switching tabs always returns to "browsing" chrome — a mid-exercise
    // tab left behind shouldn't leave the bar hidden for whichever tab the
    // user lands on next.
    if (Get.isRegistered<K70Controller>()) {
      Get.find<K70Controller>().setImmersiveMode(false);
    }
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
    currentPos = widget.controller.initialPage;
    if (Get.isRegistered<K70Controller>()) {
      Get.find<K70Controller>().setActiveTopLevelTab(currentPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showTabs)
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
              if (Get.isRegistered<K70Controller>()) {
                Get.find<K70Controller>().setActiveTopLevelTab(pos);
              }
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTab(pos));
            },
            children: widget.tabs,
          ),
        ),
      ],
    );
  }
}
