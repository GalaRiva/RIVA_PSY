# Проверка индексации rivapsy.com

Дата проверки: 2026-11-06. Только чтение: на сайте и в Tilda ничего не менялось и не публиковалось. Проверено живыми запросами к сайту (HTTP-статус, HTML, robots.txt, sitemap) и данными Tilda (список страниц, настройки страниц, настройки домена).

## Итог в двух словах

- Сайт **открыт** для поисковых и ИИ-роботов: в robots.txt одна группа `User-Agent: *`, закрыты только служебные адреса Tilda и два служебных шаблона («Menu», «ERROR»). Googlebot, Bingbot, YandexBot, OAI-SearchBot и GPTBot **не закрыты**. Ни у одной страницы нет `noindex`.
- В карте сайта все 32 статические страницы и ещё **63 статьи блога** (три карты по языкам). Опубликованных страниц, которых нет в карте, нет (кроме закрытых «Menu» и «ERROR» и дубля главной).
- Главные проблемы: ~~у всех 63 статей одинаковое meta description~~ (**исправлено 2026-11-06**, см. проблему 1), ~~hreflang на статьях ведёт на главные страницы блога~~ (**исправлено 2026-11-06**), **нет Bing Webmaster** и Яндекс.Вебмастер не подключён, **www-версия открывается как отдельный сайт**.

## Шаг 1. robots.txt

Адрес: https://rivapsy.com/robots.txt (HTTP 200). Полный текст:

```
User-Agent: *
Disallow: /page156157066.html
Disallow: /menu
Disallow: /page156359509.html
Disallow: /error
Disallow: /tilda/form*
Disallow: /tilda/rec*
Disallow: /tilda/click*
Disallow: /tilda/scroll*
Disallow: /tilda/popup*
Disallow: /tilda/cart*
Disallow: /tilda/product*
Disallow: /tilda/event*
Disallow: /members/login*
Disallow: /members/signup*
Disallow:

Sitemap: https://rivapsy.com/sitemap.xml
Sitemap: https://rivapsy.com/sitemap-store.xml
Sitemap: https://rivapsy.com/sitemap-feeds.xml

# LLM metadata
# https://rivapsy.com/llms.txt
# https://rivapsy.com/llms-full.txt
```

| Робот | Что в robots.txt | Закрыт ли сайт | Ответ сервера на запрос с его User-Agent |
|---|---|---|---|
| * (все) | группа User-Agent: * | нет, не закрыт | 200 |
| Googlebot | отдельной группы нет, действует `*` | нет, не закрыт | 200 |
| Bingbot | отдельной группы нет, действует `*` | нет, не закрыт | 200 |
| YandexBot | отдельной группы нет, действует `*` | нет, не закрыт | 200 |
| OAI-SearchBot (поиск ChatGPT) | отдельной группы нет, действует `*` | нет, не закрыт | 200 |
| GPTBot (обучение моделей) | отдельной группы нет, действует `*` | нет, не закрыт | 200 |

- Блокирует только: служебные пути Tilda (`/tilda/...`, `/members/login`, `/members/signup`) и страницы `/menu`, `/error`, `/page156157066.html`, `/page156359509.html` (шаблоны шапки/подвала и страница ошибки). Это правильно, открывать их не нужно.
- Пустая строка `Disallow:` в конце группы ничего не закрывает (пустое значение означает «разрешено всё»).
- **Sitemap:** три строки: `sitemap.xml` (страницы), `sitemap-store.xml` (магазин, пустой) и `sitemap-feeds.xml` (индекс из трёх карт блога). Все отдают 200.
- **GPTBot** (обучение моделей) сейчас **не закрыт**. Решение за вами: чтобы закрыть, нужно добавить в robots.txt блок `User-agent: GPTBot` и `Disallow: /`. OAI-SearchBot (поиск ChatGPT) при этом оставлять открытым.
- Комментарии `# LLM metadata` со ссылками на `llms.txt` и `llms-full.txt` на индексацию не влияют, оба файла отдают 200.

## Шаг 2. Карта сайта

`sitemap.xml`: 32 адресов. Блог вынесен в `sitemap-feeds.xml` (индекс): три карты по 21 статье (RU `sitemap-feed-603086731631.xml`, EN `sitemap-feed-587034676771.xml`, ES `sitemap-feed-879011341131.xml`), всего 63 статьи, дублей нет.

| Адрес | Язык | Тип | lastmod |
|---|---|---|---|
| / | RU | главная | 2026-10-17 |
| /es | ES | главная | 2026-10-17 |
| /en | EN | главная | 2026-10-17 |
| /support | RU | служебная (поддержка) | 2026-10-16 |
| /soporte | ES | служебная (поддержка) | 2026-10-16 |
| /supporten | EN | служебная (поддержка) | 2026-10-16 |
| /privacy | RU | юридическая | 2026-10-16 |
| /privacidad | ES | юридическая | 2026-10-16 |
| /privacyen | EN | юридическая | 2026-10-16 |
| /terms | RU | юридическая | 2026-10-16 |
| /responsibility | RU | юридическая | 2026-10-16 |
| /payment | RU | служебная/старая | 2026-10-16 |
| /partners_type_of_attachment | RU | служебная/старая | 2026-10-16 |
| /chiwisemagic | EN | юридическая | 2026-08-16 |
| /crisis | RU | помощь (SOS) | 2026-10-16 |
| /es/crisis | ES | помощь (SOS) | 2026-10-16 |
| /en/crisis | EN | помощь (SOS) | 2026-10-16 |
| /blog | RU | блог (индекс) | 2026-10-17 |
| /es/blog | ES | блог (индекс) | 2026-10-17 |
| /en/blog | EN | блог (индекс) | 2026-10-17 |
| /en/science | EN | наука | 2026-10-16 |
| /science | RU | наука | 2026-10-16 |
| /es/science | ES | наука | 2026-10-16 |
| /dnevnik-emocij | RU | лендинг под запрос | 2026-10-16 |
| /en/emotion-diary-app | EN | лендинг под запрос | 2026-10-16 |
| /es/app-diario-emocional | ES | лендинг под запрос | 2026-10-16 |
| /trevoga-uprazhneniya | RU | лендинг под запрос | 2026-10-16 |
| /en/anxiety-exercises-app | EN | лендинг под запрос | 2026-10-16 |
| /es/app-ejercicios-ansiedad | ES | лендинг под запрос | 2026-10-16 |
| /nastroenie-telo-mysli | RU | лендинг под запрос | 2026-10-16 |
| /en/mood-body-thoughts-app | EN | лендинг под запрос | 2026-10-16 |
| /es/app-animo-cuerpo-pensamientos | ES | лендинг под запрос | 2026-10-16 |

