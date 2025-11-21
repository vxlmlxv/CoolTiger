import 'package:flutter/material.dart';
import '../models/report_data.dart';

/// Medicine Report Tab - Medication Adherence Tracking
class MedicineReportTab extends StatelessWidget {
  final List<MedicineReport> reports;

  const MedicineReportTab({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    // Calculate adherence for current week
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final weeklyReports = reports
        .where((r) => r.date.isAfter(oneWeekAgo))
        .toList();

    final takenCount = weeklyReports
        .where((r) => r.status == MedicineStatus.taken)
        .length;
    final totalDoses = weeklyReports.length;
    final adherenceRate = (takenCount / totalDoses * 100).toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adherence Summary Card
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
                    '이번 주 복약 순응도',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.medication,
                        color: Color(0xFF6750A4),
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$adherenceRate%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$takenCount/$totalDoses 회 복용',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF49454F),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Adherence Calendar
          const Text(
            '복약 캘린더',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B20),
            ),
          ),
          const SizedBox(height: 12),

          _buildAdherenceCalendar(weeklyReports),
          const SizedBox(height: 20),

          // Medicine List
          const Text(
            '복용 약물',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B20),
            ),
          ),
          const SizedBox(height: 12),

          _buildMedicineList(),
          const SizedBox(height: 20),

          // Recent History
          const Text(
            '최근 복약 기록',
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
            itemCount: reports.take(14).length, // Show last 14 entries
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildMedicineCard(report);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceCalendar(List<MedicineReport> weeklyReports) {
    // Group by day
    final dayGroups = <DateTime, List<MedicineReport>>{};
    for (var report in weeklyReports) {
      final dayKey = DateTime(
        report.date.year,
        report.date.month,
        report.date.day,
      );
      dayGroups.putIfAbsent(dayKey, () => []).add(report);
    }

    // Sort days
    final sortedDays = dayGroups.keys.toList()..sort();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedDays.map((day) {
            final dayReports = dayGroups[day]!;
            final allTaken = dayReports.every(
              (r) => r.status == MedicineStatus.taken,
            );
            final anyMissed = dayReports.any(
              (r) => r.status == MedicineStatus.missed,
            );

            Color statusColor;
            IconData statusIcon;
            if (allTaken) {
              statusColor = const Color(0xFF2E7D32);
              statusIcon = Icons.check_circle;
            } else if (anyMissed) {
              statusColor = const Color(0xFFC62828);
              statusIcon = Icons.cancel;
            } else {
              statusColor = const Color(0xFFE65100);
              statusIcon = Icons.warning_amber_rounded;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatDayOfWeek(day),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: dayReports.map((report) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildDoseIndicator(report.status),
                        );
                      }).toList(),
                    ),
                  ),
                  Icon(statusIcon, color: statusColor, size: 24),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoseIndicator(MedicineStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case MedicineStatus.taken:
        color = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        break;
      case MedicineStatus.missed:
        color = const Color(0xFFC62828);
        icon = Icons.cancel;
        break;
      case MedicineStatus.skipped:
        color = const Color(0xFFE65100);
        icon = Icons.remove_circle;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildMedicineList() {
    return Column(
      children: [
        _buildMedicineInfoCard(name: '혈압약', time: '오전 8시', color: Colors.blue),
        const SizedBox(height: 8),
        _buildMedicineInfoCard(name: '소화제', time: '오후 8시', color: Colors.green),
      ],
    );
  }

  Widget _buildMedicineInfoCard({
    required String name,
    required String time,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineReport report) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (report.status) {
      case MedicineStatus.taken:
        statusColor = const Color(0xFF2E7D32);
        statusText = '복용 완료';
        statusIcon = Icons.check_circle;
        break;
      case MedicineStatus.missed:
        statusColor = const Color(0xFFC62828);
        statusText = '복용 누락';
        statusIcon = Icons.cancel;
        break;
      case MedicineStatus.skipped:
        statusColor = const Color(0xFFE65100);
        statusText = '건너뜀';
        statusIcon = Icons.remove_circle;
        break;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.medicineId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDateShort(report.date)} ${_formatTime(report.plannedAt)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDayOfWeek(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) {
      return '오늘';
    } else if (diff == 1) {
      return '어제';
    }

    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}/${date.day} (${weekdays[date.weekday - 1]})';
  }

  String _formatDateShort(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$period $displayHour:$minute';
  }
}
