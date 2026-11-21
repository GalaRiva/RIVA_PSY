import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/core/utils/app_text_localizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app-written Russian diary texts show in the language that is on now', () async {
    await AppTextLocalizer.init();
    AppTextLocalizer.debugLang = 'es';
    expect(AppTextLocalizer.of('Моя динамика'), 'Mi evolución');
    expect(AppTextLocalizer.of('Меланхолия'), 'Melancolía');
    // A person's own words are never touched.
    expect(AppTextLocalizer.of('Работа у мамы'), 'Работа у мамы');
    // And back: Spanish wording shows in Russian when the language is Russian.
    AppTextLocalizer.debugLang = 'ru';
    expect(AppTextLocalizer.of('Mi evolución'), 'Моя динамика');
    expect(AppTextLocalizer.of('Меланхолия · Моя динамика'), 'Меланхолия · Моя динамика');
  });
}
