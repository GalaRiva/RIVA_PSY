import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared tap-detail bottom sheet for the analytics dashboards — replaces
/// both the plain white default sheet and the black default SnackBar that
/// used to show cell/bubble details. One quiet, consistent surface for
/// "you tapped something, here's what it means" across every chart.
class DashboardDetailSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String body;

  const DashboardDetailSheet({Key? key, required this.title, this.subtitle, required this.body}) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String body,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DashboardDetailSheet(title: title, subtitle: subtitle, body: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // The sheet's own fixed bottom padding wasn't enough to clear a
      // gesture-nav bar on some devices, so the last line rendered right
      // at (or behind) the system inset — SafeArea adds whatever extra
      // padding that device actually needs.
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFFBFAF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
