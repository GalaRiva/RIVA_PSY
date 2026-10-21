import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/go_to_new_tariff_widget.dart';

// Shown when a locked (non-free) course step is opened without Orion. Same
// dark template as the journals/portrait paywalls — no discount, no timer.
class CoursePaywallPage extends StatelessWidget {
  const CoursePaywallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const benefits = [
      [Icons.headphones_rounded, 'course_paywall_b1_title', 'course_paywall_b1_desc'],
      [Icons.edit_note_rounded, 'course_paywall_b2_title', 'course_paywall_b2_desc'],
      [Icons.refresh_rounded, 'course_paywall_b3_title', 'course_paywall_b3_desc'],
    ];
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
            Text('course_paywall_title'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtH1WhiteA700.copyWith(fontSize: getFontSize(24), height: 1.25)),
            SizedBox(height: getVerticalSize(10)),
            Text('course_paywall_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white.withOpacity(0.75))),
            SizedBox(height: getVerticalSize(24)),
            Container(height: 1, color: Colors.white.withOpacity(0.12)),
            SizedBox(height: getVerticalSize(18)),
            for (final b in benefits)
              Padding(
                padding: getPadding(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: getSize(38),
                      height: getSize(38),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1FAE7A).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(b[0] as IconData, color: const Color(0xFF1FAE7A), size: getSize(20)),
                    ),
                    SizedBox(width: getHorizontalSize(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((b[1] as String).tr(),
                              style: AppStyle.txtSFProDisplayRegular14
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          Text((b[2] as String).tr(),
                              style: AppStyle.txtSFProDisplayRegular11
                                  .copyWith(color: Colors.white.withOpacity(0.65))),
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
            SizedBox(height: getVerticalSize(14)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: getPadding(top: 4, bottom: 4),
                child: Text('guided_journal_paywall_skip'.tr(),
                    textAlign: TextAlign.center,
                    style: AppStyle.txtSFProDisplayRegular14.copyWith(color: Colors.white.withOpacity(0.5))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
