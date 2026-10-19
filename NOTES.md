# NOTES

## How to run
Run `flutter pub get`, `flutter run`, `flutter analyze`, and `flutter test`.
Flutter 3.47.7 stable / Dart 3.13.5. Android API 36; final device-run results are in docs/VALIDATION.md. Initial scaffolding used the installed 3.41.6 SDK, then an isolated current stable SDK was installed for validation.

## Structure
Provided API → repository/typed parsing → ChangeNotifier controllers → widgets. One API instance retains its default failure counters. Packages: flutter_localizations (SDK translations), intl (generated localization/date/currency formatting), shared_preferences (non-critical local snapshot/preferences); flutter_lints (lint rules), flutter_test and integration_test (regression/device tests).

## Data-handling decisions
Skip non-map rows, absent/blank titles and non-string/blank IDs; keep the first valid duplicate (8 catalog records). Parse numeric prices including strings; zero is Free. Unknown category → Other under All; unknown level → Unspecified. Negative/non-finite durations/prices and ratings outside 0–5 → unavailable, not clamped. Missing/broken images → fixed-size placeholder. Missing instructor/blank description → explicit unavailable text. Missing lesson title → its numbered position; missing duration → unknown, not zero. Integer duration strings are accepted. Only boolean true grants preview/enrollment; `"yes"` does not. Missing lessons → empty; corrupt/duplicate/ID-less lesson rows are skipped. Invalid response envelope → error. Detail totals use lesson durations; c-101 has 43 known minutes and one unknown duration.

## Search and async behavior
300 ms debounce; filter/clear/retry are immediate. Generations invalidate earlier responses before the next debounce fires. New-query failure shows error; refresh failure retains matching results with a non-blocking message. Disposal invalidates work. Startup restores query/category/language and only a matching snapshot, visibly dated, then always requests fresh data. Serialized best-effort writes preserve newer preferences; storage failures never block browsing.

## Trade-offs and limitations
Small models/controllers; API Futures cannot be cancelled, only invalidated. No video, authentication, enrollment or invented course translations. Cache stores the last successful list, not images/details/access rights; the local API needs a failing test double to simulate offline. Tablet breakpoint: 840 logical pixels. Local fonts, RTL and text scale 1.5 are covered; manual spoken TalkBack evaluation is not claimed. Android builds retain supported template Gradle/AGP/Kotlin versions; Flutter warns their support will end in a future release.

## With more time
1. Detail caching with an explicit validity policy.
2. Broader Android end-to-end UI automation.
3. Accessibility review with a screen-reader user.

## AI tool use
OpenAI Codex assisted planning, implementation, tests and this review. Chose built-in ChangeNotifier instead of a larger state-management dependency; rejected coercing `"yes"` into access permission and representing unknown durations as zero. The candidate must review and understand the submission before sending it.

## Time spent
Implementation began 2026-10-19 at 18:35 UTC. Final elapsed time and allocation to Parts A/B/C will be recorded after verification; planning preceded this implementation session. No artificial time limit or backdated commits are claimed.
