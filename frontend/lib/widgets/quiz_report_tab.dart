import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/report_data.dart';

/// Quiz Report Tab - Cognitive Status Tracking
class QuizReportTab extends StatelessWidget {
  final List<QuizReport> reports;

  const QuizReportTab({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    // Calculate overall success rate
    final totalQuestions = reports.fold<int>(
      0,
      (sum, report) => sum + report.numQuestions,
    );
    final totalCorrect = reports.fold<int>(
      0,
      (sum, report) => sum + report.numCorrect,
    );
    final overallRate = totalCorrect / totalQuestions * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Rate Indicator
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
                    '전체 정답률',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        percentage: overallRate,
                        color: const Color(0xFF6750A4),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${overallRate.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6750A4),
                              ),
                            ),
                            Text(
                              '$totalCorrect/$totalQuestions',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF49454F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cognitive Trend
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Color(0xFF6750A4),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      MockReportData.getCognitiveTrend(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recent Quiz Attempts
          const Text(
            '최근 퀴즈 기록',
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
              return _buildQuizCard(report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizReport report) {
    final successRate = report.successRate;
    final isGoodScore = successRate >= 80;
    final isMediumScore = successRate >= 60 && successRate < 80;

    Color scoreColor;
    IconData scoreIcon;

    if (isGoodScore) {
      scoreColor = const Color(0xFF2E7D32);
      scoreIcon = Icons.check_circle;
    } else if (isMediumScore) {
      scoreColor = const Color(0xFFE65100);
      scoreIcon = Icons.warning_amber_rounded;
    } else {
      scoreColor = const Color(0xFFC62828);
      scoreIcon = Icons.error;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(scoreIcon, color: scoreColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${successRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(report.startedAt),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.numCorrect}/${report.numQuestions} 정답',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF49454F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.quizMode == 'daily' ? '일일 퀴즈' : '주간 퀴즈',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
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

/// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _CircularProgressPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
