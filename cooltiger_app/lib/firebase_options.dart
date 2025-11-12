// GENERATED PLACEHOLDER - Replace by running `flutterfire configure`.
// This stub allows the project to compile until real values are added.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'FirebaseOptions not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSm2DTyPlcT5TqdJpttMrdhFzc3zm1474',
    appId: '1:304653364245:android:26281e8213240ee197721c',
    messagingSenderId: '304653364245',
    projectId: 'cooltiger',
    storageBucket: 'cooltiger.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZHG88x4c5ibbi9lhKltbp0v05sBaMZd4',
    appId: '1:304653364245:ios:52be91578434a1d997721c',
    messagingSenderId: '304653364245',
    projectId: 'cooltiger',
    storageBucket: 'cooltiger.firebasestorage.app',
    iosBundleId: 'com.cooltiger.senior',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PASTE_MACOS_API_KEY',
    appId: 'PASTE_MACOS_APP_ID',
    messagingSenderId: 'PASTE_MACOS_SENDER_ID',
    projectId: 'PASTE_FIREBASE_PROJECT_ID',
    storageBucket: 'PASTE_STORAGE_BUCKET',
    iosBundleId: 'com.cooltiger.senior',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAq8xbJD1PCJ7BEqvMoJZDD8HfB4-0ykjk',
    appId: '1:304653364245:web:a247e07e202ca94e97721c',
    messagingSenderId: '304653364245',
    projectId: 'cooltiger',
    authDomain: 'cooltiger.firebaseapp.com',
    storageBucket: 'cooltiger.firebasestorage.app',
    measurementId: 'G-ECZFJYHQ6Q',
  );
}
