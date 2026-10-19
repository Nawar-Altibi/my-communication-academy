# NOTES

## How to run
Run `flutter pub get`, `flutter run`, `flutter analyze`, and `flutter test`.
Initial development SDK: Flutter 3.41.6 / Dart 3.11.4; final SDK and device validation will be recorded after verification.

## Structure
Provided API → repository/typed parsing → ChangeNotifier controllers → widgets. One API instance retains its default failure counters. No backend or enrollment flow.

## Data-handling decisions
Skip non-map rows, absent/blank titles and non-string/blank IDs; keep the first valid duplicate (8 catalog records). Parse numeric prices including strings; zero is Free. Unknown category → Other under All; unknown level → Unspecified. Negative/non-finite durations/prices and ratings outside 0–5 → unavailable, not clamped. Missing/broken images → fixed-size placeholder. Missing instructor/blank description → explicit unavailable text. Missing lesson title → its numbered position; missing duration → unknown, not zero. Integer duration strings are accepted. Only boolean true grants preview/enrollment; `"yes"` does not. Missing lessons → empty; corrupt/duplicate/ID-less lesson rows are skipped. Invalid response envelope → error. Detail totals use lesson durations; c-101 has 43 known minutes and one unknown duration.

## Search and async behavior
300 ms debounce; filter/clear/retry are immediate. Generations invalidate earlier responses as soon as criteria change, including before the debounce fires. New-query failure shows error; same-query refresh failure retains results and reports a non-blocking failure. Disposed controllers ignore completions.

## Trade-offs and limitations
Small explicit models/controllers rather than extra architectural layers. API Futures cannot be cancelled; their UI effects are invalidated. No video, authentication, enrollment or invented translated course content.

## With more time
1. Detail caching with an explicit validity policy.
2. Broader Android end-to-end UI automation.
3. Accessibility review with a screen-reader user.

## AI tool use
OpenAI Codex assisted planning, implementation, tests and this review. Chose built-in ChangeNotifier instead of a larger state-management dependency; rejected coercing `"yes"` into access permission and representing unknown durations as zero. The candidate must review and understand the submission before sending it.

## Time spent
Implementation began 2026-10-19 at 18:35 UTC. Final elapsed time and allocation to Parts A/B/C will be recorded after verification; planning preceded this implementation session. No artificial time limit or backdated commits are claimed.
