import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import '../controller.dart';

/// A full screen for one area opened from the practices hub: a back arrow
/// and a title on top, the existing page below. While a nested exercise is
/// running (K70Controller.immersiveMode) the header steps aside so the
/// exercise gets the whole screen, exactly as the old tab bar did.
class HubSectionScreen extends StatefulWidget {
  final String title;
  final Widget child;

  /// "Обретение"-type areas (the written practices) hide the mini player,
  /// like the old top-level tab did.
  final bool hidesMiniPlayer;

  const HubSectionScreen({Key? key, required this.title, required this.child, this.hidesMiniPlayer = false})
      : super(key: key);

  @override
  State<HubSectionScreen> createState() => _HubSectionScreenState();
}

class _HubSectionScreenState extends State<HubSectionScreen> {
  K70Controller? get _c => Get.isRegistered<K70Controller>() ? Get.find<K70Controller>() : null;

  @override
  void initState() {
    super.initState();
    if (widget.hidesMiniPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _c?.setActiveTopLevelTab(2));
    }
  }

  void _restore() {
    // After the frame: the controller notifies listeners, which must not
    // happen while the tree is being torn down.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c?.setImmersiveMode(false);
      if (widget.hidesMiniPlayer) _c?.setActiveTopLevelTab(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _restore();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: GetBuilder<K70Controller>(
            builder: (c) => Column(
              children: [
                if (!c.immersiveMode)
                  Padding(
                    padding: getPadding(left: 12, right: 16, top: 6, bottom: 2),
                    child: Row(
                      children: [
                        Semantics(
                          button: true,
                          label: 'back'.tr(),
                          excludeSemantics: true,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              width: getSize(44),
                              height: getSize(44),
                              alignment: Alignment.center,
                              child: Container(
                                width: getSize(34),
                                height: getSize(34),
                                decoration:
                                    const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                                child: Icon(Icons.arrow_back_rounded, size: getSize(20), color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: getHorizontalSize(6)),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                fontSize: getFontSize(18),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
