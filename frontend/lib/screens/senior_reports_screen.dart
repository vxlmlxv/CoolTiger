import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../widgets/senior_bottom_nav.dart';
import '../widgets/call_report_tab.dart';
import '../widgets/quiz_report_tab.dart';
import '../widgets/exercise_report_tab.dart';
import '../widgets/medicine_report_tab.dart';

/// Senior Reports Screen with calendar and activity reports.
///
/// Features:
/// - Goal achievement calendar with completed day markers
/// - Month/Year navigation
/// - 4-tab report sections: AI 상담, 인지, 운동, 복약
/// - Scrollable report lists
/// - Bottom navigation for seniors
class SeniorReportsScreen extends StatefulWidget {
  const SeniorReportsScreen({super.key});

  @override
  State<SeniorReportsScreen> createState() => _SeniorReportsScreenState();
}

class _SeniorReportsScreenState extends State<SeniorReportsScreen> {
  int _selectedTabIndex = 0;
  int _currentNavIndex = 1; // Reports tab is selected
  int _currentMonth = 8; // August
  int _currentYear = 2025;

  // Mock data: days with completed AI calls
  final Set<int> _completedDays = {11, 12, 13, 17, 20, 21, 25, 26};

  // Calculate calendar statistics
  int get _totalDaysInMonth {
    return DateTime(_currentYear, _currentMonth + 1, 0).day;
  }

  int get _completedDaysCount => _completedDays.length;

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/senior-home');
        break;
      case 1:
        // Already on reports, do nothing
        break;
      case 2:
        // Navigate to My Info
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('내정보 화면 준비 중입니다')));
        break;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '목표 달성률 달력',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '이번 달 $_totalDaysInMonth일 중 $_completedDaysCount일 함께했어요!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              height: 1.21,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calendar Widget
                    CalendarWidget(
                      currentMonth: _currentMonth,
                      currentYear: _currentYear,
                      completedDays: _completedDays,
                      onPreviousMonth: _previousMonth,
                      onNextMonth: _nextMonth,
                      onPreviousYear: _previousYear,
                      onNextYear: _nextYear,
                      getMonthName: _getMonthName,
                    ),

                    const SizedBox(height: 24),

                    // Report Section Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        '상담 보고서',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Report Tab Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: ReportTabSelector(
                        selectedIndex: _selectedTabIndex,
                        onTabSelected: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                      ),
                    ),

                    // Report Content Area
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minHeight: 314),
                      child: _buildReportContent(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            SeniorBottomNav(
              currentIndex: _currentNavIndex,
              onTap: _onNavItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedTabIndex) {
      case 0:
        return CallReportTab(reports: MockReportData.generateCallReports());
      case 1:
        return QuizReportTab(reports: MockReportData.generateQuizReports());
      case 2:
        return ExerciseReportTab(
          reports: MockReportData.generateExerciseReports(),
        );
      case 3:
        return MedicineReportTab(
          reports: MockReportData.generateMedicineReports(),
        );
      default:
        return const SizedBox();
    }
  }
}

/// Reusable Calendar Widget
///
/// Displays a monthly calendar with navigation and completed day markers
class CalendarWidget extends StatelessWidget {
  final int currentMonth;
  final int currentYear;
  final Set<int> completedDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final String Function(int) getMonthName;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    required this.currentYear,
    required this.completedDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPreviousYear,
    required this.onNextYear,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Month/Year navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month selector
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: onPreviousMonth,
                      iconSize: 24,
                      color: const Color(0xFF49454F),
                    ),
                    _buildDropdownButton(getMonthName(currentMonth)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: onNextMonth,
                      iconSize: 24,
                      color: const Color(0xFF49454F),
                    ),
                  ],
                ),
                // Year selector
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: onPreviousYear,
                      iconSize: 24,
                      color: const Color(0xFF49454F),
                    ),
                    _buildDropdownButton('$currentYear'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: onNextYear,
                      iconSize: 24,
                      color: const Color(0xFF49454F),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Column(
              children: [
                // Days of week header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map(
                        (day) => SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1D1B20),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Calendar days grid
                _buildCalendarGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
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

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final firstWeekday = DateTime(currentYear, currentMonth, 1).weekday % 7;

    // Generate all cells (including empty leading cells)
    final List<Widget> cells = [];

    // Add empty cells for days before the 1st
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(_buildDayCell(null, isPreviousMonth: true));
    }

    // Add actual day cells
    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(_buildDayCell(day, isCompleted: completedDays.contains(day)));
    }

    // Build rows of 7 cells each
    final List<Widget> rows = [];
    for (int i = 0; i < cells.length; i += 7) {
      final rowCells = cells.sublist(
        i,
        (i + 7 < cells.length) ? i + 7 : cells.length,
      );
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: rowCells,
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(
    int? day, {
    bool isCompleted = false,
    bool isPreviousMonth = false,
  }) {
    if (day == null) {
      // Empty cell
      return const SizedBox(width: 48, height: 48);
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF6750A4) : Colors.transparent,
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
                  : (isPreviousMonth
                        ? const Color(0xFF49454F).withOpacity(0.38)
                        : const Color(0xFF1D1B20)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable Report Tab Selector widget
///
/// Displays 4 tabs: AI 상담, 인지, 운동, 복약
class ReportTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ReportTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(0, 'AI 상담'),
          _buildTab(1, '인지'),
          _buildTab(2, '운동'),
          _buildTab(3, '복약'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = selectedIndex == index;
    final isFirst = index == 0;
    final isLast = index == 3;

    BorderRadius? borderRadius;
    if (isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      );
    } else if (isLast) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF625B71) // M3 secondary
                : const Color(0xFFE8DEF8), // M3 secondary-container
            borderRadius: borderRadius,
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
}
