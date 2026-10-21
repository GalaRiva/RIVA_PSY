import 'package:flutter/services.dart';

// Reads (once) the action chosen from the app-icon shortcut on Android.
// Returns null on iOS / when nothing was chosen / on any channel error.
class QuickActionService {
  static const _channel = MethodChannel('riva/quick');

  static Future<String?> take() async {
    try {
      return await _channel.invokeMethod<String>('take');
    } catch (_) {
      return null;
    }
  }
}
