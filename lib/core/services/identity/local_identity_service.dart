import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Gives every device a stable anonymous identity on first launch, entirely
/// offline — no Firebase Auth session, no network call. This is what lets
/// the app open straight into the Path/diary without registration; an
/// account (Firebase Auth) only gets created later, contextually, when the
/// user actually needs one (subscription, cloud backup) — see
/// [AccountRequiredSheet].
class LocalIdentityService {
  static const _localIdKey = 'local_device_id';

  static Future<String> ensureLocalId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_localIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = const Uuid().v4();
    await prefs.setString(_localIdKey, generated);
    return generated;
  }
}
