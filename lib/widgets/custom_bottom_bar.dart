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
    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.blueGray20001,
        boxShadow: [
          BoxShadow(
            color: ColorConstant.deepPurple7000c,
            spreadRadius: getHorizontalSize(
              2,
            ),
            blurRadius: getHorizontalSize(
              2,
            ),
            offset: Offset(
              0,
              -5.41,
            ),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: List.generate(bottomMenuList.length, (index) {
          return BottomNavigationBarItem(
            icon: CustomImageView(
              svgPath: bottomMenuList[index].icon,
              height: getSize(
                bottomMenuList[index].size,
              ),
              width: getSize(
                bottomMenuList[index].size,
              ),
              color: ColorConstant.gray800,
            ),
            activeIcon: Container(
              height: getSize(32 + 4),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: getVerticalSize(34),
                      height: 1,
                      color: ColorConstant.cyan700,
                    ),

                  ),
                  Center(
                    child: CustomImageView(
                      svgPath: bottomMenuList[index].icon,
                      height: getSize(
                        bottomMenuList[index].size,
                      ),
                      width: getSize(
                        bottomMenuList[index].size,
                      ),
                      color: ColorConstant.cyan700,
                    ),
                  ),
                ],
              ),
            ),
            label: '',
          );
        }),
        onTap: (index) {
          selectedIndex = index;
          getCurrentPage(selectedIndex);
        },
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
