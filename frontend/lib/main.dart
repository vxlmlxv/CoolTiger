import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_config.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/role_router.dart';
import 'screens/senior_home_screen.dart';
import 'screens/guardian_home_screen.dart';
import 'screens/demo_landing_screen.dart';
import 'screens/guardian_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only in real mode
  if (!kDemoMode) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      // Continue anyway - the app can still run in demo mode
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '효심이',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Senior-friendly font sizes
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 14),
        ),
      ),
      // Initial route depends on demo mode and auth state
      home: _getInitialScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/role-router': (context) => const RoleRouter(),
        '/senior-home': (context) => const SeniorHomeScreen(),
        '/guardian-home': (context) => const GuardianHomeScreen(),
        '/guardian-reports': (context) => const GuardianReportsScreen(),
        '/demo': (context) => const DemoLandingScreen(),
      },
    );
  }

  /// Determines the initial screen based on demo mode and authentication state.
  Widget _getInitialScreen() {
    // DEMO MODE: Start with demo landing screen
    if (kDemoMode) {
      return const DemoLandingScreen();
    }

    // REAL MODE: Check Firebase auth state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in -> go to RoleRouter
        if (snapshot.hasData && snapshot.data != null) {
          return const RoleRouter();
        }

        // No user logged in -> show login screen
        return const LoginScreen();
      },
    );
  }
}
