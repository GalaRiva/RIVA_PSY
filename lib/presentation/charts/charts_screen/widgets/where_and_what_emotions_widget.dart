import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/app_export.dart';
import '../../../../core/user_data/user.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_search_view.dart';
import '../../../../widgets/go_to_new_tariff_widget.dart';
import '../controller.dart';
import '../models/emotion_model.dart';

class WhereAndWhatEmotionsWidget extends StatelessWidget {
  final K61Controller controller;
  const WhereAndWhatEmotionsWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _sum(List<dynamic> list) {
      double _s = 0;
      for (var item in list) _s += item.quantity;
      return _s;
    }

    return !CurrentUser.tariffIsStandard() ? _emptyTab() : Container(
      width: size.width,
      height: size.height - 214,
      decoration: AppDecoration.fillGray200,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: getPadding(left: 20, top: 21, right: 20),
              child: Text(
                "Где и какие эмоции",
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
                hintText: "Найти  место",
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
                      grid(),
                      Container(
                        height: getVerticalSize(60),
                        width: size.width - 32,
                        child: IgnorePointer(
                          child: SfCartesianChart(
                            margin: EdgeInsets.only(bottom: 0, top: 0),
                              plotAreaBorderColor: Colors.transparent,
                              primaryXAxis: CategoryAxis(
                                isVisible: false
                              ),
                              primaryYAxis: NumericAxis(
                                  isVisible: false,
                                  minimum: 0, maximum: e.emotionMax.toDouble(), interval: 1),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries<EmotionModel, String>>[
                                ColumnSeries<EmotionModel, String>(
                                  dataSource: e.emotions,
                                  xValueMapper: (EmotionModel data, _) => data.name,
                                  yValueMapper: (EmotionModel data, _) => data.quantity,
                                  pointColorMapper: (EmotionModel data, int _) => data.color,
                                  name: e.place
                                )
                              ]),
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
                                      .txtSFProDisplayLight10Gray800,),
                              )
                            ],
                          ),
                        )).toList(),),
                      )
                  )
                ],
              )).toList(),
            ),
            )
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
          decoration: AppDecoration.fillGray200,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: getPadding(left: 20, top: 21, right: 20),
                  child: Text(
                    "Где и какие эмоции",
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
                    hintText: "Найти  место",
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

  Widget grid() {
    return Container(
      height: getVerticalSize(60),
      width: size.width - 31,
      child: Row(
        children: [
          Container(
            height: getVerticalSize(60),
            width: 1,
            color: Colors.white,
          ),
          SizedBox(
            height: getVerticalSize(60),
            child: Column(
              children: List<Widget>.generate(11, (index) => line(index)),
            ),
          )
        ],
      ),
    );
  }

  Widget line(i) => Column(
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
      height: getVerticalSize(4.8),
    ),
  )
  ],
  );
}
