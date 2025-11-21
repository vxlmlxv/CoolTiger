import 'package:flutter/material.dart';
import '../models/report_data.dart';

/// Call Report Tab - Mental Health & Risk Level Tracking
class CallReportTab extends StatelessWidget {
  final List<CallReport> reports;

  const CallReportTab({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Sentiment Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFFE8DEF8), // Light purple
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Color(0xFF6750A4),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '주간 감정 동향',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    MockReportData.getWeeklySentiment(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Daily Call Reports
          const Text(
            '최근 통화 기록',
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
              return _buildCallCard(report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCallCard(CallReport report) {
    final isHighRisk = report.riskLevel == RiskLevel.high;
    final isMediumRisk = report.riskLevel == RiskLevel.medium;

    Color cardColor = Colors.white;
    Color borderColor = const Color(0xFFCAC4D0);

    if (isHighRisk) {
      cardColor = const Color(0xFFFFEBEE); // Light red
      borderColor = const Color(0xFFEF5350);
    } else if (isMediumRisk) {
      cardColor = const Color(0xFFFFF3E0); // Light orange
      borderColor = const Color(0xFFFF8D28);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date and Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(report.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B20),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Color(0xFF49454F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.durationMinutes}분',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF49454F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Risk Level Badge
            _buildRiskBadge(report.riskLevel),
            const SizedBox(height: 12),

            // Summary
            Text(
              report.summary,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1D1B20),
                height: 1.4,
              ),
            ),

            // Care Note (only for high risk)
            if (report.careNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '돌봄 노트',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.careNote!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1D1B20),
                            ),
                          ),
                        ],
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

  Widget _buildRiskBadge(RiskLevel level) {
    String text;
    Color bgColor;
    Color textColor;

    switch (level) {
      case RiskLevel.low:
        text = '안정';
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case RiskLevel.medium:
        text = '주의';
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case RiskLevel.high:
        text = '위험';
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
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
    }

    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
  }
}
