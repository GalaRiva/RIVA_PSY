import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'text_for_select_period_widget.dart';

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
        decoration: AppDecoration.glassCard,
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
                      'where_do_my_emotions_live_in_the_body'.tr(),
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
                          height: getVerticalSize(380) * 1.26,
                          width: (size.width - 32),
                          child: Transform.scale(
                            scale: 1.26,
                            alignment: Alignment.topCenter,
                            child: Row(
                              children: [
                                Transform.translate(offset: Offset(20, 0), child: BodyWidget(list: _all.map((e) =>  (e).bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(_all.length, (index) => controller.getColor(index)))), //
                                Transform.translate(offset: Offset(-20, 0), child: BodyWidget(list: _all.map((e) =>  (e).bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(_all.length, (index) => controller.getColor(index)), index: 2,)),
                              ],
                            ),
                          ),
                        ))
              ),
              Padding(
                padding: getPadding(left: 16, right: 16, bottom: 16, top: 50),
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
                        child: Text('${(e).bodyPart.bodyPartsModel.localizedBodyPart} ${(((e).quantity  / _sum(_all)) * 100).toInt()}%',
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
                      'where_body_emotions_prefix'.tr(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                    Text(
                      'positive'.tr().toLowerCase(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      'where_body_emotions_suffix'.tr(),
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
                          height: getVerticalSize(380) * 1.26,
                          width: (size.width - 32),
                          child: Transform.scale(
                            scale: 1.26,
                            alignment: Alignment.topCenter,
                            child: Row(
                              children: [
                                Transform.translate(offset: Offset(20, 0), child: BodyWidget(list: positiveType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(positiveType!.bodyParts.length, (index) => controller.getColor(index)))),
                                Transform.translate(offset: Offset(-20, 0), child: BodyWidget(list: positiveType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), index: 2, circleColors: List<Color>.generate(positiveType!.bodyParts.length, (index) => controller.getColor(index)))),
                              ],
                            ),
                          ),
                        ))
              ),
              Padding(
                padding: getPadding(left: 16, right: 16, bottom: 16, top: 50),
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
                        child: Text('${e.bodyPart.bodyPartsModel.localizedBodyPart} ${((e.quantity  / _sum(positiveType!.bodyParts)) * 100).toInt()}%',
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
                      'where_body_emotions_prefix'.tr(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                    Text(
                      'negative'.tr().toLowerCase(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800.copyWith(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      'where_body_emotions_suffix'.tr(),
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
                          height: getVerticalSize(380) * 1.26,
                          width: (size.width - 32),
                          child: Transform.scale(
                            scale: 1.26,
                            alignment: Alignment.topCenter,
                            child: Row(
                              children: [
                                Transform.translate(offset: Offset(20, 0), child: BodyWidget(list: negativeType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), circleColors: List<Color>.generate(negativeType!.bodyParts.length, (index) => controller.getColor(index)))),
                                Transform.translate(offset: Offset(-20, 0), child: BodyWidget(list: negativeType!.bodyParts.map((e) => e.bodyPart.bodyPartsModel).toList(), index: 2, circleColors: List<Color>.generate(negativeType!.bodyParts.length, (index) => controller.getColor(index)))),
                              ],
                            ),
                          ),
                        ),
                      )
              ),
              Padding(
                padding: getPadding(left: 16, right: 16, bottom: 16, top: 50),
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
                        child: Text('${e.bodyPart.bodyPartsModel.localizedBodyPart} ${((e.quantity  / _sum(negativeType!.bodyParts)) * 100).toInt()}%',
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
                padding: getPadding(left: 20, top: 40, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: getHorizontalSize(30),
                  children: emotionsInBody.map((e) => Padding(
                  padding: getPadding(bottom: 23),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(e.emotionModel,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppStyle.txtSFProDisplayLight10Gray800,
                      ),
                      SizedBox(height: getVerticalSize(5),),
                      Container(
                        alignment: Alignment.center,
                        height: getHorizontalSize(83),
                      width: getHorizontalSize(83),
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (final part in e.bodyParts)
                                PieChartSectionData(
                                  value: part.quantity.toDouble(),
                                  color: part.color,
                                  showTitle: false,
                                  radius: getHorizontalSize(40),
                                ),
                            ],
                            sectionsSpace: 1,
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                      Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
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
                                child: Text('${_e.bodyPart.bodyPartsModel.localizedBodyPart} ${((_e.quantity / _sum(e.bodyParts)) * 100).toInt()}%',
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
          decoration: AppDecoration.glassCard,
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
                        'where_do_my_emotions_live_in_the_body'.tr(),
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
                        'where_body_emotions_prefix'.tr(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                      Text(
                        'positive'.tr().toLowerCase(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        'where_body_emotions_suffix'.tr(),
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
                        'where_body_emotions_prefix'.tr(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800,
                      ),
                      Text(
                        'negative'.tr().toLowerCase(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        'where_body_emotions_suffix'.tr(),
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

