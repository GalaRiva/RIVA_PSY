import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

// These four callbacks used to be empty stubs — the only evidence we had
// that a reminder was even attempted was the schedule itself, which tells
// you nothing about what actually happened at the moment it was due. On a
// killed/backgrounded app awesome_notifications runs this in a separate
// headless isolate, so state can't just live in memory — persisting to
// SharedPreferences is what lets the About screen read it back after the
// fact, next time the app is opened. Surfaced in NotificationDiagnosticsWidget.
const notifEventLogKey = 'notif_event_log';
const _maxLogEntries = 40;

Future<void> _logNotificationEvent(String label, {
  int? id,
  String? channelKey,
  String? title,
}) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final log = prefs.getStringList(notifEventLogKey) ?? [];
    log.add('${DateTime.now().toIso8601String()} $label id=$id channel=$channelKey title="$title"');
    while (log.length > _maxLogEntries) {
      log.removeAt(0);
    }
    await prefs.setStringList(notifEventLogKey, log);
  } catch (_) {
    // Diagnostic-only — a failure here must never take down the actual
    // notification callback it's attached to.
  }
}

class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    await _logNotificationEvent('CREATED',
        id: receivedNotification.id,
        channelKey: receivedNotification.channelKey,
        title: receivedNotification.title);
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    await _logNotificationEvent('DISPLAYED',
        id: receivedNotification.id,
        channelKey: receivedNotification.channelKey,
        title: receivedNotification.title);
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    await _logNotificationEvent('DISMISSED',
        id: receivedAction.id,
        channelKey: receivedAction.channelKey,
        title: receivedAction.title);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    await _logNotificationEvent('ACTION',
        id: receivedAction.id,
        channelKey: receivedAction.channelKey,
        title: receivedAction.title);
    if(receivedAction.channelKey == 'open') {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.concrete_pill,
          (route) =>
              (route.settings.name != AppRoutes.concrete_pill) || route.isFirst,
          arguments: receivedAction.payload);
    }
  }
}
