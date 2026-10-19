# NOTES

## How to run
Flutter 3.47.7 stable / Dart 3.13.5. Tested on an Android emulator (API 36, Pixel 2 profile).
`flutter pub get`, `flutter run`, `flutter analyze`, `flutter test`. The device flow is in `integration_test/` (see README).

## Structure
Provided API → `ApiCourseRepository` (JSON parsing into typed models, API errors mapped to `CourseFailure`) → `ChangeNotifier` controllers (`CatalogController`, `DetailController`) → widgets. The UI never touches raw JSON. One API instance is shared so its default failure counters behave as in production.

Packages: `flutter_localizations` + `intl` for English/Arabic strings, dates and currency; `shared_preferences` for the saved catalog and last search/category/language; `flutter_lints` for lint rules; `integration_test` for the device flow.

## Data-handling decisions
- Non-map rows, missing/blank titles and non-string IDs (`109`) are skipped: a card without a real title or stable ID is not useful.
- Duplicate IDs: keep the first valid record (8 courses remain).
- Price: numbers and numeric strings (`"39.00"`) are accepted; `0` is shown as Free.
- Unknown category (`quantum`) → shown as "Other" under All; unknown level (`expert`) → "Unspecified".
- Negative durations and ratings outside 0–5 (`9.2`) or `null` → "unavailable", not clamped, so no fake value is shown.
- Missing or broken thumbnail → fixed-size placeholder, layout does not move.
- Missing instructor / blank description → explicit "unavailable" text.
- Lesson without a title → "Lesson N" from its position; lesson without a duration → unknown, not zero. Integer duration strings (`"600"`) are accepted.
- Only boolean `true` grants preview or enrollment; `"yes"` does not.
- Missing `lessons` → empty state; corrupt, duplicate or ID-less lesson rows are skipped.
- Invalid response envelope → error state, never an empty list.
- c-101 total shows 43 known minutes plus "1 lesson duration unavailable" instead of a misleading total.

## Search and async behavior
Typing is debounced (300 ms); filter, clear and retry fire immediately. Every criteria change bumps a generation counter before the next request, and a response is applied only if its generation is still current, so slow responses for "n"/"ne" can never replace "net". A failed new search shows the error state (old results are hidden because they no longer match). A failed pull-to-refresh keeps the current list and shows a SnackBar. Controllers ignore results after `dispose`, so leaving a screen early is safe.

On startup the last query/category/language are restored; a saved catalog is shown (with its date) only if it matches the restored criteria, and a fresh request is always sent.

## Trade-offs and limitations
- API futures cannot be cancelled, only ignored.
- Detail is shown inside the catalog page (overlay on phones, side panel from 840 px) instead of a pushed route, so the tablet layout can keep the selection.
- The cache stores only the last successful list, not images or details. The fake API is local, so offline is tested with a failing repository double.
- No video, login or enrollment flow; course titles and descriptions are not translated.
- RTL and text scale 1.5 are covered by tests; no manual TalkBack session yet.

## With more time
1. Cache course details with a clear expiry policy.
2. More end-to-end device tests.
3. Accessibility review with a screen-reader user.

## AI tool use
I used OpenAI Codex for planning, much of the implementation and the tests, and Cursor for a final review and small UI polish (AppBar, language button, card and lesson styling).
Changed or rejected: kept plain `ChangeNotifier` instead of adding a state-management package; rejected coercing `"yes"` into preview access and counting unknown durations as zero.

## Time spent
Part A: ~ h · Part B: ~ min · Part C: ~ min (fill in before sending).
