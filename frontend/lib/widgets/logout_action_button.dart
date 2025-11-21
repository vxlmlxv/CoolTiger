import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';

/// Reusable logout button for app bars.
class LogoutActionButton extends StatelessWidget {
  const LogoutActionButton({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      if (!kDemoMode) {
        await FirebaseAuth.instance.signOut();
      }
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.logout,
        color: Color(0xFF49454F),
      ),
      tooltip: '로그아웃',
      onPressed: () => _handleLogout(context),
    );
  }
}
