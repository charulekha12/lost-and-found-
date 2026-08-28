# 📱 Campus Lost & Found App

Flutter + Firebase app for college campuses to report and find lost items.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x, stable) — verify with `flutter doctor`
- Android Studio / Android SDK if running on Android — accept licenses with `flutter doctor --android-licenses`

## Setup & Run

1. **Clone the repo**
   ```bash
   git clone https://github.com/charulekha12/lost-and-found-.git
   cd lost-and-found-
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add Firebase config** — extract `secrets.zip` (in the repo root) and place the files at:
   - `android/app/google-services.json`
   - `lib/firebase_options.dart`
   - `android/local.properties` (optional — Flutter/Android Studio regenerates this pointing at your own SDK install)

   (Or run `flutterfire configure` to point at your own Firebase project instead.)

4. **Run the app**
   ```bash
   flutter run              # Android device/emulator
   flutter run -d chrome    # Web
   flutter run -d windows   # Windows desktop
   ```

## Build a release APK

```bash
flutter build apk --release
```