**Каких опубликованных страниц нет в карте:**
- `/page35473029.html`: это та же русская главная по второму адресу. Канонический адрес главной `https://rivapsy.com` (в карте `https://rivapsy.com/`), так что это правильно.
- `/menu` и `/error`: закрыты намеренно (шаблон шапки/подвала и страница ошибки). Всё правильно.
- Остальные опубликованные страницы (всего 34 в Tilda) в карте есть.

**Лишнее или спорное в карте** (страницы, которые вряд ли должны продвигаться в поиске):
| Адрес | Что это | Рекомендация |
|---|---|---|
| /chiwisemagic | Политика конфиденциальности другого приложения (Chi Wise Magic), на английском | Оставить доступной (нужна для магазина), но закрыть от индексации; убрать из карты |
| /payment | Старая страница «Индивидуальный курс психотерапия Rivapsy» с заявкой. Она же указана автором по умолчанию у статей блога. Звучит как психотерапия, что расходится с текущим позиционированием приложения | Проверить текст; если страница не нужна, закрыть от индексации; сменить автора по умолчанию у статей | **РЕШЕНИЕ 2026-11-06 (владелец сайта):** страница привязана к платёжному сервису и содержит сведения об авторе — не переименовывать, не удалять, адрес не менять; ссылка автора статей на неё остаётся. `noindex` добавлен и **снят 2026-11-06 по решению владельца**: страница должна находиться пользователями и индексироваться всеми; в коде ничего не осталось. Также 2026-11-06 заданы title «Индивидуальный курс «Выныривай» — психолог Галина Егорова» и meta description (139 знаков), og — те же.
| /partners_type_of_attachment | Старый тест «Тип привязанности пары»; парная страница `test_my_type_of_attachment` не опубликована (404) | Решить, нужна ли; если нет, закрыть от индексации |
| /responsibility | «Контракт ответственности» психолога и клиента (от 12.02.2024) | Оставить доступной, индексировать не обязательно |

## Шаг 3. Закрытые от индексации и технические проблемы страниц

Проверено по каждой из 36 страниц Tilda: настройка запрета индексации, `meta robots`, `X-Robots-Tag`, `canonical`, HTTP-статус.

- **Запрет индексации (`nosearch`) в настройках Tilda не включён ни у одной страницы.** `meta robots noindex` или `nofollow` в HTML нет ни на одной странице, заголовка `X-Robots-Tag` нет.
- **Canonical** есть у всех открытых страниц и указывает на себя (ни на какую другую страницу).
- «Шапка» и «Подвал» для потоков (`/menu`, `/error` и страницы с `Disallow` по номеру) закрыты **в robots.txt**: правильно, оставляем. Мета-тег noindex на них не нужен и даже вреден: робот не может его прочитать, пока доступ закрыт.

| Адрес | Проблема | Что сделать |
|---|---|---|
| /test_my_type_of_attachment | Не опубликована, 404 | Ничего (не в карте). Если не нужна, можно удалить |
| /page69394273.html | «Стили привязанности в отношениях», не опубликована, 404 | Ничего (не в карте) |
| /partners_type_of_attachment | нет meta description, нет hreflang | Закрыта от индексации (`noindex`, 2026-11-06), описание не нужно |
| /crisis | ~~нет meta description~~ (**добавлено 2026-11-06**), hreflang добавлен (**2026-11-06**) | Сделано: описание, понятный title (50–63 знака), og-заголовок и hreflang между тремя версиями SOS |
| /es/crisis | ~~нет meta description~~ (**добавлено 2026-11-06**), hreflang добавлен (**2026-11-06**) | Сделано: описание, понятный title (50–63 знака), og-заголовок и hreflang между тремя версиями SOS |
| /en/crisis | ~~нет meta description~~ (**добавлено 2026-11-06**), hreflang добавлен (**2026-11-06**) | Сделано: описание, понятный title (50–63 знака), og-заголовок и hreflang между тремя версиями SOS |
| /support, /soporte, /supporten, /privacy, /privacidad, /privacyen | Нет hreflang между языковыми версиями (описание есть) | Не критично; при желании связать версии hreflang |
| Все страницы | В `<html>` нет атрибута `lang` | Низкий приоритет: язык определяется по содержимому, на ключевых страницах есть hreflang |
| www.rivapsy.com | Отдаёт 200 как отдельный сайт (редирект www на основной адрес не включён), http на https перенаправляется правильно | Включить редирект с www в настройках домена (ниже). Пока canonical на страницах защищает от дублей | **ИСПРАВЛЕНО 2026-11-06:** включён редирект www → без www (301), проверено в браузере на `/` и `/en/blog`.
| Все (повторные запросы) | При серии из десятков быстрых запросов защита DDoS-Guard один раз выдала 403 (llms.txt, rss.xml) с общим User-Agent; через минуту всё открывалось (200), для Googlebot, Bingbot, YandexBot, OAI-SearchBot, GPTBot ответы 200 | Следить: если в Search Console появятся «ошибки 403», написать в поддержку Tilda, чтобы роботы поисковиков были в белом списке |

## Шаг 4. Статьи блога (63 штуки)

Каждая статья открывается как **отдельная страница со своим адресом** `/tpost/...` (код 200, canonical на себя, в карте блога). У всех есть title на языке статьи. **Ссылка на приложение есть во всех 63 статьях**: в конце абзац «Скачать приложение RIVA PSY» со ссылкой на главную страницу своего языка (`/`, `/en`, `/es`), а на главной есть кнопка Google Play. Прямых ссылок на Google Play в самих статьях нет.

**Проблема 1. Meta description у всех статей одинаковый — ИСПРАВЛЕНО 2026-11-06.** Для всех 63 статей заполнено уникальное SEO-описание (112–152 знака, поле SEO Description в Тильде); на живых страницах проверено: 63 разных описания, `og:description` теперь совпадает с ним. Ниже — состояние до исправления.

**Было:** meta description у всех статей одинаковый (общий описание блога на своём языке, по 21 статье на каждое). Уникальное описание статьи есть только в `og:description` (для соцсетей). Поисковики могут сами подбирать фрагмент, но свой описание нужно задать.
**Проблема 2. hreflang на каждой статье — ИСПРАВЛЕНО 2026-11-06** (ниже описано состояние до исправления) (4 тега: ru, en, es, x-default) ведёт на **главные страницы блога**, а не на переводы этой статьи. Тот же код добавляет на каждую статью JSON-LD типа `Blog` с названием «Блог Rivapsy». Это общий код head блога, который наследуют все статьи. Для статьи такие метки неверны.

