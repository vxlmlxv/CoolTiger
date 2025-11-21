/// Data models for senior activity reports

class CallReport {
  final DateTime date;
  final int durationMinutes;
  final String summary;
  final RiskLevel riskLevel;
  final String? careNote;

  CallReport({
    required this.date,
    required this.durationMinutes,
    required this.summary,
    required this.riskLevel,
    this.careNote,
  });
}

enum RiskLevel { low, medium, high }

class QuizReport {
  final DateTime startedAt;
  final String quizMode;
  final int numQuestions;
  final int numCorrect;

  QuizReport({
    required this.startedAt,
    required this.quizMode,
    required this.numQuestions,
    required this.numCorrect,
  });

  double get successRate => numCorrect / numQuestions * 100;
}

class ExerciseReport {
  final String exerciseId;
  final int lengthSeconds;
  final bool completed;
  final String? note;
  final DateTime performedAt;

  ExerciseReport({
    required this.exerciseId,
    required this.lengthSeconds,
    required this.completed,
    this.note,
    required this.performedAt,
  });

  String get durationDisplay {
    final minutes = lengthSeconds ~/ 60;
    final seconds = lengthSeconds % 60;
    return '${minutes}분 ${seconds}초';
  }
}

class MedicineReport {
  final String medicineId;
  final DateTime plannedAt;
  final MedicineStatus status;
  final DateTime date;

  MedicineReport({
    required this.medicineId,
    required this.plannedAt,
    required this.status,
    required this.date,
  });
}

enum MedicineStatus { taken, missed, skipped }

/// Mock data generator for testing and development
class MockReportData {
  static List<CallReport> generateCallReports() {
    final now = DateTime.now();
    return [
      CallReport(
        date: now.subtract(const Duration(days: 0)),
        durationMinutes: 15,
        summary: '오늘은 손주들과 통화했다는 이야기를 하셨습니다. 기분이 좋아 보이셨어요.',
        riskLevel: RiskLevel.low,
      ),
      CallReport(
        date: now.subtract(const Duration(days: 1)),
        durationMinutes: 22,
        summary: '최근 잠을 잘 못 주무신다고 하셨습니다. 가벼운 걱정이 있으신 것 같습니다.',
        riskLevel: RiskLevel.medium,
      ),
      CallReport(
        date: now.subtract(const Duration(days: 2)),
        durationMinutes: 18,
        summary: '혼자 계시는 시간이 많아 외로움을 많이 느끼신다고 말씀하셨습니다.',
        riskLevel: RiskLevel.high,
        careNote: '심각한 고독감을 표현하셨습니다. 보호자님의 방문이나 전화가 필요합니다.',
      ),
      CallReport(
        date: now.subtract(const Duration(days: 3)),
        durationMinutes: 12,
        summary: '오늘은 날씨가 좋아서 산책을 다녀오셨다고 합니다.',
        riskLevel: RiskLevel.low,
      ),
      CallReport(
        date: now.subtract(const Duration(days: 4)),
        durationMinutes: 25,
        summary: '약 복용을 가끔 잊으신다고 하셨습니다. 알람 설정을 도와드렸습니다.',
        riskLevel: RiskLevel.medium,
      ),
      CallReport(
        date: now.subtract(const Duration(days: 5)),
        durationMinutes: 20,
        summary: '이웃 어르신과 함께 점심을 드셨다고 하시며 즐거워하셨습니다.',
        riskLevel: RiskLevel.low,
      ),
      CallReport(
        date: now.subtract(const Duration(days: 6)),
        durationMinutes: 16,
        summary: '건강검진 결과를 기다리고 계셔서 조금 불안해하셨습니다.',
        riskLevel: RiskLevel.medium,
      ),
    ];
  }

