import '../../models/insight_model.dart';
import '../notifications/awesome_notification_service.dart';
import 'offline_translations.dart';

/// Turns a batch of freshly-generated insights into a single local
/// notification: 1-2 insights get embedded directly in the body, more than
/// that gets a generic "N new observations, open the app" message — reading
/// the full set in that case happens inside the app (InsightSection).
class InsightNotifier {
  static Future<void> notify(List<InsightModel> batch) async {
    if (batch.isEmpty) return;

    final translations = await OfflineTranslations.load();
    final title = OfflineTranslations.tr(translations, 'insight_notification_title');
    final String body;
    if (batch.length <= 2) {
      body = batch
          .map((i) => OfflineTranslations.tr(translations, i.templateKey, i.namedArgs))
          .join('\n\n');
    } else {
      body = OfflineTranslations.tr(
          translations, 'insight_notification_many_body', {'count': '${batch.length}'});
    }
    await AwesomeNotificationService().scheduleInsightNotification(title: title, body: body);
  }
}