**Что сделано:** в head-коде трёх страниц блога (Blog RU/EN/ES) статические теги hreflang и JSON-LD `Blog` заменены скриптом. На страницах блога (`/blog`, `/en/blog`, `/es/blog`) он добавляет прежние hreflang и `Blog`. На статьях добавляет hreflang на переводы именно этой статьи (ru/en/es и x-default на EN, где английская версия есть), JSON-LD `Blog` на статьях больше нет. Пары: 20 статей есть на трёх языках, дневник эмоций только RU+ES, `DBT Skills List` только EN (без hreflang). Проверено на живых страницах в браузере; прежний head-код сохранён в scratchpad (`head_*.json`). Ограничение: теги создаются скриптом, Google их видит после рендера страницы; в сыром HTML их нет.
**Проблема 3.** Длинные title (больше 70 знаков, в выдаче обрезаются): 22 статей.

| Заголовок | Язык | Адрес | title | description | Отдельная страница | Ссылка на приложение |
|---|---|---|---|---|---|---|
| Дневник эмоций СМЭР: как записать, что вы чувствуете | RU | /tpost/egr41zzmt1-dnevnik-emotsii-smer-kak-zapisat-chto-vi | есть (52) | общий для блога | да | да (главная RU) |
| 12 ловушек в твоей голове | RU | /tpost/hs5hzpno81-12-lovushek-v-tvoei-golove | есть (25) | общий для блога | да | да (главная RU) |
| СМЭР: поймать мысль, от которой стало плохо | RU | /tpost/odttbfxza1-smer-poimat-misl-ot-kotoroi-stalo-ploho | есть (43) | общий для блога | да | да (главная RU) |
| Осенняя хандра или депрессия: как понять | RU | /tpost/gm5hbr19n1-osennyaya-handra-ili-depressiya-kak-pony | есть (40) | общий для блога | да | да (главная RU) |
| Когда любая критика ранит: как выдерживать замечания и ссоры | RU | /tpost/4mrycgku71-kogda-lyubaya-kritika-ranit-kak-viderzhi | есть (60) | общий для блога | да | да (главная RU) |
| Сложно выдерживать конфликты: что делать, когда давят, требуют и жалуются | RU | /tpost/phxlzfgf01-slozhno-viderzhivat-konflikti-chto-delat | есть (73) | общий для блога | да | да (главная RU) |
| Я оказалась в роли любовницы. Что делать? | RU | /tpost/27j2gu06k1-ya-okazalas-v-roli-lyubovnitsi-chto-dela | есть (41) | общий для блога | да | да (главная RU) |
| Меня бросил любимый. Как перестать надеяться и ждать? | RU | /tpost/88rglk3831-menya-brosil-lyubimii-kak-perestat-nadey | есть (53) | общий для блога | да | да (главная RU) |
| Упражнения от тревоги: 7 способов успокоиться за 5 минут | RU | /tpost/1h9jhnyvb1-uprazhneniya-ot-trevogi-7-sposobov-uspok | есть (56) | общий для блога | да | да (главная RU) |
| Стесняюсь своего тела: что делать, если диеты не помогают | RU | /tpost/6g8yxkgrz1-stesnyayus-svoego-tela-chto-delat-esli-d | есть (57) | общий для блога | да | да (главная RU) |
| Лень или прокрастинация: что делать, когда ничего не хочется | RU | /tpost/le8ud6b2g1-len-ili-prokrastinatsiya-chto-delat-kogd | есть (60) | общий для блога | да | да (главная RU) |
| Меня бесят коллеги: что делать, когда на работе змеиное гнездо | RU | /tpost/ejkryhv201-menya-besyat-kollegi-chto-delat-kogda-na | есть (62) | общий для блога | да | да (главная RU) |
| Эмоции в перименопаузе: почему то слёзы, то раздражение, и как себе помочь | RU | /tpost/mp3r78im61-emotsii-v-perimenopauze-pochemu-to-slyoz | есть (74) | общий для блога | да | да (главная RU) |
| Узнать себя заново в перименопаузе: кто я теперь и чего хочу | RU | /tpost/2y30bhzza1-uznat-sebya-zanovo-v-perimenopauze-kto-y | есть (60) | общий для блога | да | да (главная RU) |
| Приливы, бессонница и туман в голове в перименопаузе: что действительно помогает | RU | /tpost/ypuhxuelt1-prilivi-bessonnitsa-i-tuman-v-golove-v-p | есть (80) | общий для блога | да | да (главная RU) |
| Перименопауза и близкие: как поговорить с партнёром, детьми и коллегами | RU | /tpost/yscouu15l1-perimenopauza-i-blizkie-kak-pogovorit-s | есть (71) | общий для блога | да | да (главная RU) |
| Как помочь себе в перименопаузе: план на 4 недели шаг за шагом | RU | /tpost/u5jsn66031-kak-pomoch-sebe-v-perimenopauze-plan-na | есть (62) | общий для блога | да | да (главная RU) |
| Беби-блюз или послеродовая депрессия: как отличить и когда бить тревогу | RU | /tpost/tnysm3hjp1-bebi-blyuz-ili-poslerodovaya-depressiya | есть (71) | общий для блога | да | да (главная RU) |
| Послеродовая депрессия: 7 шагов, которые помогают маме | RU | /tpost/cm6o1l9xe1-poslerodovaya-depressiya-7-shagov-kotori | есть (54) | общий для блога | да | да (главная RU) |
| Как поддержать маму с послеродовой депрессией: советы партнёру и близким | RU | /tpost/xjxbuam3y1-kak-podderzhat-mamu-s-poslerodovoi-depre | есть (72) | общий для блога | да | да (главная RU) |
| Послеродовая депрессия: когда нужен врач и какое бывает лечение | RU | /tpost/ki00f2ggi1-poslerodovaya-depressiya-kogda-nuzhen-vr | есть (63) | общий для блога | да | да (главная RU) |
| DBT Skills List: The Four Modules Explained | EN | /tpost/ac0kjo37i1-dbt-skills-list-the-four-modules-explain | есть (43) | общий для блога | да | да (главная EN) |
| CBT Thought Record: A Step-by-Step Guide With Examples | EN | /tpost/k2nuhbgdf1-cbt-thought-record-a-step-by-step-guide | есть (54) | общий для блога | да | да (главная EN) |
| Cognitive Distortions: 12 Thinking Traps With Everyday Examples | EN | /tpost/037fcmxvr1-cognitive-distortions-12-thinking-traps | есть (63) | общий для блога | да | да (главная EN) |
| Winter Blues vs Seasonal Depression: How to Tell the Difference | EN | /tpost/i256lk7as1-winter-blues-vs-seasonal-depression-how | есть (63) | общий для блога | да | да (главная EN) |
| When any criticism hurts: how to get through comments and arguments | EN | /tpost/ps5m3ji1z1-when-any-criticism-hurts-how-to-get-thro | есть (67) | общий для блога | да | да (главная EN) |
| I find conflict hard: what to do when people push, demand and complain | EN | /tpost/z16byyn5e1-i-find-conflict-hard-what-to-do-when-peo | есть (70) | общий для блога | да | да (главная EN) |
| I'm "the other woman". What do I do? | EN | /tpost/yxisfpmah1-im-the-other-woman-what-do-i-do | есть (36) | общий для блога | да | да (главная EN) |
| He left me. How do I stop hoping and waiting? | EN | /tpost/xlxjgmnmv1-he-left-me-how-do-i-stop-hoping-and-wait | есть (45) | общий для блога | да | да (главная EN) |
| Anxiety Exercises: 7 Ways to Calm Down in 5 Minutes | EN | /tpost/v9xdi9lu71-anxiety-exercises-7-ways-to-calm-down-in | есть (51) | общий для блога | да | да (главная EN) |
| Ashamed of Your Body? What to Do When Diets Don't Help | EN | /tpost/233tft4d71-ashamed-of-your-body-what-to-do-when-die | есть (54) | общий для блога | да | да (главная EN) |
| Laziness or Procrastination? What to Do When You Can't Get Started | EN | /tpost/2hcjp2e871-laziness-or-procrastination-what-to-do-w | есть (66) | общий для блога | да | да (главная EN) |
| My coworkers drive me crazy: what to do when work feels like a snake pit | EN | /tpost/8t8rroz6a1-my-coworkers-drive-me-crazy-what-to-do-w | есть (72) | общий для блога | да | да (главная EN) |
| Emotions in perimenopause: why you feel so on edge, and how to help yourself | EN | /tpost/xrcneo2061-emotions-in-perimenopause-why-you-feel-s | есть (76) | общий для блога | да | да (главная EN) |
| Getting to know yourself again in perimenopause: who am I now, and what do I want? | EN | /tpost/vn8021xls1-getting-to-know-yourself-again-in-perime | есть (82) | общий для блога | да | да (главная EN) |
| Hot flashes, insomnia and brain fog in perimenopause: what actually helps | EN | /tpost/t42513d3a1-hot-flashes-insomnia-and-brain-fog-in-pe | есть (73) | общий для блога | да | да (главная EN) |
| Perimenopause and the people close to you: how to talk to your partner, children and colleagues | EN | /tpost/litftoi2i1-perimenopause-and-the-people-close-to-yo | есть (95) | общий для блога | да | да (главная EN) |
| How to help yourself in perimenopause: a 4-week plan, step by step | EN | /tpost/5c8u57kxg1-how-to-help-yourself-in-perimenopause-a | есть (66) | общий для блога | да | да (главная EN) |
| Baby blues or postpartum depression: how to tell the difference and when to worry | EN | /tpost/240k68orn1-baby-blues-or-postpartum-depression-how | есть (81) | общий для блога | да | да (главная EN) |
| Postpartum depression: 7 steps that help a mother | EN | /tpost/sl2ubju5u1-postpartum-depression-7-steps-that-help | есть (49) | общий для блога | да | да (главная EN) |
| How to support a mother with postpartum depression: advice for partners and loved ones | EN | /tpost/zkpd2cix11-how-to-support-a-mother-with-postpartum | есть (86) | общий для блога | да | да (главная EN) |
| Postpartum depression: when to see a doctor and what treatment is available | EN | /tpost/i3di42dzd1-postpartum-depression-when-to-see-a-doct | есть (75) | общий для блога | да | да (главная EN) |
| Diario emocional: cómo empezar, qué escribir y ejemplos | ES | /tpost/diario_emocional | есть (55) | общий для блога | да | да (главная ES) |
| Registro de pensamientos: plantilla y ejemplos paso a paso | ES | /tpost/a85s2bd701-registro-de-pensamientos-plantilla-y-eje | есть (58) | общий для блога | да | да (главная ES) |
| Distorsiones cognitivas: las 12 más frecuentes con ejemplos | ES | /tpost/7jxlbl7li1-distorsiones-cognitivas-las-12-ms-frecue | есть (59) | общий для блога | да | да (главная ES) |
| Astenia otoñal o depresión: cómo distinguirlas y cuándo consultar | ES | /tpost/in2re55ng1-astenia-otoal-o-depresin-cmo-distinguirl | есть (65) | общий для блога | да | да (главная ES) |
| Cuando cualquier crítica duele: cómo aguantar los comentarios y las discusiones | ES | /tpost/eiaoeld9p1-cuando-cualquier-crtica-duele-cmo-aguant | есть (79) | общий для блога | да | да (главная ES) |
| Me cuesta aguantar los conflictos: qué hacer cuando te presionan, te exigen y se quejan | ES | /tpost/pbjmf36le1-me-cuesta-aguantar-los-conflictos-qu-hac | есть (87) | общий для блога | да | да (главная ES) |
| Soy «la otra». Qué hago? | ES | /tpost/dtuon4yu81-soy-la-otra-qu-hago | есть (24) | общий для блога | да | да (главная ES) |
| Me ha dejado. ¿Cómo dejo de esperar y de tener esperanza? | ES | /tpost/2yzyio2hm1-me-ha-dejado-cmo-dejo-de-esperar-y-de-te | есть (57) | общий для блога | да | да (главная ES) |
| Ejercicios para la ansiedad: 7 formas de calmarte en 5 minutos | ES | /tpost/dzmihkg0j1-ejercicios-para-la-ansiedad-7-formas-de | есть (62) | общий для блога | да | да (главная ES) |
| Me da vergüenza mi cuerpo: qué hacer cuando las dietas no ayudan | ES | /tpost/z7uiuxh9o1-me-da-vergenza-mi-cuerpo-qu-hacer-cuando | есть (64) | общий для блога | да | да (главная ES) |
| ¿Pereza o procrastinación? Qué hacer cuando no te sale empezar | ES | /tpost/mvp6yn5ny1-pereza-o-procrastinacin-qu-hacer-cuando | есть (62) | общий для блога | да | да (главная ES) |
| Mis compañeros de trabajo me sacan de quicio: qué hacer cuando la oficina es un nido de víboras | ES | /tpost/h5ixs0xj11-mis-compaeros-de-trabajo-me-sacan-de-qui | есть (95) | общий для блога | да | да (главная ES) |
| Emociones en la perimenopausia: por qué todo te afecta más y cómo ayudarte | ES | /tpost/akai5htm81-emociones-en-la-perimenopausia-por-qu-to | есть (74) | общий для блога | да | да (главная ES) |
| Conocerte de nuevo en la perimenopausia: quién soy ahora y qué quiero | ES | /tpost/t0ymrnuxs1-conocerte-de-nuevo-en-la-perimenopausia | есть (69) | общий для блога | да | да (главная ES) |
| Sofocos, insomnio y niebla mental en la perimenopausia: qué ayuda de verdad | ES | /tpost/eon5nrzl71-sofocos-insomnio-y-niebla-mental-en-la-p | есть (75) | общий для блога | да | да (главная ES) |
| Perimenopausia y tus seres queridos: cómo hablar con tu pareja, tus hijos y tus compañeros | ES | /tpost/pev8nsb501-perimenopausia-y-tus-seres-queridos-cmo | есть (90) | общий для блога | да | да (главная ES) |
| Cómo ayudarte en la perimenopausia: un plan de 4 semanas paso a paso | ES | /tpost/yk6i933ig1-cmo-ayudarte-en-la-perimenopausia-un-pla | есть (68) | общий для блога | да | да (главная ES) |
| Baby blues o depresión posparto: cómo distinguirlas y cuándo preocuparse | ES | /tpost/0046hogta1-baby-blues-o-depresin-posparto-cmo-disti | есть (72) | общий для блога | да | да (главная ES) |
| Depresión posparto: 7 pasos que ayudan a la madre | ES | /tpost/6pgcdv0vy1-depresin-posparto-7-pasos-que-ayudan-a-l | есть (49) | общий для блога | да | да (главная ES) |
| Cómo apoyar a una madre con depresión posparto: consejos para parejas y allegados | ES | /tpost/6e2u0kth61-cmo-apoyar-a-una-madre-con-depresin-posp | есть (81) | общий для блога | да | да (главная ES) |
| Depresión posparto: cuándo acudir al médico y qué tratamientos existen | ES | /tpost/gfm4yo5xf1-depresin-posparto-cundo-acudir-al-mdico | есть (70) | общий для блога | да | да (главная ES) |

