# My Communication Academy

A Flutter course catalog built against the provided fake API: debounced search, category filters, pull-to-refresh, course details and lesson access based on enrollment and preview flags.

## Run

Flutter 3.47.7 stable (Dart 3.13.5), Android emulator.

```sh
flutter pub get
flutter run
```

The app uses the default `FakeCourseApi()`, so some failures are expected: searching `fail` fails, every fifth catalog request fails, Python details fail on the first attempt and Optical Fiber details return 404.

## Check

```sh
flutter analyze
flutter test
```

Device flow on an emulator:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/assessment_test.dart -d <device-id>
```

## Extras

- English/Arabic with RTL, remembered between launches together with the last search and category.
- Last successful catalog is shown on startup when it matches the restored search.
- List and detail side by side from 840 logical pixels.
- Semantics labels and no overflow at text scale 1.5.

See [NOTES.md](NOTES.md) for decisions and [REVIEW.md](REVIEW.md) for the code review.
