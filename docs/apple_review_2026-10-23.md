# Ответ на отказ Apple от 23.10.2026 (версия 1.0.9, билд 69)

Четыре замечания. Ниже: что это значит, что уже сделано в коде, что остаётся сделать вручную в App Store Connect, и готовые тексты (английские — вставлять как есть).

## Порядок действий
1. В App Store Connect отправить на проверку подписку **Orion Yearly** (п. 1).
2. Обновить описание приложения (п. 2).
3. Собрать и загрузить **новый билд 1.0.9 (70)** с разделом «Источники» (п. 3).
4. В «Примечаниях для проверки» добавить блок про ИИ и источники, ответить на отказ (п. 4, п. 5).
5. Выбрать новый билд, прикрепить обе подписки, отправить.

## 1. Guideline 2.1(b): подписка «1 year» не отправлена на проверку
Причина: на экране покупки есть годовая подписка (`riva_psy_orion_yearly`), а в заявке прикреплена только месячная.
Что сделать (подробнее — в `apple_submission_guide.md`, раздел 2): App Store Connect → Монетизация → Подписки → группа Orion → **Orion Yearly** → заполнить локализации (RU/EN/ES), цену и **скриншот для проверки** (экран покупки с годовым тарифом) → на странице версии, блок «Покупки в приложении и подписки», **«+»** → добавить Orion Yearly (и Orion Monthly) → сохранить.
Запасной вариант, если не успеваете: в новом билде скрыть годовой тариф на iOS (скажите — сделаю).

## 2. Guideline 2.3.2: в описании есть платная подписка без пометки, что нужна покупка
Это только текст в App Store Connect (описание, при желании promotional text). Добавьте в конец описания (RU / EN / ES):

**RU:**
Подписка Orion (платная, автопродлеваемая: 1 месяц или 1 год) открывает полный доступ к аудиопрактикам, рекомендациям, программам, аналитике и всем темам «Хлебных крошек». Часть функций доступна бесплатно. Оплата списывается с Apple ID при подтверждении покупки; подписка продлевается автоматически, если не отключить её минимум за 24 часа до конца периода. Управлять подпиской и отменить её можно в настройках Apple ID → Подписки. Условия использования: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/ · Политика конфиденциальности: [ссылка из вашей карточки].

**EN:**
RIVA PSY has free core features. The optional Orion subscription (paid, auto-renewing: 1 month or 1 year) unlocks full access to audio practices, recommendations, programs, analytics and all guided-journal topics. Payment is charged to your Apple ID at confirmation of purchase. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. You can manage or cancel it in Settings > Apple ID > Subscriptions. Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/ · Privacy Policy: [your link].

**ES:**
RIVA PSY ofrece funciones básicas gratuitas. La suscripción opcional Orion (de pago, con renovación automática: 1 mes o 1 año) da acceso completo a las prácticas de audio, recomendaciones, programas, analítica y todos los temas del diario guiado. El pago se carga en tu Apple ID al confirmar la compra. La suscripción se renueva automáticamente salvo que se cancele al menos 24 horas antes de que termine el periodo. Puedes gestionarla o cancelarla en Ajustes > Apple ID > Suscripciones. Condiciones de uso: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/ · Política de privacidad: [tu enlace].

Проверьте также: в названии, subtitle, promotional text и скриншотах нет слов вроде «бесплатно»/«free» рядом с платными функциями без оговорки; на скриншотах платных экранов уместна пометка «Orion».

## 3. Guideline 1.4.1: медицинская информация без ссылок на источники
Сделано в коде (войдёт в билд 70): экран **«Источники и научная основа»** — ссылки на ВОЗ, NIMH, NICE, APA и 25 научных статей по методам приложения (все DOI сверены по Crossref 23.10.2026) плюс ссылка на страницу науки на сайте. Где найти: Настройки → «Источники и научная основа», а также ссылка «Источники и научная основа» под медицинской оговоркой на экранах приложения (О приложении, итог теста, практики, программы, покупка, консультация).
В ответе Apple укажите путь: *Settings > Sources and scientific basis* (и ссылка под дисклеймером на каждом экране с практиками).

## 4. Guidelines 5.1.1(i) и 5.1.2(i): «данные пользователя уходят в сторонний ИИ»
Проверено по коду и зависимостям (23.10.2026): приложение **не использует** сторонние ИИ-сервисы и не отправляет им данные: нет ни ИИ-SDK в `pubspec.yaml`, ни вызовов ИИ-API в приложении и в `functions/`. Инсайты, «Мой портрет», итоги теста считаются локально по заданным правилам. В политике конфиденциальности (раздел «Будущее использование ИИ») уже сказано, что генеративный ИИ сейчас не используется.
Что сделать: **ответить на отказ** (текст ниже) и добавить тот же абзац в «Примечания для проверки».

## Текст ответа в App Review (English)
```
Hello,

Thank you for the detailed feedback. Here is what we have done in the new build 1.0.9 (70):

1. Guideline 2.1(b): The "Orion Yearly" auto-renewable subscription has now been submitted for review together with "Orion Monthly" (with an App Review screenshot) and attached to this version.

2. Guideline 2.3.2: The app description now states that the Orion subscription is a paid, auto-renewing purchase and lists which features it unlocks; other features are free.

3. Guideline 1.4.1: We added a "Sources and scientific basis" screen with links to the sources of the app's information (WHO, NIMH, NICE, APA and peer-reviewed publications with DOI links). It is available in Settings > "Sources and scientific basis" and via a link under the medical disclaimer shown on the practice, quiz result, program, purchase and About screens.

4. Guidelines 5.1.1(i) and 5.1.2(i): RIVA PSY does not send user data to any third-party AI service and does not include a third-party AI service. In-app insights, the "portrait" and quiz results are generated on the device from fixed rules. Personal data entered by the user (diary, course notes) is stored on the device; account and subscription data are processed by Firebase (Google) and Apple. Our Privacy Policy (Section 14) states that the app does not currently use generative AI.

Best regards,
Galina Egorova
```

## Дополнение к «Примечаниям для проверки» (English)
```
AI: The app does not use any third-party AI service and does not send user data to one. Insights, the "portrait" feature and quiz results are rule-based and computed on the device.
Medical sources: Settings > "Sources and scientific basis" (also linked under the medical disclaimer on practice, quiz result, program, purchase and About screens).
Subscriptions: Orion Monthly and Orion Yearly (auto-renewing, group "Orion"); both are submitted with this version.
```

## Сборка нового билда (iOS)
`pubspec.yaml` уже `1.0.9+70`. На Mac: `flutter build ipa --release` (или Archive в Xcode) → загрузить в App Store Connect → выбрать билд 70 в версии 1.0.9 → прикрепить подписки → отправить. Если нужна помощь с подписью/архивом — скажите.
