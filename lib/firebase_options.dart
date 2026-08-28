import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// ⚠️  IMPORTANT: This is a PLACEHOLDER file!
/// You MUST replace these values with your actual Firebase project config.
///
/// Steps to configure:
///   1. Install Firebase CLI: `npm install -g firebase-tools`
///   2. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
///   3. Login: `firebase login`
///   4. Run from project root: `flutterfire configure`
///   5. This file will be automatically regenerated with correct values.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ⚠️ REPLACE ALL VALUES BELOW WITH YOUR FIREBASE PROJECT CONFIG

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBIudJWLw7jQ2SFuvwhZyMBTaBSYWUp_TI',
    appId: '1:1061913599134:web:9de631142e549a7d9fef8f',
    messagingSenderId: '1061913599134',
    projectId: 'lost-and-found-cc958',
    authDomain: 'lost-and-found-cc958.firebaseapp.com',
    storageBucket: 'lost-and-found-cc958.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.collegeLostFound',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.collegeLostFound',
  );
}
