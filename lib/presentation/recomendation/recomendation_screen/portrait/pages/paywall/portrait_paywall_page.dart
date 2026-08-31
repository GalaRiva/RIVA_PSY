import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../widgets/go_to_new_tariff_widget.dart';

class _WhatsNextBlock {
  final String title;
  final String body;
  const _WhatsNextBlock(this.title, this.body);
}

const List<_WhatsNextBlock> _whatsNext = [
  _WhatsNextBlock(
    'Тесты 7–9: Анатомия защитных механизмов',
    'Исследуем, почему вы стремитесь всё контролировать, где корень «лени» '
        '(прокрастинации) и о чём на самом деле кричит ваш гнев.',
  ),
  _WhatsNextBlock(
    'Тест 9: Ваш истинный компас',
    'Определим персональную иерархию ценностей по методике ACT, чтобы '
        'перестать сливать энергию на чужие цели.',
  ),
  _WhatsNextBlock(
    'Тесты 10–12: Отношения, оптимизм и хронобиология',
    'Раскроем ваш стиль привязанности без ярлыков, стиль взгляда в будущее '
        'и настроим режим под ваши биоритмы.',
  ),
  _WhatsNextBlock(
    'Финал: Финальный синтез',
    'Алгоритм объединит все 12 тестов в персональную карту вашей психики с '
        'поиском скрытых пересечений и точек роста.',
  ),
];

class _Benefit {
  final IconData icon;
  final String title;
  final String desc;
  const _Benefit(this.icon, this.title, this.desc);
}

const List<_Benefit> _benefits = [
  _Benefit(Icons.spa_rounded, 'Снятие вины за усталость', 'Легализация отдыха без самоедства и мысленной жвачки о делах.'),
  _Benefit(Icons.radar_rounded, 'Управление триггерами', 'Понимание, почему вы взрываетесь или замираете, ещё до того, как реакция захватит тело.'),
  _Benefit(Icons.self_improvement_rounded, 'Отказ от гиперконтроля', 'Снижение мышечного спазма и фонового напряжения за счёт возврата доверия к миру.'),
  _Benefit(Icons.headphones_rounded, 'Персональные аудио-практики', '7 специализированных соматических сессий: «Снятие брони», «Право на паузу», «Охлаждение реактора» и другие.'),
];

// Copy taken verbatim from the approved master-plan (PROJECT_CONTEXT.md
// §62) — reuses the existing Orion subscription via GoToNewTariffWidget
// rather than a separate product/IAP flow, per the confirmed decision
// ("за существующей подпиской «Орион», не отдельный продукт").
class PortraitPaywallPage extends StatelessWidget {
  const PortraitPaywallPage({Key? key}) : super(key: key);

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
            Text(
              'portrait_paywall_title'.tr(),
              textAlign: TextAlign.center,
              style: AppStyle.txtH1WhiteA700.copyWith(fontSize: getFontSize(24), height: 1.25),
            ),
            SizedBox(height: getVerticalSize(10)),
            Text(
              'portrait_paywall_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white.withOpacity(0.75)),
            ),
            SizedBox(height: getVerticalSize(26)),
            for (final block in _whatsNext)
              Padding(
                padding: getPadding(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.title,
                      style: AppStyle.txtSFProDisplayRegular14.copyWith(
                        color: const Color(0xFFC9A24B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: getVerticalSize(4)),
                    Text(
                      block.body,
                      style: AppStyle.txtSFProDisplayRegular14
                          .copyWith(color: Colors.white.withOpacity(0.75), height: 1.4),
                    ),
                  ],
                ),
              ),
            SizedBox(height: getVerticalSize(10)),
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
                            b.title,
                            style: AppStyle.txtSFProDisplayRegular14
                                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            b.desc,
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
              'portrait_paywall_note'.tr(),
              textAlign: TextAlign.center,
              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white.withOpacity(0.55), height: 1.4),
            ),
            SizedBox(height: getVerticalSize(14)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: getPadding(top: 4, bottom: 4),
                child: Text(
                  'portrait_paywall_skip'.tr(),
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
