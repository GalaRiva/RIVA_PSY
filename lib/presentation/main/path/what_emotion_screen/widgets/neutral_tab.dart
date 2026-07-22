import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../../core/models/day_event_model.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/event_card.dart';
import '../controller.dart';

class NeutralTab extends StatelessWidget {
  final DayEventModel dayEventModel;
  final int number;
  final K27Controller controller;
  final List<EventModel> list;

  const NeutralTab(
      {Key? key, required this.controller, required this.number, required this.dayEventModel, required this.list})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.currentTab = 3;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: getPadding(left: 38, right: 38, top: 44),
              child: GetBuilder(
                  builder: (K27Controller _c) => Visibility(
                    visible: controller.currentEventList.isNotEmpty,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: getHorizontalSize(109),
                          child: Text("Нейтральные \n(скорее позитивные)",
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight12Gray800a0)),
                      Container(
                          width: getHorizontalSize(108),
                          child: Text("Нейтральные \n(скорее негативные)",
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight12Gray800a0))
                    ])),
              )),
          Padding(
            padding: getPadding(top: 18),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: GetBuilder(
                  builder: (K27Controller _c) => Row(
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 32) / 2,

                        child: Wrap(
                          spacing: 12,
                          runAlignment: WrapAlignment.center,
                          children: List.generate(list.length, (index)=> Padding(
                            padding:  EdgeInsets.only(bottom: index == list.length - 1 ? 40 : 20),
                            child: EventCard(
                              cardWidth: size.width / 2 - 30,

                              textIsFitted: true,
                              isSelect: controller.contain(list.where((element) => element.name.contains('+')).toList()[index].name),
                              cardHeight: 44 ,
                              model: list.where((element) => element.name.contains('+')).toList()[index], onTap: () {
                              controller.emotion = list.where((element) => element.name.contains('+')).toList()[index];
                              controller.update();
                            },),
                          ))
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 32) / 2,

                        child: Wrap(
                          spacing: 12,
                          children: List.generate(list.where((element) => element.name.contains('-')).length, (index)=> Padding(
                            padding:  EdgeInsets.only(bottom: index == list.where((element) => element.name.contains('-')).length - 1 ? 20 : 0),
                            child: EventCard(
                              textIsFitted: true,
                              isSelect: controller.contain(list.where((element) => element.name.contains('-')).toList()[index].name),
                              cardHeight: 44 ,
                              cardWidth: size.width / 2.4,
                              model: list.where((element) => element.name.contains('-')).toList()[index], onTap: () {
                              controller.emotion =list.where((element) => element.name.contains('-')).toList()[index];
                              controller.update();
                            },),
                          ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GetBuilder(
            builder: (K27Controller _c) => Visibility(
              visible: list.isEmpty,
              child: Center(
                child: Container(
                  width: getHorizontalSize(
                    144,
                  ),
                  margin: getMargin(
                    top: 37,
                  ),
                  child: Text(
                    "Эмоция не найдена\nДобавьте свою эмоцию",
                    maxLines: null,
                    textAlign: TextAlign.center,
                    style: AppStyle.txtSFProDisplayLight14Gray800a01,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: getVerticalSize(40),
          )
        ],
      ),
    );
  }
}
