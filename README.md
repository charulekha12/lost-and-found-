# 📱 Campus Lost & Found App

> A Flutter + Firebase application for college campuses to report and find lost items.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth+Firestore-FFA000?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)

---

## 🚀 How to Clone & Run (Quick Start for Teammates)

Follow these exact steps if you are cloning this project from GitHub:

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd "YOUR_REPO_NAME"
```

### 2️⃣ Install Dependencies
```bash
### 2️⃣ Install Dependencies
```bash
flutter pub get
```

### 3️⃣ Run the App!
- **Run in Web Browser (Chrome):**
  ```bash
  flutter run -d chrome
  ```
- **Run on Android (Emulator or Connected Phone):**
  ```bash
  flutter run
  ```
- **Run as Windows Desktop App:**
  ```bash
  flutter run -d windows
  ```

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

## 🔥 Firebase Setup (REQUIRED)

> ⚠️ **You MUST complete this step before running the app.**

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

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

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

- [ ] Firebase project created & configured (`flutterfire configure` done)
- [ ] `google-services.json` replaced with real file
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
