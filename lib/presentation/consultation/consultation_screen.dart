import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_pop_button.dart';

// Set this to the real public Cal.com booking page once it exists
// (Play Console-style Phase 1: cal.com account, Stripe, availability, and
// the "Консультация с психологом" event type are all set up outside this
// codebase — see the ТЗ for exact steps).
const String consultationBookingUrl = 'https://cal.com/galina-egorova-zwylhf/consultation';

// RU-only screen (no en-US/es-ES translation keys exist for these strings
// on purpose) — callers must gate navigation to this screen behind
// context.locale.languageCode == 'ru'.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 20, right: 20, top: 12, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomAppBar(widget: CustomPopButton(text: 'consultation_screen_title'.tr())),
              SizedBox(height: getVerticalSize(24)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: getPadding(left: 20, top: 24, right: 20, bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ColorConstant.cardShadow.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/consultation_therapist.jpg',
                                width: getSize(160),
                                height: getSize(160),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: getVerticalSize(14)),
                            Text(
                              'Галина Егорова',
                              style: AppStyle.txtH2.copyWith(
                                color: ColorConstant.gray800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: getVerticalSize(6)),
                            Text(
                              'consultation_signature'.tr(),
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight12
                                  .copyWith(color: ColorConstant.gray500, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: getVerticalSize(22)),
                      Text(
                        'consultation_invite_text'.tr(),
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: ColorConstant.gray800, height: 1.5),
                      ),
                      SizedBox(height: getVerticalSize(16)),
                      Text(
                        'consultation_invite_text_2'.tr(),
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: ColorConstant.gray800, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: getVerticalSize(16)),
              CustomButton(
                height: getVerticalSize(48),
                width: double.infinity,
                text: 'consultation_cta'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConsultationBookingScreen()),
                ),
              ),
              SizedBox(height: getVerticalSize(10)),
              Text(
                'consultation_note'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsultationBookingScreen extends StatefulWidget {
  const ConsultationBookingScreen({Key? key}) : super(key: key);

  @override
  State<ConsultationBookingScreen> createState() => _ConsultationBookingScreenState();
}

class _ConsultationBookingScreenState extends State<ConsultationBookingScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(consultationBookingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: getPadding(left: 20, right: 20, top: 12),
              child: CustomAppBar(widget: CustomPopButton(text: 'back'.tr())),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading)
                    Center(child: CircularProgressIndicator(color: ColorConstant.cyan700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
