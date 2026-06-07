# AGENTS — Quickstart for AI coding agents

Purpose: give an AI coding agent the minimal, actionable knowledge to be productive in this Flutter app (Miraiku). Focused, code-location-based guidance so a model can make safe edits and run the project.

1) Big-picture architecture (what touches what)
- Single Flutter app (lib/main.dart) composed of four major feature areas: learn, simulation, kana, profile under `lib/features/`.
- `lib/core/` contains cross-cutting services: `game_manager.dart` (global state + persistence + cloud sync), `notification_service.dart` (local notifications / timezone), `sound_manager.dart` (audio playback). These are singletons / global notifiers used throughout the UI.
- Auth + cloud persistence is handled by Supabase's Auth user metadata (not a separate DB table). See `lib/main.dart` (Supabase.initialize) and `lib/core/game_manager.dart` (syncToCloud, _updateLocalStateFromMeta).
- UI pattern: many screens are stateful widgets and read/write global state via ValueNotifiers defined in `game_manager.dart` (e.g. `globalHearts`, `globalXP`, `globalLanguage`, `globalDarkMode`). There is no separate provider/riverpod architecture in this codebase.

2) Critical conventions & patterns to follow (code changes must respect these)
- Persistent keys: SharedPreferences keys are deliberate and important. Look for prefixes:
  - gm_ for game-global keys (gm_hearts, gm_xp, gm_last_login, etc.)
  - u1_, u2_, u3_, u4_ for unit progress keys (GameManager scans prefs keys starting with these prefixes)
  - learned_hiragana_list / learned_katakana_list / learned_kanji_list for learned sets
  - setting_dark and setting_lang mirror globalDarkMode/globalLanguage
- Cloud sync model: user metadata (Supabase) is the canonical cloud store. Edits should use `Supabase.instance.client.auth.updateUser(UserAttributes(data: {...}))` (see `GameManager.syncToCloud`). Avoid introducing alternate cloud-sync flows without updating `syncToCloud` and `_updateLocalStateFromMeta` in `game_manager.dart`.
- Anti-rollback pattern: when applying cloud values the app prefers the larger XP or a non-empty local for safety (see comments and logic in `_updateLocalStateFromMeta`). Preserve that logic when editing state merging.
- UI translations: minimal bilingual support done inline. Many screens use a local helper `_t(en, id)` (example in `lib/features/login/screen_auth.dart`) and `globalLanguage` notifier. Prefer keeping that pattern for small strings.
- Sound & notifications toggles saved in SharedPreferences under `setting_sound` and `is_daily_reminder_on` — changing keys needs coordinated updates across `sound_manager.dart`, `notification_service.dart`, and UI settings screens (`lib/features/profile/screen_settings.dart`).

3) Integration points & external dependencies to be mindful of
- Supabase: initialization in `lib/main.dart` (hard-coded url and anonKey). Any agent editing auth or keys should not leak secrets; treat the anonKey and web client IDs found in code as sensitive and prompt a human if you must change them.
- Google Sign-In: `lib/features/login/screen_auth.dart` contains a web client id and sign-in flow. Tests or CI that run headless will not be able to fully exercise Google sign-in flows.
- flutter_local_notifications + timezone: scheduled notifications rely on timezone initialization in `notification_service.dart`. When adding tests, avoid actually scheduling system notifications — mock or short-circuit `requestPermissions()` and `scheduleDailyStudyReminder()`.
- Audio: `audioplayers` plays assets at `assets/audio/...`. See `pubspec.yaml` assets section. When running on CI, audio playback may fail — wrap calls or use the existing try/catch in `sound_manager.dart`.

4) Developer workflows & useful commands
- Install deps: `flutter pub get`
- Run app (connected device or windows desktop): `flutter run` or `flutter run -d windows` or `flutter run -d <emulator-id>`
- Build release APK: `flutter build apk --release`
- Analyze and lints: `flutter analyze` (project uses `flutter_lints` configured in `analysis_options.yaml`)
- Tests: `flutter test` (there is a `test/widget_test.dart`) — many UI flows rely on platform plugins (Supabase, notifications) and may need mocking.

5) Files to open first for most tasks
- `lib/main.dart` — app entrypoint, Supabase init, navigatorKey, root MaterialApp and auth gating
- `lib/core/game_manager.dart` — global ValueNotifiers, sync rules, SharedPreferences keys and important logic (streaks, heart regen, addXP, syncToCloud)
- `lib/features/login/screen_auth.dart` — auth flows, Google Sign-in, examples of language/theme toggles and SharedPreferences writes
- `lib/core/notification_service.dart` — notification scheduling details and timezone handling
- `pubspec.yaml` — dependencies and assets list
- `assets/` folders — image/audio assets referenced from code

6) Safe edit checklist for an agent before changing behavior that affects users
- If you change a SharedPreferences key name, update every place the key is read/written (game_manager, sound_manager, auth screen, settings). Prefer adding a single constant in `game_manager.dart` if you must rename.
- If you change cloud sync shape (metadata keys), update both `_updateLocalStateFromMeta` and `syncToCloud` to remain symmetric.
- Do not change hard-coded Supabase keys or Google client IDs without human approval. Flag them and create a TODO referencing secure storage.
- When adding tests, mock Supabase auth and platform-specific plugins (notifications, google_sign_in, audioplayers).

7) Quick examples from repo (copy/paste ready)
- Read current XP and safely increment:
  - See: `GameManager.addXP(int amount)` in `lib/core/game_manager.dart` — updates `globalXP` + SharedPreferences then calls `syncToCloud()` if user logged in.
- Schedule notification only when user preference is on:
  - See: `main()` in `lib/main.dart` lines ~42-46: reads `is_daily_reminder_on` from prefs and schedules only if true.
- Avoiding rollback when applying cloud XP:
  - See `_updateLocalStateFromMeta` in `lib/core/game_manager.dart` lines ~60-70 where cloud XP is applied only if it's greater than local or local is zero.

8) When you need clarification from a human
- Any credential/key change (Supabase anonKey, Google client id) — ask a human.
- If the requested feature needs a new persistent key or new cloud field — ask whether it should live in Supabase user metadata or a new table.

End of file.

