import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';

// Deliberately minimal — a single optional track on the insight screen,
// not a scrubbable list like AudioCardWidget (which is built around a
// shared player instance + index bookkeeping for a whole tab's track
// list). One play/pause button and a progress bar is all this needs.
//
// Plays through the app-wide AppAudioService instead of owning its own
// player — starting this track stops whatever else was playing anywhere
// else in the app, and vice versa (tapping play elsewhere while this is
// playing pauses this one). Trades away the old eager preload-on-open
// (which let the total duration show before the user tapped play) for
// that shared-state correctness — the duration now only appears once
// playback actually starts.
class GuidedJournalAudioPlayer extends StatelessWidget {
  final String url;
  final String? title;

  const GuidedJournalAudioPlayer({Key? key, required this.url, this.title}) : super(key: key);

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final track = AppAudioTrack.forUrl(url, title: title ?? 'guided_journal_audio_title'.tr());
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: getPadding(left: 16, right: 16, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ValueListenableBuilder<AppAudioState>(
            valueListenable: AppAudioService.instance.state,
            builder: (context, audioState, _) {
              final isMine = audioState.isCurrent(track.id);
              final playing = isMine && audioState.playing;
              final position = isMine ? audioState.position : Duration.zero;
              final total = isMine ? audioState.duration : Duration.zero;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: ColorConstant.cyan700,
                      size: 40,
                    ),
                    onPressed: () {
                      final service = AppAudioService.instance;
                      if (isMine) {
                        service.togglePlayPause();
                      } else {
                        service.play(track);
                      }
                    },
                  ),
                  SizedBox(width: getHorizontalSize(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('guided_journal_audio_title'.tr(), style: AppStyle.txtSFProDisplayLight14Gray800),
                        SizedBox(height: 4),
                        Text(
                          '${_format(position)} / ${_format(total)}',
                          style: AppStyle.txtSFProDisplayLight12.copyWith(color: ColorConstant.gray800),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
