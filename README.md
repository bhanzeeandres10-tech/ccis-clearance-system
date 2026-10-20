# CCIS CLEARANCE

CCIS CLEARANCE is one responsive Flutter codebase for two delivery modes:

- an installable Android application for students and authorized CCIS personnel;
- an installable progressive web app (PWA) and normal browser website.

The UI follows the supplied mobile wireframes while adapting to desktop with an expanded navigation rail and wider content panels. It includes light and dark themes, responsive layouts, and motion designed for quick clearance-status review.

## Revised role flow

- **Administrator:** creates or activates/deactivates CCIS personnel accounts and reviews timestamped login, logout, create, and update audit activity.
- **CCIS personnel:** searches students, records or verifies attendance, manages clearance requirement states and fines, resolves deficiencies, and approves eligible clearance records.
- **Student:** views clearance requirements and progress, receives updates, and views their profile. Student records remain view-only.

The demo is presentation-functional: sign in with any non-empty credentials, choose a role, update a student requirement or attendance entry as Personnel, then view the changed progress and notification as Student. Admin actions add audit-log entries immediately.

## What is included

- `lib/` contains the Dart/Flutter interface and state source.
- `web/manifest.json`, web icon assets, and `web/sw.js` make the web build installable.
- `web/flutter_bootstrap.js` deliberately does **not** enable Flutter's legacy caching service worker. Instead, `web/index.html` registers the small app-owned worker in `web/sw.js` for the PWA app shell and same-origin runtime assets.
- `.vscode/launch.json` adds VS Code launch configurations for Chrome and Android.

## First-time setup

Flutter and Dart are not installed in this workspace. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install/windows), make sure `flutter` is on your `PATH`, then run:

```powershell
cd C:\Users\asus\Documents\Codex\2026-10-18\tryt\outputs\CCIS_CLEARANCE
flutter doctor
.\tool\bootstrap_platforms.ps1
```

The bootstrap script runs the required command below to create Flutter's generated Android and web platform directories, preserves the CCIS CLEARANCE PWA configuration around it, and downloads SDK dependencies:

```powershell
flutter create . --platforms=android,web
flutter pub get
```

It also sets the generated Android application's visible label to **CCIS CLEARANCE**.

If you choose to run `flutter create` yourself, run it before editing generated platform files. Reapply or preserve the custom files in `web/` afterward, especially `index.html`, `manifest.json`, `flutter_bootstrap.js`, and `sw.js`.

## Run it

Open the `CCIS_CLEARANCE` folder in Visual Studio Code, install the Dart and Flutter extensions, then select **CCIS CLEARANCE — Chrome** from Run and Debug. Or use a terminal:

```powershell
flutter run -d chrome
```

To run the installable mobile app, start an Android emulator or connect an Android device, then use:

```powershell
flutter run
```

## Build the website / PWA

```powershell
flutter build web --release
```

Deploy the contents of `build/web` to an HTTPS-capable static host. Browsers allow service workers on `localhost` during development, but require HTTPS for installed PWAs on a real domain. Open the site once online, then use the browser's **Install app** option to install CCIS CLEARANCE.

## Build Android for installation

```powershell
flutter build apk --release
```

The resulting installable APK is under `build\app\outputs\flutter-apk\`.

## Project scope

This UI prototype is for CCIS clearance only. It models the supplied student and authorized-personnel flow: attendance checkpoints, event-day completion, requirement verification, deficiencies, notifications, review, and approval. It does not connect to a production authentication service or database yet.
