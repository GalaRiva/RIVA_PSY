import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/user_data/user.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_search_view.dart';
import '../../../../widgets/go_to_new_tariff_widget.dart';
import '../controller.dart';

class WhereAndWhatEmotionsWidget extends StatelessWidget {
  final K61Controller controller;
  const WhereAndWhatEmotionsWidget({Key? key, required this.controller}) : super(key: key);

  static const double chartHeight = 108;

  @override
  Widget build(BuildContext context) {
    double _sum(List<dynamic> list) {
      double _s = 0;
      for (var item in list) _s += item.quantity;
      return _s;
    }

    return Container(
      width: size.width,
      decoration: AppDecoration.glassCard,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: getPadding(left: 20, top: 21, right: 20),
              child: Text(
                'where_and_what_emotions'.tr(),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight14Gray800,
              ),
            ),
            Padding(
              padding: getPadding(left: 16, right: 16),
              child: CustomSearchView(
                onChange: (text) {
                  controller.searchPlaces(text);
                  controller.update();
                },
                focusNode: FocusNode(),
                hintText: 'find_a_place'.tr(),
                margin: getMargin(
                  left: 2,
                  top: 23,
                ),
                variant: SearchViewVariant.UnderLineWhiteA700,
                fontStyle: SearchViewFontStyle.SFProDisplayLight14Gray800,
                suffix: Container(
                  margin: getMargin(
                    left: 30,
                    top: 1,
                    right: 10,
                    bottom: 9,
                  ),
                  child: CustomImageView(
                    svgPath: ImageConstant.imgSearchWhiteA700,
                  ),
                ),
                suffixConstraints: BoxConstraints(
                  maxHeight: getVerticalSize(
                    26,
                  ),
                ),
              ),
            ),

            Padding(padding: getPadding(top: 32, left: 16, right: 16, bottom: 32),
            child: Wrap(
              spacing: 30,
direction: Axis.vertical,
              children: controller.placesResult.map((e) =>  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.place,
                  style: AppStyle.txtSFProDisplayLight12Gray800,
                  ),
                  SizedBox(height: getVerticalSize(14),),
                  Stack(
                    children: [
                      grid(chartHeight),
                      Container(
                        height: getVerticalSize(chartHeight),
                        width: size.width - 32,
                        child: IgnorePointer(
                          // Premium redesign (spec block 3): the light grid
                          // lines behind this chart (grid()/line() above)
                          // already provide the subtle horizontal
                          // direction — fl_chart's own axis/grid stay off
                          // so nothing doubles up or looks "technical".
                          child: BarChart(
                            BarChartData(
                              maxY: e.emotionMax.toDouble(),
                              minY: 0,
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              barTouchData: const BarTouchData(enabled: false),
                              barGroups: [
                                for (var i = 0; i < e.emotions.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.emotions[i].quantity.toDouble(),
                                        color: e.emotions[i].color,
                                        width: 12,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: getPadding(top: 16),
                      child: SizedBox(
                        width: size.width,
                        height: getSize(50),
                        child: ListView(
                          physics: PageScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: e.emotions.map((_e) => Padding(
                          padding: getPadding(bottom: 18, right: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                color: (_e).color,
                                width: getSize(14),
                                height: getSize(14),
                              ),
                              Padding(padding: getPadding(left: 6),
                                child: Text('${(_e).name} ${(((_e).quantity  / _sum(e.emotions)) * 100).toInt()}%',
                                  overflow:
                                  TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle
                                      .txtSFProDisplayLight10Gray800.copyWith(fontSize: getFontSize(16)),),
                              )
                            ],
                          ),
                        )).toList(),),
                      )
                  )
                ],
              )).toList(),
            ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  Widget _emptyTab () {
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height - 214,
          decoration: AppDecoration.glassCard,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: getPadding(left: 20, top: 21, right: 20),
                  child: Text(
                    'where_and_what_emotions'.tr(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayLight14Gray800,
                  ),
                ),
                Padding(
                  padding: getPadding(left: 16, right: 16),
                  child: CustomSearchView(
                    onChange: (text) {
                      controller.searchPlaces(text);
                      controller.update();
                    },
                    focusNode: FocusNode(),
                    hintText: 'find_a_place'.tr(),
                    margin: getMargin(
                      left: 2,
                      top: 23,
                    ),
                    variant: SearchViewVariant.UnderLineWhiteA700,
                    fontStyle: SearchViewFontStyle.SFProDisplayLight14Gray800,
                    suffix: Container(
                      margin: getMargin(
                        left: 30,
                        top: 1,
                        right: 10,
                        bottom: 9,
                      ),
                      child: CustomImageView(
                        svgPath: ImageConstant.imgSearchWhiteA700,
                      ),
                    ),
                    suffixConstraints: BoxConstraints(
                      maxHeight: getVerticalSize(
                        26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GoToNewTariffWidget(height: size.height - 214,)
      ],
    );
  }

  Widget grid(double height) {
    final gap = (height - 11) / 10;
    return Container(
      height: getVerticalSize(height),
      width: size.width - 31,
      child: Row(
        children: [
          Container(
            height: getVerticalSize(height),
            width: 1,
            color: Colors.white,
          ),
          SizedBox(
            height: getVerticalSize(height),
            child: Column(
              children: List<Widget>.generate(11, (index) => line(index, gap)),
            ),
          )
        ],
      ),
    );
  }

  Widget line(i, double gap) => Column(
    children: [
      SizedBox(
        width: size.width - 32,

        child: Divider(
          height: getVerticalSize(
            1,
          ),
          thickness: getVerticalSize(
            1,
          ),
          indent: 0,
          endIndent: 0,
          color: ColorConstant.gray50,
        ),
      ),
  Visibility(
    visible: i != 10,
    child: SizedBox(
      height: getVerticalSize(gap),
    ),
  )
  ],
  );
}
