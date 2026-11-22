# Разбор страницы версии 1.0.9 в App Store Connect (по скриншоту от 22 ноября)

## Что видно на скриншоте

- Версия 1.0.9, сборка **71**, статус «Ожидание проверки». Apple пишет: пока версия ждёт проверки, часть информации можно править, а **чтобы отправить новую сборку, нужно удалить эту версию из очереди**. Это подтверждает, что замена сборки сбрасывает очередь.
- Красная точка у пункта «Проверка приложения» в левом меню. Её нужно открыть первой (см. ниже).
- Баннер: «Обновите ответы на вопросы о возрастных ограничениях (геопозиция и знакомства). Ответы не требуются до 31 января 2027 г., но обязательны при отправке нового приложения или обновления». **Для сборки 74 это нужно будет сделать до отправки.**
- В меню появился раздел «Соответствие требованиям» (метка «Новое»). Там обычно статус trader по DSA.
- Выпуск версии: автоматически после одобрения. Это нормально.

## Что в метаданных верно

- Название «RIVA PSY: Psychology & Calm» (27 знаков, лимит 30).
- Описание честно называет подписку Orion (платная, автопродление, 1 месяц или 1 год), списание с Apple ID, отмену за 24 часа до конца периода, как управлять в настройках, ссылки на Terms of Use и Privacy Policy. Это закрывает прошлый отказ 23 октября (2.3.2).
- Дисклеймер в конце («не заменяет психолога или врача», что делать в кризисе), раздел про источники, блок «Private by design».
- Ссылка на поддержку и на сайт есть, copyright указан.

## Что неточно или устарело

1. **Примечания для проверки** (самое важное). В них написано, что личные данные «nothing is uploaded to a server». Это не совсем так: данные аккаунта (почта, статус подписки) хранятся в Firebase, обращения в поддержку (с необязательным фото) отправляются, возможен резервный диск в Google Drive. Ревьюер, увидев аккаунт, подписку и отправку обращений, может расценить это как неточность (2.3.1(a), 5.1.1). Дневник остаётся только на устройстве, это нужно сказать точно.
2. В примечаниях нет: пояснения подписок, программ, консультации (она есть в 71 для русскоязычных), исключения ATS, фоновых режимов, удаления аккаунта.
3. Описание: «Programs ... (currently in Russian)». С тех пор «Еда без автопилота» вышла на английском и испанском, «После расставания» на испанском. В сборке 74 появилась «Меланхолия» (RU и ES). Описание надо обновить к 74, чтобы оно соответствовало продукту (2.3.1).
4. Ключевые слова содержат «addiction» и «depression». Допустимо, но приложение не лечит зависимости и депрессию, и слова привлекают ожидание лечения. Рекомендую заменить на нейтральные («mood», «journal», «meditation», «self care»).
5. Пароль тестового аккаунта виден на скриншоте. Аккаунт тестовый, но лучше не слать скриншоты с паролем, а если он где-то ещё используется, сменить.

## Что исправить в примечаниях для 71 уже сейчас (правка возможна, пока заявка ждёт)

Заменить текст на такой (он описывает именно сборку 71, где консультация на iOS ещё есть):

```
RIVA PSY is a self-help and psychological education app (not a medical device, not a substitute for professional care). Diary entries, voice notes and exercise answers are stored only on the user's device. An account (email, Sign in with Apple or Google) is optional and requested only when needed, for example before buying a subscription. Account data (email, subscription status) is stored in Firebase. Optional: backup to the user's own Google Drive; error reports the user chooses to send (with an optional photo).

HOW TO TEST: the sign-in above has an active Orion subscription, so premium content can be reviewed without a purchase. Subscriptions Orion Monthly and Orion Yearly are bought only through In-App Purchase; Restore Purchases and links to Terms and Privacy are on the subscription screens. There are no promo codes on iOS and no external payment links. Account deletion: Settings > Profile > Delete account.

HEALTH AND SAFETY: a disclaimer (does not diagnose or treat, not a substitute for a doctor or psychologist) is shown on the main screens and next to purchases; sources are listed in Settings > Sources; a help page and the emergency number 112 are linked from "I'm struggling right now".

NOTES: (1) NSAllowsArbitraryLoads is enabled only so the audio player can stream practices through a local loopback proxy (127.0.0.1) for caching. (2) Background modes: audio playback, and fetch/processing for the user's own local reminders and a nightly on-device analysis that produces a local notification; nothing is sent anywhere. (3) Camera, location and Bluetooth strings exist only because of third-party plugins; the app never requests them. (4) For Russian-language users there is a paid one-to-one online consultation with the author, booked on an external page (Guideline 3.1.3(d)). (5) No ads, no tracking, no analytics SDKs.
```

Текст для сборки 74 лежит в `apple_review_notes_build74.md`.

## Какие ещё скриншоты нужны для полной проверки (по порядку важности)

1. **Раздел «Проверка приложения»** (красная точка в меню): сообщения и статус в Resolution Center. Возможно, там есть вопрос Apple без ответа, и именно он задерживает заявку.
2. **«Соответствие требованиям»**: статус trader по DSA (правила Apple, 5.6.2, и закон ЕС).
3. **«Конфиденциальность приложения»**: какие типы данных заявлены (сверю с кодом, включая консультацию и аккаунт).
4. **Возрастной рейтинг** («Оценки и отзывы» или «Информация о приложении»): ответы на анкету (2.3.6, 5.2 Schedule 2).
5. **«Подписки»** (метка «Новое»): группа Orion, оба товара, статусы, цены, локализации названия и описания, скриншот для проверки (2.1(b), 3.1.2(c)).
6. **«Информация о приложении»**: категория, ссылка на политику конфиденциальности, права на контент, подзаголовок.
7. **«Цены и доступность»**: список стран (для Китая нужна лицензия, для ЕС нужен trader-статус).
8. **Скриншоты и превью в карточке** (2.3.3, 2.3.10): что показано, без упоминаний Android.
9. **Локализации** (русская и испанская страницы: название, подзаголовок, описание), если они включены.

Когда пришлёшь, сверю каждое с правилами и составлю итог «что проверено и по каким пунктам», который можно приложить к письму.
