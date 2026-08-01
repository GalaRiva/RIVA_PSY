import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notifications/notification_controller.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final log = prefs.getStringList(notifEventLogKey) ?? [];
      // Newest first — the most recent attempt is what actually answers
      // "did anything happen at the time the reminder was due".
      result['eventLog'] = log.reversed.take(15).join('\n');
      result['eventLogCount'] = log.length;
    } catch (e) {
      result['eventLogError'] = e.toString();
    }
    return result;
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _clearLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(notifEventLogKey);
    _refresh();
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
                '${d['scheduledSample'] ?? ''}\n'
                '\nCREATED = уведомление ПОСТАВЛЕНО В ПЛАН (в момент сохранения/открытия приложения), это НЕ значит, что оно сработало. Только DISPLAYED подтверждает реальный показ в нужное время.\n'
                'Журнал (всего записей: ${d['eventLogCount'] ?? 0}, новые сверху):\n'
                '${(d['eventLog'] ?? d['eventLogError'] ?? '').toString().isEmpty ? '(пусто — ни CREATED, ни DISPLAYED ещё не зафиксированы)' : d['eventLog'] ?? d['eventLogError']}',
                style: AppStyle.txtSFProDisplayLight10Gray800);
          },
        ),
        Padding(
          padding: getPadding(top: 8, bottom: 8),
          child: Row(
            children: [
              CustomButton(
                height: getVerticalSize(38),
                width: getHorizontalSize(220),
                text: 'запросить будильники+батарею',
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
              SizedBox(width: getHorizontalSize(10)),
              CustomButton(
                height: getVerticalSize(38),
                width: getHorizontalSize(90),
                text: 'обновить',
                onTap: _refresh,
              ),
            ],
          ),
        ),
        CustomButton(
          height: getVerticalSize(30),
          width: getHorizontalSize(150),
          text: 'очистить журнал',
          onTap: _clearLog,
        ),
      ],
    );
  }
}