  static List<QuizReport> generateQuizReports() {
    final now = DateTime.now();
    return [
      QuizReport(
        startedAt: now.subtract(const Duration(days: 0)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 8,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 1)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 9,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 2)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 7,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 3)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 8,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 4)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 9,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 5)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 6,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 6)),
        quizMode: 'daily',
        numQuestions: 10,
        numCorrect: 8,
      ),
      QuizReport(
        startedAt: now.subtract(const Duration(days: 7)),
        quizMode: 'weekly',
        numQuestions: 20,
        numCorrect: 16,
      ),
    ];
  }

  static List<ExerciseReport> generateExerciseReports() {
    final now = DateTime.now();
    return [
      ExerciseReport(
        exerciseId: '다리 올리기',
        lengthSeconds: 280,
        completed: true,
        performedAt: now.subtract(const Duration(days: 0)),
      ),
      ExerciseReport(
        exerciseId: '팔 스트레칭',
        lengthSeconds: 240,
        completed: true,
        performedAt: now.subtract(const Duration(days: 0)),
      ),
      ExerciseReport(
        exerciseId: '허벅지 강화 운동',
        lengthSeconds: 180,
        completed: false,
        note: '무릎 통증으로 중간에 중단했습니다.',
        performedAt: now.subtract(const Duration(days: 1)),
      ),
      ExerciseReport(
        exerciseId: '목 스트레칭',
        lengthSeconds: 300,
        completed: true,
        performedAt: now.subtract(const Duration(days: 1)),
      ),
      ExerciseReport(
        exerciseId: '어깨 운동',
        lengthSeconds: 360,
        completed: true,
        performedAt: now.subtract(const Duration(days: 2)),
      ),
      ExerciseReport(
        exerciseId: '발목 운동',
        lengthSeconds: 200,
        completed: true,
        note: '처음엔 어려웠지만 잘 따라하셨습니다.',
        performedAt: now.subtract(const Duration(days: 3)),
      ),
      ExerciseReport(
        exerciseId: '전신 스트레칭',
        lengthSeconds: 420,
        completed: true,
        performedAt: now.subtract(const Duration(days: 4)),
      ),
      ExerciseReport(
        exerciseId: '호흡 운동',
        lengthSeconds: 180,
        completed: false,
        note: '숨이 차서 조기 종료했습니다.',
        performedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<MedicineReport> generateMedicineReports() {
    final now = DateTime.now();
    final reports = <MedicineReport>[];

    // Generate 3 weeks of medicine data (morning and evening)
    for (int day = 0; day < 21; day++) {
      final date = now.subtract(Duration(days: day));

      // Morning dose
      reports.add(
        MedicineReport(
          medicineId: '혈압약',
          plannedAt: DateTime(date.year, date.month, date.day, 8, 0),
          status: day == 2 || day == 8 || day == 15
              ? MedicineStatus.missed
              : day == 5
              ? MedicineStatus.skipped
              : MedicineStatus.taken,
          date: date,
        ),
      );

      // Evening dose
      reports.add(
        MedicineReport(
          medicineId: '소화제',
          plannedAt: DateTime(date.year, date.month, date.day, 20, 0),
          status: day == 3 || day == 12
              ? MedicineStatus.missed
              : day == 7 || day == 18
              ? MedicineStatus.skipped
              : MedicineStatus.taken,
          date: date,
        ),
      );
    }

    return reports.reversed.toList();
  }

  static String getWeeklySentiment() {
    final sentiments = [
      '지난주보다 기분이 좋아지셨습니다 😊',
      '감정 상태가 안정적입니다',
      '약간의 걱정이 있으신 것 같습니다',
      '전반적으로 긍정적인 한 주였습니다',
    ];
    return sentiments[0]; // Return first one for consistent demo
  }

  static String getCognitiveTrend() {
    final trends = [
      '기억력 과제에서 꾸준한 향상을 보이고 있습니다 📈',
      '인지 능력이 안정적으로 유지되고 있습니다',
      '주의력 과제에서 좋은 성과를 보이고 있습니다',
      '전반적으로 우수한 수행 능력을 보이고 있습니다',
    ];
    return trends[0]; // Return first one for consistent demo
  }
}
