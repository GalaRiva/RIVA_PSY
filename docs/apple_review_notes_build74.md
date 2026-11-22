# Notes for Review для следующей iOS-сборки (1.0.9, 74)

Вставлять в App Store Connect, поле «Notes for Review». Цель: ревьюеру нечего уточнять (2.1(a), 2.3.1(a)). Пароль тестового аккаунта подставь сама.

```
RIVA PSY is a self-help and psychological education app (not a medical device and not a substitute for professional care). It helps people work through one problem at a time (emotions, anxiety, a breakup, eating habits, low mood) using audio practices, short written exercises, a private diary and step-by-step programs.

HOW TO TEST
- The app works without registration. An account is requested only when a feature needs one (for example a subscription).
- Test account with an active Orion subscription for premium content: [email of the QA account], password: [password].
- Sign in with Apple and Google sign-in are both offered.
- Account deletion: Settings > Profile > Delete account. For accounts created with Sign in with Apple the app revokes the Apple token on deletion.

SUBSCRIPTIONS
- Orion Monthly and Orion Yearly (one subscription group, "Orion"). Purchased only through In-App Purchase. Restore Purchases is on the subscription screen. Terms of Use and Privacy Policy are linked next to every purchase button.
- Free content: the first steps of each program, all emergency tools and the help page. Programs: "After the breakup. Return to yourself", "Eating without autopilot", and "Melancholia" (12 weeks of skills for hard states, a complement to professional help, not a treatment).
- There are no promo or gift codes on iOS, no links to external payment, and no countdown discounts on iOS.

NEW SINCE THE PREVIOUS SUBMISSION
- A "Practices" home screen that groups all emotion practices, audio, written exercises and programs on one page.
- The program "Melancholia" (Russian and Spanish), 12 weeks, one step per week recommended, with required reading cards and a daily "On every day" card built from the user's own diary entries (stored on the device only).
- Mood chart colors, calendar period picker, localization fixes (English, Spanish, Russian).
- The paid consultation with the author (Russian only, booked on an external page) is NOT available on iOS.

HEALTH AND SAFETY
- A disclaimer ("does not diagnose or treat, not a substitute for a doctor or psychologist") appears on the main screens and next to purchases. Sources for program content are listed in the app (Settings > Sources) with links.
- "I'm struggling right now" screens and the About screen link to a help page and show the emergency number 112.

TECHNICAL EXPLANATIONS
- NSAllowsArbitraryLoads is enabled only so the audio player can stream remote practices through a local loopback proxy (http://127.0.0.1) for caching and offline playback. Without it, streaming stopped working in a test build.
- Background modes: "audio" for practice playback and lock screen controls; "fetch" and "processing" for scheduling the user's own local reminders and a nightly on-device analysis of the user's own diary that produces a local notification. No data is sent anywhere by these tasks.
- Camera, location and Bluetooth strings exist only because third-party plugins reference these APIs. The app never requests these permissions. The microphone is used only for optional voice notes in the diary. The photo library is used only when the user attaches an image to a report.
- No advertising, no tracking, no analytics SDKs. Diary content stays on the device.

Contact for questions: support@rivapsy.com
```
