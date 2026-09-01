import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../core/services/audio/app_audio_track.dart';
import '../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../core/user_data/user.dart';
import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../core/services/audio/post_audio_checkin_gate.dart';
import '../../../../core/services/datasource_service.dart';
import '../controller.dart';
import '../models/tabs/medetation_model.dart';
import '../models/tabs/negative_emotion_tabs/negative_emotions_tab.dart';
import '../../../../widgets/audio_card_widget.dart';
import 'post_audio_checkin_sheet.dart';

import '../../../../../widgets/go_to_new_tariff_widget.dart';

class TabWidget extends StatefulWidget {
  final bool? isStandardCheck;
  final NegativeEmotionsModelTab tab;
  final K70Controller controller;
  final double height;
  final bool? enableScroll;

  const TabWidget(
      {Key? key,
      required this.tab,
      required this.controller,
      required this.height, this.enableScroll = true, this.isStandardCheck = true})
      : super(key: key);

  @override
  State<TabWidget> createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  List<Widget> _audios = [];
  int? audioLength;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant TabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `tab` is always one of K70Controller's own stable singleton fields
    // (introductionModel/meditationModel/depressionModel/a NegativeTab from
    // NegativeEmotionsModel) — this only fires if a call site ever swaps in
    // a genuinely different tab for an existing Element, which doesn't
    // happen today, but guards against silently keeping stale data if it
    // ever does.
    if (!identical(oldWidget.tab, widget.tab)) {
      _audios = [];
      audioLength = null;
      _load();
    }
  }

  // tab.audioAssets() re-runs a fresh Firestore query every single call
  // (see IntroductionModel etc.) with no orderBy — nothing guarantees two
  // separate calls return the docs in the same order. This used to call
  // it four separate times per build (once per item here, once for
  // audioLength, once for each card's title, once again inside playFun),
  // so the duration list built in one pass could end up matched against
  // a differently-ordered asset list from a later pass — a track's
  // "00:00" (or another track's) duration landing on the wrong card.
  // Fetching once and threading the same resolved list through
  // everything below removes the reordering window entirely.
  //
  // Loaded once in initState (not on every build()) — this used to live
  // directly in a StatelessWidget's build() with the result cached on a
  // mutable instance field, which Flutter is free to discard and recreate
  // on any ancestor rebuild (this call site sits under K70Controller's own
  // GetBuilder, which rebuilds on every controller.update() — tab
  // switches, tariff changes, anything). Each rebuild silently restarted
  // the fetch from scratch, and if a new rebuild landed before the
  // previous fetch resolved, its result was written onto an
  // already-discarded widget instance and never shown — the tab could
  // spin forever under any moderately active rebuild cadence. A
  // StatefulWidget's State survives ancestor rebuilds, so this now runs
  // exactly once per real mount.
  Future<void> _load() async {
    final assets = await widget.tab.audioAssets();
    if (assets == null || !mounted) return;
    final widgets = await _audiosFun(assets);
    if (!mounted) return;
    setState(() {
      _audios = widgets;
    });
  }

  Future<List<Duration?>> _durations(List<AudioCardModel> assets) async {
    final List<Duration?> list = [];
    for (var item in assets) {
      // Known ahead of time (Audio.duration_ms, precomputed once and
      // stored in Firestore) — skip the network probe entirely. This is
      // the common case for every track already in the catalog; only a
      // brand-new track added without a duration backfill falls through
      // to the live probe below.
      list.add(item.knownDuration ?? await AudioCacheManager.probeDuration(item.audioAsset));
    }
    return list;
  }

  Future<List<Widget>> _audiosFun(List<AudioCardModel> assets) async {
    List<Widget> list = [];

    List<Duration?> dur = await _durations(assets);
    audioLength = assets.length;
    for (int i = 0; i < audioLength!; i++) {
      list.add(AudioCardWidget(
        text: assets[i].title,
        maxDuration: dur[i] ?? Duration(seconds: 0),
        track: AppAudioTrack.forUrl(
          assets[i].audioAsset,
          title: assets[i].title,
          nextUrl: i + 1 < assets.length ? assets[i + 1].audioAsset : null,
        ),
        onNaturalCompletion: widget.tab is MeditationModel
            ? () {
                if (!PostAudioCheckinGate.canShow) return;
                PostAudioCheckinGate.markShown();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => PostAudioCheckinSheet(trackTitle: assets[i].title),
                );
              }
            : null,
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final controller = widget.controller;
    final isStandardCheck = widget.isStandardCheck;

    return GetBuilder(
      builder: (K70Controller _c) => Container(
           // height: getVerticalSize(height),
            width: size.width,
            color: ColorConstant.grayLight,
            child: Stack(
              children: [
            Padding(
                  padding: getPadding(top: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: tab.titleImage() != null && tab.titleText() != null,
                          child: Padding(
                            padding: getPadding(left: 16, right: 16),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (tab.titleImage() ?? '').startsWith('assets/')
                                    ? ((tab.titleImage() ?? '').endsWith('.svg')
                                        ? SvgPicture.asset(
                                            tab.titleImage()!,
                                            height: getVerticalSize(100),
                                            width: getHorizontalSize(60),
                                            fit: BoxFit.contain,
                                          )
                                        : Image.asset(
                                            tab.titleImage()!,
                                            height: getVerticalSize(100),
                                            width: getHorizontalSize(60),
                                            fit: BoxFit.contain,
                                          ))
                                    : DataSourceService.dataSourceIsRemote() ? SvgPicture.network(
                                    tab.titleImage() ?? '',
                                    height: getVerticalSize(100),
                                    placeholderBuilder: (context) {
                                      return Center(child: CircularProgressIndicator(color: ColorConstant.cyan700,));
                                    },
                                    width: getHorizontalSize(60),
                                    fit: BoxFit.contain,
                                  ) : SvgPicture.file(
                                    File(tab.titleImage() ?? ''),
                                    height: getVerticalSize(100),
                                    width: getHorizontalSize(60),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: getHorizontalSize(10),),
                                  // No fixed height here — was clipping
                                  // translations longer than the Russian
                                  // original (e.g. Spanish "Termina cada
                                  // ejercicio..."). The Row/Column above
                                  // grows to fit instead.
                                  Container(
                                    alignment: Alignment.topLeft,
                                    width: size.width -getHorizontalSize( 140),
                                    child: Text(
                                      tab.titleText() ?? '',
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProDisplayMedium9.copyWith(
                                          fontSize: 14,
                                          color: ColorConstant.fromHex('#3B3B4A'),
                                        fontWeight: FontWeight.w300
                                      ),
                                    ),
                                  )
                                ],
                              ),
                          ),
                        ),
                        Visibility(
                          // `tab.audioAssets()` returns a Future, which is
                          // never null — this check always evaluated true,
                          // but still fired a brand-new Firestore query
                          // (thrown away unread) on every rebuild, including
                          // every seek-slider drag tick (see
                          // AudioCardWidget's onChange -> controller.update()
                          // below). The actual empty/loading states are
                          // already handled by the ternary right underneath.
                          visible: true,
                            child: Padding(
                          padding: getPadding(top: 23,right: 16, left: 16),
                          child:
                          _audios.isEmpty ? Center(child: CircularProgressIndicator(color: ColorConstant.cyan700,),) :  Wrap(
                              direction: Axis.vertical,
                              spacing: getVerticalSize(33),
                              children: _audios,
                            ),

                        )),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Visibility(
                              visible: tab.buttons() != null,
                              child: Padding(
                                padding: getPadding(left: 16, right: 16, top: 33),
                                child: SizedBox(
                                  width: size.width - 32,
                                  child: Wrap(
                                    spacing: 8,
                                    alignment: WrapAlignment.spaceAround,
                            children: (tab.buttons() ?? []).map((e) => Padding(padding: EdgeInsets.only(bottom: 8), child: e,)).toList(),
                          ),
                                ),
                              )),
                        ),
                        SizedBox(height: 20,)
                      ],
                ),
                  ),
                ),
                Visibility(
                    visible: CurrentUser.user.currentTariff!.name == 'Базовый' && isStandardCheck == true,
                    // Used to start 100px down, to clear this tab's own
                    // header/instruction text — but that gap also left the
                    // first audio card's real, working play/scrub controls
                    // exposed and usable on the free tier. The teaser
                    // overlay is already semi-transparent (you can see
                    // there's real content under it), so covering the
                    // header too is a small loss next to leaving actual
                    // playback reachable without a subscription.
                    // No `height:` here — this used to inherit tabHeight,
                    // which is derived from this tab's own audio count and
                    // collapses to ~200px when that list is empty. The
                    // overlay's own promo content (title/image/buttons/
                    // disclaimer) needs far more than that, so a low-audio
                    // tab clipped it down to an apparently blank gray box.
                    // Omitting height lets the widget fall back to its own
                    // sensible full-screen-ish default.
                    child: GoToNewTariffWidget(onSecondButtonTap: () {
                      controller.tabController!.animateTo(0);
                      controller.currentTab = 0;
                    })),
                // Temporary on-screen diagnostic (debug builds only) — a
                // blank tab here has had two different suspected causes
                // already; this shows the actual values live instead of
                // guessing a third time.
                if (kDebugMode)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black87,
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'tariff=${CurrentUser.user.currentTariff?.name} std=$isStandardCheck audios=${_audios.length} audioLen=$audioLength',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}
