import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/services/dashboards/dashboard_feedback_store.dart';
import '../core/utils/color_constant.dart';
import '../theme/app_colors.dart';

/// Shared "Сводка / Совет / Немного теории" block used under all three
/// analytics dashboards (Матрица, Тепловая карта, Батарейка). Highlighted
/// substrings (tag names) inside [summaryText]/[nudgeText] are rendered as
/// small chips — matched by literal substring search on the already-
/// resolved (`.tr()`'d) sentence, so it works regardless of word order in
/// any of the app's languages.
class DashboardInsightCard extends StatefulWidget {
  /// Stable id for the specific finding (e.g. tag names involved) — the
  /// 👎 cooldown is keyed on this, not on which template variant was shown,
  /// so it survives across different random phrasings of the same finding.
  final String signature;
  final String summaryText;
  final List<String> highlights;
  final String nudgeText;
  final String theoryTitle;
  final String theoryBody;

  // Same supportive-coaching emoji vocabulary already used across the
  // gratitude/invitation push templates — picked per-finding (stable via
  // signature hash, not re-rolled on every rebuild) instead of one fixed
  // icon per screen, per the "советы вариативны" requirement.
  static const _nudgeIcons = ['💡', '🌿', '✨', '🌟', '🧘', '☀️', '🍃', '🤍'];

  const DashboardInsightCard({
    Key? key,
    required this.signature,
    required this.summaryText,
    required this.highlights,
    required this.nudgeText,
    required this.theoryTitle,
    required this.theoryBody,
  }) : super(key: key);

  String get _nudgeIcon => _nudgeIcons[signature.hashCode.abs() % _nudgeIcons.length];

  @override
  State<DashboardInsightCard> createState() => _DashboardInsightCardState();
}

class _DashboardInsightCardState extends State<DashboardInsightCard> {
  late bool _dismissed;
  bool _thankedPositive = false;

  @override
  void initState() {
    super.initState();
    _dismissed = DashboardFeedbackStore.isSuppressed(widget.signature);
  }

  Future<void> _markNotHelpful() async {
    await DashboardFeedbackStore.markNotHelpful(widget.signature);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'insight_feedback_dismissed'.tr(),
          style: const TextStyle(fontSize: 12, color: Colors.black38),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('insights_period_all_time'.tr(), style: const TextStyle(fontSize: 11, color: Colors.black45)),
        const SizedBox(height: 8),
        _buildHighlightedText(widget.summaryText, widget.highlights),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.chartGold.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.chartGold.withOpacity(0.25), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget._nudgeIcon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: _buildHighlightedText(widget.nudgeText, widget.highlights, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: Text(widget.theoryTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.theoryBody, style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.black54)),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('insight_helpful'.tr(), style: TextStyle(fontSize: 11, color: _thankedPositive ? ColorConstant.cyan700 : Colors.black45)),
            GestureDetector(
              onTap: () => setState(() => _thankedPositive = true),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: Text('👍')),
            ),
            const SizedBox(width: 8),
            Text('insight_inaccurate'.tr(), style: const TextStyle(fontSize: 11, color: Colors.black45)),
            GestureDetector(
              onTap: _markNotHelpful,
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: Text('👎')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlightedText(String text, List<String> highlights, {double fontSize = 13}) {
    final spans = <InlineSpan>[];
    var remaining = text;
    while (remaining.isNotEmpty) {
      var matchIndex = -1;
      String? matched;
      for (final h in highlights) {
        if (h.isEmpty) continue;
        final idx = remaining.indexOf(h);
        if (idx != -1 && (matchIndex == -1 || idx < matchIndex)) {
          matchIndex = idx;
          matched = h;
        }
      }
      if (matchIndex == -1) {
        spans.add(TextSpan(text: remaining));
        break;
      }
      if (matchIndex > 0) spans.add(TextSpan(text: remaining.substring(0, matchIndex)));
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: ColorConstant.cyan700.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
          child: Text(matched!, style: TextStyle(fontWeight: FontWeight.w600, color: ColorConstant.cyan700, fontSize: fontSize)),
        ),
      ));
      remaining = remaining.substring(matchIndex + matched.length);
    }
    return RichText(text: TextSpan(style: TextStyle(fontSize: fontSize, height: 1.5, color: Colors.black87), children: spans));
  }
}
