# Программа «Еда без автопилота» (EN/ES): тексты для сторов и сайта

Подготовлено 2026-11-12. **Ничего не опубликовано**: в консолях Google Play / App Store Connect и на Tilda не менялось. Выкладывать в день, когда новая сборка с EN/ES-версией курса уже доступна пользователям, иначе описание обещает то, чего в приложении ещё нет.

Факты, на которых стоят тексты (проверено в коде 2026-11-12): курс из 8 шагов, в каждом аудио, короткое задание и мини-практики; инструменты «Сильный импульс» и «Была ситуация» (в EN «Strong urge» / «It happened», в ES «Impulso fuerte» / «Ya pasó»); первые два шага бесплатны, остальные по подписке Orion; перед началом короткий опрос безопасности; без диет и подсчёта калорий; приложение не лечит.

**Важно про второй курс.** «После расставания. Вернуться к себе» сейчас только на русском (`languages: ["ru"]` в `assets/courses/return_to_self.json`): в EN/ES он в приложении не показывается. Поэтому в EN/ES-текстах он не упомянут.

## Google Play и App Store: что добавить в полное описание

Вставить пункт в список «ЧТО ВНУТРИ» после «Хлебных крошек», а в блок «ВАЖНО» добавить предложение про питание. Остальное (название, короткое описание, subtitle) не менять.

### RU

Пункт в «ЧТО ВНУТРИ»:
• Программа «Еда без автопилота»: 8 шагов о переедании без диет и подсчёта калорий. В каждом шаге аудио, короткое задание и кнопка «Сильный импульс» для трудных минут. Первые два шага бесплатны

Добавить в конец «ВАЖНО»:
Программа о переедании это самопомощь, а не лечение расстройств пищевого поведения. Если после еды вы вызываете рвоту, голодаете или быстро теряете вес, обратитесь к специалисту.

### EN

Bullet under "WHAT'S INSIDE":
• Program "Eating Without Autopilot": 8 steps on overeating, with no diets or calorie counting. Each step has an audio, a short task and a "Strong urge" tool for hard moments. The first two steps are free

Add to the end of "IMPORTANT":
The overeating program is self-help, not treatment for eating disorders. If you make yourself vomit, fast or lose weight quickly, please see a specialist.

### ES

Punto en «QUÉ HAY DENTRO»:
• Programa «Comer sin piloto automático»: 8 pasos sobre los atracones, sin dietas ni contar calorías. Cada paso incluye un audio, una tarea breve y la herramienta «Impulso fuerte» para los momentos difíciles. Los dos primeros pasos son gratis

Añadir al final de «IMPORTANTE»:
El programa sobre los atracones es autoayuda, no un tratamiento de los trastornos de la conducta alimentaria. Si te provocas el vómito, ayunas o pierdes peso rápidamente, acude a un especialista.

### Ключевые слова App Store (по желанию)

В EN-списке (97/100 знаков) слово `meditation` (10 знаков) можно заменить на `overeating` (10 знаков), длина не изменится. Менять только если «meditation» не приносит показов.

## Сайт rivapsy.com

Конкретные программы на главных страницах пока нигде не названы: там есть только общие слова «follow the program». Предлагаю одну правку на каждой из трёх главных страниц, в блоке «Два способа пользоваться» (EN: "Two ways to use it", текущий текст «Follow the program step by step, or play a single audio in a hard moment.»):

- RU: к текущему тексту добавить предложение: «Например, программа «Еда без автопилота»: 8 шагов о переедании, без диет и подсчёта калорий».
- EN: add: "For example, the program "Eating Without Autopilot": 8 steps on overeating, with no diets or calorie counting."
- ES: añadir: «Por ejemplo, el programa «Comer sin piloto automático»: 8 pasos sobre los atracones, sin dietas ni contar calorías.»

Дальше в `llms.txt` (раздел про приложение) одна строка:
`- Step-by-step program "Eating Without Autopilot" (8 steps on overeating, with audio and short tasks; Russian, English, Spanish). Self-help, not treatment.`

Опционально, если захочешь SEO-эффект: отдельная страница-сценарий «Эмоциональное переедание» в формате трёх существующих (RU/EN/ES) со ссылкой на статью блога «Заедание эмоций и чувство вины после срыва» и на программу. Сейчас такой страницы нет.
