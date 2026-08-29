import '../../../../../../core/db/hive_db.dart';

// User answers to a guided journal never leave the device — same privacy
// principle as the rest of the diary (see DayEventModel/K38Repo).
class GuidedJournalAnswersStore {
  static Future<void> save(String topicId, List<String> answers) async {
    await HiveDB.setBox({
      'topicId': topicId,
      'answers': answers,
      'date': DateTime.now().toIso8601String(),
    }, HiveDBTags.guidedJournalAnswers);
  }
}
