import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/controller.dart';

import '../main.dart';
import 'fullscreen_audio_player_screen.dart';

// Global "now playing" strip — mounted once in MaterialApp.builder (see
// main.dart) so it floats above every screen without touching any of the
// ~29 individual Scaffolds that each own their own CustomBottomBar. Reads
// AppAudioService.state directly; nothing to wire per-screen.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({Key? key}) : super(key: key);

  // K70Controller's immersiveMode/activeTopLevelTab (full-screen exercises,
  // "Обретение") have no app-wide notifier of their own — this is a plain
  // snapshot read, not a subscription, but it's checked on every rebuild
  // this widget already gets from the audio-state ticks below, so a mode
  // change is reflected within a beat rather than instantly. Good enough
  // for a chrome-hiding decision, not worth new cross-cutting state for.
  bool _hiddenForK70() {
    if (!Get.isRegistered<K70Controller>()) return false;
    final c = Get.find<K70Controller>();
    return c.immersiveMode || c.activeTopLevelTab == 1;
  }

  String _fmtRemaining(Duration position, Duration duration) {
    final remaining = duration - position;
    if (remaining <= Duration.zero) return '';
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '-$m:$s';
  }

  Widget _cover(AppAudioTrack track) {
    if (track.coverBuilder != null) {
      return SizedBox(width: 40, height: 40, child: Builder(builder: track.coverBuilder!));
    }
    if ((track.coverAsset ?? '').isNotEmpty) {
      return Image.asset(track.coverAsset!,
          width: 40, height: 40, fit: BoxFit.cover);
    }
    if ((track.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        track.coverUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCover(),
      );
    }
    return _fallbackCover();
  }

  Widget _fallbackCover() {
    return Container(
      width: 40,
      height: 40,
      color: ColorConstant.cyan700.withOpacity(0.12),
      alignment: Alignment.center,
      child: Icon(Icons.music_note_rounded,
          color: ColorConstant.cyan700, size: 20),
    );
  }

  Widget _fullscreenCover(AppAudioTrack track) {
    if (track.coverBuilder != null) {
      return Builder(builder: track.coverBuilder!);
    }
    if ((track.coverAsset ?? '').isNotEmpty) {
      return Image.asset(track.coverAsset!, fit: BoxFit.cover);
    }
    if ((track.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        track.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: ColorConstant.cyan700),
      );
    }
    return Container(color: ColorConstant.cyan700);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FullscreenAudioPlayerScreen.isOpen,
      builder: (context, fullscreenOpen, _) {
        return ValueListenableBuilder<AppAudioState>(
          valueListenable: AppAudioService.instance.state,
          builder: (context, audioState, __) {
            final track = audioState.track;
            if (track == null || fullscreenOpen || _hiddenForK70()) {
              return const SizedBox.shrink();
            }
            // CustomBottomBar's own real height (lib/widgets/custom_bottom_bar.dart):
            // getVerticalSize(10) top padding + getVerticalSize(52) content +
            // the device's own bottom safe-area inset (its inner SafeArea).
            // Matching that exactly (plus a clear gap) instead of a flat guess
            // means this docks just above the nav bar on every screen that has
            // one, and doesn't undershoot on devices with a tall gesture inset.
            final bottomClearance = getVerticalSize(10) +
                getVerticalSize(52) +
                MediaQuery.of(context).padding.bottom +
                getVerticalSize(14);
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: getHorizontalSize(16),
                  right: getHorizontalSize(16),
                  bottom: bottomClearance,
                ),
                child: GestureDetector(
                  onTap: () {
                    // MiniPlayerBar is mounted in MaterialApp.builder,
                    // alongside the Navigator rather than inside it —
                    // Navigator.of(context) from here would find nothing.
                    // The app's own navigatorKey (already used the same
                    // way in notification_controller.dart) reaches it
                    // from outside the routed subtree.
                    MyApp.navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        settings: const RouteSettings(
                          name: FullscreenAudioPlayerScreen.routeName,
                        ),
                        builder: (_) => FullscreenAudioPlayerScreen(
                          title: track.title,
                          cover: _fullscreenCover(track),
                          accentColor: ColorConstant.cyan700,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: getVerticalSize(64),
                    padding:
                        EdgeInsets.symmetric(horizontal: getHorizontalSize(10)),
                    decoration: BoxDecoration(
                      color: ColorConstant.whiteA700,
                      borderRadius:
                          BorderRadius.circular(getHorizontalSize(32)),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstant.deepPurple7000c,
                          blurRadius: getHorizontalSize(16),
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(getHorizontalSize(20)),
                          child: _cover(track),
                        ),
                        SizedBox(width: getHorizontalSize(12)),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    AppStyle.txtSFProDisplayRegular14.copyWith(
                                  color: ColorConstant.gray800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (audioState.duration > Duration.zero)
                                Text(
                                  _fmtRemaining(
                                      audioState.position, audioState.duration),
                                  style: AppStyle.txtSFProDisplayRegular14
                                      .copyWith(
                                    color: ColorConstant.gray500,
                                    fontSize: getFontSize(11),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: getHorizontalSize(8)),
                        GestureDetector(
                          onTap: () =>
                              AppAudioService.instance.togglePlayPause(),
                          child: Container(
                            width: getSize(40),
                            height: getSize(40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConstant.cyan700),
                            child: Icon(
                              audioState.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: getSize(22),
                            ),
                          ),
                        ),
                        SizedBox(width: getHorizontalSize(2)),
                        GestureDetector(
                          onTap: () => AppAudioService.instance.stop(),
                          child: Padding(
                            padding: EdgeInsets.all(getHorizontalSize(8)),
                            child: Icon(Icons.close_rounded,
                                color: ColorConstant.gray500,
                                size: getSize(18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
