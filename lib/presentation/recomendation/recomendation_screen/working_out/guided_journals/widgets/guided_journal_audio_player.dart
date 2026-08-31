import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/audio_cache_manager.dart';

// Deliberately minimal — a single optional track on the insight screen,
// not a scrubbable list like AudioCardWidget (which is built around a
// shared player instance + index bookkeeping for a whole tab's track
// list). One play/pause button and a progress bar is all this needs.
class GuidedJournalAudioPlayer extends StatefulWidget {
  final String url;

  const GuidedJournalAudioPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<GuidedJournalAudioPlayer> createState() => _GuidedJournalAudioPlayerState();
}

class _GuidedJournalAudioPlayerState extends State<GuidedJournalAudioPlayer> {
  final _player = AudioPlayer();
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    AudioCacheManager.sourceFor(widget.url).then((source) => _player.setAudioSource(source)).catchError((_) {
      if (mounted) setState(() => _loadFailed = true);
      return null;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) return const SizedBox.shrink();

    return Container(
      padding: getPadding(left: 16, right: 16, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: ColorConstant.grayLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final playing = snapshot.data?.playing ?? false;
          return Row(
            children: [
              IconButton(
                icon: Icon(
                  playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: ColorConstant.cyan700,
                  size: 40,
                ),
                onPressed: () => playing ? _player.pause() : _player.play(),
              ),
              SizedBox(width: getHorizontalSize(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('guided_journal_audio_title'.tr(), style: AppStyle.txtSFProDisplayLight14Gray800),
                    SizedBox(height: 4),
                    StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      builder: (context, posSnapshot) {
                        final position = posSnapshot.data ?? Duration.zero;
                        final total = _player.duration ?? Duration.zero;
                        return Text(
                          '${_format(position)} / ${_format(total)}',
                          style: AppStyle.txtSFProDisplayLight12.copyWith(color: ColorConstant.gray800),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
