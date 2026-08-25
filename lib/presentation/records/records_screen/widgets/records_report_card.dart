import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/pdf_viewer_widget.dart';

import '../../../../theme/app_colors.dart';
import '../controller.dart';

/// SMER report generator — moved here from the Charts screen (see
/// K61Screen/ReportWidget) because it's fundamentally about these diary
/// entries, not the analytics tabs. Sits at the top of the Records screen
/// with its own period picker; "share" comes for free from the PDF preview
/// screen (package:printing's default share button — every installed
/// messenger/email app the OS offers).
class RecordsReportCard extends StatelessWidget {
  final K49Controller controller;
  const RecordsReportCard({Key? key, required this.controller}) : super(key: key);

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _pickPeriod(BuildContext context) async {
    final result =
        await Navigator.pushNamed(context, AppRoutes.charts_calendar) as Map<String, dynamic>?;
    if (result == null) return;
    controller.reportDateStart = result['start'];
    controller.reportDateEnd = result['end'];
    controller.update();
  }

  void _openReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewWidget(
          pdf: (format) async => controller.reportModel.makePdf(await controller.getReportEvents()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<K49Controller>(
      builder: (_) => Container(
        width: double.infinity,
        margin: getMargin(top: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: getHorizontalSize(8)),
                Expanded(
                  child: Text(
                    'summary_report'.tr(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1E)),
                  ),
                ),
              ],
            ),
            SizedBox(height: getVerticalSize(6)),
            Text(
              'summary_report_intro'.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
            SizedBox(height: getVerticalSize(14)),
            GestureDetector(
              onTap: () => _pickPeriod(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: getHorizontalSize(8)),
                    Expanded(
                      child: Text(
                        '${_fmt(controller.reportDateStart)} — ${_fmt(controller.reportDateEnd)}',
                        style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            SizedBox(height: getVerticalSize(14)),
            GestureDetector(
              onTap: () => _openReport(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5)),
                  ],
                ),
                child: Center(
                  child: Text(
                    'send_summary_report'.tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