## Шаг 5. Итог

### 1. Проблемы по важности и как исправить в Tilda

Ниже без изменений на сайте: всё делается только с вашего отдельного «да». Пункты меню Tilda указаны по моим знаниям интерфейса; если названия отличаются, найдите похожий раздел.

**Высокая важность**
1. ~~**Одинаковый meta description у 63 статей.**~~ **Сделано 2026-11-06.** Где: Тильда → Потоки (блог) → открыть статью → Настройки (шестерёнка) → SEO → поле «Description». Нужно заполнить уникальным описанием (можно взять уже готовое из карточки статьи, 150–160 знаков). Могу заполнить все 63 через Tilda MCP по вашему «да».
2. ~~**hreflang и JSON-LD `Blog` на каждой статье.**~~ **Сделано 2026-11-06.** Где: страница «Blog RU/EN/ES» → Настройки страницы → «Дополнительно» → «HTML-код для вставки в HEAD». Нужно оставить hreflang и разметку `Blog` только на самих страницах блога (условие: нет атрибута `data-tilda-post-uid` у `#allrecords`) или убрать hreflang со статей. Могу поправить код по вашему «да».

**Средняя важность**
3. **Bing Webmaster Tools не подключён** (в коде сайта нет метки `msvalidate.01`). Где: bing.com/webmasters → «Add site» → «Import from Google Search Console» (быстрее всего), затем «Sitemaps»: добавить `https://rivapsy.com/sitemap.xml` и `https://rivapsy.com/sitemap-feeds.xml`. Это нужно и для поиска ChatGPT/Copilot. **Статус 2026-11-06 (повторная проверка):** метки `msvalidate.01` по-прежнему нет; подключить может только владелец аккаунта Bing (самый быстрый путь: «Import from Google Search Console», сайт в GSC уже подтверждён). **Обновление 2026-11-06:** сайт добавлен в Bing Webmaster, `sitemap.xml` принят (32 URL); `sitemap-feeds.xml` дал ошибку «Страница недоступна» (файл сам отдаётся с кодом 200, вероятно сработала защита DDoS-Guard) — отправить повторно или добавить три карты блога `sitemap-feed-<id>.xml` напрямую. **Итог 2026-11-06:** повторная отправка прошла, обе карты («Успешно»): `sitemap.xml` — 32 URL, `sitemap-feeds.xml` — 3 карты блога, всего 95 URL.
4. **Google Search Console:** сайт подтверждён. Добавить карту `sitemap-feeds.xml` (статьи блога) в «Sitemaps», если её там ещё нет.
5. **Яндекс.Вебмастер не подключён** (Tilda предлагает авторизацию). Где: Настройки сайта → SEO → «Яндекс.Вебмастер». **Статус 2026-11-06:** Tilda по-прежнему просит авторизацию (`yandexwebmaster_needregister: yes`); войти должна владелец аккаунта Яндекса. **Обновление 2026-11-06:** сайт подтверждён в Яндекс.Вебмастере, ошибок и дублей title/description нет; отправка карт отложена: инструмент «Файлы Sitemap» у Яндекса в режиме «Только для чтения» (сбой на их стороне). Повторить через 1–2 дня: `sitemap.xml` и `sitemap-feeds.xml`.
6. ~~**Редирект www → без www.** Где: Настройки сайта → «Домен» (или «Ещё» → перенаправления) → включить «Редирект с www на основной адрес».~~ **Сделано 2026-11-06** (через Tilda MCP, настройка проекта «redirect_wwwtodom»).
7. ~~**Нет meta description на трёх страницах SOS**~~ **Сделано 2026-11-06.** (`/crisis`, `/es/crisis`, `/en/crisis`). Где: Страница → Настройки → SEO → «Описание». Они важные, их стоит индексировать с понятным описанием.
8. ~~**Спорные страницы в карте** (`/chiwisemagic`, `/payment`, `/partners_type_of_attachment`): Страница → Настройки → «Доступ»/SEO → «Запретить индексацию» (названия могут отличаться); после этого Tilda уберёт страницу из карты сайта.~~ **Сделано 2026-11-06 иначе:** поля «запретить индексацию» в API нет, поэтому в head-код трёх страниц добавлен `<meta name="robots" content="noindex, follow">` (проверено на живых страницах). В карте сайта они пока остаются; чтобы убрать, нужна ручная галочка в настройках страницы Tilda.

