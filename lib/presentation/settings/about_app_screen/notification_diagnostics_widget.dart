import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/size_utils.dart';
import '../../../theme/app_style.dart';
import '../../../widgets/custom_button.dart';

// Temporary on-screen notification-scheduling diagnostic. Pills/diary
// reminders were reported as not firing even after fixing the
// cancelAllSchedules() race and declaring POST_NOTIFICATIONS. Without
// logcat/USB access this surfaces the two facts that actually decide
// whether a scheduled reminder can fire on Android 12+: whether
// PreciseAlarms was ever granted (the onboarding screen's
// requestPermissionToSendNotifications() call never asked for it — it
// used the package default permission list, which omits PreciseAlarms),
// and whether the OS still has the notifications in its schedule table
// at all, straight from awesome_notifications' own
// listScheduledNotifications() instead of guessing from app-side logic.
class NotificationDiagnosticsWidget extends StatefulWidget {
  const NotificationDiagnosticsWidget({Key? key}) : super(key: key);

  @override
  State<NotificationDiagnosticsWidget> createState() =>
      _NotificationDiagnosticsWidgetState();
}

class _NotificationDiagnosticsWidgetState
    extends State<NotificationDiagnosticsWidget> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final result = <String, dynamic>{};
    try {
      final granted = await AwesomeNotifications().checkPermissionList(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.PreciseAlarms,
        ],
      );
      result['preciseAlarms'] =
          granted.contains(NotificationPermission.PreciseAlarms);
      result['alert'] = granted.contains(NotificationPermission.Alert);
    } catch (e) {
      result['permError'] = e.toString();
    }
    try {
      final scheduled = await AwesomeNotifications().listScheduledNotifications();
      result['scheduledCount'] = scheduled.length;
      result['scheduledSample'] = scheduled.take(6).map((n) {
        final s = n.schedule;
        String when = '?';
        if (s is NotificationCalendar) {
          when = '${s.day}.${s.month} ${s.hour}:${s.minute}';
        }
        return 'id=${n.content?.id} "${n.content?.title}" @ $when';
      }).join('\n');
    } catch (e) {
      result['scheduledError'] = e.toString();
    }
    try {
      result['batteryIgnored'] =
          await Permission.ignoreBatteryOptimizations.isGranted;
    } catch (e) {
      result['batteryError'] = e.toString();
    }
    return result;
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Загрузка диагностики уведомлений...',
                  style: AppStyle.txtSFProDisplayLight10Gray800);
            }
            final d = snapshot.data!;
            return SelectableText(
                'PreciseAlarms разрешён: ${d['preciseAlarms'] ?? d['permError']}\n'
                'Alert разрешён: ${d['alert']}\n'
                'Батарея не ограничена: ${d['batteryIgnored'] ?? d['batteryError']}\n'
                'Запланировано в системе сейчас: ${d['scheduledCount'] ?? d['scheduledError']}\n'
                '${d['scheduledSample'] ?? ''}',
                style: AppStyle.txtSFProDisplayLight10Gray800);
          },
        ),
        Padding(
          padding: getPadding(top: 8, bottom: 8),
          child: CustomButton(
            height: getVerticalSize(38),
            width: getHorizontalSize(300),
            text: 'запросить точные будильники и батарею',
            onTap: () async {
              await AwesomeNotifications().requestPermissionToSendNotifications(
                permissions: [
                  NotificationPermission.Alert,
                  NotificationPermission.Sound,
                  NotificationPermission.Badge,
                  NotificationPermission.Vibration,
                  NotificationPermission.Light,
                  NotificationPermission.PreciseAlarms,
                ],
              );
              await Permission.ignoreBatteryOptimizations.request();
              _refresh();
            },
          ),
        ),
      ],
    );
  }
}
