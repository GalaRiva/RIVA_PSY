import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_bottom_bar.dart';
import '../../../../widgets/custom_image_view.dart';
import 'controller.dart';
import 'widgets/tab_widget.dart';

class K70Screen extends StatefulWidget {
  const K70Screen({Key? key}) : super(key: key);

  @override
  State<K70Screen> createState() => _K70ScreenState();
}

class _K70ScreenState extends State<K70Screen> with TickerProviderStateMixin {
  final controller = Get.put(K70Controller());

  @override
  Widget build(BuildContext context) {

    final data = ModalRoute.of(context)?.settings.arguments as Map?;
    if(data != null){
      controller.currentTab = data['first'];
      controller.currentTabSecond = data['second'];
    }
    if(data == null){
      controller.currentTab = 0;
      controller.currentTabSecond = 0;
    }
    controller.init(this);
    controller.tabControllerSecond!.addListener(() {
      controller.currentTabSecond = controller.tabControllerSecond!.index;

      controller.update();
    });
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: getPadding(top: 39, left: 16),
              child: Text(
                "Рекомендации и упражнения",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight10Gray800,
              ),
            ),
            Padding(
              padding: getPadding(
                top: 12,
              ),
              child: Divider(
                height: getVerticalSize(
                  1,
                ),
                thickness: getVerticalSize(
                  1,
                ),
                indent: getVerticalSize(16),
                endIndent: getVerticalSize(16),
                color: ColorConstant.gray50,
              ),
            ),
            Padding(
              padding: getPadding(top: 14, left: 16),
              child: Text(
                'Справится с эмоциями',
                style: AppStyle.txtH1,
              ),
            ),
            InkWell(
              onTap: () {
                controller.tabController!.animateTo(2);
                controller.currentTab = 2;
                controller.tabControllerSecond!.animateTo(controller.panicTab);
                controller.currentTabSecond = controller.panicTab;
              },
              child: Padding(
                padding: getPadding(top: 23, left: 16),
                child: Row(
                  children: [
                    Text(
                      "Паника. Аффект",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtSFProDisplayLight14Cyan700.copyWith(
                        fontStyle: FontStyle.normal,
                        letterSpacing: getHorizontalSize(
                          0.56,
                        ),
                      ),
                    ),
                    CustomImageView(
                      svgPath: ImageConstant.imgVector46,
                      color: ColorConstant.cyan700,
                      height: getVerticalSize(
                        8,
                      ),
                      width: getHorizontalSize(
                        4,
                      ),
                      radius: BorderRadius.circular(
                        getHorizontalSize(
                          1,
                        ),
                      ),
                      margin: getMargin(
                        left: 7,
                        top: 4,
                        bottom: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}