**Низкая важность**
9. Нет `lang` в `<html>`; нет hreflang у пар support/privacy/crisis; у 22 статей длинные title; нет hreflang между переводами статей (необязательно).
10. Эпизодический 403 от DDoS-Guard при быстрой серии запросов: наблюдать.

### 2. Список адресов для отправки в Google и Bing

Только страницы, которые должны индексироваться. Служебные, юридические и старые страницы не включены. Страницы «Шапка» и «Подвал» закрыты и не включены.

```
# 1. Главные страницы
https://rivapsy.com/
https://rivapsy.com/en
https://rivapsy.com/es

# 2. Блог (списки статей)
https://rivapsy.com/blog
https://rivapsy.com/en/blog
https://rivapsy.com/es/blog

# 3. Наука
https://rivapsy.com/science
https://rivapsy.com/en/science
https://rivapsy.com/es/science

# 4. Страницы под запросы (RU, EN, ES)
https://rivapsy.com/dnevnik-emocij
https://rivapsy.com/en/emotion-diary-app
https://rivapsy.com/es/app-diario-emocional
https://rivapsy.com/trevoga-uprazhneniya
https://rivapsy.com/en/anxiety-exercises-app
https://rivapsy.com/es/app-ejercicios-ansiedad
https://rivapsy.com/nastroenie-telo-mysli
https://rivapsy.com/en/mood-body-thoughts-app
https://rivapsy.com/es/app-animo-cuerpo-pensamientos

# 5. Срочная помощь (SOS)
https://rivapsy.com/crisis
https://rivapsy.com/en/crisis
https://rivapsy.com/es/crisis

# 6. Статьи, RU (21)
https://rivapsy.com/tpost/egr41zzmt1-dnevnik-emotsii-smer-kak-zapisat-chto-vi
https://rivapsy.com/tpost/hs5hzpno81-12-lovushek-v-tvoei-golove
https://rivapsy.com/tpost/odttbfxza1-smer-poimat-misl-ot-kotoroi-stalo-ploho
https://rivapsy.com/tpost/gm5hbr19n1-osennyaya-handra-ili-depressiya-kak-pony
https://rivapsy.com/tpost/4mrycgku71-kogda-lyubaya-kritika-ranit-kak-viderzhi
https://rivapsy.com/tpost/phxlzfgf01-slozhno-viderzhivat-konflikti-chto-delat
https://rivapsy.com/tpost/27j2gu06k1-ya-okazalas-v-roli-lyubovnitsi-chto-dela
https://rivapsy.com/tpost/88rglk3831-menya-brosil-lyubimii-kak-perestat-nadey
https://rivapsy.com/tpost/1h9jhnyvb1-uprazhneniya-ot-trevogi-7-sposobov-uspok
https://rivapsy.com/tpost/6g8yxkgrz1-stesnyayus-svoego-tela-chto-delat-esli-d
https://rivapsy.com/tpost/le8ud6b2g1-len-ili-prokrastinatsiya-chto-delat-kogd
https://rivapsy.com/tpost/ejkryhv201-menya-besyat-kollegi-chto-delat-kogda-na
https://rivapsy.com/tpost/mp3r78im61-emotsii-v-perimenopauze-pochemu-to-slyoz
https://rivapsy.com/tpost/2y30bhzza1-uznat-sebya-zanovo-v-perimenopauze-kto-y
https://rivapsy.com/tpost/ypuhxuelt1-prilivi-bessonnitsa-i-tuman-v-golove-v-p
https://rivapsy.com/tpost/yscouu15l1-perimenopauza-i-blizkie-kak-pogovorit-s
https://rivapsy.com/tpost/u5jsn66031-kak-pomoch-sebe-v-perimenopauze-plan-na
https://rivapsy.com/tpost/tnysm3hjp1-bebi-blyuz-ili-poslerodovaya-depressiya
https://rivapsy.com/tpost/cm6o1l9xe1-poslerodovaya-depressiya-7-shagov-kotori
https://rivapsy.com/tpost/xjxbuam3y1-kak-podderzhat-mamu-s-poslerodovoi-depre
https://rivapsy.com/tpost/ki00f2ggi1-poslerodovaya-depressiya-kogda-nuzhen-vr

# 7. Статьи, EN (21)
https://rivapsy.com/tpost/ac0kjo37i1-dbt-skills-list-the-four-modules-explain
https://rivapsy.com/tpost/k2nuhbgdf1-cbt-thought-record-a-step-by-step-guide
https://rivapsy.com/tpost/037fcmxvr1-cognitive-distortions-12-thinking-traps
https://rivapsy.com/tpost/i256lk7as1-winter-blues-vs-seasonal-depression-how
https://rivapsy.com/tpost/ps5m3ji1z1-when-any-criticism-hurts-how-to-get-thro
https://rivapsy.com/tpost/z16byyn5e1-i-find-conflict-hard-what-to-do-when-peo
https://rivapsy.com/tpost/yxisfpmah1-im-the-other-woman-what-do-i-do
https://rivapsy.com/tpost/xlxjgmnmv1-he-left-me-how-do-i-stop-hoping-and-wait
https://rivapsy.com/tpost/v9xdi9lu71-anxiety-exercises-7-ways-to-calm-down-in
https://rivapsy.com/tpost/233tft4d71-ashamed-of-your-body-what-to-do-when-die
https://rivapsy.com/tpost/2hcjp2e871-laziness-or-procrastination-what-to-do-w
https://rivapsy.com/tpost/8t8rroz6a1-my-coworkers-drive-me-crazy-what-to-do-w
https://rivapsy.com/tpost/xrcneo2061-emotions-in-perimenopause-why-you-feel-s
https://rivapsy.com/tpost/vn8021xls1-getting-to-know-yourself-again-in-perime
https://rivapsy.com/tpost/t42513d3a1-hot-flashes-insomnia-and-brain-fog-in-pe
https://rivapsy.com/tpost/litftoi2i1-perimenopause-and-the-people-close-to-yo
https://rivapsy.com/tpost/5c8u57kxg1-how-to-help-yourself-in-perimenopause-a
https://rivapsy.com/tpost/240k68orn1-baby-blues-or-postpartum-depression-how
https://rivapsy.com/tpost/sl2ubju5u1-postpartum-depression-7-steps-that-help
https://rivapsy.com/tpost/zkpd2cix11-how-to-support-a-mother-with-postpartum
https://rivapsy.com/tpost/i3di42dzd1-postpartum-depression-when-to-see-a-doct

# 8. Статьи, ES (21)
https://rivapsy.com/tpost/diario_emocional
https://rivapsy.com/tpost/a85s2bd701-registro-de-pensamientos-plantilla-y-eje
https://rivapsy.com/tpost/7jxlbl7li1-distorsiones-cognitivas-las-12-ms-frecue
https://rivapsy.com/tpost/in2re55ng1-astenia-otoal-o-depresin-cmo-distinguirl
https://rivapsy.com/tpost/eiaoeld9p1-cuando-cualquier-crtica-duele-cmo-aguant
https://rivapsy.com/tpost/pbjmf36le1-me-cuesta-aguantar-los-conflictos-qu-hac
https://rivapsy.com/tpost/dtuon4yu81-soy-la-otra-qu-hago
https://rivapsy.com/tpost/2yzyio2hm1-me-ha-dejado-cmo-dejo-de-esperar-y-de-te
https://rivapsy.com/tpost/dzmihkg0j1-ejercicios-para-la-ansiedad-7-formas-de
https://rivapsy.com/tpost/z7uiuxh9o1-me-da-vergenza-mi-cuerpo-qu-hacer-cuando
https://rivapsy.com/tpost/mvp6yn5ny1-pereza-o-procrastinacin-qu-hacer-cuando
https://rivapsy.com/tpost/h5ixs0xj11-mis-compaeros-de-trabajo-me-sacan-de-qui
https://rivapsy.com/tpost/akai5htm81-emociones-en-la-perimenopausia-por-qu-to
https://rivapsy.com/tpost/t0ymrnuxs1-conocerte-de-nuevo-en-la-perimenopausia
https://rivapsy.com/tpost/eon5nrzl71-sofocos-insomnio-y-niebla-mental-en-la-p
https://rivapsy.com/tpost/pev8nsb501-perimenopausia-y-tus-seres-queridos-cmo
https://rivapsy.com/tpost/yk6i933ig1-cmo-ayudarte-en-la-perimenopausia-un-pla
https://rivapsy.com/tpost/0046hogta1-baby-blues-o-depresin-posparto-cmo-disti
https://rivapsy.com/tpost/6pgcdv0vy1-depresin-posparto-7-pasos-que-ayudan-a-l
https://rivapsy.com/tpost/6e2u0kth61-cmo-apoyar-a-una-madre-con-depresin-posp
https://rivapsy.com/tpost/gfm4yo5xf1-depresin-posparto-cundo-acudir-al-mdico
```

