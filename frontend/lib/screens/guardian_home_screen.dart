import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';

/// Home screen for guardian (caregiver) users.
///
/// Displays monitoring dashboard with senior activity reports,
/// call history, quiz results, and health alerts.
class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  // DEMO MODE: Use dummy reports
  final List<SeniorReport> _demoReports = [
    SeniorReport(
      date: DateTime.now().subtract(const Duration(hours: 2)),
      seniorName: '김효심',
      mood: 'good',
      summary: '산책 다녀오셨다고 말씀하셨어요. 기분이 좋아 보이셨습니다.',
      callDuration: const Duration(minutes: 8),
    ),
    SeniorReport(
      date: DateTime.now().subtract(const Duration(days: 1)),
      seniorName: '김효심',
      mood: 'normal',
      summary: '퀴즈 3문제 풀이 완료. 2문제 정답.',
      callDuration: const Duration(minutes: 5),
    ),
    SeniorReport(
      date: DateTime.now().subtract(const Duration(days: 2)),
      seniorName: '김효심',
      mood: 'caution',
      summary: '오늘은 조금 피곤하다고 하셨어요. 걱정되는 부분이 있으시면 연락 주세요.',
      callDuration: const Duration(minutes: 12),
    ),
  ];

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
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
          '보호자 홈',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 28),
            onPressed: () {
              // TODO: Show notifications
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('알림 기능 준비 중입니다')));
            },
            tooltip: '알림',
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('설정 기능 준비 중입니다')));
            },
            tooltip: '설정',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: _handleLogout,
            tooltip: '로그아웃',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // DEMO MODE: Simulate refresh
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('새로고침 완료')));
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.phone_in_talk,
                    label: '오늘 통화',
                    value: '1회',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.quiz,
                    label: '이번 주 퀴즈',
                    value: '5회',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.fitness_center,
                    label: '이번 주 운동',
                    value: '3회',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.favorite,
                    label: '전체 기분',
                    value: '좋음',
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Reports section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 활동',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to all reports
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('전체 보기 기능 준비 중입니다')),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('전체 보기'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Report list
            ..._demoReports.map((report) => _buildReportCard(report)).toList(),

            // Demo mode indicator
            if (kDemoMode) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.science, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DEMO MODE: 더미 데이터가 표시되고 있습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(SeniorReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: Text(
                        report.seniorName[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.seniorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(report.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildMoodChip(report.mood),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.summary,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '통화 시간: ${report.callDuration.inMinutes}분',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChip(String mood) {
    Color color;
    String label;
    IconData icon;

    switch (mood) {
      case 'good':
        color = Colors.green;
        label = '좋음';
        icon = Icons.sentiment_satisfied;
        break;
      case 'normal':
        color = Colors.blue;
        label = '보통';
        icon = Icons.sentiment_neutral;
        break;
      case 'caution':
        color = Colors.orange;
        label = '주의';
        icon = Icons.sentiment_dissatisfied;
        break;
      default:
        color = Colors.grey;
        label = '알 수 없음';
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}분 전';
      }
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.year}.${date.month}.${date.day}';
    }
  }
}

/// Model for senior activity reports.
class SeniorReport {
  final DateTime date;
  final String seniorName;
  final String mood; // 'good', 'normal', 'caution'
  final String summary;
  final Duration callDuration;

  SeniorReport({
    required this.date,
    required this.seniorName,
    required this.mood,
    required this.summary,
    required this.callDuration,
  });
}
