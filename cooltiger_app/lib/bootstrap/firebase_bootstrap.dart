import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../app.dart';
import '../firebase_options.dart';

/// Web-only guardian dashboard options pulled from Firebase Console.
/// Replace every placeholder string with the snippet under
/// "Add app > Web" for the Guardian web app in Firebase.
const FirebaseOptions guardianWebOptions = FirebaseOptions(
  apiKey: 'AIzaSyAq8xbJD1PCJ7BEqvMoJZDD8HfB4-0ykjk',
  appId: '1:304653364245:web:a247e07e202ca94e97721c',
  messagingSenderId: '304653364245',
  projectId: 'cooltiger',
  authDomain: 'cooltiger.firebaseapp.com',
  storageBucket: 'cooltiger.firebasestorage.app',
  measurementId: 'G-ECZFJYHQ6Q',
);

/// Web-only senior showcase options; populate from the Showcase web app config.
const FirebaseOptions seniorWebOptions = FirebaseOptions(
  apiKey: 'AIzaSyAq8xbJD1PCJ7BEqvMoJZDD8HfB4-0ykjk',
  appId: '1:304653364245:web:a247e07e202ca94e97721c',
  messagingSenderId: '304653364245',
  projectId: 'cooltiger',
  authDomain: 'cooltiger.firebaseapp.com',
  storageBucket: 'cooltiger.firebasestorage.app',
  measurementId: 'G-ECZFJYHQ6Q',
);

bool _isFirebaseInitialized = false;

/// Initializes Firebase once per process, selecting the right options per target.
Future<void> bootstrapFirebase(TargetFlavor flavor) async {
  if (_isFirebaseInitialized) return;

  if (kIsWeb) {
    final FirebaseOptions webOptions =
        flavor == TargetFlavor.guardianWeb
            ? guardianWebOptions
            : seniorWebOptions;

    await Firebase.initializeApp(options: webOptions);
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (flavor == TargetFlavor.seniorMobile) {
      await _configureMessaging();
    }
  }

  _isFirebaseInitialized = true;
}

Future<void> _configureMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Request user-facing permissions on iOS/macOS; Android will just resolve.
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  await messaging.setAutoInitEnabled(true);
}