Итого: 84 адресов. Лимит Google на ручную отправку примерно 10–12 в сутки; важнее отправить карты сайта (`sitemap.xml` и `sitemap-feeds.xml`): по ним роботы найдут всё сами.

## GEO (оптимизация под ИИ-поиск), 2026-11-06
Сделано в Tilda и проверено на живых страницах:
- **`llms.txt` и `llms-full.txt`**: убраны фразы «нет собственного исследования» и «iOS не вышла», добавлено «100+ аудиопрактик», в `llms.txt` список 21 английской статьи, в `llms-full.txt` все 63 статьи (RU/EN/ES) с описаниями; блог описан с темой «женское здоровье».
- **JSON-LD `BlogPosting`** у всех 63 статей (заголовок, описание, картинка, дата публикации и изменения, автор Galina Egorova со ссылкой на `/payment`, язык, издатель). Добавляется скриптом в head, поэтому видна поисковикам после рендера страницы.
- **JSON-LD `WebPage`** (в сыром HTML) у `/science` и 9 сценарных страниц на трёх языках; **`Person` + `Service`** у `/payment`.
- Доступ ИИ-роботов (GPTBot, ClaudeBot, PerplexityBot, OAI-SearchBot, Google-Extended) открыт, код 200.
- Тексты для ASO (Google Play и App Store, RU/EN/ES) подготовлены в `docs/aso_geo_texts.md`; в консолях ничего не менялось.

