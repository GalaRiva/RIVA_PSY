import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../widgets/custom_icon_button.dart';
import '../presentation/recomendation/recomendation_screen/controller.dart';

class AudioCardWidget extends StatelessWidget {
  final String text;
  final Duration maxDuration;
  final Function(Duration) onChange;
  final Function? loadFun;
  final AudioPlayer audioInstance;
  final int Function() currentAudioIndex;
  final Function(int index) changeCurrentAudioIndex;
  final Function(Duration duration)? playFun;
  final Function()? stopFun;
  final int index;

   AudioCardWidget(
      {Key? key,
      required this.text,
      required this.onChange,
      required this.maxDuration,
      this.playFun,
      this.stopFun,
      this.loadFun, required this.index, required this.audioInstance, required this.currentAudioIndex, required this.changeCurrentAudioIndex})
      : super(key: key);

  AudioState state = AudioState.Stopped;

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration.zero;


    String _formatTime(int milliseconds) {
      var secs = milliseconds ~/ 1000;
      var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
      var seconds = (secs % 60).toString().padLeft(2, '0');

      return "$minutes.$seconds";
    }

    Timer? _timer;

    audioInstance.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;

      if(audioInstance.playing && currentAudioIndex() != index){
        state = AudioState.Stopped;
        try {
          if(_timer != null)
          _timer!.cancel();
        } catch(_) {

        }
        } if (processingState == ProcessingState.completed) { // completed
        try {
          audioInstance.seek(Duration.zero);
          audioInstance.pause();
        } catch (_) {

        }
        }
    });
    return GetBuilder(
        builder: (K70Controller _c) =>
        SizedBox(
        height: getVerticalSize(65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayRegular11.copyWith(
                letterSpacing: getHorizontalSize(
                  0.44,
                ),
              ),
            ),
            SizedBox(
              height: getVerticalSize(12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconButton(
                  height: getVerticalSize(32),
                  width: getVerticalSize(32),
                  child: CustomImageView(
                    svgPath: ImageConstant.imgMusicCyan70032x32,
                  ),
                ),
                Padding(
                  padding: getPadding(left: 10),
                  child: Container(
                    width: size.width - 74,
                    height: getVerticalSize(32),
                    decoration: AppDecoration.back.copyWith(
                      color: ColorConstant.gray300,
                      borderRadius: BorderRadiusStyle.roundedBorder3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: (){

                            if(currentAudioIndex() != index && state == AudioState.Playing) {
                              state = AudioState.Stopped;
                            }
                            changeCurrentAudioIndex(index);
                            if(state == AudioState.Stopped){
                              state = AudioState.Playing;
                              playFun!(duration);
                              _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                                duration = Duration(seconds: duration.inSeconds + 1);
                                if(duration.inSeconds.toDouble() >= maxDuration.inSeconds.toDouble()){
                                  changeCurrentAudioIndex(index);
                                  if(_timer != null)
                                    _timer!.cancel();
                                  stopFun!();
                                  state = AudioState.Stopped;
                                  duration = Duration.zero;
                                }
                              _c.update();
                              });

                            } else {
                              changeCurrentAudioIndex(index);
                              if(_timer != null)
                                _timer!.cancel();
                              stopFun!();
                              state = AudioState.Stopped;
                              _c.update();
                            }
                          },

                          child: CustomImageView(
                            height: getSize(30),
                            width: getSize(30),
                            svgPath: (state == AudioState.Stopped || currentAudioIndex() != index) ? ImageConstant.buttonStart : ImageConstant.imgVolume,
                          ),
                        ),
                        SizedBox(
                          width: size.width - 159,
                          child: SliderTheme(

                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 1,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                              ),
                              child: Slider(
                                value: duration.inSeconds.toDouble() >= maxDuration.inSeconds.toDouble() ? maxDuration.inSeconds.toDouble() : duration.inSeconds.toDouble(),
                                min: 0.0,
                                thumbColor: ColorConstant.cyan700,
                                activeColor: ColorConstant.cyan700,
                                inactiveColor: Colors.white,
                                max: maxDuration.inSeconds.toDouble(),
                                onChanged: (double value) {
                                    duration = Duration(seconds: value.toInt());
                                    onChange(duration);
                                },
                              ),
                            )

                        ),
                        Text(
                          _formatTime(maxDuration.inMilliseconds),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayMedium9.copyWith(color: ColorConstant.cyan700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum AudioState { Playing, Stopped }
class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}