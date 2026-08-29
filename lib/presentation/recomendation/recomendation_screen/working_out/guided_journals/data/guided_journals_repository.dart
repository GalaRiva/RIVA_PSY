import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../core/models/audio/audio.dart';
import '../models/guided_journal_topic.dart';

// Same R2 public URL used everywhere else audio is played from — see
// negative_emotions_model.dart / introduction_model.dart.
const _r2AudioBaseUrl = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

class GuidedJournalsRepository {
  Future<String> _langCode() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('locale') ?? 'ru_RU').split('_').first;
  }

  // {field: {ru,en,es}} -> current-locale value, falling back to ru — same
  // fallback shape as NegativeEmotionsModel._localizedField.
  String _localized(Map<String, dynamic>? field, String langCode) {
    if (field == null) return '';
    final value = field[langCode];
    if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    return (field['ru'] ?? '').toString();
  }

  Future<List<GuidedJournalTopic>> getTopics() async {
    final langCode = await _langCode();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('GuidedJournals')
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final questions = ((data['questions'] as List?) ?? [])
            .map((q) => _localized(q as Map<String, dynamic>?, langCode))
            .toList();
        return GuidedJournalTopic(
          id: doc.id,
          title: _localized(data['title'] as Map<String, dynamic>?, langCode),
          questions: questions,
          insight: _localized(data['insight'] as Map<String, dynamic>?, langCode),
          linkedAudioTab: data['linked_audio_tab'] as String?,
          linkedAudioPath: data['linked_audio_$langCode'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // Priority: a specific track recorded for this exact topic (already
  // resolved to the current locale on the model) beats the group fallback,
  // which beats showing no player at all — matches the end-of-Path
  // recommendation logic (any track from the emotion's group tab).
  Future<String?> resolveAudioUrl(GuidedJournalTopic topic) async {
    // Uri.encodeFull, not just Uri.parse — some of these filenames carry
    // accented characters (e.g. "Decepción.mp3"), which the rest of the
    // app's audio URLs never had to deal with; a raw non-ASCII path isn't
    // guaranteed to load on every platform's HTTP client.
    if ((topic.linkedAudioPath ?? '').trim().isNotEmpty) {
      return Uri.encodeFull(_r2AudioBaseUrl + topic.linkedAudioPath!);
    }
    if ((topic.linkedAudioTab ?? '').trim().isEmpty) return null;
    try {
      final langCode = await _langCode();
      final snapshot = await FirebaseFirestore.instance
          .collection('Audio')
          .where('tab', isEqualTo: topic.linkedAudioTab)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final audio = Audio.fromJson(snapshot.docs.first.data());
      return Uri.encodeFull(_r2AudioBaseUrl + audio.localizedFileName(langCode) + '.' + audio.format);
    } catch (_) {
      return null;
    }
  }
}
