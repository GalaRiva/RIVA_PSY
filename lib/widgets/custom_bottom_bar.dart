import 'package:flutter/material.dart';

import 'package:riva_psy/core/app_export.dart';

class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({this.onChanged});

  int selectedIndex = 0;


  List<BottomMenuModel> bottomMenuList = [
    BottomMenuModel(
      icon: ImageConstant.imgSearchGray800,
      type: BottomBarEnum.Searchgray800,
      size: 15
    ),
    BottomMenuModel(
      icon: ImageConstant.imgCalendar,
      type: BottomBarEnum.Calendar,
      size: 16
    ),
    BottomMenuModel(
      icon: ImageConstant.imgArrowright,
      type: BottomBarEnum.Arrowright,
      size: 32
    ),
    BottomMenuModel(
      icon: ImageConstant.imgVectorGray800,
      type: BottomBarEnum.Vectorgray800,
      size: 18
    ),
    BottomMenuModel(
      icon: ImageConstant.imgSettings,
      type: BottomBarEnum.Settings,
      size: 16
    )
  ];

  Function(BottomBarEnum)? onChanged;

  @override
  Widget build(BuildContext context) {

    void getCurrentPage(int currentRoute) {
      switch (currentRoute) {
        case 0:
          if(ModalRoute.of(context)!.settings.name != AppRoutes.recommendations) {
            AppRoutes.currentRoute = AppRoutes.recommendations;

            Navigator.pushNamed(context, AppRoutes.recommendations);
          }
          break;
        case 1:
          if(ModalRoute.of(context)!.settings.name != AppRoutes.records) {
            AppRoutes.currentRoute = AppRoutes.records;
            Navigator.pushNamed(context, AppRoutes.records);
          }
          break;
        case 2:
          if(ModalRoute.of(context)!.settings.name != AppRoutes.main) {
            AppRoutes.currentRoute = AppRoutes.main;
            Navigator.pushNamed(context, AppRoutes.main);
          }
          break;
          case 3:
            if(ModalRoute.of(context)!.settings.name != AppRoutes.charts) {
            AppRoutes.currentRoute = AppRoutes.charts;
            Navigator.pushNamed(context, AppRoutes.charts);
          }
          break;
        case 4:
          if(ModalRoute.of(context)!.settings.name != AppRoutes.settings) {
            AppRoutes.currentRoute = AppRoutes.settings;
            Navigator.pushNamed(context, AppRoutes.settings);
          }
          break;
        default:
          if(ModalRoute.of(context)!.settings.name != AppRoutes.main) {
            AppRoutes.currentRoute = AppRoutes.main;
            Navigator.pushNamed(context, AppRoutes.main);
          }
          break;
      }
    }

    void getCurrentIndex(String? currentRoute) {
      switch (currentRoute) {
        case AppRoutes.recommendations:
          selectedIndex = 0;
          break;
        case AppRoutes.records:
          selectedIndex = 1;
          break;
        case AppRoutes.main:
          selectedIndex = 2;
          break;
        case AppRoutes.charts:
          selectedIndex = 3;
          break;
        case AppRoutes.settings:
          selectedIndex = 4;
          break;
        default:
          selectedIndex = 2;
          break;
      }
    }

    getCurrentIndex(AppRoutes.currentRoute);
    // Was a plain BottomNavigationBar with a 1px cyan line above the
    // selected icon — replaced with a floating rounded bar (same fixed
    // position at the bottom of the screen, same 5 routes/onTap logic
    // above, purely a different visual shell) with an animated soft pill
    // behind the selected icon instead of the static line, and the
    // center item (index 2 — already sized 32 vs. 15-18 for the rest,
    // clearly meant to be the primary action) raised into its own filled
    // circle, a common pattern for a bar's main action.
    return Container(
      padding: EdgeInsets.only(top: getVerticalSize(10)),
      decoration: BoxDecoration(
        color: ColorConstant.whiteA700,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(getHorizontalSize(28)),
          topRight: Radius.circular(getHorizontalSize(28)),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.deepPurple7000c,
            spreadRadius: getHorizontalSize(1),
            blurRadius: getHorizontalSize(16),
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: getVerticalSize(52),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(bottomMenuList.length, (index) {
              final isSelected = index == selectedIndex;
              final isCenter = index == 2;
              return _BottomBarItem(
                icon: bottomMenuList[index].icon,
                iconSize: bottomMenuList[index].size,
                isSelected: isSelected,
                isCenter: isCenter,
                onTap: () {
                  selectedIndex = index;
                  getCurrentPage(selectedIndex);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final String icon;
  final double iconSize;
  final bool isSelected;
  final bool isCenter;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.iconSize,
    required this.isSelected,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: Offset(0, getVerticalSize(-14)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: getSize(56),
            height: getSize(56),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstant.cyan700,
              boxShadow: [
                BoxShadow(
                  color: ColorConstant.cyan700.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: CustomImageView(
                svgPath: icon,
                height: getSize(iconSize),
                width: getSize(iconSize),
                color: ColorConstant.whiteA700,
              ),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: getSize(44),
        height: getSize(44),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? ColorConstant.cyan700.withOpacity(0.12)
              : Colors.transparent,
        ),
        child: Center(
          child: CustomImageView(
            svgPath: icon,
            height: getSize(iconSize),
            width: getSize(iconSize),
            color: isSelected ? ColorConstant.cyan700 : ColorConstant.gray800,
          ),
        ),
      ),
    );
  }
}

enum BottomBarEnum {
  Searchgray800,
  Calendar,
  Arrowright,
  Vectorgray800,
  Settings,
}

class BottomMenuModel {
  BottomMenuModel( {required this.icon, required this.type, required this.size});

  String icon;
  final double size;

  BottomBarEnum type;
}

class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please replace the respective Widget here',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
