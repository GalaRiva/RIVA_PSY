import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/models/body_parts_model.dart';
import 'package:riva_psy/core/models/event_model.dart';
import '../../main/path/what_body_parts_screen/k32_model.dart';
import 'repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/models/day_event_model.dart';
import '../../../core/utils/size_utils.dart';
import '../../../widgets/custom_message_box.dart';
import 'widgets/body_parts_widget.dart';
import 'widgets/bottom_sheet_widget.dart';
import 'widgets/voice_button.dart';
import 'package:path_provider/path_provider.dart';
class K54Controller extends GetxController {
  final DayEventModel dayEventModel;
  K54Controller(this.dayEventModel);

  void initDate(DateTime diffrentDate){
    if(date == null) {
      date = diffrentDate;
    }else if(date != diffrentDate){
      clear();
      date = diffrentDate;
    }
  }

  void clear () {
    currentState = ButtonState.BeforeRecording;
    eventSearchController = TextEditingController();
    eventAddController = TextEditingController();
    placeSearchController = TextEditingController();
    placeAddController = TextEditingController();
    personaSearchController = TextEditingController();
    personaAddController = TextEditingController();
    emotionSearchController = TextEditingController();
    emotionAddController = TextEditingController();
    bodyPartsSearchController = TextEditingController();
    bodyPartsAddController = TextEditingController();
    whatIDoController = TextEditingController();
    firstThoughtsController = TextEditingController();
    selectedBodyParts = [];
  }
  //controllers

  TextEditingController eventSearchController = TextEditingController();
  TextEditingController eventAddController = TextEditingController();
  TextEditingController placeSearchController = TextEditingController();
  TextEditingController placeAddController = TextEditingController();
  TextEditingController personaSearchController = TextEditingController();
  TextEditingController personaAddController = TextEditingController();
  TextEditingController emotionSearchController = TextEditingController();
  TextEditingController emotionAddController = TextEditingController();
  TextEditingController bodyPartsSearchController = TextEditingController();
  TextEditingController bodyPartsAddController = TextEditingController();
  TextEditingController whatIDoController = TextEditingController();
  TextEditingController firstThoughtsController = TextEditingController();

  //focusNodes

  FocusNode eventSNode = FocusNode();
  FocusNode eventANode= FocusNode();
  FocusNode placeSNode= FocusNode();
  FocusNode placeANode= FocusNode();
  FocusNode personaSNode= FocusNode();
  FocusNode personaANode= FocusNode();
  FocusNode emotionSNode= FocusNode();
  FocusNode emotionANode= FocusNode();
  FocusNode bodyPartsSNode= FocusNode();
  FocusNode bodyPartsANode= FocusNode();
  FocusNode whatIDoNode= FocusNode();
  FocusNode firstThoughtsNode= FocusNode();



  final _repo = K54Repo();
  DateTime? date;
  var eventList = <EventModel>[];
  var bodyParts = <K32Model>[];
  late var selectedBodyParts = <K32Model>[];

