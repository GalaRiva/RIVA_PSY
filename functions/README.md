# Stripe → Firestore tariff sync

Эта функция принимает webhook от Stripe и синхронизирует тариф пользователя
в коллекции `Users` (поля `tariff` / `tariff_is_end`) на основе оплаты,
сделанной через Payment Link на сайте (Tilda).

## Что делает

- `checkout.session.completed` — новая подписка → `tariff: "Орион"`,
  `tariff_is_end` = дата окончания текущего периода подписки.
- `invoice.payment_succeeded` — продление → обновляет `tariff_is_end` на
  новую дату окончания периода.
- `customer.subscription.deleted` — отмена/окончание подписки →
  `tariff: "Базовый"`, `tariff_is_end` возвращается к `9999-12-24`
  (как у `TariffModel.BASE_TARIFF` в приложении).

Если email покупателя не находит **ровно один** документ в `Users`
(ни одного, или несколько — например человек регистрировался и через
Google, и отдельно по email) — тариф **не применяется автоматически**,
событие пишется в коллекцию `UnmatchedStripePayments` для ручного разбора.

## Перед деплоем

1. **Перевести проект Firebase на тарифный план Blaze** (Настройки проекта →
   Usage and billing → Modify plan). Без этого функция не сможет ходить в
   Stripe API — Spark (бесплатный план) не разрешает исходящие запросы к
   внешним сервисам. Само выполнение функции почти наверняка останется в
   пределах бесплатного лимита Blaze при таких объёмах, но перейти на план
   обязательно нужно даже для запуска.

2. Установить Firebase CLI, если ещё не установлен:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

3. Установить зависимости функции:
   ```bash
   cd functions
   npm install
   ```

## Деплой — строго в этом порядке

Секрет вебхука (`whsec_...`) Stripe покажет только после того, как вы
зарегистрируете URL уже развёрнутой функции — поэтому первый деплой идёт
без него, потом добавляем и деплоим ещё раз.

**Шаг 1 — задать секретный ключ Stripe** (тестовый режим, `sk_test_...`,
Stripe Dashboard → Developers → API keys):
```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
```
(команда спросит значение в интерактивном режиме — ключ никуда не попадёт
в файлы проекта)

**Шаг 2 — временно задать любое значение для webhook-секрета**, чтобы
функция вообще задеплоилась (Cloud Functions требует, чтобы все объявленные
секреты существовали на момент деплоя):
```bash
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
# на этом шаге можно ввести любую временную строку, например "placeholder"
```

**Шаг 3 — деплой:**
```bash
firebase deploy --only functions
```
После деплоя в выводе будет URL вида:
```
https://us-central1-rigel-psy-9361c.cloudfunctions.net/stripeWebhook
```

**Шаг 4 — зарегистрировать webhook в Stripe** (тестовый режим):
Stripe Dashboard → Developers → Webhooks → Add endpoint
- Endpoint URL: URL из шага 3
- События: `checkout.session.completed`, `invoice.payment_succeeded`,
  `customer.subscription.deleted`

После создания эндпоинта Stripe покажет **Signing secret** (`whsec_...`).

**Шаг 5 — задать настоящий webhook-секрет и передеплоить:**
```bash
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
# теперь вводим настоящий whsec_... из шага 4
firebase deploy --only functions
```

## Проверка

В Stripe Dashboard → Webhooks → выбранный эндпоинт есть кнопка "Send test
event" — можно отправить тестовое `checkout.session.completed` и посмотреть
в Firebase Console → Functions → Logs, дошло ли событие и что функция с ним
сделала. Оплатите один из тестовых Payment Link тестовой картой Stripe
(`4242 4242 4242 4242`, любая будущая дата, любой CVC) — после оплаты в
`Users/{ваш doc id}` должно появиться `tariff: "Орион"` с датой окончания
примерно через месяц/год.

## Логи и ручной разбор

```bash
firebase functions:log
```

Коллекция `UnmatchedStripePayments` в Firestore — каждый документ содержит
`reason` (`no_match` / `multiple_matches` / `no_email`), email покупателя,
и (при `multiple_matches`) список совпавших doc ID в `Users` — чтобы вручную
решить, какой аккаунт настоящий.

# Google Play Billing → Firestore tariff sync

Android-версия оплаты (кнопки в приложении), заменяет Stripe Payment Link
для Android, пока аккаунт разработчика не оформлен как компания и не может
зарегистрировать Stripe как "альтернативную платёжную систему" в Play
Console. Функция `verifyAndroidPurchase` — callable-функция, которую
вызывает само приложение сразу после покупки (не webhook, в отличие от
Stripe) — проверяет токен покупки через Android Publisher API и, если
подписка активна, пишет `tariff: "Орион"` / `tariff_is_end` в тот же
Firestore `Users`, что и Stripe-путь.

## Перед деплоем — обязательные шаги в Play Console

1. **Создать два товара-подписки** (Play Console → Monetize → Products →
   Subscriptions) с **точно такими ID** (код их ищет по этим строкам):
   - `riva_psy_orion_monthly` — 5,90 €/мес
   - `riva_psy_orion_yearly` — 69 €/год

   Опубликовать оба (черновик не будет виден `queryProductDetails()` в
   приложении).

2. **Включить Android Publisher API** для проекта `rigel-psy-9361c` в
   Google Cloud Console (APIs & Services → Library → "Google Play Android
   Developer API" → Enable).

3. **Дать доступ service account'у Cloud Functions** в Play Console:
   Play Console → Setup → API access → должен появиться проект
   `rigel-psy-9361c` (Cloud Console linked project) → напротив service
   account'а `7653326357-compute@developer.gserviceaccount.com` (тот же,
   что уже используется для остальных функций) нажать "Grant Access" и
   выдать права минимум на "View financial data" + "Manage orders and
   subscriptions" (в интерфейсе Play Console формулировки могут немного
   отличаться — нужен доступ к чтению/управлению подписками, не только
   "View app information").

   Без этого шага `verifyAndroidPurchase` будет падать с ошибкой доступа
   при любой попытке проверить покупку.

4. Установить зависимости (если ещё не сделано для Stripe-части):
   ```bash
   cd functions
   npm install
   ```

## Деплой

Секретов для этой функции не требуется (в отличие от Stripe) — она
использует собственный service account функции через Application Default
Credentials:
```bash
firebase deploy --only functions
```

## Проверка

Тестовые покупки в Play Billing требуют **закрытого тестирования**
(Play Console → Testing → Internal testing), с тестовым аккаунтом,
добавленным в список тестировщиков (License testing), иначе с настоящей
карты спишутся реальные деньги за тестовую покупку. После тестовой покупки
в приложении — смотреть `firebase functions:log` на предмет вызовов
`verifyAndroidPurchase`, и `Users/{doc id}` в Firestore на предмет
`tariff: "Орион"`.