Замечания: (1) на главных (RU, EN, ES) в блоке «Приватно и прозрачно» фраза «эффективность приложения ещё предстоит изучить» **заменена 2026-11-06** на вариант A («У каждой темы видны источники: на чём она основана и какие у неё границы»); оговорки «Чего приложение не делает» на сценарных страницах и раздел об исследованиях на `/science` оставлены по рекомендации (решение владельца: только главная). (2) Описания части сценарных страниц длиннее 160 знаков (143–185), заголовки хорошие; сокращение по желанию. (3) Разметка статей создаётся скриптом: роботы без выполнения JavaScript её не увидят.

Правка 2026-11-06: на `/science` (RU) в блоке «Исследования самого приложения» добавлено слово «Приложение» («Приложение RIVA PSY пока не оценивалось в опубликованном исследовании»); это не грамматическая ошибка, а смысловая неловкость, смысл не менялся.

## Новые статьи 2026-11-06: адреса для отправки на индексацию
Google Search Console «Проверка URL-адреса» → «Запросить индексирование», Bing «Проверка URL-адреса», Яндекс «Переобход страниц».
- Выгорание (RU): https://rivapsy.com/tpost/n43a5usu51-vigoranie-na-rabote-chto-delat-esli-net
- Выгорание (EN): https://rivapsy.com/tpost/29ybmycvl1-burnout-at-work-what-to-do-when-you-have
- Выгорание (ES): https://rivapsy.com/tpost/1la8tilt61-burnout-en-el-trabajo-qu-hacer-si-no-tie
- Паническая атака (RU): https://rivapsy.com/tpost/93ya3t5e31-panicheskaya-ataka-chto-delat-pryamo-sei
- Паническая атака (EN): https://rivapsy.com/tpost/zoe81g3fi1-panic-attack-what-to-do-right-now-and-wh
- Паническая атака (ES): https://rivapsy.com/tpost/ia8m51l801-ataque-de-pnico-qu-hacer-ahora-mismo-y-q
- Написать бывшему (RU): https://rivapsy.com/tpost/lpo0kb3yr1-tyanet-napisat-bivshemu-ili-bivshei-chto
- Написать бывшему (EN): https://rivapsy.com/tpost/m1e9bjayn1-you-want-to-text-your-ex-what-to-do-in-t
- Написать бывшему (ES): https://rivapsy.com/tpost/34f9faarx1-te-dan-ganas-de-escribir-a-tu-ex-qu-hace
- Заедание и вина (RU): https://rivapsy.com/tpost/6shkktxxb1-zaedanie-emotsii-i-chuvstvo-vini-posle-s
- Заедание и вина (EN): https://rivapsy.com/tpost/72x1hh59p1-emotional-eating-and-guilt-after-a-slip
- Заедание и вина (ES): https://rivapsy.com/tpost/peeb28bou1-comer-por-las-emociones-y-la-culpa-despu

Лимит Google на ручные запросы небольшой (порядка 10 в сутки): сегодня по одному адресу на тему (RU), остальные в ближайшие дни. Карты `sitemap-feeds.xml` уже содержат все 75 статей.

## Программа «Еда без автопилота» на сайте, 2026-11-12
По запросу сессии аудита приложения и с «да» владельца: на главных RU/EN/ES в блоке «Два режима» добавлено одно предложение про программу; в `llms.txt` добавлен раздел «Programs in the app» с одной строкой. Остальное не менялось. Проверено вживую. Сборка 1.0.9 (71) вышла (подтвердила владелица 2026-11-12), риск по сборке снят. Остаётся: программа «После расставания» по документу аудита только на русском (EN/ES-статьи про неё опубликованы как «доступна»), нужно подтвердить её выход на EN/ES.

2026-11-12 (продолжение): по «делай» владельца в блок «Два режима» главных RU/EN/ES добавлено второе предложение про программу «После расставания. Вернуться к себе» (EN: «After a breakup: coming back to yourself», ES: «Después de la ruptura: volver a ti»; это мои переводы названия, сверить с финальными названиями в приложении) и строка про неё в `llms.txt`. Программа на EN/ES в приложении ещё не вышла («скоро»): после выхода проверить названия и убедиться, что описание точное.


## 2026-11-14 — og-картинка главных страниц (старый логотип RIGEL PSY)

