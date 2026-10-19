# My Communication Academy

Course catalog and course detail screens for the My Communication Academy Flutter assessment, built on top of the provided `FakeCourseApi`.

## Running it

```sh
flutter pub get
flutter run
```

The app uses the default `FakeCourseApi()`, so a few failures are on purpose:
- searching "fail" always errors
- every 5th catalog request fails
- "Python for Network Engineers" fails the first time you open it
- "Optical Fiber Transmission Systems" returns 404

## Tests

```sh
flutter analyze
flutter test
```

The device flow (runs through most of the acceptance checks on a real device or emulator):

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/assessment_test.dart -d <device-id>
```

## Extras

- Arabic/English with RTL. The language, last search and category are remembered.
- The last loaded catalog is shown on startup while fresh data loads.
- Side-by-side list and detail on tablets.

Decisions and trade-offs are in [NOTES.md](NOTES.md), and the code review is in [REVIEW.md](REVIEW.md).
