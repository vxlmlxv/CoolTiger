/// Global application configuration.
///
/// Controls demo mode and other app-wide settings.
library;

/// Demo mode flag - when true, the app runs without backend/Firebase.
///
/// Set to `true` for local development and UI testing without backend.
/// Set to `false` for production with real Firebase + FastAPI backend.
const bool kDemoMode = true;

/// Base URL for the FastAPI backend.
///
const String kBaseApiUrl =
    "https://cooltiger-backend-304653364245.asia-northeast3.run.app/";

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
