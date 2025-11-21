/// Global application configuration.
///
/// Controls demo mode and other app-wide settings.
library;

import 'package:flutter/foundation.dart';

/// Application configuration settings
class AppConfig {
  // Prevent instantiation
  const AppConfig._();
}

/// Backend API URL
///
/// For Android Emulator: Use 'http://10.0.2.2:8000'
/// For iOS Simulator: Use 'http://127.0.0.1:8000'
/// For Web (Local): Use 'http://127.0.0.1:8000' or 'http://localhost:8000'
/// For Production: Use your Cloud Run URL
const String kBaseApiUrl =
    'https://cooltiger-backend-304653364245.asia-northeast3.run.app';
// const String kBaseApiUrl = 'http://127.0.0.1:8000'; // Local Development URL

/// Demo mode flag
///
/// Set to true to use fake data and responses for UI testing
/// Set to false to use actual backend API
const bool kDemoMode = false; // <--- CHANGED TO FALSE

/// Demo user data for testing without Firebase.
class DemoUser {
  final String uid;
  final String email;
  final String name;
  final String role; // "senior" or "guardian"

  const DemoUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  static const DemoUser senior = DemoUser(
    uid: 'demo-senior-001',
    email: 'senior@demo.com',
    name: '김효심',
    role: 'senior',
  );

  static const DemoUser guardian = DemoUser(
    uid: 'demo-guardian-001',
    email: 'guardian@demo.com',
    name: '이보호',
    role: 'guardian',
  );
}
