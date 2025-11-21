import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../widgets/guardian_bottom_nav.dart';
import '../widgets/logout_action_button.dart';

/// Guardian Reports Screen with calendar and activity reports.
///
/// Features:
/// - Goal achievement calendar with completed day markers
/// - Month/Year navigation
/// - 4-tab report sections: AI 상담, 인지, 운동, 복약
/// - Scrollable report lists
class GuardianReportsScreen extends StatefulWidget {
  const GuardianReportsScreen({super.key});

  @override
  State<GuardianReportsScreen> createState() => _GuardianReportsScreenState();
}

class _GuardianReportsScreenState extends State<GuardianReportsScreen> {
  int _selectedTabIndex = 0;
  int _currentMonth = 8; // August
  int _currentYear = 2025;

  // Mock data: days with completed AI calls
  final Set<int> _completedDays = {11, 12, 13, 17, 20, 21, 25, 26};

  // Calculate calendar statistics
  int get _totalDaysInMonth {
    return DateTime(_currentYear, _currentMonth + 1, 0).day;
  }

  int get _completedDaysCount => _completedDays.length;

  @override
  Widget build(BuildContext context) {
    // Calculate sizes based on available width to avoid overflows on small screens.
    const maxContentWidth = 520.0;
    const horizontalPadding = 18.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 보고서'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: const [LogoutActionButton()],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: GuardianBottomNav(
        currentIndex: 1, // Report tab is active
        onTap: (index) {
          // Handle navigation
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/guardian-home');
          }
          // index 1 is current screen
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final constrainedWidth =
              constraints.maxWidth > maxContentWidth ? maxContentWidth : constraints.maxWidth;
          final contentWidth = math.max(0, constrainedWidth - (horizontalPadding * 2));
          final calendarAvailableWidth = math.max(0, contentWidth - 24);
          final cellSize =
              math.max(36.0, math.min(56.0, calendarAvailableWidth / 7));
          final reportHeight = math.max(
            280.0,
            MediaQuery.of(context).size.height * 0.45,
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '목표 달성률 달력',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '이번 달 $_totalDaysInMonth일 중 $_completedDaysCount일 함께했어요!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Calendar section
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Month/Year navigation
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Month selector
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _previousMonth,
                                        iconSize: 24,
                                      ),
                                      _buildDropdownButton(
                                        _getMonthName(_currentMonth),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _nextMonth,
                                        iconSize: 24,
                                      ),
                                    ],
                                  ),
                                  // Year selector
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _previousYear,
                                        iconSize: 24,
                                      ),
                                      _buildDropdownButton('$_currentYear'),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _nextYear,
                                        iconSize: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Calendar grid
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Column(
                                children: [
                                  // Days of week header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                                        .map(
                                          (day) => SizedBox(
                                            width: cellSize,
                                            height: cellSize,
                                            child: Center(
                                              child: Text(
                                                day,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),

                                  // Calendar days
                                  ..._buildCalendarWeeks(cellSize),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Report section title
                      const Text(
                        '상담 보고서',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Segmented control tabs
                      _buildSegmentedControl(),

                      const SizedBox(height: 8),

                      // Report content area
                      Container(
                        height: reportHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildReportContent(),
                      ),

                      const SizedBox(height: 32), // Bottom spacing
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

  Widget _buildDropdownButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: Color(0xFF49454F),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF49454F)),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks(double cellSize) {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sunday
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final daysInPrevMonth = DateTime(_currentYear, _currentMonth, 0).day;

    final List<Widget> weeks = [];
    final List<Widget> currentWeek = [];

    // Previous month's trailing days
    for (int i = firstWeekday - 1; i >= 0; i--) {
      currentWeek.add(
        _buildCalendarDay(
          day: daysInPrevMonth - i,
          isCurrentMonth: false,
          isCompleted: false,
          cellSize: cellSize,
        ),
      );
    }

    // Current month's days
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(
        _buildCalendarDay(
          day: day,
          isCurrentMonth: true,
          isCompleted: _completedDays.contains(day),
          cellSize: cellSize,
        ),
      );

      if (currentWeek.length == 7) {
        weeks.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.from(currentWeek),
          ),
        );
        currentWeek.clear();
      }
    }

    // Next month's leading days
    if (currentWeek.isNotEmpty) {
      int nextMonthDay = 1;
      while (currentWeek.length < 7) {
        currentWeek.add(
          _buildCalendarDay(
            day: nextMonthDay++,
            isCurrentMonth: false,
            isCompleted: false,
            cellSize: cellSize,
          ),
        );
      }
      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.from(currentWeek),
        ),
      );
    }

    return weeks;
  }

  Widget _buildCalendarDay({
    required int day,
    required bool isCurrentMonth,
    required bool isCompleted,
    required double cellSize,
  }) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Center(
        child: Container(
          width: cellSize - 8,
          height: cellSize - 8,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF6750A4) // M3 primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isCompleted
                    ? Colors.white
                    : isCurrentMonth
                    ? const Color(0xFF1D1B20)
                    : const Color(0xFF49454F).withOpacity(0.38),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 48,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _buildSegmentButton('AI 상담', 0),
          _buildSegmentButton('인지', 1),
          _buildSegmentButton('운동', 2),
          _buildSegmentButton('복약', 3),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    final isFirst = index == 0;
    final isLast = index == 3;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF625B71) // M3 secondary
                : const Color(0xFFE8DEF8), // M3 secondary-container
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(24) : Radius.zero,
              right: isLast ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: isSelected
                    ? Colors
                          .white // M3 on-secondary
                    : const Color(0xFF4A4459), // M3 on-secondary-container
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    // Mock data
    final callReports = MockReportData.generateCallReports();
    final quizReports = MockReportData.generateQuizReports();
    final exerciseReports = MockReportData.generateExerciseReports();
    final medicineReports = MockReportData.generateMedicineReports();

    Widget content;

    switch (_selectedTabIndex) {
      case 0: // AI 상담
        content = ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: callReports.length,
          itemBuilder: (context, index) {
            final report = callReports[index];
            return _buildCallReportCard(report);
          },
        );
        break;
      case 1: // 인지
        content = ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizReports.length,
          itemBuilder: (context, index) {
            final report = quizReports[index];
            return _buildQuizReportCard(report);
          },
        );
        break;
      case 2: // 운동
        content = ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exerciseReports.length,
          itemBuilder: (context, index) {
            final report = exerciseReports[index];
            return _buildExerciseReportCard(report);
          },
        );
        break;
      case 3: // 복약
        content = ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: medicineReports.length,
          itemBuilder: (context, index) {
            final report = medicineReports[index];
            return _buildMedicineReportCard(report);
          },
        );
        break;
      default:
        content = const Center(child: Text('보고서를 선택하세요'));
    }

    return content;
  }

  Widget _buildCallReportCard(CallReport report) {
    final riskColor = report.riskLevel == RiskLevel.high
        ? const Color(0xFFC62828)
        : report.riskLevel == RiskLevel.medium
        ? const Color(0xFFE65100)
        : const Color(0xFF2E7D32);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(report.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.riskLevel == RiskLevel.high
                        ? '높음'
                        : report.riskLevel == RiskLevel.medium
                        ? '중간'
                        : '낮음',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report.summary,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${report.durationMinutes}분',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizReportCard(QuizReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(report.startedAt),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.quizMode,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              '${report.numCorrect}/${report.numQuestions}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseReportCard(ExerciseReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(report.performedAt),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  report.completed ? Icons.check_circle : Icons.warning,
                  color: report.completed
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.exerciseId, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              '${report.lengthSeconds ~/ 60}분 ${report.lengthSeconds % 60}초',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineReportCard(MedicineReport report) {
    final statusColor = report.status == MedicineStatus.taken
        ? const Color(0xFF2E7D32)
        : report.status == MedicineStatus.missed
        ? const Color(0xFFC62828)
        : const Color(0xFF616161);

    // Determine time of day based on plannedAt hour
    final timeOfDay = report.plannedAt.hour < 12 ? '아침' : '저녁';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(report.date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeOfDay,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.status == MedicineStatus.taken
                    ? '복용'
                    : report.status == MedicineStatus.missed
                    ? '미복용'
                    : '건너뜀',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
      return '${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _previousYear() {
    setState(() {
      _currentYear--;
    });
  }

  void _nextYear() {
    setState(() {
      _currentYear++;
    });
  }
}
