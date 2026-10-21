import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/audio/audio.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';

import 'package:riva_psy/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/course_repository.dart';
import '../widgets/course_ui.dart';

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
  // Where the person stopped last time (null: start from the beginning).
  Duration? _resume;
  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);

  String get _posKey => 'course_audio_pos_${widget.docId}';

  @override
  void initState() {
    super.initState();
    _load();
    AppAudioService.instance.state.addListener(_onState);
  }

  @override
  void dispose() {
    _savePosition(force: true);
    AppAudioService.instance.state.removeListener(_onState);
    super.dispose();
  }

  // Remembers the position (every few seconds while playing and on leaving)
  // so the next open can offer "continue from 04:20". Finished -> forgotten.
  Future<void> _savePosition({bool force = false}) async {
    final t = _track;
    if (t == null || widget.docId == null) return;
    final s = AppAudioService.instance.state.value;
    if (!s.isCurrent(t.id)) return;
    final d = s.duration.inMilliseconds;
    if (d <= 0) return;
    final now = DateTime.now();
    if (!force && now.difference(_lastSaved) < const Duration(seconds: 5)) return;
    _lastSaved = now;
    final p = s.position.inMilliseconds;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (p < 10000 || p >= d * 0.95) {
        await prefs.remove(_posKey);
      } else {
        await prefs.setInt(_posKey, p);
      }
    } catch (_) {}
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
      final saved = (await SharedPreferences.getInstance()).getInt(_posKey);
      if (saved != null && saved >= 10000) _resume = Duration(milliseconds: saved);
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
    if (s.playing) _savePosition();
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
    final dark = widget.dark;
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: courseMuted(dark));
    if (_loading) {
      return const SizedBox(height: 24, child: Center(child: LinearProgressIndicator()));
    }
    final track = _track;
    if (track == null) {
      return Text('course_audio_soon'.tr(), style: small);
    }
    final accent = courseAccent(dark);
    return ValueListenableBuilder<AppAudioState>(
      valueListenable: AppAudioService.instance.state,
      builder: (context, s, _) {
        final mine = s.isCurrent(track.id);
        final position = mine ? s.position : Duration.zero;
        final duration = mine ? s.duration : Duration.zero;
        final playing = mine && s.playing;
        return SoftCard(
          dark: dark,
          padding: getPadding(left: 16, top: 14, right: 12, bottom: 6),
          child: Column(
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
                          : AppAudioService.instance.play(track, initialPosition: _resume),
                      child: Container(
                        width: getSize(54),
                        height: getSize(54),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
                        ),
                        child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: dark ? kNightBg : Colors.white, size: getSize(30)),
                      ),
                    ),
                  ),
                  SizedBox(width: getHorizontalSize(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(track.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.txtSFProDisplayLight16.copyWith(
                                color: courseText(dark), fontWeight: FontWeight.w600, height: 1.2)),
                        SizedBox(height: getVerticalSize(3)),
                        if (!mine && _resume != null)
                          Row(
                            children: [
                              Text('course_resume_from'.tr(namedArgs: {'time': _fmt(_resume!)}),
                                  style: small.copyWith(color: accent, fontWeight: FontWeight.w600)),
                              Text('  ·  ', style: small),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() => _resume = null);
                                  AppAudioService.instance.play(track);
                                },
                                child: Padding(
                                  padding: getPadding(top: 4, bottom: 4),
                                  child: Text('course_from_start'.tr(),
                                      style: small.copyWith(decoration: TextDecoration.underline)),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(mine ? '${_fmt(position)} / ${_fmt(duration)}' : 'course_listen'.tr(), style: small),
                      ],
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                  min: 0,
                  max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                  activeColor: accent,
                  inactiveColor: (dark ? Colors.white : AppColors.primary).withOpacity(0.15),
                  onChanged: mine ? (v) => AppAudioService.instance.seek(Duration(seconds: v.toInt())) : null,
                ),
              ),
              if (widget.showMark)
                Padding(
                  padding: getPadding(bottom: 6),
                  child: widget.listened
                      ? Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: getSize(16), color: accent),
                            SizedBox(width: getHorizontalSize(6)),
                            Text('course_listened'.tr(), style: small.copyWith(color: accent)),
                          ],
                        )
                      : GestureDetector(
                          onTap: widget.onListened,
                          behavior: HitTestBehavior.opaque,
                          child: Text('course_mark_listened'.tr(),
                              style: small.copyWith(decoration: TextDecoration.underline)),
                        ),
                )
              else
                SizedBox(height: getVerticalSize(8)),
            ],
          ),
        );
      },
    );
  }
}
