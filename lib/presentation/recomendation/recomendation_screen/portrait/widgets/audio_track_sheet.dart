import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';

import '../../working_out/guided_journals/widgets/guided_journal_audio_player.dart';
import '../data/portrait_audio_tracks.dart';

// audioCoverAssets is keyed by the track's Russian Firestore name, not by
// the trackId slug used here — this bridges the two for the 7 "Портрет"
// tracks (see audio_cover_map.dart's own comment on this same set).
const Map<String, String> _portraitTrackRuTitles = {
  'removing_armor': 'Снятие брони',
  'right_to_pause': 'Право на паузу',
  'reactor_cooling': 'Охлаждение реактора',
  'contour_restoration': 'Восстановление контура',
  'dropping_charges': 'Снятие обвинений',
  'return_to_present': 'Возврат в сейчас',
  'cache_reset': 'Сброс кэша',
};

// Standalone single-track player, reached directly from a "Мой портрет"
// test result CTA — deliberately NOT nested inside WorkingOutScreen /
// WorkingOutCubit / GuidedJournalsCubit, so it physically cannot hit that
// module's tariff gate. This is the one CTA type free tests (1-6) are
// allowed to open without an Orion subscription — see PROJECT_CONTEXT.md
// §62 finding 3 (audio-only exception; the rest of "Обретение" stays
// gated). Reuses GuidedJournalAudioPlayer for the actual player widget.
class AudioTrackSheet extends StatelessWidget {
  final String trackId;
  final String title;

  const AudioTrackSheet({Key? key, required this.trackId, required this.title}) : super(key: key);

  static void show(BuildContext context, {required String trackId, required String title}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AudioTrackSheet(trackId: trackId, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getPadding(left: 20, right: 20, top: 24, bottom: 32),
      decoration: BoxDecoration(
        color: ColorConstant.whiteA700,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConstant.gray50,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: getVerticalSize(18)),
          Builder(builder: (context) {
            final cover = audioCoverAsset(_portraitTrackRuTitles[trackId]);
            if (cover == null) return const SizedBox.shrink();
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(cover, width: 140, height: 140, fit: BoxFit.cover),
              ),
            );
          }),
          SizedBox(height: getVerticalSize(16)),
          Text(title, style: AppStyle.txtH2, textAlign: TextAlign.center),
          SizedBox(height: getVerticalSize(16)),
          FutureBuilder<String?>(
            future: PortraitAudioTracks.urlFor(trackId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: getPadding(top: 12, bottom: 12),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final url = snapshot.data;
              if (url == null) return const SizedBox.shrink();
              return GuidedJournalAudioPlayer(url: url, title: title);
            },
          ),
          SizedBox(height: getVerticalSize(12)),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr(), style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
            ),
          ),
        ],
      ),
    );
  }
}
