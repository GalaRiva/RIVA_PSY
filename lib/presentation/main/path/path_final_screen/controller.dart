import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import 'package:flutter_sound/flutter_sound.dart';
import 'package:record/record.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import 'repository.dart';
import 'widgets/voice_button.dart';
import 'package:path_provider/path_provider.dart';

class K39Controller extends GetxController {
  final DayEventModel dayEventModel;
  final List<String> svgPaths = [
    ImageConstant.imgGlobe,
    ImageConstant.eventFaceTwo,
    ImageConstant.eventFaceThree
  ];
  final List<String> titles = [
    'live_through_wrath'.tr(),
    'live_through_resentment'.tr(),
    'live_through_sorrow'.tr()
  ];

  bool _canPop = false;
  final _repo = K39Repo();
  late String timerText = _formatTime(_stopwatch.elapsedMilliseconds);
  ButtonState currentState = ButtonState.BeforeRecording;
  late OverlayEntry _overlay;

  K39Controller(this.dayEventModel);

  String _formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');

    return "$minutes.$seconds";
  }

  late Timer _timer;
  Stopwatch _stopwatch = Stopwatch();

  void voiceButtonOnTap(K39Controller controller, BuildContext context) {
    switch (currentState) {
      case ButtonState.BeforeRecording:
        _overlay = _overlayEntry(controller);
        currentState = ButtonState.Recording;
        _startRecording(controller, context);
        break;
      case ButtonState.Recording:
        currentState = ButtonState.AfterRecording;
        _stopRecording(controller, context);
        break;
    }
  }
  final record = AudioRecorder();
  void initRecorder() async {
    try {

      await Permission.microphone.request();
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    } catch (_) {

    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
  }

  void _startRecording(K39Controller controller, BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + dayEventModel.date!.toIso8601String();
    if (!directory.existsSync()) {
      directory.createSync();
    }

    if (await record.hasPermission()) {
      await record.start(const RecordConfig(
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000,
      ),
        path: path + '.m4a',
        // by default
      );
    }
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      timerText=  _formatTime(_stopwatch.elapsedMilliseconds);
      controller.update();
    });
    Overlay.of(context).insert(_overlay);
  }

  Future<String?> _stopRecording(
      K39Controller controller, BuildContext context) async {
    _canPop = true;
    _overlay.remove();
    await record.stop();
    _stopwatch.stop();
    _stopwatch.reset();
    _timer.cancel();
    final events = await _repo.getEvent();
    events.removeLast();
    final directory = await getApplicationDocumentsDirectory();
    dayEventModel.pathToAudio = directory.path + dayEventModel.date!.toIso8601String()+ '.m4a';
    events.add(dayEventModel);
    await _repo.updateEvent(events);
    controller.update();
  }

  void deleteAllController() {
    Get.delete<K39Controller>();
  }

  OverlayEntry _overlayEntry(K39Controller controller) => OverlayEntry(
        builder: (context) => GetBuilder(
          builder: (K39Controller _c) => WillPopScope(
            onWillPop: () async {
              _stopRecording(controller, context);
              return true;
            },
            child: Container(
                color: ColorConstant.fromHex('#3B3B4A').withOpacity(0.44),
                width: size.width,
                height: size.height,
                padding: getPadding(
                  left: 10,
                  right: 10,
                ),
                child: Padding(
                  padding: getPadding(top: 140),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: VoiceButton(
                      currentState: _c.currentState,
                      controller: _c,
                    ),
                  ),
                )),
          ),
        ),
      );
}
