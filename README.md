# 📱 Campus Lost & Found App

> A Flutter + Firebase application for college campuses to report and find lost items.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth+Firestore-FFA000?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)

---

## 🚀 How to Clone & Run (Quick Start for Teammates)

### 0️⃣ Prerequisites

Install these once, in order:

1. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (3.x, stable channel). Verify with:
   ```bash
   flutter doctor
   ```
2. **Android SDK** — needed even if you only run on a physical phone via USB. Easiest path: install [Android Studio](https://developer.android.com/studio) and let it install the SDK, platform-tools (`adb`), and a build-tools version on first launch. (A command-line-tools-only setup also works — see [Troubleshooting](#-troubleshooting) below.)
3. Accept the Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```
4. Run `flutter doctor` again — every line should show a green `[✓]` for Android toolchain before continuing (web/desktop-only checks can stay unchecked).

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd "YOUR_REPO_NAME"
```

### 2️⃣ Install Dependencies
```bash
flutter pub get
```

### 3️⃣ Run the App!
- **Run on Android (Emulator or Connected Phone via USB debugging):**
  ```bash
  flutter devices   # confirm your phone shows up here first
  flutter run
  ```
  On the phone: enable Developer Options → **USB debugging**, plug in via USB, and accept the "Allow USB debugging?" prompt that pops up on the device screen. If the phone doesn't appear in `flutter devices`, see [Troubleshooting](#-troubleshooting).
- **Run in Web Browser (Chrome):**
  ```bash
  flutter run -d chrome
  ```
- **Run as Windows Desktop App:**
  ```bash
  flutter run -d windows
  ```

---

## 🛠️ Troubleshooting

**Gradle build fails / `flutter run` fails on Android with no clear Dart error**
This is almost always a native Android toolchain problem, not an app bug. Run `flutter doctor -v` and fix every `[✗]`/`[!]` under "Android toolchain" first — a red Dart stack trace during a *Gradle* failure is usually a red herring.

**`Unable to locate Android SDK` / `No Android SDK found`**
Android Studio wasn't installed, or Flutter doesn't know where it is. Either install Android Studio (its SDK Manager handles everything), or install the SDK manually:
```bash
# after installing the "command line tools only" package from
# https://developer.android.com/studio#command-line-tools-only
sdkmanager --sdk_root=<path> "platform-tools" "platforms;android-36" "build-tools;36.0.0"
flutter config --android-sdk <path>
flutter doctor --android-licenses
```

**`Some Android licenses not accepted`**
Run `flutter doctor --android-licenses` and accept each prompt with `y`. If that hangs or the prompt seems ignored, the SDK is not installed correctly — reinstall via Android Studio's SDK Manager instead.

**Phone doesn't show up in `flutter devices` over USB**
- Enable **Developer Options** (Settings → About phone → tap "Build number" 7 times), then enable **USB debugging** inside Developer Options.
- Accept the "Allow USB debugging?" dialog on the phone when it appears (it only appears once you actually plug in and the computer's `adb` talks to it).
- Try a different USB cable/port — many cables are charge-only.
- Run `adb devices` — if it lists nothing or says `unauthorized`, revoke USB debugging authorizations on the phone (Developer Options) and reconnect.

**Missing/incomplete `android/` folder (missing `settings.gradle`, `MainActivity.kt`, `gradlew`, etc.)**
This can happen if the project folder was zipped/shared without the full Android scaffolding. Regenerate it without touching your Dart code:
```bash
flutter create --platforms=android .
```
Then re-check `android/app/build.gradle.kts` (or `build.gradle`) still has the Firebase `google-services` plugin applied, since a fresh scaffold won't include it.

---

## 👤 Member 1 — User Module (This Repository)

Implements all user-facing authentication and profile features:

| Feature | Status |
|---------|--------|
| Splash Screen | ✅ Done |
| Login Screen | ✅ Done |
| Registration Screen | ✅ Done |
| Forgot Password | ✅ Done |
| Home Screen | ✅ Done |
| User Profile | ✅ Done |
| Edit Profile | ✅ Done |
| Help & Support | ✅ Done |
| Firebase Authentication | ✅ Done |
| Firestore User Profiles | ✅ Done |
| Navigation & Routing | ✅ Done |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config ⚠️ REPLACE THIS
├── config/
│   ├── app_theme.dart                 # Dark theme (Poppins + teal palette)
│   ├── app_routes.dart                # Named routes + transitions
│   └── app_constants.dart             # App-wide constants & FAQ data
├── core/
│   ├── models/user_model.dart         # UserModel (Firestore-ready)
│   ├── services/
│   │   ├── auth_service.dart          # Firebase Auth wrapper
│   │   └── firestore_service.dart     # Firestore + Storage CRUD
│   ├── providers/
│   │   ├── auth_provider.dart         # Auth state (ChangeNotifier)
│   │   └── user_provider.dart         # Profile state (ChangeNotifier)
│   └── utils/
│       ├── validators.dart            # Form validators
│       └── snackbar_utils.dart        # Styled SnackBars
├── features/
│   ├── splash/splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── registration_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/home_screen.dart
│   ├── profile/
│   │   ├── user_profile_screen.dart
│   │   └── edit_profile_screen.dart
│   └── support/help_support_screen.dart
└── widgets/
    ├── custom_text_field.dart
    ├── custom_button.dart
    ├── loading_overlay.dart
    └── app_drawer.dart
```

---

## 🔥 Firebase Setup

> ✅ **Already done for this repo.** `lib/firebase_options.dart` and `android/app/google-services.json` are checked in and point at the project's shared Firebase backend (`lost-and-found-cc958`), so `flutter pub get` + `flutter run` is all a teammate needs — no `flutterfire configure` required.
>
> Only follow the steps below if you're deliberately pointing this app at your **own** Firebase project (e.g. testing in isolation).

### Step 1 — Create a Firebase Project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add Project** → name it (e.g. "campus-lost-found")
3. Enable Google Analytics (optional)

### Step 2 — Enable Firebase Services
In your Firebase project:
- **Authentication** → Sign-in method → Enable **Email/Password**
- **Firestore Database** → Create database → Start in **test mode** (update rules before production)
- **Storage** → Create bucket → Start in **test mode**

### Step 3 — Configure Flutter
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure from project root — SELECT your Firebase project
flutterfire configure

# This generates lib/firebase_options.dart with correct values
```

### Step 4 — Download google-services.json
1. In Firebase Console → Project Settings → Your Android App
2. Download `google-services.json`
3. Replace `android/app/google-services.json` with the downloaded file

### Step 5 — Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Anyone authenticated can submit support requests
    match /support_requests/{docId} {
      allow create: if request.auth != null;
      allow read: if false; // Only admins
    }
    // Items — placeholder for Member 2 & 3
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Step 6 — Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📦 Release Builds

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

## 📐 Architecture

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│   (Screens, Widgets, Providers)         │
├─────────────────────────────────────────┤
│          Service Layer                  │
│   (AuthService, FirestoreService)       │
├─────────────────────────────────────────┤
│          Data Layer                     │
│   (Firebase Auth, Firestore, Storage)   │
└─────────────────────────────────────────┘
```

**State Management**: Provider (ChangeNotifier)
- `AuthProvider` — auth state & Firebase Auth operations
- `UserProvider` — Firestore profile with optimistic updates

---

## 🗄️ Firestore Schema

### `users/{uid}`
| Field | Type | Description |
|-------|------|-------------|
| `uid` | String | Firebase Auth UID |
| `fullName` | String | User's full name |
| `email` | String | Email address |
| `phone` | String | Phone number |
| `department` | String | Academic department |
| `rollNumber` | String | Student roll number |
| `profileImageUrl` | String | Firebase Storage URL |
| `createdAt` | Timestamp | Account creation |
| `updatedAt` | Timestamp | Last update |

### `support_requests/{docId}`
| Field | Type | Description |
|-------|------|-------------|
| `userId` | String | Submitting user's UID |
| `name` | String | User's name |
| `email` | String | User's email |
| `subject` | String | Support subject |
| `message` | String | Message body |
| `status` | String | "open" / "resolved" |
| `createdAt` | Timestamp | Submission time |

---

## 🔗 Navigation Flow

```
Splash Screen (2.8s)
   ├── Not logged in → Login Screen
   │       ├── → Registration → Home ✅
   │       └── → Forgot Password → Login
   └── Logged in → Home Screen
           ├── Drawer
           │   ├── Home
           │   ├── Profile → Edit Profile
           │   ├── Help & Support
           │   └── Logout → Login
           └── Top Bar → Profile
```

---

## 🤝 Integration Points for Other Members

### Member 2 (Lost Items) — Hook Points
```dart
// In home_screen.dart → _QuickActionCard "Report Lost Item" → onTap
// In app_drawer.dart → "Report Lost Item" nav item → onTap
// In home_screen.dart → _buildRecentItemsPlaceholder() → replace with real items
// Firebase: items collection is pre-declared in app_constants.dart
static const String itemsCollection = 'items';
```

### Member 3 (Found Items) — Hook Points
```dart
// In home_screen.dart → _QuickActionCard "Report Found Item" → onTap
// In app_drawer.dart → "Report Found Item" nav item → onTap
// In app_drawer.dart → "Browse Items" nav item → onTap
```

### Shared UserModel
```dart
// Import from:
import 'package:college_lost_found/core/models/user_model.dart';

// Get current user in any widget:
final user = context.read<UserProvider>().user;
```

---

## 📋 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.6.0 | Firebase initialization |
| `firebase_auth` | ^5.3.1 | Email/password auth |
| `cloud_firestore` | ^5.4.4 | User profiles & support |
| `firebase_storage` | ^12.3.3 | Profile image upload |
| `provider` | ^6.1.2 | State management |
| `google_fonts` | ^6.2.1 | Poppins typography |
| `flutter_animate` | ^4.5.0 | Screen animations |
| `cached_network_image` | ^3.4.1 | Profile image caching |
| `image_picker` | ^1.1.2 | Camera/gallery picker |
| `intl` | ^0.19.0 | Date formatting |
| `shared_preferences` | ^2.3.2 | Local preferences |

---

## ✅ Checklist Before Submission

- [ ] Firestore Security Rules deployed
- [ ] Firebase Storage Rules deployed
- [ ] App runs on physical Android device
- [ ] All auth flows tested (register, login, forgot password, logout)
- [ ] Profile edit and image upload tested
- [ ] Release APK built: `flutter build apk --release`
- [ ] APK installable on test device

---

## 👥 Team

- **Member 1** — User Module + Final Integration (this branch)
- **Member 2** — Lost Items Module
- **Member 3** — Found Items Module

---

*Built with ❤️ using Flutter & Firebase*
