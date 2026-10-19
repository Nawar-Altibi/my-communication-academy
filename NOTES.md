# NOTES

## How to run
- Flutter 3.47.7 stable / Dart 3.13.5 for `flutter analyze` and `flutter test`. The app also builds with 3.41.6 (Dart 3.11.4), which is what I have installed locally.
- Tested on a physical Samsung Galaxy A55 and on an Android 16 (API 36) emulator.
- `flutter pub get`, then `flutter run`. Tests: `flutter test`. There's also a device flow in `integration_test/` (command in the README).

## Structure
`lib/provided` holds the fake API, unchanged. `lib/data` wraps it in a small repository that parses the JSON into my own models and turns `ApiException` into a `CourseFailure` (404 = course gone, everything else = temporary). `lib/state` has two `ChangeNotifier` controllers, one for the catalog and one per opened course. `lib/ui` only renders controller state, so none of the widgets ever see raw JSON.

I went with plain `ChangeNotifier`. For two screens it felt like enough, and it keeps the logic easy to test without widgets.

Packages I added: `intl` + `flutter_localizations` (Arabic/English, dates, currency), `shared_preferences` (remembering the last search/category/language and the last catalog). Dev: `flutter_lints`, `integration_test`.

## Data-handling decisions
- **Skipped:** the `"corrupted-row"` string, c-104 (no title) and `109` (numeric id). A card with no title or no stable id isn't something a learner can use.
- **Duplicates:** c-101 appears twice, and I keep the first one. That leaves 8 courses.
- **c-103 price `"39.00"`:** parsed as a number. A price of `0` shows "Free".
- **Unknown values:** category `quantum` shows as "Other" (only under All), and level `expert` shows as "Unspecified". I'd rather show the course than hide it.
- **Out-of-range values:** c-107 duration `-1` and the ratings `9.2` and `null` show as "unavailable". I didn't clamp them because clamping would show a value that never came from the API.
- **Images:** a missing or broken thumbnail shows a fixed-size placeholder, so the card height doesn't jump.
- **Detail:** a missing instructor or an empty description gets an explicit "unavailable" text.
- **Lessons:** a lesson with no title becomes "Lesson 4" (its position). A missing duration stays unknown instead of 0, so c-101 shows "43 min known · 1 lesson duration unavailable" rather than a wrong total. `"600"` as a string is accepted.
- **c-103 `isPreview: "yes"`:** not treated as preview. Only a real `true` unlocks a lesson, because guessing in the learner's favour on access felt wrong.
- **c-111 has no `lessons` field:** treated as an empty list, so it gets the empty-lessons state.
- **Broken envelope** (no `data` list): shown as an error, not as "no courses".

## Search and async behavior
Search is debounced by 300 ms. Category, clear and retry go out immediately. Each time the criteria change I bump a counter, and a response only gets applied if its counter is still the current one. That way the slow "n" response can't land after "net", and a late failure can't overwrite newer results either. When a new search fails I show the error state and hide the old list, because the old results no longer match what's typed.

Pull-to-refresh is different: if it fails, the current list stays and a SnackBar says the refresh didn't work. Both controllers ignore anything that completes after `dispose`, which covers pressing back while a course is still loading.

## Trade-offs and limitations
- The API futures can't be cancelled, only ignored when they come back.
- The detail opens inside the catalog page (full screen on phones, side panel on tablets) instead of as a pushed route. I did it this way so the tablet layout keeps the selection, but on phones it means there's no route transition.
- The offline cache only keeps the last catalog list, not images or details. Since the fake API is local, turning off Wi-Fi doesn't break it, so I tested offline with a failing repository in tests.
- Course content isn't translated; only the app UI is.
- I checked text scale 1.5 and RTL, but I haven't done a real TalkBack pass.

## With more time
1. Cache course details too, with some expiry rule.
2. Use a real route for the detail on phones and keep the side panel for tablets.
3. A proper accessibility pass with TalkBack.

## AI tool use
I used OpenAI Codex quite a lot as a pair programmer: planning the structure, writing the first versions of the parser, controllers and most tests, and drafting parts of REVIEW.md. Near the end I used Cursor to check the work against the brief and to tidy up the UI (app bar, language button, cards, lesson list).

What I changed or rejected:
- I kept plain `ChangeNotifier` instead of bringing in Bloc or Riverpod.
- I didn't accept treating `"yes"` as preview access or counting unknown durations as 0.
- I dropped extra tooling it produced (an emulator CI workflow and a Windows run script) because it was more than this task needed.

## Time spent
About 2 h 50 min in total: Part A ~2 h, Part B ~25 min, Part C ~25 min.
