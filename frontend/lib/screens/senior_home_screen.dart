import 'package:flutter/material.dart';

import '../app_config.dart';
import '../widgets/senior_app_bar.dart';
import '../widgets/senior_bottom_nav.dart';
import '../widgets/service_card.dart';
import '../widgets/floating_call_button.dart';
import 'senior_call_screen.dart';
import 'senior_quiz_screen.dart';
import 'senior_exercise_screen.dart';

/// Home screen for senior users with card-based navigation.
///
/// Provides easy access to four main features:
/// - AI companion calls (효심이 상담)
/// - Cognitive quizzes (인지능력 퀴즈)
/// - Exercise guidance (운동 길잡이)
/// - Medication guidance (복약 지도)
///
/// Features a scrollable list of service cards and bottom navigation.
class SeniorHomeScreen extends StatefulWidget {
  const SeniorHomeScreen({super.key});

  @override
  State<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends State<SeniorHomeScreen> {
  int _currentNavIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Already on home, do nothing
        break;
      case 1:
        // TODO: Navigate to Goals screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('목표 화면 준비 중입니다')));
        break;
      case 2:
        // TODO: Navigate to My Info screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('내정보 화면 준비 중입니다')));
        break;
    }
  }

  void _navigateToCallScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeniorCallScreen(
          seniorId: kDemoMode ? DemoUser.senior.uid : 'TODO-real-uid',
        ),
      ),
    );
  }

  void _navigateToQuizScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SeniorQuizScreen()),
    );
  }

  void _navigateToExerciseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SeniorExerciseScreen()),
    );
  }

  void _showMedicationComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('복약 지도 기능 준비 중입니다')));
    debugPrint('TODO: Implement medication guidance feature');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SeniorAppBar(),
      body: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 34,
                ),
                child: Column(
                  children: [
                    // AI 효심이 상담 card
                    ServiceCard(
                      title: 'AI 효심이 상담',
                      subtitle: '무엇이든 편하게 물어보세요',
                      buttonText: '시작하기',
                      onPressed: _navigateToCallScreen,
                    ),
                    const SizedBox(height: 27),

                    // 인지능력 퀴즈 card
                    ServiceCard(
                      title: '인지능력 퀴즈',
                      subtitle: '꾸준히 하면 기억력에 도움이 됩니다',
                      buttonText: '시작하기',
                      onPressed: _navigateToQuizScreen,
                    ),
                    const SizedBox(height: 27),

                    // 하루 운동 길잡이 card
                    ServiceCard(
                      title: '하루 운동 길잡이',
                      subtitle: '쉬운 동작으로 건강을 지켜요',
                      buttonText: '시작하기',
                      onPressed: _navigateToExerciseScreen,
                    ),
                    const SizedBox(height: 27),

                    // 복약 지도 card
                    ServiceCard(
                      title: '복약 지도',
                      subtitle: '약 드실 시간을 잊지 않게 챙겨드려요',
                      buttonText: '시작하기',
                      onPressed: _showMedicationComingSoon,
                    ),
                    const SizedBox(height: 80), // Space for floating button
                  ],
                ),
              ),
            ),
          ),

          // Floating call button
          FloatingCallButton(onPressed: _navigateToCallScreen),
        ],
      ),
      bottomNavigationBar: SeniorBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
