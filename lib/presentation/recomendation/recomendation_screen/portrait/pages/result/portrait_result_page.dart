import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../../core/user_data/user.dart';
import '../../bloc/portrait_cubit.dart';
import '../../bloc/portrait_state.dart';
import '../../cta_action_router.dart';
import '../../data/portrait_result_builder.dart';
import '../../widgets/glass_button.dart';
import '../paywall/portrait_paywall_page.dart';

const _kProjectionBg = Color(0xFF0B1917);

class PortraitResultPage extends StatelessWidget {
  const PortraitResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortraitCubit, PortraitState>(
      builder: (context, state) {
        final result = state.lastResult;
        final id = state.selectedTestId;
        if (result == null || id == null) return const ColoredBox(color: _kProjectionBg);
        final def = portraitTestDefinitions[id]!;
        final view = buildPortraitResultView(def, result);
        final isShadow = kPortraitShadowTestIds.contains(id);

        return ColoredBox(
          color: _kProjectionBg,
          child: SingleChildScrollView(
            padding: getPadding(left: 16, right: 16, top: 8, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (view.isHybrid)
                  Padding(
                    padding: getPadding(bottom: 8),
                    child: Container(
                      padding: getPadding(left: 10, top: 4, right: 10, bottom: 4),
                      decoration: BoxDecoration(
                        color: ColorConstant.cyan700.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'portrait_hybrid_badge'.tr(),
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.cyan700),
                      ),
                    ),
                  ),
                Text(view.title, style: AppStyle.txtH1WhiteA700),
                SizedBox(height: getVerticalSize(16)),
                if (isShadow || def.requiresDisclaimer)
                  Padding(
                    padding: getPadding(bottom: 16),
                    child: Container(
                      padding: getPadding(left: 14, top: 12, right: 14, bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isShadow)
                            Text(
                              'portrait_shadow_disclaimer'.tr(),
                              style: AppStyle.txtSFProDisplayLight12
                                  .copyWith(color: Colors.white.withOpacity(0.7), height: 1.4),
                            ),
                          if (isShadow && def.requiresDisclaimer) SizedBox(height: getVerticalSize(8)),
                          if (def.requiresDisclaimer)
                            Text(
                              kPortraitAttachmentDisclaimer,
                              style: AppStyle.txtSFProDisplayLight12
                                  .copyWith(color: Colors.white.withOpacity(0.7), height: 1.4),
                            ),
                        ],
                      ),
                    ),
                  ),
                Text(view.light,
                    style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white.withOpacity(0.92), height: 1.5)),
                SizedBox(height: getVerticalSize(16)),
                Text(view.shadow,
                    style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.7), height: 1.5)),
                SizedBox(height: getVerticalSize(24)),
                GlassButton(
                  text: view.ctaLabel,
                  height: 47,
                  accent: const Color(0xFF2A5C55),
                  onTap: () => CtaActionRouter.navigate(context, view.cta, audioLabel: view.ctaLabel),
                ),
                SizedBox(height: getVerticalSize(12)),
                GlassButton(
                  text: 'portrait_back_to_library'.tr().toUpperCase(),
                  height: 47,
                  accent: Colors.white,
                  onTap: () => _backToLibrary(context, id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _backToLibrary(BuildContext context, PortraitTestId id) {
    context.read<PortraitCubit>().backToLibrary();
    // Paywall shows right after test 6 finishes (the last free test) and
    // again if the user taps into test 7 — confirmed decision,
    // PROJECT_CONTEXT.md §62.
    final isLastFreeTest =
        kPortraitNumberedOrder.indexOf(id) == kPortraitFreeTestCount - 1;
    if (isLastFreeTest && !CurrentUser.tariffIsOrion()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PortraitPaywallPage()));
    }
  }
}
