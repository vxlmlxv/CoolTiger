import 'package:flutter/material.dart';
import '../models/report_data.dart';

/// Exercise Report Tab - Physical Activity Tracking
class ExerciseReportTab extends StatelessWidget {
  final List<ExerciseReport> reports;

  const ExerciseReportTab({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    // Calculate total active time for the week
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final weeklyReports = reports
        .where((r) => r.performedAt.isAfter(oneWeekAgo))
        .toList();

    final totalSeconds = weeklyReports.fold<int>(
      0,
      (sum, report) => sum + report.lengthSeconds,
    );

    final totalMinutes = totalSeconds ~/ 60;
    final completedCount = weeklyReports.where((r) => r.completed).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFFE8DEF8), // Light purple
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '이번 주 활동 시간',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        icon: Icons.timer,
                        value: '$totalMinutes분',
                        label: '총 운동 시간',
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: const Color(0xFF6750A4).withOpacity(0.3),
                      ),
                      _buildStatColumn(
                        icon: Icons.check_circle,
                        value: '$completedCount회',
                        label: '완료한 운동',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Exercise Sessions
          const Text(
            '운동 기록',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B20),
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildExerciseCard(report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6750A4), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF49454F)),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseReport report) {
    final hasIssue =
        !report.completed ||
        (report.note != null &&
            (report.note!.contains('통증') ||
                report.note!.contains('중단') ||
                report.note!.contains('어려')));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasIssue
            ? const BorderSide(color: Color(0xFFFF8D28), width: 2)
            : BorderSide.none,
      ),
      color: hasIssue ? const Color(0xFFFFF3E0) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Status Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: report.completed
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    report.completed
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: report.completed
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Exercise Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.exerciseId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(report.performedAt),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Duration
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6750A4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: Color(0xFF6750A4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.durationDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Note (if exists)
            if (report.note != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasIssue ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasIssue
                        ? Colors.orange.shade300
                        : Colors.blue.shade300,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      hasIssue ? Icons.info : Icons.note,
                      color: hasIssue ? Colors.orange : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.note!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1D1B20),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) {
      return '오늘';
    } else if (diff == 1) {
      return '어제';
    } else if (diff < 7) {
      return '$diff일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}
