# My Communication Academy

A Flutter course catalog built against the supplied fake API. It includes debounced search, category filters, refresh recovery and lesson access based on enrollment and preview flags.

## Run

Use Flutter **3.47.7 stable** (Dart **3.13.5**) and an Android emulator.

```sh
flutter pub get
flutter run
```

The app deliberately uses the default API failures. Searching `fail` fails; the fifth catalog request fails; Python details fail on the first attempt; Optical Fiber details return 404. These are expected assessment cases.

## Check

```sh
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib/main.dart lib/data lib/state lib/ui test integration_test test_driver
flutter build apk --debug
```

The supplied API is excluded from formatting to preserve its original bytes. Its SHA-256 is checked in CI.

Run the Android acceptance flow and capture screenshots:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/assessment_test.dart -d <android-device-id>
```

## Additional behavior

- English/Arabic UI, local fonts and RTL.
- Screen-reader labels, usable locked-lesson explanations and scalable text.
- Last successful catalog saved with its query, category and timestamp; it is used at startup only when the restored criteria match.
- Search, category and language remembered between launches.
- List/detail side by side from 840 logical pixels; the selected detail survives resizing.

The fake API is local: disabling Wi-Fi does not make it fail. Offline fallback is tested using a failing repository double. Cached images and offline detail access are outside scope.

See [NOTES.md](NOTES.md) for decisions and verification, [REVIEW.md](REVIEW.md) for the provided-widget review, and [the Arabic walkthrough](docs/INTERVIEW_GUIDE.ar.md) for interview preparation.

## Screenshots

Screenshots captured by the Android integration driver are saved to `docs/screenshots/`.
