import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'text_for_select_period_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/user_data/user.dart';

import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/body_widget.dart';
import '../../../../widgets/go_to_new_tariff_widget.dart';
import '../controller.dart';
import '../models/emotion_in_body.dart';

class WhereInBodyWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback? onPeriodTap;
  final List<EmotionInBodyModel> emotionsInBody;
  final EmotionTypeInBodyModel? positiveType;
  final EmotionTypeInBodyModel? negativeType;
  final EmotionTypeInBodyModel? neutralType;

  final K61Controller controller;
  const WhereInBodyWidget(
      {Key? key, required this.start, required this.end, this.onPeriodTap, required this.controller, required this.emotionsInBody, required this.positiveType, required this.negativeType, this.neutralType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final _all = controller.sortBodyPartsList( positiveType!.bodyParts + negativeType!.bodyParts + neutralType!.bodyParts);

    double _sum (List<dynamic> list) {
      double _s = 0;
      for(var item in list) _s += item.quantity;
      return _s;
    };
    return GetBuilder(
      builder: (K61Controller _c) =>
      Container(
        width: size.width,
        height: size.height - 214,
        decoration: AppDecoration.fillGray200,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: getPadding(
                    left: 20,
                    top: 21,
                    right: 20
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Где в теле живут мои эмоции",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                    TextForSelectPeriodWidget(start: controller.dateStart, end: controller.dateEnd, controller: controller,)
                  ],
                ),
              ),
              Padding(
                  padding: getPadding(top: 18),
                  child:  Center(
                        child: SizedBox(
                          height: getVerticalSize(380),
                          width: (size.width - 32),
                          child: Row(
                            children: [
                              BodyWidget(list: _all.map((e) =>  (e).bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(_all.length, (index) => controller.getColor(index))), //
                              BodyWidget(list: _all.map((e) =>  (e).bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(_all.length, (index) => controller.getColor(index)), index: 2,),                            ],
                        ),
                      ))
              ),
              Padding(
                padding: getPadding(all: 16),
                child: Wrap(children: _all.map((e) => Padding(
                  padding: getPadding(right: 16,bottom: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: (e).color,
                        width: getSize(14),
                        height: getSize(14),
                      ),
                      Padding(padding: getPadding(left: 6),
                        child: Text('${(e).bodyPart.bodyPartsModel.bodyPart} ${(((e).quantity  / _sum(_all)) * 100).toInt()}%',
                          overflow:
                          TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight10Gray800,),
                      )
                    ],
                  ),
                )).toList(),),
              ),
              Padding(
                padding: getPadding(
                    left: 20,
                    top: 30,
                ),
                child: Row(
                  children: [
                    Text(
                      "Где в теле живут ",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                    Text(
                      "позитивные ",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "эмоции",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: getPadding(top: 18),
                  child:   Center(
                        child: SizedBox(
                          height: getVerticalSize(380),
                          width: (size.width - 32),
                          child: Row(
                            children: [
                              BodyWidget(list: positiveType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(positiveType!.bodyParts.length, (index) => controller.getColor(index))),
                              BodyWidget(list: positiveType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), index: 2, circleColors: List<Color>.generate(positiveType!.bodyParts.length, (index) => controller.getColor(index))),
                            ],
                        ),
                      ))
              ),
              Padding(
                padding: getPadding(all: 16),
                child: Wrap(children: positiveType!.bodyParts.map((e) => Padding(
                  padding: getPadding(right: 16,bottom: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: e.color,
                        width: getSize(14),
                        height: getSize(14),
                      ),
                      Padding(padding: getPadding(left: 6),
                        child: Text('${e.bodyPart.bodyPartsModel.bodyPart} ${((e.quantity  / _sum(positiveType!.bodyParts)) * 100).toInt()}%',
                          overflow:
                          TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight10Gray800,),
                      )
                    ],
                  ),
                )).toList(),),
              ),
              Padding(
                padding: getPadding(
                  left: 20,
                  top: 30,
                ),
                child: Row(
                  children: [
                    Text(
                      "Где в теле живут ",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                    Text(
                      "негативные ",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800.copyWith(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "эмоции",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: getPadding(top: 18),
                  child:  Center(
                        child: SizedBox(
                          height: getVerticalSize(380),
                          width: (size.width - 32),
                          child: Row(
                            children: [
                              BodyWidget(list: negativeType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(negativeType!.bodyParts.length, (index) => controller.getColor(index))),
                              BodyWidget(list: negativeType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), index: 2, circleColors: List<Color>.generate(negativeType!.bodyParts.length, (index) => controller.getColor(index))),
                            ],
                          ),
                        ),
                      )
              ),
              Padding(
                padding: getPadding(all: 16),
                child: Wrap(children: negativeType!.bodyParts.map((e) => Padding(
                  padding: getPadding(right: 16,bottom: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: e.color,
                        width: getSize(14),
                        height: getSize(14),
                      ),
                      Padding(padding: getPadding(left: 6),
                        child: Text('${e.bodyPart.bodyPartsModel.bodyPart} ${((e.quantity  / _sum(negativeType!.bodyParts)) * 100).toInt()}%',
                          overflow:
                          TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight10Gray800,),
                      )
                    ],
                  ),
                )).toList(),),
              ),
              Padding(
                padding: getPadding(left: 20, top: 40),
                child: Wrap(
                  spacing: getHorizontalSize(30),
                  children: emotionsInBody.map((e) => Padding(
                  padding: getPadding(bottom: 23),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.emotionModel,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight10Gray800,
                      ),
                      SizedBox(height: getVerticalSize(5),),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: getHorizontalSize(83),
                      width: getHorizontalSize(83),
                        child: FittedBox(
                        fit: BoxFit.fill,
                        child: SfCircularChart(
                          series: [
                            PieSeries(
                                dataSource: e.bodyParts,
                                pointColorMapper: (dynamic model, int _) => model.color,
                                xValueMapper: (dynamic data, _) => data.bodyPart.bodyPartsModel.bodyPart,
                                yValueMapper: (dynamic data, _) => data.quantity
                            )
                          ],
                        ),
                      ),
                      ),
                      Wrap(
                        direction: Axis.vertical,
                        children: e.bodyParts.map((_e) => Padding(
                          padding: getPadding(right: 16,bottom: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                color: _e.color,
                                width: getSize(14),
                                height: getSize(14),
                              ),
                              Padding(padding: getPadding(left: 6),
                                child: Text('${_e.bodyPart.bodyPartsModel.bodyPart} ${((_e.quantity / _sum(e.bodyParts)) * 100).toInt()}%',
                                  overflow:
                                  TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle
                                      .txtSFProDisplayLight10Gray800,),
                              )
                            ],
                          ),
                        )).toList(),
                      ),
                      SizedBox(height: getVerticalSize(60),)

                    ],
                  )
                )).toList(),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whereInBodyEmpty () {
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
                  padding: getPadding(
                      left: 20,
                      top: 21,
                      right: 20
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Где в теле живут мои эмоции",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                      TextForSelectPeriodWidget(start: controller.dateStart, end: controller.dateEnd, controller: controller,)
                    ],
                  ),
                ),
                Padding(
                    padding: getPadding(top: 18),
                    child:  Center(
                        child: SizedBox(
                          height: getVerticalSize(380),
                          width: (size.width - 32),
                          child: Row(
                            children: [
                              BodyWidget(list: [], circleColors: negativeType!.bodyParts.map((e) => e.color).toList()),
                              BodyWidget(list: [], index: 2, circleColors: negativeType!.bodyParts.map((e) => e.color).toList()),
                            ],
                          ),
                        ))
                ),
                Padding(
                  padding: getPadding(
                    left: 20,
                    top: 30,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Где в теле живут ",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                      Text(
                        "позитивные ",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        "эмоции",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: getPadding(top: 18),
                    child:   Center(
                        child: SizedBox(
                          height: getVerticalSize(380),
                          width: (size.width - 32),
                          child: Row(
                            children: [
                              BodyWidget(list: [], circleColors: negativeType!.bodyParts.map((e) => e.color).toList()),
                              BodyWidget(list: [], index: 2, circleColors: negativeType!.bodyParts.map((e) => e.color).toList()),],
                          ),
                        ))
                ),
                Padding(
                  padding: getPadding(
                    left: 20,
                    top: 30,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Где в теле живут ",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                      Text(
                        "негативные ",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        "эмоции",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: getPadding(top: 18),
                    child:  Center(
                      child: SizedBox(
                        height: getVerticalSize(380),
                        width: (size.width - 32),
                        child: Row(
                          children: [
                            BodyWidget(list: [], circleColors: negativeType!.bodyParts.map((e) => e.color).toList()),
                            BodyWidget(list: [], index: 2, circleColors: negativeType!.bodyParts.map((e) => e.color).toList()),
                          ],
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
        GoToNewTariffWidget(height: size.height - 214,)
      ],
    );
  }
}

