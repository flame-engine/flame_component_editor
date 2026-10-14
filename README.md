# Flame Component Editor

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]

A Flutter desktop app (macOS, Windows, Linux) to create
[Flame](https://flame-engine.org) components visually.

## Getting started

```sh
flutter pub get
flutter run -d macos   # or windows / linux
```

## Development

```sh
flutter analyze
dart format lib test
flutter test --coverage --test-randomize-ordering-seed random
```

The project follows the
[VGV layered architecture](https://engineering.verygood.ventures/architecture/architecture/).
See [`docs/`](docs/) for architecture, conventions, testing and CI details, and
[`CLAUDE.md`](CLAUDE.md) for the agent guide.

[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