- Старый логотип был только в обложке для соцсетей (`og:image`) трёх главных страниц: `/`, `/en`, `/es` (файл `Pigel_PSY_App.png`). Остальные страницы используют макет без логотипа; у `/payment` обложка пустая (белая).
- Новая картинка с логотипом RIVA PSY: `docs/og/riva-psy-app-og.png` (1680×945), загружена в Tilda: https://static.tildacdn.com/tila3834-6231-4335-a163-373963336330/riva-psy-app-og.png
- Через API обложку страницы задать нельзя (`update_page_settings` игнорирует поле `img`), а мета-тег в head не перебьёт тег Tilda, стоящий выше. Ставит вручную: Настройки страницы → «Facebook и соцсети» → Изображение, для трёх страниц, затем публикация.
- После замены: превью в WhatsApp/Telegram кэшируются; для проверки отправить ссылку с `?v=2` или обновить кэш в Facebook Sharing Debugger.
- **Выполнено 2026-11-14:** обложка (вкладка «Бейджик» в настройках страницы) заменена на `riva-psy-app-og.png` на `/`, `/en`, `/es` через редактор Tilda (файл подставлен в поле загрузки), страницы опубликованы; `og:image` на живом сайте проверен. Остальные настройки страниц не менялись (сверено через API).
- Не тронуто: `/payment` (обложка `rigel_psy.jpg` — белый квадрат) и страницы с макетом без логотипа (`/science`, сценарные, support, privacy, terms). Названия файлов содержат «Rigel», но посетителю не видны.
- **`/payment` (2026-11-14):** обложка заменена с пустого белого `rigel_psy.jpg` на `riva-psy-app-og.png` (вкладка «Бейджик»), страница опубликована, `og:image` проверен на живом сайте. Мета-тега robots нет (слово «noindex» в коде — служебный комментарий Tilda вокруг формы оплаты), индексация и платёжная форма не затронуты, остальные настройки сверены через API.

## 2026-11-21: пять новых статей блога (15 постов RU/EN/ES)
Опубликованы по запросам «накручиваю себя», «не могу забыть бывшего», «виню и ненавижу себя», «нет сил», «заедаю стресс». Список, источники, проверки и инцидент с `llms.txt` (на несколько минут был пуст, восстановлен): `docs/blog_articles_2026-11-21.md`. Проверено вживую: 15 из 15 отдают 200, canonical, нет noindex, hreflang и `BlogPosting` на отрисованной странице, `llms.txt` и `llms-full.txt` содержат новые адреса. Остаётся ручная отправка адресов в GSC/Bing/Яндекс.

## 2026-11-21: пять новых статей блога (15 постов RU/EN/ES)
Опубликованы по запросам «накручиваю себя», «не могу забыть бывшего», «виню и ненавижу себя», «нет сил», «заедаю стресс». Список, источники, проверки и инцидент с `llms.txt` (на несколько минут был пуст, восстановлен): `docs/blog_articles_2026-11-21.md`. Проверено вживую: 15 из 15 отдают 200, canonical, нет noindex, hreflang и `BlogPosting` на отрисованной странице, `llms.txt` и `llms-full.txt` содержат новые адреса. Остаётся ручная отправка адресов в GSC, Bing и Яндекс.

## 2026-11-22: длинные тире убраны с сайта (по поручению владельца: «убирай везде и не пиши с ним»)
- Правило: в текстах нет «—» и «–». Замены по смыслу: «X это Y» без тире, двоеточие для пояснений, запятая или скобки для вставок, дефис в диапазонах (1-6, 10:00-20:00, 5-4-3-2-1, если-то), в заголовках страниц « | RIVA PSY» и «Rivapsy: ...».
- Изменено: 49 постов блога (RU/EN/ES), настройки и head-код 19 страниц (заголовки и описания для поиска и соцсетей, JSON-LD), 38 блоков и 5 зеро-блоков на страницах (главные, наука, посадочные, SOS/crisis, privacy, terms, support, payment, оферта), `llms-full.txt`. Все затронутые страницы переопубликованы. Проверено вживую: 120 адресов (все посты и все страницы) без длинных тире в видимом тексте, `llms.txt` и `llms-full.txt` без тире и отдают 200.
- Не удалось: два квиза («Мой тип привязанности», «Тип привязанности партнера», страницы 69034243 и 69040143, блок «квиз», 13 тире в вопросах и подписях шкал). Инструмент записи не сохраняет список вопросов этого блока (ответ OK, но значения не меняются), править нужно в редакторе Tilda вручную.
- Не тронуто: тексты приложения в репозитории (translations, courses: около 300 строк с тире), код и старые заметки в docs.
- Технически: Tilda при сохранении поста или настроек страницы удваивает HTML-сущности (`&laquo;` превращается в `&amp;laquo;`), поэтому такие поля отправлялись уже без сущностей; результат сверен чтением обратно.
- 2026-11-22: владелица сообщила, что программа «После расставания. Вернуться к себе» уже вышла на испанском. Для статей RU/ES это снимает оговорку; на EN программа ещё не вышла (проверить, прежде чем просить индексацию EN-статей про неё).

## 2026-11-22: название «Rigel PSY» заменено на «RIVA PSY» на сайте
- Заменено в видимых текстах: заголовки блоков на главных RU/EN/ES («RIGEL PSY» над подзаголовком), /payment (заголовок блока и текст об авторе), пользовательское соглашение /terms (название везде, описание страницы), согласие в форме оплаты.
- Старый домен `rigelpsy.ru` недоступен, поэтому ссылки и адрес поддержки в /terms, /responsibility и в форме оплаты заменены на `rivapsy.com` и `support@rivapsy.com`.
- Исправлена битая кнопка Google Play на главных RU/EN/ES: вела на `com.rigel_psy.app` (404), теперь `com.riva_psy.app`.
- Страницы переопубликованы, на живом сайте в видимом тексте «Rigel» не осталось (вживую проверено 32 адреса), в приложении в пользовательских строках «Rigel» нет.
- Осталось: (1) /support, согласие в контактной форме ссылается на `http://rigelpsy.ru/privacy` (мёртвый домен): список полей этого блока API не сохраняет, править нужно в редакторе Tilda; (2) квиз «Мой тип привязанности», ссылка результата `rigelpsy.ru/partners_type_of_attachment` (не видна на странице, в скрипте блока), та же причина; (3) кнопки RuStore, Xiaomi и Nashstore на главных ведут на старые карточки приложения `com.rigel_psy.app` (на RuStore она называется «Психология. Отношения Rigel PSY»): решение за владелицей; (4) имена файлов картинок (Rigel_psy.png, Rigel_PSY_.png и др.) содержат «Rigel», посетителям не видны, сами картинки без старого названия (логотип «R» общий).
