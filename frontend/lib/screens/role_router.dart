import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_config.dart';

/// Role-based router that directs users to the appropriate home screen.
///
/// In demo mode: Uses the demoRole argument to determine navigation.
/// In real mode: Reads Firebase user's role from Firestore and navigates
/// to either SeniorHomeScreen or GuardianHomeScreen.
class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      return data?['role'] as String?;
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return null;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그아웃 실패: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // DEMO MODE: Use demoRole from route arguments
    if (kDemoMode) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final demoRole = args?['demoRole'] as String? ?? 'senior';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (demoRole == 'senior') {
          Navigator.of(context).pushReplacementNamed('/senior-home');
        } else if (demoRole == 'guardian') {
          Navigator.of(context).pushReplacementNamed('/guardian-home');
        }
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // REAL MODE: Check Firebase auth state
    final currentUser = FirebaseAuth.instance.currentUser;

    // If no user is logged in, redirect to login
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<String?>(
      future: _getUserRole(currentUser.uid),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('로딩 중…', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }

        // Error state or no role found
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('오류')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '사용자 정보를 찾을 수 없습니다.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '계정이 올바르게 설정되지 않았습니다.\n회원가입을 다시 진행해주세요.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('로그아웃'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final role = snapshot.data!;

        // Navigate based on role
        if (role == 'senior') {
          // Navigate to Senior Home Screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/senior-home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (role == 'guardian') {
          // Navigate to Guardian Home Screen
          // TODO: Implement GuardianHomeScreen if not already defined
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/guardian-home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Unknown role
          return Scaffold(
            appBar: AppBar(title: const Text('오류')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '알 수 없는 사용자 역할',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 역할: $role\n\n지원되는 역할이 아닙니다.\n관리자에게 문의해주세요.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('로그아웃'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
