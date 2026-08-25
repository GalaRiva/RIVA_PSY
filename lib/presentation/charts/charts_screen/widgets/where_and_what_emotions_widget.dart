import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/custom_search_view.dart';
import '../../../../widgets/go_to_new_tariff_widget.dart';
import '../controller.dart';
import '../models/emotion_model.dart';
import '../models/place_model.dart';

// Quiet-luxury / trauma-informed redesign: no gridlines, no dense
// wall-of-bars, each place gets its own soft card, and only the top few
// emotions are shown by default so the eye lands on what actually matters
// instead of a dozen 4%-each slivers.
class WhereAndWhatEmotionsWidget extends StatelessWidget {
  final K61Controller controller;
  const WhereAndWhatEmotionsWidget({Key? key, required this.controller}) : super(key: key);

  static const double chartHeight = 108;
  static const int _topN = 3;
  static const Color _otherColor = Color(0xFFBFC4C4);

  double _sum(List<EmotionModel> list) {
    double s = 0;
    for (var item in list) s += item.quantity;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      decoration: AppDecoration.glassCard,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: getPadding(left: 20, top: 21, right: 20),
              child: Text(
                'where_and_what_emotions'.tr(),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                  fontSize: getFontSize(17),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: getPadding(left: 20, top: 6, right: 20),
              child: Text(
                'where_and_what_emotions_intro'.tr(),
                style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
            ),
            Padding(
              padding: getPadding(left: 16, top: 18, right: 16),
              child: CustomSearchView(
                onChange: (text) {
                  controller.searchPlaces(text);
                  controller.update();
                },
                focusNode: FocusNode(),
                hintText: 'find_a_place'.tr(),
                variant: SearchViewVariant.FillGray200,
                fontStyle: SearchViewFontStyle.SFProDisplayLight14Gray800,
                suffix: Padding(
                  padding: getPadding(right: 14),
                  child: CustomImageView(
                    svgPath: ImageConstant.imgSearchWhiteA700,
                    color: ColorConstant.gray800.withOpacity(0.6),
                    height: getVerticalSize(18),
                    width: getHorizontalSize(18),
                  ),
                ),
                suffixConstraints: BoxConstraints(
                  maxHeight: getVerticalSize(26),
                ),
              ),
            ),
            Padding(
              padding: getPadding(top: 24, left: 16, right: 16, bottom: 24),
              child: Wrap(
                spacing: 14,
                direction: Axis.vertical,
                children: controller.placesResult
                    .map((e) => _PlaceCard(place: e, sumAll: _sum(e.emotions)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTab() {
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height - 214,
          decoration: AppDecoration.glassCard,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: getPadding(left: 20, top: 21, right: 20),
                  child: Text(
                    'where_and_what_emotions'.tr(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayLight14Gray800,
                  ),
                ),
                Padding(
                  padding: getPadding(left: 16, right: 16),
                  child: CustomSearchView(
                    onChange: (text) {
                      controller.searchPlaces(text);
                      controller.update();
                    },
                    focusNode: FocusNode(),
                    hintText: 'find_a_place'.tr(),
                    margin: getMargin(
                      left: 2,
                      top: 23,
                    ),
                    variant: SearchViewVariant.FillGray200,
                    fontStyle: SearchViewFontStyle.SFProDisplayLight14Gray800,
                    suffix: Padding(
                      padding: getPadding(right: 14),
                      child: CustomImageView(
                        svgPath: ImageConstant.imgSearchWhiteA700,
                        color: ColorConstant.gray800.withOpacity(0.6),
                        height: getVerticalSize(18),
                        width: getHorizontalSize(18),
                      ),
                    ),
                    suffixConstraints: BoxConstraints(
                      maxHeight: getVerticalSize(
                        26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GoToNewTariffWidget(height: size.height - 214,)
      ],
    );
  }
}

// One place's card: name, bar chart (top emotions + a folded-in "Other"),
// a two-column legend of circular dots, and — only if anything was folded
// in — a toggle to reveal what "Other" is made of.
class _PlaceCard extends StatefulWidget {
  final PlaceModel place;
  final double sumAll;
  const _PlaceCard({required this.place, required this.sumAll});

  @override
  State<_PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<_PlaceCard> {
  bool _expanded = false;
  late final List<EmotionModel> _sorted;
  late final List<EmotionModel> _top;
  late final List<EmotionModel> _hidden;
  late final List<EmotionModel> _display;

  @override
  void initState() {
    super.initState();
    _sorted = [...widget.place.emotions]..sort((a, b) => b.quantity.compareTo(a.quantity));
    if (_sorted.length <= WhereAndWhatEmotionsWidget._topN + 1) {
      _top = _sorted;
      _hidden = const [];
    } else {
      _top = _sorted.take(WhereAndWhatEmotionsWidget._topN).toList();
      _hidden = _sorted.skip(WhereAndWhatEmotionsWidget._topN).toList();
    }
    final otherQty = _hidden.fold<int>(0, (s, e) => s + e.quantity);
    _display = [
      ..._top,
      if (otherQty > 0)
        EmotionModel(otherQty, 'other_emotions_bucket'.tr(), WhereAndWhatEmotionsWidget._otherColor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Headroom above the tallest bar so its percent label always has room
    // to sit above it — without this, fl_chart pushes the label down
    // *inside* the bar when it's close to maxY, and the (color-matched)
    // text disappears against the bar's own fill.
    final maxY = _display.map((e) => e.quantity).reduce((a, b) => a > b ? a : b).toDouble() * 1.25;
    return Container(
      width: size.width - 32,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.place.place,
            style: AppStyle.txtSFProDisplayLight12Gray800.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: getVerticalSize(16)),
          SizedBox(
            height: getVerticalSize(WhereAndWhatEmotionsWidget.chartHeight),
            width: double.infinity,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                // spaceBetween (the default) pins bars to the chart's outer
                // edges — with only 1-3 bars now (top-3 + Other) that reads
                // as lopsided; spaceEvenly keeps them centered and evenly
                // breathing regardless of count.
                alignment: BarChartAlignment.spaceEvenly,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                // Value labels are shown permanently (not on touch) so the
                // percent is readable directly on the bar — no gridlines,
                // no axis, nothing to cross-reference.
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    // A subtle white chip behind the label — belt-and-
                    // suspenders alongside the maxY headroom above, so the
                    // percent stays legible even in a tight spot instead of
                    // ever blending into a same-toned bar.
                    getTooltipColor: (_) => Colors.white.withOpacity(0.85),
                    tooltipBorderRadius: BorderRadius.circular(6),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    tooltipMargin: 6,
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final em = _display[group.x];
                      final percent = ((em.quantity / widget.sumAll) * 100).round();
                      return BarTooltipItem(
                        '$percent%',
                        TextStyle(
                          color: em.color,
                          fontWeight: FontWeight.w700,
                          fontSize: getFontSize(10),
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < _display.length; i++)
                    BarChartGroupData(
                      x: i,
                      showingTooltipIndicators: const [0],
                      barRods: [
                        BarChartRodData(
                          toY: _display[i].quantity.toDouble(),
                          // Solid, matte fill — the old top-light/bottom-dark
                          // gradient read as a dated 2010s chart texture.
                          color: _display[i].color,
                          width: 30,
                          // Full capsule (radius = half the bar width), not
                          // just rounded top corners.
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: getVerticalSize(16)),
          _legendGrid(_display),
          if (_hidden.isNotEmpty) ...[
            SizedBox(height: getVerticalSize(10)),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'show_less'.tr() : 'show_more'.tr(),
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            if (_expanded)
              Padding(
                padding: EdgeInsets.only(top: getVerticalSize(8)),
                child: _legendGrid(_hidden),
              ),
          ],
        ],
      ),
    );
  }

  Widget _legendGrid(List<EmotionModel> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 4.2,
      children: items.map((em) {
        final percent = ((em.quantity / widget.sumAll) * 100).round();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: getSize(10),
              height: getSize(10),
              decoration: BoxDecoration(shape: BoxShape.circle, color: em.color),
            ),
            SizedBox(width: getHorizontalSize(6)),
            Flexible(
              child: Text(
                '${em.name} — $percent%',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: getFontSize(12), color: const Color(0xFF3B3A4A)),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
