import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../core/user_data/user.dart';
import '../../../core/utils/build_info.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
import 'drop_text_widget.dart';
import 'notification_diagnostics_widget.dart';
import '../../../theme/app_colors.dart';

// Live, direct-from-Firestore snapshot for the "Emociones negativas" text
// and the audio-matching fallback count — not routed through
// NegativeEmotionsModel/ExerciseContentController at all, so this can't
// inherit whatever bug (or lack thereof) is in those code paths. Same
// "screenshot instead of logcat" approach as the tariff diagnostic below.
Future<Map<String, dynamic>> _loadTextRecAudioDiagnostics() async {
  final result = <String, dynamic>{};
  try {
    final textRecSnap = await FirebaseFirestore.instance
        .collection('Text_Recommendation')
        .where('tab', isEqualTo: 'wrath')
        .orderBy('order')
        .limit(1)
        .get(const GetOptions(source: Source.server));
    if (textRecSnap.docs.isNotEmpty) {
      final doc = textRecSnap.docs.first;
      final data = doc.data();
      result['docId'] = doc.id;
      result['title'] = data['title'];
      result['title_en'] = data['title_en'];
      result['title_es'] = data['title_es'];
      result['order'] = data['order'];
    } else {
      result['textRecError'] = 'no docs returned for tab=wrath';
    }
  } catch (e) {
    result['textRecError'] = e.toString();
  }
  try {
    final audioSnap = await FirebaseFirestore.instance
        .collection('Audio')
        .where('tab', isEqualTo: 'wrath')
        .get(const GetOptions(source: Source.server));
    result['audioCountForTab'] = audioSnap.docs.length;
  } catch (e) {
    result['audioError'] = e.toString();
  }
  return result;
}

class K7Screen extends StatelessWidget {
  TextEditingController group1006Controller = TextEditingController();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = K7Controller(context.locale.languageCode);
    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: getPadding(left: 16, right: 16, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                height: getVerticalSize(12),
                                width: getHorizontalSize(328),
                                margin: getMargin(top: 39),
                                child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child:  CustomPopButton( text: 'settings'.tr(),)),
                                      Align(
                                          alignment:
                                          Alignment.bottomCenter,
                                          child: Padding(
                                              padding:
                                              getPadding(bottom: 2, top: 22),
                                              child: SizedBox(
                                                  width:
                                                  getHorizontalSize(
                                                      MediaQuery.of(context).size.width - 32),
                                                  child: Divider(
                                                      height:
                                                      getVerticalSize(
                                                          1),
                                                      thickness:
                                                      getVerticalSize(
                                                          1),
                                                      color: ColorConstant
                                                          .gray50))))
                                    ])),
                            Padding(
                                padding: getPadding(top: 25),
                                child: Text('about_app'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Padding(
                                padding: getPadding(left: 4, top: 82),
                                child: DropTextWidget(model: controller.termsOfUse,)),
                            Padding(
                                padding: getPadding(left: 4, top: 96),
                                child: DropTextWidget(model: controller.privacyPolicy,)),
                            Padding(
                                padding: getPadding(left: 4, top: 16),
                                child: Text(
                                    'build ${BuildInfo.gitHash} · ${BuildInfo.buildTime}',
                                    style: AppStyle.txtSFProDisplayLight10Gray800)),
                            // Temporary on-screen tariff/session diagnostic —
                            // lets the account's actual runtime state be read
                            // off a screenshot when USB/logcat access isn't
                            // available. See PROJECT_CONTEXT.md, the
                            // "tariff says Орион but app won't unlock" thread.
                            Padding(
                                padding: getPadding(left: 4, top: 12),
                                child: SelectableText(
                                    'email: ${CurrentUser.user.email}\n'
                                    'userId(): ${CurrentUser.repo.userId()}\n'
                                    'currentTariff: ${CurrentUser.user.currentTariff?.name}\n'
                                    'tariffIsOrion(): ${CurrentUser.tariffIsOrion()}\n'
                                    'context.locale: ${context.locale} (languageCode: ${context.locale.languageCode})',
                                    style: AppStyle.txtSFProDisplayLight10Gray800)),
                            // Temporary: live Text_Recommendation (одна позиция
                            // тега wrath) + Audio-by-tab count, прямым запросом
                            // к Firestore прямо здесь — см. PROJECT_CONTEXT.md.
                            Padding(
                                padding: getPadding(left: 4, top: 12),
                                child: FutureBuilder<Map<String, dynamic>>(
                                    future: _loadTextRecAudioDiagnostics(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Text('Загрузка диагностики Text_Recommendation/Audio...',
                                            style: AppStyle.txtSFProDisplayLight10Gray800);
                                      }
                                      final d = snapshot.data!;
                                      return SelectableText(
                                          'wrath[0] doc: ${d['docId'] ?? d['textRecError']}\n'
                                          '  title: ${d['title']}\n'
                                          '  title_en: ${d['title_en']}\n'
                                          '  title_es: ${d['title_es']}\n'
                                          '  order: ${d['order']}\n'
                                          'Audio count for tab=wrath: ${d['audioCountForTab'] ?? d['audioError']}',
                                          style: AppStyle.txtSFProDisplayLight10Gray800);
                                    })),
                            Padding(
                                padding: getPadding(left: 4, top: 12),
                                child: const NotificationDiagnosticsWidget()),
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: AppRoutes.currentRoute == AppRoutes.settings? 'settings'.tr().toUpperCase() : 'back'.tr().toUpperCase(),
                                margin: getMargin(top: 154),
                                padding: ButtonPadding.PaddingT8,
                                prefixWidget: CustomImageView(
                                  margin: getMargin(right: 12),
                                  svgPath: ImageConstant.leftArrow,
                                ),
                                onTap: () => onTaptf(context),
                                alignment: Alignment.center)
                          ])))),
        ),
        bottomNavigationBar:
        AppRoutes.currentRoute == AppRoutes.settings?CustomBottomBar(onChanged: (BottomBarEnum type) {}):null);
  }

  onTaptf(BuildContext context) {
    Navigator.pop(context);
  }
}
