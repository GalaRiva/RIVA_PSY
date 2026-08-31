import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';

import '../../../../core/utils/shared_prefs.dart';
import '../controller.dart';
import 'bloc/portrait_cubit.dart';
import 'bloc/portrait_state.dart';
import 'pages/library/portrait_library_page.dart';
import 'pages/question/portrait_question_page.dart';
import 'pages/result/portrait_result_page.dart';
import 'widgets/glass_button.dart';

const _kOnboardingShownKey = 'portrait_onboarding_shown';

// Splits a translated paragraph into one-sentence chunks for rendering as
// separate paragraphs (per feedback: each sentence on its own line, with
// breathing room) — works off the rendered string itself so it holds for
// all 3 languages without needing a separate array-shaped translation key.
List<String> _splitSentences(String text) {
  return text
      .split('. ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((s) => RegExp(r'[.!?]$').hasMatch(s) ? s : '$s.')
      .toList();
}

// "Мой портрет" — 12 numbered ipsative tests + 1 bonus, own module (own
// Cubit/BlocProvider, own per-test gates), NOT nested inside
// WorkingOutScreen: tests 1-6 are free and WorkingOutScreen's whole
// container is tariff-gated, so this needed its own top-level placement —
// see K70Screen's 3rd CustomTabBar tab.
class PortraitPage extends StatefulWidget {
  const PortraitPage({Key? key}) : super(key: key);

  @override
  State<PortraitPage> createState() => _PortraitPageState();
}

class _PortraitPageState extends State<PortraitPage> {
  bool _showOnboarding = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final shown = SharedPrefs.sharedPreferences.getBool(_kOnboardingShownKey) ?? false;
    _showOnboarding = !shown;
    _loaded = true;
  }

  void _dismissOnboarding() {
    SharedPrefs.sharedPreferences.setBool(_kOnboardingShownKey, true);
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    if (_showOnboarding) return _PortraitOnboarding(onContinue: _dismissOnboarding);

    return BlocProvider(
      create: (_) => PortraitCubit(),
      child: BlocConsumer<PortraitCubit, PortraitState>(
        // Tells K70Screen to hide its top tab bar + bottom nav while the
        // user is inside a test question/result screen — see
        // K70Controller.immersiveMode.
        listener: (context, state) {
          if (Get.isRegistered<K70Controller>()) {
            Get.find<K70Controller>().setImmersiveMode(state.stage != PortraitStage.library);
          }
        },
        builder: (context, state) {
          switch (state.stage) {
            case PortraitStage.question:
              return const PortraitQuestionPage();
            case PortraitStage.result:
              return const PortraitResultPage();
            case PortraitStage.library:
              return const PortraitLibraryPage();
          }
        },
      ),
    );
  }
}

class _PortraitOnboarding extends StatelessWidget {
  final VoidCallback onContinue;

  const _PortraitOnboarding({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0B1917)),
      padding: getPadding(left: 24, right: 24, top: 40, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.blur_circular_rounded, color: const Color(0xFFC9A24B), size: getSize(64)),
          SizedBox(height: getVerticalSize(20)),
          Text(
            'portrait_intro_title'.tr(),
            textAlign: TextAlign.center,
            style: AppStyle.txtH1WhiteA700.copyWith(fontSize: getFontSize(24)),
          ),
          SizedBox(height: getVerticalSize(14)),
          for (final sentence in _splitSentences('portrait_onboarding_body'.tr()))
            Padding(
              padding: getPadding(bottom: 14),
              child: Text(
                sentence,
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white.withOpacity(0.75), height: 1.5),
              ),
            ),
          SizedBox(height: getVerticalSize(14)),
          GlassButton(text: 'portrait_intro_cta'.tr().toUpperCase(), onTap: onContinue),
        ],
      ),
    );
  }
}
