import 'drop_text_model.dart';
import 'legal_content_en.dart';
import 'legal_content_es.dart';
import 'legal_content_ru.dart';

// Was hardcoded Russian-only (2023 revision) regardless of app locale —
// EN/ES users saw the same Russian legal text as RU users. Content now
// mirrors rivapsy.com's published RU/EN/ES Privacy Policy and Terms of
// Use (fetched 2026-08-02), picked by languageCode so each locale shows
// its own already-published, legally-current version.
class K7Controller {
  final DropTextModel termsOfUse;
  final DropTextModel privacyPolicy;

  K7Controller([String languageCode = 'ru'])
      : termsOfUse = _termsOfUseFor(languageCode),
        privacyPolicy = _privacyPolicyFor(languageCode);

  static DropTextModel _termsOfUseFor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return termsOfUseEn();
      case 'es':
        return termsOfUseEs();
      default:
        return termsOfUseRu();
    }
  }

  static DropTextModel _privacyPolicyFor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return privacyPolicyEn();
      case 'es':
        return privacyPolicyEs();
      default:
        return privacyPolicyRu();
    }
  }
}
