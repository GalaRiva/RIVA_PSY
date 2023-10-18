import 'dart:io';

import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

import '../../../../../core/models/day_event_model.dart';
import '../../../../../core/services/datasource_service.dart';
import '../../../../../core/services/negative_emotion_tabs.dart';
import '../../../../../core/user_data/user.dart';
import '../path_to_new_screen_model.dart';
import 'exercise_content/exercise_content_widget.dart';
import 'listglobe_item_widget.dart';

class ScreenBodyWidget extends StatelessWidget {
  final bool isNegative;
  final DayEventModel dayEventModel;
  const ScreenBodyWidget({Key? key, required this.isNegative, required this.dayEventModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurrentUser.tariffIsOrion() && isNegative ? ExerciseContentWidget(dayEvent: dayEventModel,) : Padding(
      padding: getPadding(left: 10,
        right: 10,),
      child: isNegative ? ifIsNegative() : ifNotNegative(),
    );
  }

  Widget ifIsNegative () {
    final paths = NegativeEmotionTabs.tabs.map((e) => PathToNewScreenModel({
      'first': 2,
      'second': e.tabIndex
    }, e.imagePath, e.title)).toList();

    return SizedBox(
      height: getVerticalSize(((118 + 15) * paths.length).toDouble()),
      child: Wrap(
        spacing: getVerticalSize(15),
        direction: Axis.vertical,
        children: paths
            .map((e) => ListglobeItemWidget(e.title,
                params: e.param,
                svgFile: !DataSourceService.dataSourceIsRemote()
                    ? File(e.svgIcon)
                    : null,
                svgUrl: DataSourceService.dataSourceIsRemote()
                    ? e.svgIcon
                    : null))
            .toList(),
      ),
    );
  }

  Widget ifNotNegative () {
    return ListglobeItemWidget('Рекомендации', params: {
      'first': 0,
      'second':0
    }, svgPath: ImageConstant.recommendationsLogo,);
  }
}
