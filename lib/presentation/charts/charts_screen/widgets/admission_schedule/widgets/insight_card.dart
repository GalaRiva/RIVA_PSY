import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/models/insight_model.dart';
import 'package:riva_psy/core/services/insights/insights_repo.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_style.dart';

Color _categoryColor(String category) {
  if (category == 'missed_dose') return ColorConstant.fromHex('#E8E4F3');
  if (category == 'anxiety_reduction') return ColorConstant.fromHex('#FFF6D9');
  return ColorConstant.fromHex('#DFF5F0');
}

/// Shows the most recent insight "batch" — every insight the engine produced
/// in one run shares the exact same `generatedAt` instant (see
/// InsightEngine.run()), so grouping by that timestamp reconstructs the
/// batch the nightly job (or a reactive save) found together, letting the
/// user read the full report in-app instead of just the single latest item.
class InsightSection extends StatefulWidget {
  const InsightSection({Key? key}) : super(key: key);

  @override
  State<InsightSection> createState() => _InsightSectionState();
}

class _InsightSectionState extends State<InsightSection> {
  final _repo = InsightsRepo();
  List<InsightModel> _batch = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _repo.getAll();
    all.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    final latestBatch = all.isEmpty
        ? <InsightModel>[]
        : all.where((i) => i.generatedAt == all.first.generatedAt).toList();
    for (final insight in latestBatch) {
      if (!insight.isRead) await _repo.markRead(insight.id);
    }
    if (mounted) {
      setState(() {
        _batch = latestBatch;
        _loaded = true;
      });
    }
  }

  Future<void> _feedback(InsightModel insight, String value) async {
    await _repo.setFeedback(insight.id, value);
    setState(() {
      final index = _batch.indexWhere((i) => i.id == insight.id);
      if (index != -1) _batch[index] = insight.copyWith(feedback: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insight_of_day_title'.tr(),
          style: AppStyle.txtSFProDisplayLight14
              .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: getVerticalSize(10)),
        if (_batch.isEmpty)
          _card(
            color: Colors.white,
            child: Text(
              'insights_empty'.tr(),
              style: AppStyle.txtSFProDisplayLight12.copyWith(color: ColorConstant.gray800),
            ),
          ),
        ..._batch.map((insight) => Padding(
              padding: getPadding(bottom: 10),
              child: _card(
                color: _categoryColor(insight.category),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.templateKey.tr(namedArgs: insight.namedArgs),
                      style: AppStyle.txtSFProDisplayLight12.copyWith(color: ColorConstant.gray800),
                    ),
                    SizedBox(height: getVerticalSize(8)),
                    if (insight.feedback == null)
                      Row(
                        children: [
                          _feedbackButton('insight_helpful'.tr(), () => _feedback(insight, 'helpful')),
                          SizedBox(width: getHorizontalSize(8)),
                          _feedbackButton(
                              'insight_inaccurate'.tr(), () => _feedback(insight, 'inaccurate')),
                        ],
                      )
                    else
                      Text(
                        insight.feedback == 'helpful' ? 'insight_helpful'.tr() : 'insight_inaccurate'.tr(),
                        style: AppStyle.txtSFProDisplayLight11
                            .copyWith(color: ColorConstant.gray800, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _card({required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: getPadding(all: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(getHorizontalSize(8)),
      ),
      child: child,
    );
  }

  Widget _feedbackButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: getPadding(top: 12, bottom: 12, right: 8),
        child: Text(
          label,
          style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.deepPurple600),
        ),
      ),
    );
  }
}
