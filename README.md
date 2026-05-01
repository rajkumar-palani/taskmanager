# TaskManager

TaskManager is a small Flutter application that demonstrates a simple authenticated task management app with:

- Login / Register
- Task list with filters, create/update/delete
- Task charts (pie chart by status)
- Persistent session and secure storage

This README documents the project structure, how to run the app, and how to build debug and release APKs.

---

Project structure (important files and folders)

- android/                — Android platform project and Gradle build files
- ios/                    — iOS platform project
- lib/                    — Main Dart source code
  - main.dart             — App entry point, routes and providers
  - models/               — Data models (e.g. `task.dart`)
  - providers/            — ChangeNotifier providers (`auth_provider.dart`, `task_provider.dart`)
  - screens/              — UI screens (`login_screen.dart`, `task_list_screen.dart`, `chart_screen.dart`, ...)
  - services/             — Remote/backend services (`back4app_service.dart`)
  - widgets/              — Reusable widgets (e.g. `left_panel.dart`)
  - config/               — App configuration (Back4App credentials)
- pubspec.yaml            — Dart/Flutter dependencies and assets
- build/                  — Generated build artifacts (ignored by VCS)

Notes:
- The project uses Provider for state management and Back4App (Parse) as a backend via REST.
- Charts are implemented using `fl_chart` (dependency in `pubspec.yaml`).
- There are local key files under `android/app/` such as `my-release-key.jks` and `task-manager-key.jks`. The Gradle configuration reads `key.properties` for signing when building a release.

Prerequisites

- Flutter SDK (the project targets Flutter stable; tested with Flutter 3.11.x)
- Android SDK & Android Studio (for Android builds)
- For Windows builds: enable Developer Mode (required by some plugins)

Quick start — run in debug on a connected device or emulator

1. Open a terminal in the project root:

```powershell
cd D:\01_Work\Projects\taskmanager
flutter pub get
```

2. Run on the default connected device/emulator:

```powershell
flutter run
```

3. To run a specific device or emulator, use `flutter devices` to list devices and `flutter run -d <deviceId>`.

Building APKs

Debug APK (fast, not signed)

```powershell
# Produce a debug APK
flutter build apk --debug
# Location: build/app/outputs/flutter-apk/app-debug.apk
```

Release APK (optimized, unsigned or signed depending on config)

If you already have signing configured in `android/key.properties` and the keystore under `android/app/`, the normal release build will sign automatically following the Gradle configuration.

```powershell
# Produce a release APK (universal, single artifact)
flutter build apk --release
# Or produce per-ABI split APKs (smaller artifacts):
flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
```

Signing notes
- This project contains `android/key.properties` and sample keystore(s) in `android/app/`. If your `android/app/build.gradle` is configured to use those values, the `flutter build apk --release` command will create a signed APK.
- If you need to sign manually, follow the instructions in the Android docs and/or configure `key.properties` with the keystore location, alias, and passwords.

Common build troubleshooting

- If you see errors coming from packages in the pub cache (e.g. due to API changes in Flutter), prefer upgrading the package version in `pubspec.yaml`. Example: `fl_chart` may require a newer Flutter SDK or a newer package release.
- Avoid editing files directly under your pub cache for long-term fixes; instead fork the package or update the dependency.

Development tips

- Hot reload is available via `flutter run` in debug mode (press `r` in terminal or use IDE shortcuts).
- Use `flutter analyze` to run static analysis.
- Use `flutter pub outdated` to check for outdated dependencies.

Where to look next in the codebase

- `lib/screens/task_list_screen.dart` — main task list UI and filters
- `lib/screens/task_form_screen.dart` — create / update task UI
- `lib/screens/chart_screen.dart` — charts (pie chart by task status)
- `lib/services/back4app_service.dart` — REST calls to Back4App
- `lib/providers/task_provider.dart` — state management for tasks

Contributing and fixes

- If you discover a dependency incompatibility (e.g. with your local Flutter SDK), prefer updating `pubspec.yaml` to use a compatible version. If a package needs a small fix, consider forking it and referencing your fork in `pubspec.yaml`.

License & authors

- This repository follows the project's existing license (if any). Update this README with author and license information as appropriate.

---

If you'd like, I can also:
- Add a small `docs/BUILDING.md` with step-by-step signing instructions using the keystore files found in `android/app/`.
- Create a short CONTRIBUTING guide showing how to run and test changes locally.


