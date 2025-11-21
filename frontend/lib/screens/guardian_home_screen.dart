import 'package:flutter/material.dart';

import '../widgets/guardian_bottom_nav.dart';
import '../widgets/logout_action_button.dart';

/// Guardian (보호자) Home Screen - Dashboard for family members/protectors
///
/// Displays:
/// - Purple gradient header with greeting and days together
/// - Today's scheduled activities list
/// - Action button to view life reports
/// - Bottom navigation bar
class GuardianHomeScreen extends StatefulWidget {
  final String guardianName;
  final int daysWithHyosim;

  const GuardianHomeScreen({
    super.key,
    this.guardianName = '홍길동',
    this.daysWithHyosim = 42,
  });

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
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
        // TODO: Navigate to Reports screen
        Navigator.of(context).pushReplacementNamed('/guardian-reports');
        break;
      case 2:
        // TODO: Navigate to Settings screen
        _showComingSoon('설정');
        break;
      case 3:
        // TODO: Navigate to User screen
        _showComingSoon('사용자');
        break;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature 화면 준비 중입니다')));
  }

  void _navigateToAllActivities() {
    _showComingSoon('전체 활동');
  }

  void _navigateToReports() {
    Navigator.of(context).pushReplacementNamed('/guardian-reports');
  }

  void _editSchedule(String activityTitle) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$activityTitle 일정 수정')));
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to keep content responsive on smaller devices.
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 홈'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: const [LogoutActionButton()],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: GuardianBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Guardian Profile Header (Purple gradient banner)
                      GuardianProfileHeader(
                        guardianName: widget.guardianName,
                        daysWithHyosim: widget.daysWithHyosim,
                      ),

                      const SizedBox(height: 24),

                      // Activity List with Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Activity Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  '오늘 예정된 활동',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // "전체 보기" button
                              GestureDetector(
                                onTap: _navigateToAllActivities,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8D28), // Orange
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '전체 보기',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 9),

                          // Activity List
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFF2F2F7),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                DailyActivityItem(
                                  title: 'AI 인지 퀴즈',
                                  subtitle: '구체적 내용',
                                  onEditPressed: () =>
                                      _editSchedule('AI 인지 퀴즈'),
                                ),
                                DailyActivityItem(
                                  title: 'AI 트레이닝',
                                  subtitle: '구체적 내용',
                                  onEditPressed: () => _editSchedule('AI 트레이닝'),
                                ),
                                DailyActivityItem(
                                  title: 'Ai 트레이너 효빵이',
                                  subtitle: '구체적 내용',
                                  onEditPressed: () =>
                                      _editSchedule('Ai 트레이너 효빵이'),
                                ),
                                DailyActivityItem(
                                  title: '복약지도',
                                  subtitle: '구체적 내용',
                                  onEditPressed: () => _editSchedule('복약지도'),
                                ),
                                DailyActivityItem(
                                  title: '복약지도',
                                  subtitle: '구체적 내용',
                                  onEditPressed: () => _editSchedule('복약지도'),
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Bottom Action Button - "효심이와 생활 보고서 보러 가기"
                          GestureDetector(
                            onTap: _navigateToReports,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(2, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      '효심이와 생활 보고서 보러 가기',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.1,
                                        color: Color(0xFF49454F),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 30,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable Guardian Profile Header widget
///
/// Purple gradient banner with greeting message and profile image placeholder
class GuardianProfileHeader extends StatelessWidget {
  final String guardianName;
  final int daysWithHyosim;

  const GuardianProfileHeader({
    super.key,
    required this.guardianName,
    required this.daysWithHyosim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9B7FD4), // Lighter purple
            Color(0xFF6750A4), // Primary purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          // Profile Image Placeholder
          Container(
            width: 137,
            height: 133,
            decoration: BoxDecoration(
              color: const Color(0xFFEADDFF), // Light purple container
              borderRadius: BorderRadius.circular(1000),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 70,
                color: const Color(0xFF6750A4).withOpacity(0.5),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '안녕하세요 $guardianName 님',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // Days together message
                Text(
                  '효심이와 함께한지\n$daysWithHyosim일 되었어요',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Daily Activity Item widget
///
/// Displays activity title, subtitle, and "일정 수정" (Edit Schedule) button
class DailyActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onEditPressed;
  final bool isLast;

  const DailyActivityItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEditPressed,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1),
              ),
        borderRadius: isLast ? BorderRadius.circular(8) : null,
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 62,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(1000),
            ),
          ),

          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: Color(0xFF828282),
                  ),
                ),
              ],
            ),
          ),

          // Edit schedule button
          GestureDetector(
            onTap: onEditPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8DEF8), // Secondary container
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '일정 수정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: Color(0xFF4A4459), // On-secondary-container
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
