import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../../../../core/models/body_parts_model.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../widgets/custom_message_box.dart';
import 'k32_model.dart';
import 'repository.dart';
import 'widgets/body_parts_widget.dart';

class K32Controller extends GetxController {

  final _repo = K32Repo();

  final searchController = TextEditingController();
  final addEventController = TextEditingController();

  late List<K32Model> selectedEventList = [];
  late List<BodyPartsModel> currentEventList = _repo.standardEventList;


  List<BodyPartsModel>? bodyParts;

  void changeCurrentEventList (String text) async {

    if(text.isNotEmpty) {
      if (currentEventList.isNotEmpty)
        currentEventList = [];
      for (final event in await initCurrentEventList()) {
        if (event.bodyPart.toLowerCase().contains(text.toLowerCase())) currentEventList.add(event);
      }
    } else {
      currentEventList = await initCurrentEventList();
    }
  }

  Future<List<BodyPartsModel>> updateCurrentEventList (BodyPartsModel model) async {
    currentEventList.add(model);
        await _repo.updateEvent(currentEventList);
    return currentEventList;
  }

  Future<List<BodyPartsModel>> initCurrentEventList () async {
        return _repo.getEvent();
  }

  double getMessageBoxHeight (BodyPartsModel model) => model.messageBoxHeight;

  Future showSelectWhatHartDialog(BuildContext context, K32Controller controller, BodyPartsModel model) => showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return GetBuilder(
          builder: (K32Controller _c) => CustomMessageBox(
            title: model.bodyPart,
            height: getMessageBoxHeight(model),
            content: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Center(
                    child: Container(
                      margin: getMargin(all: 20),
                      child: Wrap(
                        children: model.whatHurts.map((e) => Padding(
                          padding: getPadding(bottom: 15, right: 6),
                          child: BodyPartWidget(model: model,
                            cwidth: size.width / 2 - 60,

                            title: e, controller: controller, color: Colors.white,),
                        )).toList(),
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
