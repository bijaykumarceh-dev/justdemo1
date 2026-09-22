# Study Tracker

Study Tracker is a Flutter app for organizing study subjects, tracking focus time, and practicing with flashcards and quizzes.

## Features

- Add, edit, rename, complete, and delete study subjects
- Track completed hours and average study time
- Stopwatch and Pomodoro timers
- Flashcards with answer reveal and known-status tracking
- Quiz mode with score tracking
- Study streaks, reminders, groups, cloud-sync, export, audio-notes, and location views
- Material 3 interface with light and dark system themes
- Runs on Android, web, Windows, macOS, Linux, iOS, and Android-compatible Flutter targets

## Requirements

- Flutter stable channel
- Dart SDK compatible with the version in `pubspec.yaml`
- Android Studio and an Android SDK for Android builds
- Chrome for web development

Check the local setup with:

```bash
flutter doctor
```

## Getting Started

Clone the repository and install dependencies:

```bash
git clone https://github.com/bijaykumarceh-dev/justdemo1.git
cd justdemo1
flutter pub get
```

Run the app on a connected device or Chrome:

```bash
flutter devices
flutter run
flutter run -d chrome
```

## Testing and Analysis

Run the widget tests and static analysis before submitting changes:

```bash
flutter test
flutter analyze
```

## Build a Release APK

Build the Android release package:

```bash
flutter build apk --release
```

The generated file is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

You can also download the latest published APK from the [GitHub Releases page](https://github.com/bijaykumarceh-dev/justdemo1/releases/latest).

## Build for Web

```bash
flutter build web
```

The production web bundle is generated in `build/web/`.

## Project Structure

```text
lib/main.dart          Application screens and study-tracking logic
test/widget_test.dart  Widget tests for the main user flows
android/               Android platform project
web/                   Flutter web shell
release/               APK artifacts checked into the repository
```

## Contributing

1. Create a feature branch.
2. Make a focused change and update tests where needed.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request with a short description and test results.

## License

This project is not currently published under an open-source license. Ask the repository owner before redistributing or using it in a commercial product.
