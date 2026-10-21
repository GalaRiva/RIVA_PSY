import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/audio/audio.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';

import '../data/course_repository.dart';

const String _r2AudioBase = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

// One course audio: looks the Audio document up by id, plays it through the
// shared AppAudioService, and reports "listened" once ~80% was played or the
// person marks it manually. If the document doesn't exist yet (audio still
// being recorded) it says so instead of failing.
class CourseAudioPlayer extends StatefulWidget {
  final String? docId;
  final bool listened;
  final VoidCallback onListened;
  final bool showMark;
  // Fires every time a play-through reaches the end (also on repeats, when
  // [onListened] no longer does) — used for the "how are you now?" check.
  final VoidCallback? onFinished;
  // Light-on-dark colours for the night screen.
  final bool dark;

  const CourseAudioPlayer(
      {Key? key,
      required this.docId,
      required this.listened,
      required this.onListened,
      this.showMark = true,
      this.onFinished,
      this.dark = false})
      : super(key: key);

  @override
  State<CourseAudioPlayer> createState() => _CourseAudioPlayerState();
}

class _CourseAudioPlayerState extends State<CourseAudioPlayer> {
  AppAudioTrack? _track;
  bool _loading = true;
  bool _reported = false; // this play-through already reported

  @override
  void initState() {
    super.initState();
    _load();
    AppAudioService.instance.state.addListener(_onState);
  }

  @override
  void dispose() {
    AppAudioService.instance.state.removeListener(_onState);
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.docId;
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('Audio').doc(id).get();
      final data = doc.data();
      if (data == null) throw Exception('not found');
      final lang = await CourseRepository.langCode();
      final audio = Audio.fromJson(data);
      final url = Uri.encodeFull('$_r2AudioBase${audio.localizedFileName(lang)}.${audio.format}');
      _track = AppAudioTrack.forUrl(url,
          title: audio.localizedName(lang),
          coverAsset: audioCoverAsset(audio.name),
          coverBuilder: animatedAudioCoverBuilder(audio.name));
    } catch (_) {
      _track = null;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onState() {
    final t = _track;
    if (t == null) return;
    final s = AppAudioService.instance.state.value;
    if (!s.isCurrent(t.id)) return;
    final d = s.duration.inMilliseconds;
    if (d <= 0) return;
    final p = s.position.inMilliseconds;
    if (p < d * 0.3) {
      _reported = false; // started again (repeat)
      return;
    }
    if (!_reported && p >= d * 0.8) {
      _reported = true;
      if (!widget.listened) widget.onListened();
      widget.onFinished?.call();
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final small = AppStyle.txtSFProDisplayRegular11
        .copyWith(color: widget.dark ? Colors.white60 : ColorConstant.gray500);
    if (_loading) {
      return const SizedBox(height: 24, child: Center(child: LinearProgressIndicator()));
    }
    final track = _track;
    if (track == null) {
      return Text('course_audio_soon'.tr(), style: small);
    }
    return ValueListenableBuilder<AppAudioState>(
      valueListenable: AppAudioService.instance.state,
      builder: (context, s, _) {
        final mine = s.isCurrent(track.id);
        final position = mine ? s.position : Duration.zero;
        final duration = mine ? s.duration : Duration.zero;
        final playing = mine && s.playing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  label: playing ? 'pause' : 'course_listen'.tr(),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => mine
                        ? AppAudioService.instance.togglePlayPause()
                        : AppAudioService.instance.play(track),
                    child: Container(
                      width: getSize(44),
                      height: getSize(44),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: ColorConstant.cyan700),
                      child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white, size: getSize(26)),
                    ),
                  ),
                ),
                SizedBox(width: getHorizontalSize(12)),
                Expanded(
                  child: Slider(
                    value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                    min: 0,
                    max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                    activeColor: widget.dark ? const Color(0xFF7FBDBA) : ColorConstant.cyan700,
                    inactiveColor: (widget.dark ? Colors.white : ColorConstant.cyan700).withOpacity(0.2),
                    onChanged: mine ? (v) => AppAudioService.instance.seek(Duration(seconds: v.toInt())) : null,
                  ),
                ),
                Text(mine ? _fmt(position) : '00:00', style: small),
              ],
            ),
            if (!widget.showMark)
              const SizedBox.shrink()
            else if (widget.listened)
              Text('course_listened'.tr(),
                  style: small.copyWith(color: widget.dark ? const Color(0xFF7FBDBA) : ColorConstant.cyan700))
            else
              TextButton(
                onPressed: widget.onListened,
                child: Text('course_mark_listened'.tr(), style: small),
              ),
          ],
        );
      },
    );
  }
}
