import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../../widgets/go_to_new_tariff_widget.dart';

class _Benefit {
  final IconData icon;
  final String title;
  final String desc;
  const _Benefit(this.icon, this.title, this.desc);
}

const List<_Benefit> _benefits = [
  _Benefit(Icons.auto_stories_rounded, 'guided_journal_paywall_benefit1_title',
      'guided_journal_paywall_benefit1_desc'),
  _Benefit(Icons.headphones_rounded, 'guided_journal_paywall_benefit2_title',
      'guided_journal_paywall_benefit2_desc'),
  _Benefit(Icons.favorite_rounded, 'guided_journal_paywall_benefit3_title',
      'guided_journal_paywall_benefit3_desc'),
];

// Same shape/template as PortraitPaywallPage — no discount, no countdown,
// just the regular Orion offer (monthly/yearly via GoToNewTariffWidget) with
// a short benefits pitch. Shown when tapping a locked "Хлебные крошки" topic
// (index >= kGuidedJournalFreeTopicCount, see GuidedJournalLibraryPage).
class GuidedJournalPaywallPage extends StatelessWidget {
  const GuidedJournalPaywallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1917),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: getPadding(left: 20, right: 20, top: 0, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: getVerticalSize(56)),
            Text(
              'guided_journal_paywall_title'.tr(),
              textAlign: TextAlign.center,
              style: AppStyle.txtH1WhiteA700.copyWith(fontSize: getFontSize(24), height: 1.25),
            ),
            SizedBox(height: getVerticalSize(10)),
            Text(
              'guided_journal_paywall_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white.withOpacity(0.75)),
            ),
            SizedBox(height: getVerticalSize(26)),
            Container(height: 1, color: Colors.white.withOpacity(0.12)),
            SizedBox(height: getVerticalSize(18)),
            for (final b in _benefits)
              Padding(
                padding: getPadding(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: getSize(38),
                      height: getSize(38),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1FAE7A).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(b.icon, color: const Color(0xFF1FAE7A), size: getSize(20)),
                    ),
                    SizedBox(width: getHorizontalSize(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title.tr(),
                            style: AppStyle.txtSFProDisplayRegular14
                                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            b.desc.tr(),
                            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white.withOpacity(0.65)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: getVerticalSize(8)),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GoToNewTariffWidget(height: 400, goToFreeRecommendation: false),
            ),
            SizedBox(height: getVerticalSize(6)),
            Text(
              'guided_journal_paywall_note'.tr(),
              textAlign: TextAlign.center,
              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white.withOpacity(0.55), height: 1.4),
            ),
            SizedBox(height: getVerticalSize(14)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: getPadding(top: 4, bottom: 4),
                child: Text(
                  'guided_journal_paywall_skip'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.txtSFProDisplayRegular14.copyWith(color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
