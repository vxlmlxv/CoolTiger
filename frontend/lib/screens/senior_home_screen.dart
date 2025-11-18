import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';
import 'senior_call_screen.dart';
import 'senior_quiz_screen.dart';
import 'senior_exercise_screen.dart';

/// Home screen for senior users with tab-based navigation.
///
/// Provides easy access to three main features:
/// - AI companion calls (효심이 상담)
/// - Cognitive quizzes (인지능력 퀴즈)
/// - Exercise guidance (운동 길잡이)
///
/// Includes a quick-start button for immediate access to AI calls.
class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToCallTab() {
    setState(() {
      _tabController.animateTo(0);
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃', style: TextStyle(fontSize: 20)),
        content: const Text('로그아웃 하시겠습니까?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (!kDemoMode) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('로그아웃 실패: $e')));
            return;
          }
        }
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed(kDemoMode ? '/demo' : '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '효심이 홈',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () {
              // TODO: Navigate to profile/settings screen
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('프로필 화면 준비 중입니다')));
            },
            tooltip: '프로필',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: _handleLogout,
            tooltip: '로그아웃',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 4,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          tabs: const [
            Tab(icon: Icon(Icons.phone, size: 28), text: '효심이 상담'),
            Tab(icon: Icon(Icons.quiz, size: 28), text: '인지능력 퀴즈'),
            Tab(icon: Icon(Icons.fitness_center, size: 28), text: '운동 길잡이'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // In demo mode, use demo senior ID
                SeniorCallScreen(
                  seniorId: kDemoMode ? DemoUser.senior.uid : 'TODO-real-uid',
                ),
                const SeniorQuizScreen(),
                const SeniorExerciseScreen(),
              ],
            ),
          ),

          // Quick-start button area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _navigateToCallTab,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.phone_in_talk, size: 32),
                    SizedBox(width: 12),
                    Text(
                      '효심이 상담 바로 시작하기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
