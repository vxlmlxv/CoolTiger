# Senior Reports Feature

## Overview

Comprehensive activity tracking system with 4 distinct report types visualizing senior health data with realistic dummy data.

## Components Created

### 1. Data Models (`lib/models/report_data.dart`)

- **CallReport**: Mental health tracking with risk levels (Low/Medium/High)
- **QuizReport**: Cognitive ability assessment with success rates
- **ExerciseReport**: Physical activity monitoring with completion status
- **MedicineReport**: Medication adherence tracking with taken/missed/skipped status
- **MockReportData**: Generates realistic dummy data for all report types

### 2. Report Tab Widgets

#### CallReportTab (`lib/widgets/call_report_tab.dart`)

**Features:**

- Weekly sentiment trend card (purple background)
- Daily call summaries with duration
- Risk level badges (Low=Green, Medium=Orange, High=Red)
- High-risk calls highlighted with light red background
- Care notes for critical situations (e.g., "severe loneliness")
- Senior-friendly 18px+ fonts

**Key Highlights:**

- High-risk entries show warning with care notes
- Border color changes based on risk level
- Responsive card layout with proper spacing

#### QuizReportTab (`lib/widgets/quiz_report_tab.dart`)

**Features:**

- Circular success rate indicator (custom painted)
- Overall percentage display with total correct/total questions
- Cognitive trend insights (e.g., "Steady improvement in memory tasks")
- Individual quiz cards with score icons (✓/⚠/✗)
- Daily vs Weekly quiz mode differentiation

**Key Highlights:**

- Custom circular progress painter showing 0-100%
- Color-coded scores: Green (≥80%), Orange (60-79%), Red (<60%)
- Recent quiz attempts listed chronologically

#### ExerciseReportTab (`lib/widgets/exercise_report_tab.dart`)

**Features:**

- Weekly summary card: Total active time + completed sessions
- Exercise session cards with duration display
- Warning icons for incomplete exercises or pain notes
- Special highlighting for sessions with issues (orange border)
- Exercise notes display (e.g., "Stopped due to knee pain")

**Key Highlights:**

- Detects pain keywords ("통증", "중단", "어려") and highlights
- Shows duration in "X분 Y초" format
- Completed vs incomplete visual differentiation

#### MedicineReportTab (`lib/widgets/medicine_report_tab.dart`)

**Features:**

- Adherence percentage for current week
- Adherence calendar with daily status (✓/✗ indicators)
- Medicine list showing scheduled times
- Detailed history: taken/missed/skipped with timestamps
- Color-coded status badges

**Key Highlights:**

- Calendar view groups by day showing all doses
- Green checks for taken, red X for missed, orange for skipped
- "18/20 doses this week" summary
- Morning/evening dose tracking

### 3. Main Screen (`lib/screens/senior_reports_screen.dart`)

**Features:**

- TabBar with 4 tabs: 통화/퀴즈/운동/복약
- Purple/Orange senior-friendly theme
- SeniorAppBar integration
- SafeArea + scrollable content
- Header with title "활동 리포트"

## Usage

### Navigation

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const SeniorReportsScreen(),
  ),
);
```

### Using Individual Tabs

Each tab can be used standalone:

```dart
// Example: Embed in another screen
TabBarView(
  children: [
    CallReportTab(reports: MockReportData.generateCallReports()),
    QuizReportTab(reports: MockReportData.generateQuizReports()),
    // ...
  ],
)
```

## Data Structure Examples

### Call Report

```dart
CallReport(
  date: DateTime.now(),
  durationMinutes: 15,
  summary: '오늘은 손주들과 통화했다는 이야기를 하셨습니다.',
  riskLevel: RiskLevel.low,
  careNote: null, // Only for high-risk
)
```

### Quiz Report

```dart
QuizReport(
  startedAt: DateTime.now(),
  quizMode: 'daily',
  numQuestions: 10,
  numCorrect: 8,
)
```

### Exercise Report

```dart
ExerciseReport(
  exerciseId: '다리 올리기',
  lengthSeconds: 280,
  completed: true,
  note: '처음엔 어려웠지만 잘 따라하셨습니다.',
  performedAt: DateTime.now(),
)
```

### Medicine Report

```dart
MedicineReport(
  medicineId: '혈압약',
  plannedAt: DateTime(2024, 1, 1, 8, 0),
  status: MedicineStatus.taken,
  date: DateTime.now(),
)
```

## Backend Integration (TODO)

Replace mock data with API calls:

```dart
// In SeniorReportsScreen
Future<void> _loadReports() async {
  final response = await dio.get('$backendUrl/reports/senior/$seniorId');
  setState(() {
    _callReports = (response.data['calls'] as List)
        .map((json) => CallReport.fromJson(json))
        .toList();
    // ... load other reports
  });
}
```

## Design Specifications

### Colors

- Primary Purple: `#6750A4`
- Light Purple: `#E8DEF8`
- Orange Accent: `#FF8D28`
- Background: `#F5F3F7`
- Success Green: `#2E7D32`
- Warning Orange: `#E65100`
- Error Red: `#C62828`

### Typography

- Titles: 22-28px, Bold
- Body: 16-18px, Regular
- Labels: 14-16px
- Large numbers: 36-48px, Bold

### Spacing

- Card padding: 16-20px
- Between cards: 12px
- Section spacing: 20px
- Border radius: 12px

## Testing Checklist

✅ All tabs display mock data correctly
✅ No overflow errors on various screen sizes
✅ Cards are scrollable in each tab
✅ High-risk call entries show red background + care notes
✅ Quiz circular indicator displays correct percentage
✅ Exercise warnings show for incomplete/pain notes
✅ Medicine calendar shows proper ✓/✗ indicators
✅ Purple/Orange theme consistent throughout
✅ Senior-friendly large fonts (18px+)
✅ Tab switching works smoothly
✅ SafeArea prevents notch/navigation overlap

## Notes

- All dummy data generated via `MockReportData` class
- 7 days of call data, 8 quiz attempts, 8 exercises, 21 days of medicine data
- Dates formatted as "오늘", "어제", "X일 전", or "M월 D일 (요일)"
- Fully responsive with `SingleChildScrollView` in each tab
- Ready for backend integration - just swap MockReportData calls with API requests