  void openEventBottomSheet(
      {required BuildContext context,
      List<EventModel>? events,
      List<K32Model>? bodyParts,
      required String initialText,
      required String hintText,
      Function(EventModel model)? onChangeEventModel,
      Function(K32Model model)? onChangeBodyPartsModel,
      Function(String text)? onChangeSearchText}) {
    Scaffold.of(context).showBottomSheet(
        (context) => BottomSheetWidget(
              onChangeSearchText: onChangeSearchText,
              events: events,
              bodyParts: bodyParts,
              initialText: initialText,
              hintText: hintText,
              controller: this,
              onChangeBodyPartsModel: onChangeBodyPartsModel,
              onChangeEventModel: onChangeEventModel,
            ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))));
  }

  Future eventSearch(String text) async {
    var currentEventList = await _repo.getEventByEnum(RepoEvent.event);
    if (text.isNotEmpty) {
      if (eventList.isNotEmpty) eventList = [];
      for (final event in currentEventList) {
        if (event.name.toLowerCase().contains(text.toLowerCase())) eventList.add(event);
      }
    } else {
      eventList = currentEventList;
    }
    update();
  }

  Future<List<EventModel>> eventAdd (EventModel model) async {
    final listToUpdate = await _repo.getEventByEnum(RepoEvent.event);
    listToUpdate.add(model);
    await _repo.updateEventByEnum(RepoEvent.event, events: listToUpdate);
    return listToUpdate;
  }

  Future placeSearch(String text) async {
    var currentEventList = await _repo.getEventByEnum(RepoEvent.place);
    if (text.isNotEmpty) {
      if (eventList.isNotEmpty) eventList = [];
      for (final event in currentEventList) {
        if (event.name.toLowerCase().contains(text.toLowerCase())) eventList.add(event);
      }
    } else {
      eventList = currentEventList;
    }
    update();
  }

  Future<List<EventModel>> placeAdd (EventModel model) async {
    final listToUpdate = await _repo.getEventByEnum(RepoEvent.place);
    listToUpdate.add(model);
    await _repo.updateEventByEnum(RepoEvent.place, events: listToUpdate);
    return listToUpdate;
  }

  Future personaSearch(String text) async {
    var currentEventList = await _repo.getEventByEnum(RepoEvent.persona);
    if (text.isNotEmpty) {
      if (eventList.isNotEmpty) eventList = [];
      for (final event in currentEventList) {
        if (event.name.toLowerCase().contains(text.toLowerCase())) eventList.add(event);
      }
    } else {
      eventList = currentEventList;
    }
    update();
  }

  Future<List<EventModel>> personaAdd (EventModel model) async {
    final listToUpdate = await _repo.getEventByEnum(RepoEvent.persona);
    listToUpdate.add(model);
    await _repo.updateEventByEnum(RepoEvent.persona, events: listToUpdate);
    return listToUpdate;
  }

  Future emotionSearch(String text) async {
    final neutralPositive = await _repo.getEventByEnum(RepoEvent.emotion3);
    final neutralNegative = await _repo.getEventByEnum(RepoEvent.emotion3);

    for(EventModel item in neutralPositive) {
      item.name += ' +';
    }
    for(EventModel item in neutralNegative) {
      item.name += ' -';
    }
    var currentEventList = await _repo.getEventByEnum(RepoEvent.emotion1) + await _repo.getEventByEnum(RepoEvent.emotion2) + neutralPositive + neutralNegative;
    if (text.isNotEmpty) {
      if (eventList.isNotEmpty) eventList = [];
      for (final event in currentEventList) {
        if (event.name.toLowerCase().contains(text.toLowerCase())) eventList.add(event);
      }
    } else {
      eventList = currentEventList;
    }
    update();
  }

  Future<List<EventModel>> emotionAdd (EventModel model) async {
    final listToUpdate = await _repo.getEventByEnum(RepoEvent.emotion3);
    listToUpdate.add(model);
    await _repo.updateEventByEnum(RepoEvent.emotion3, events: listToUpdate);
    return listToUpdate;
  }

  Future bodyPartsSearch(String text) async {
    var currentEventList = await _repo.getEventByEnum(RepoEvent.bodyParts);
    if (text.isNotEmpty) {
      if (bodyParts.isNotEmpty) bodyParts = [];
      for (BodyPartsModel event in currentEventList) {
        if (event.bodyPart.toLowerCase().contains(text.toLowerCase())) bodyParts.add(K32Model(event, event.bodyPart));
      }
    } else {
      bodyParts = (currentEventList as List<BodyPartsModel>).map((e) => K32Model(e, e.bodyPart)).toList();
    }
  }

  Future<List<BodyPartsModel>> bodyPartAdd (BodyPartsModel model) async {
    final listToUpdate = await _repo.getEventByEnum(RepoEvent.bodyParts);
    listToUpdate.add(model);
    await _repo.updateEventByEnum(RepoEvent.bodyParts, bodyParts: listToUpdate);
    return listToUpdate;
  }

  Future<List<DayEventModel>> getDayEvents () async {
    return await _repo.getEventByEnum(RepoEvent.dayEvent) as List<DayEventModel>;
  }

  Future<void> dayEventUpdate (DayEventModel model) async {
    final listToUpdate = await getDayEvents();
    listToUpdate.add(model);
    await _repo.updateEventByEnum(RepoEvent.dayEvent, dayEvents: listToUpdate);
  }

  double getMessageBoxHeight (BodyPartsModel model) {
    switch(model.bodyPart.toLowerCase()) {
      case 'голова и лицо':
        return 266;
      case 'горло':
        return 266;
      case 'грудная клетка':
        return 314;
      case 'плечи и руки':
        return 314;
      case 'ноги':
        return 266;
      case 'живот':
        return 314;
      default:
        return 160;
    }
  }

  Future showSelectWhatHartDialog(BuildContext context, BodyPartsModel model) => showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return GetBuilder(
          builder: (K54Controller _c) => CustomMessageBox(
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
                            child: BodyPartWidget(model: model, title: e, controller: this, color: Colors.white,),
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

  late String timerText = _formatTime(_stopwatch.elapsedMilliseconds);
  ButtonState currentState = ButtonState.BeforeRecording;

  String _formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');

    return "$minutes.$seconds";
  }

  late Timer _timer;
  Stopwatch _stopwatch = Stopwatch();

  void voiceButtonOnTap(BuildContext context) {
    switch (currentState) {
      case ButtonState.BeforeRecording:
        currentState = ButtonState.Recording;
        _startRecording(context);
        update();
        break;
      case ButtonState.Recording:
        currentState = ButtonState.AfterRecording;
        _stopRecording(context);
        update();
    }
  }

  final record = AudioRecorder();
  void initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();

  }

  void _startRecording(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + dayEventModel.date!.toIso8601String();
    if (!directory.existsSync()) {
      directory.createSync();
    }

    if (await record.hasPermission()) {
      await record.start(
        RecordConfig(encoder: AudioEncoder.aacLc, // by default
          bitRate: 128000, ),
        path: path + '.m4a',
      );
    }
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      timerText=  _formatTime(_stopwatch.elapsedMilliseconds);
      update();
    });
  }

  Future<String?> _stopRecording(BuildContext context) async {
    await record.stop();
    _stopwatch.stop();
    _stopwatch.reset();
    _timer.cancel();
    final directory = await getApplicationDocumentsDirectory();
    dayEventModel.pathToAudio = directory.path + dayEventModel.date!.toIso8601String()+ '.m4a';
    update();
  }
}
