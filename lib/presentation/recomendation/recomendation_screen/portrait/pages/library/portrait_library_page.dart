import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../../core/user_data/user.dart';
import '../../bloc/portrait_cubit.dart';
import '../../bloc/portrait_state.dart';
import '../../widgets/portrait_countdown.dart';
import '../../widgets/projection_orb.dart';
import '../finale/portrait_finale_page.dart';
import '../paywall/portrait_paywall_page.dart';

// Whole "Проекция Я" module runs on a deep dark background (not just the
// orb) — matches the original brief's "глубокий изумрудный фон" for the
// section, and gives the shader's glow/blend something to actually read
// against instead of fighting the app's light "quiet luxury" theme.
const _kProjectionBg = Color(0xFF0B1917);

class PortraitLibraryPage extends StatelessWidget {
  const PortraitLibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortraitCubit, PortraitState>(
      builder: (context, state) {
        if (state.loading) {
          return const ColoredBox(
            color: _kProjectionBg,
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        return ColoredBox(
          color: _kProjectionBg,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full-bleed, no side padding, no card/frame — fills the
                // width edge-to-edge like a photograph.
                ProjectionOrb(progress: state.completedNumberedCount.toDouble()),
                Padding(
                  padding: getPadding(left: 16, right: 16, top: 20, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'portrait_intro_title'.tr(),
                        style: AppStyle.txtH1WhiteA700,
                      ),
                      SizedBox(height: getVerticalSize(6)),
                      Text(
                        'portrait_intro_body'.tr(),
                        style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.65)),
                      ),
                      SizedBox(height: getVerticalSize(20)),
                      for (var i = 0; i < kPortraitNumberedOrder.length; i++)
                        _PortraitTestCard(
                          id: kPortraitNumberedOrder[i],
                          number: i + 1,
                          state: state,
                          onTap: () => _openTest(context, kPortraitNumberedOrder[i], i),
                        ),
                      if (state.allNumberedComplete) ...[
                        _PortraitTestCard(
                          id: PortraitTestId.bonusChronotype,
                          number: null,
                          state: state,
                          onTap: () => _openTest(
                            context,
                            PortraitTestId.bonusChronotype,
                            kPortraitNumberedOrder.length,
                          ),
                        ),
                        SizedBox(height: getVerticalSize(8)),
                        _FinaleCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PortraitFinalePage()),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTest(BuildContext context, PortraitTestId id, int index) {
    final requiresTariff = index >= kPortraitFreeTestCount;
    if (requiresTariff && !CurrentUser.tariffIsOrion()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PortraitPaywallPage()));
      return;
    }
    context.read<PortraitCubit>().selectTest(id);
  }
}

class _PortraitTestCard extends StatelessWidget {
  final PortraitTestId id;
  final int? number; // null for the bonus card
  final PortraitState state;
  final VoidCallback onTap;

  const _PortraitTestCard({
    required this.id,
    required this.number,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final def = portraitTestDefinitions[id]!;
    final done = state.hasResultFor(id);
    final unlockAt = done ? null : state.unlockAt(id);
    final unlockedByCadence = state.isUnlocked(id);
    final index = number != null ? number! - 1 : kPortraitNumberedOrder.length;
    final requiresTariff = index >= kPortraitFreeTestCount;
    final tariffLocked = requiresTariff && !CurrentUser.tariffIsOrion();
    final cadenceLocked = !done && !unlockedByCadence;
    final locked = !done && (cadenceLocked || tariffLocked);

    return Padding(
      padding: getPadding(bottom: 12),
      child: GestureDetector(
        onTap: locked && cadenceLocked ? null : onTap,
        child: Container(
          padding: getPadding(left: 16, top: 14, right: 16, bottom: 14),
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF14312C)
                : locked
                    ? Colors.white.withOpacity(0.04)
                    : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done
                  ? const Color(0xFFC9A24B).withOpacity(0.5)
                  : Colors.white.withOpacity(0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: getSize(36),
                height: getSize(36),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFFC9A24B).withOpacity(0.18)
                      : ColorConstant.cyan700.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: locked
                    ? Icon(Icons.lock_rounded, size: getSize(18), color: Colors.white.withOpacity(0.5))
                    : Text(
                        number?.toString() ?? '★',
                        style: AppStyle.txtSFProDisplayRegular14.copyWith(
                          color: done ? const Color(0xFFC9A24B) : ColorConstant.cyan700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              SizedBox(width: getHorizontalSize(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            def.title,
                            style: AppStyle.txtSFProDisplayRegular14.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (number == null)
                          Container(
                            padding: getPadding(left: 8, top: 2, right: 8, bottom: 2),
                            decoration: BoxDecoration(
                              color: ColorConstant.cyan700.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'portrait_bonus_badge'.tr(),
                              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.cyan700),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: getVerticalSize(4)),
                    if (done)
                      Text(
                        'portrait_completed_badge'.tr(),
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white.withOpacity(0.55)),
                      )
                    else if (tariffLocked && !cadenceLocked)
                      Text(
                        'portrait_locked_tariff'.tr(),
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white.withOpacity(0.55)),
                      )
                    else if (cadenceLocked && unlockAt != null)
                      PortraitCountdown(unlockAt: unlockAt)
                    else if (cadenceLocked)
                      // unlockAt is null here specifically because the
                      // previous test hasn't been completed yet (nothing to
                      // count down from) — was showing the Orion-subscription
                      // message by mistake, including on free tests 2-6.
                      Text(
                        'portrait_locked_previous'.tr(),
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white.withOpacity(0.55)),
                      )
                    else
                      Text(
                        'portrait_start_test'.tr(),
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.cyan700),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinaleCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FinaleCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: getPadding(left: 16, top: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF14312C), Color(0xFF1FAE7A)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFC9A24B)),
            SizedBox(width: getHorizontalSize(12)),
            Expanded(
              child: Text(
                'portrait_finale_title'.tr(),
                style: AppStyle.txtSFProDisplayRegular14.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
