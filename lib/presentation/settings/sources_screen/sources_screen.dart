import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/sources_data.dart';
import '../../recomendation/recomendation_screen/working_out/programs/widgets/course_ui.dart';

// "Источники и научная основа": where the app's practices and information
// come from, with links (App Store Review Guideline 1.4.1). Reachable from
// Settings and from the medical disclaimer shown across the app.
void openSourcesScreen(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const SourcesScreen()));
}

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({Key? key}) : super(key: key);

  String _sitePage(BuildContext context) {
    switch (context.locale.languageCode) {
      case 'en':
        return 'https://rivapsy.com/en/science';
      case 'es':
        return 'https://rivapsy.com/es/science';
      default:
        return 'https://rivapsy.com/science';
    }
  }

  Future<void> _open(BuildContext context, String url) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('src_open_failed'.tr())));
    }
  }

  Widget _link(BuildContext context,
      {required String title, required String meta, required String url}) {
    return InkWell(
      onTap: () => _open(context, url),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: getPadding(top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppStyle.txtSFProDisplayLight14
                          .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.3)),
                  SizedBox(height: getVerticalSize(3)),
                  Text(meta,
                      style: AppStyle.txtSFProDisplayRegular11
                          .copyWith(color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
            SizedBox(width: getHorizontalSize(10)),
            Padding(
              padding: getPadding(top: 2),
              child: Icon(Icons.open_in_new_rounded, size: getSize(16), color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CourseTextScale(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: getPadding(left: 20, right: 20, top: 10, bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                    tooltip: 'back'.tr(),
                    onImage: false),
                SizedBox(height: getVerticalSize(20)),
                Text('src_title'.tr(),
                    style: AppStyle.txtH1
                        .copyWith(color: AppColors.textPrimary, fontSize: getFontSize(27), height: 1.15)),
                SizedBox(height: getVerticalSize(10)),
                Text('src_intro'.tr(),
                    style: AppStyle.txtSFProDisplayLight16
                        .copyWith(color: AppColors.textPrimary.withOpacity(0.78), height: 1.55)),
                SizedBox(height: getVerticalSize(8)),
                Text('src_open_note'.tr(),
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, height: 1.45)),
                SizedBox(height: getVerticalSize(22)),
                SectionLabel('src_general'.tr()),
                SizedBox(height: getVerticalSize(10)),
                SoftCard(
                  padding: getPadding(left: 16, top: 4, right: 14, bottom: 4),
                  child: Column(
                    children: [
                      for (var i = 0; i < kGeneralSources.length; i++) ...[
                        if (i > 0) const Divider(height: 1, color: AppColors.divider),
                        _link(context,
                            title: kGeneralSources[i].titleKey.tr(),
                            meta: kGeneralSources[i].org,
                            url: kGeneralSources[i].url),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: getVerticalSize(26)),
                SectionLabel('src_methods'.tr()),
                for (final topic in kSourceTopics) ...[
                  SizedBox(height: getVerticalSize(14)),
                  Text(topic.titleKey.tr(),
                      style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary)),
                  SizedBox(height: getVerticalSize(8)),
                  SoftCard(
                    padding: getPadding(left: 16, top: 4, right: 14, bottom: 4),
                    child: Column(
                      children: [
                        for (var i = 0; i < topic.refs.length; i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.divider),
                          _link(context,
                              title: topic.refs[i].title,
                              meta: '${topic.refs[i].authors} (${topic.refs[i].year}). ${topic.refs[i].journal}',
                              url: topic.refs[i].url),
                        ],
                      ],
                    ),
                  ),
                ],
                SizedBox(height: getVerticalSize(26)),
                SectionLabel('src_site_title'.tr()),
                SizedBox(height: getVerticalSize(10)),
                SoftCard(
                  padding: getPadding(left: 16, top: 4, right: 14, bottom: 4),
                  child: _link(context,
                      title: 'src_site_link'.tr(), meta: 'rivapsy.com', url: _sitePage(context)),
                ),
                SizedBox(height: getVerticalSize(18)),
                Text('medical_disclaimer'.tr(),
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
