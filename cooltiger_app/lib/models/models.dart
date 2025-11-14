import 'dart:convert';

enum ConversationSpeaker { user, ai }

enum TrainingModuleType { cardMatch, memoryRecall, custom }

class Guardian {
  Guardian({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  factory Guardian.fromJson(Map<String, dynamic> json) => Guardian(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};
}

class SeniorSettings {
  SeniorSettings({required this.checkinTime, this.proactiveCall = true});

  final String checkinTime;
  final bool proactiveCall;

  factory SeniorSettings.fromJson(Map<String, dynamic> json) => SeniorSettings(
        checkinTime: json['checkinTime'] as String? ?? json['checkin_time'] as String? ?? '',
        proactiveCall: json['proactiveCall'] as bool? ??
            json['proactive_call'] as bool? ??
            true,
      );

  Map<String, dynamic> toJson() => {
        'checkinTime': checkinTime,
        'proactiveCall': proactiveCall,
      };
}

class Senior {
  Senior({
    required this.id,
    required this.guardianId,
    required this.name,
    required this.settings,
    this.personalHistory = const {},
  });

  final String id;
  final String guardianId;
  final String name;
  final SeniorSettings settings;
  final Map<String, dynamic> personalHistory;

  factory Senior.fromJson(Map<String, dynamic> json) => Senior(
        id: json['id'] as String,
        guardianId: json['guardianId'] as String,
        name: json['name'] as String,
        settings: SeniorSettings.fromJson(json['settings'] as Map<String, dynamic>),
        personalHistory:
            (json['personalHistory'] as Map<String, dynamic>?) ?? const {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'guardianId': guardianId,
        'name': name,
        'settings': settings.toJson(),
        'personalHistory': personalHistory,
      };
}

class ConversationLog {
  ConversationLog({
    required this.id,
    required this.seniorId,
    required this.guardianId,
    required this.timestamp,
    required this.speaker,
    required this.transcript,
    this.audioUrl,
    this.analysisStatus = 'pending',
  });

  final String id;
  final String seniorId;
  final String guardianId;
  final DateTime timestamp;
  final ConversationSpeaker speaker;
  final String transcript;
  final String? audioUrl;
  final String analysisStatus;

  factory ConversationLog.fromJson(Map<String, dynamic> json) => ConversationLog(
        id: json['id'] as String,
        seniorId: json['seniorId'] as String,
        guardianId: json['guardianId'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        speaker: ConversationSpeaker.values.firstWhere(
          (s) => s.name == (json['speaker'] as String),
          orElse: () => ConversationSpeaker.ai,
        ),
        transcript: json['transcript'] as String,
        audioUrl: json['audioUrl'] as String?,
        analysisStatus: json['analysisStatus'] as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'seniorId': seniorId,
        'guardianId': guardianId,
        'timestamp': timestamp.toIso8601String(),
        'speaker': speaker.name,
        'transcript': transcript,
        'audioUrl': audioUrl,
        'analysisStatus': analysisStatus,
      };
}

class AnalysisMetrics {
  AnalysisMetrics({
    required this.sentiment,
    required this.wordCount,
    required this.ttr,
    required this.speakingRate,
  });

  final String sentiment;
  final int wordCount;
  final double ttr;
  final int speakingRate;

  factory AnalysisMetrics.fromJson(Map<String, dynamic> json) => AnalysisMetrics(
        sentiment: json['sentiment'] as String,
        wordCount: (json['wordCount'] as num).toInt(),
        ttr: (json['ttr'] as num).toDouble(),
        speakingRate: (json['speakingRate'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'sentiment': sentiment,
        'wordCount': wordCount,
        'ttr': ttr,
        'speakingRate': speakingRate,
      };
}

class AnalysisReport {
  AnalysisReport({
    required this.id,
    required this.seniorId,
    required this.guardianId,
    required this.date,
    required this.metrics,
    required this.summary,
  });

  final String id;
  final String seniorId;
  final String guardianId;
  final DateTime date;
  final AnalysisMetrics metrics;
  final String summary;

  factory AnalysisReport.fromJson(Map<String, dynamic> json) => AnalysisReport(
        id: json['id'] as String,
        seniorId: json['seniorId'] as String,
        guardianId: json['guardianId'] as String,
        date: DateTime.parse(json['date'] as String),
        metrics: AnalysisMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
        summary: json['summary'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'seniorId': seniorId,
        'guardianId': guardianId,
        'date': date.toIso8601String(),
        'metrics': metrics.toJson(),
        'summary': summary,
      };
}

class TrainingModuleResponse {
  TrainingModuleResponse({
    required this.type,
    required this.ttsAudioUrl,
    required this.ttsPrompt,
    required this.moduleType,
    required this.moduleData,
    this.moduleId,
  });

  final String type;
  final String ttsAudioUrl;
  final String ttsPrompt;
  final TrainingModuleType moduleType;
  final Map<String, dynamic> moduleData;
  final String? moduleId;

  factory TrainingModuleResponse.fromJson(Map<String, dynamic> json) {
    final type = json['module_type'] as String? ?? 'custom';
    final moduleType = TrainingModuleType.values.firstWhere(
      (m) => m.name == type,
      orElse: () => TrainingModuleType.custom,
    );
    return TrainingModuleResponse(
      type: json['type'] as String? ?? 'training_module',
      ttsAudioUrl: json['tts_audio_url'] as String? ?? '',
      ttsPrompt: json['tts_prompt'] as String? ?? '',
      moduleType: moduleType,
      moduleData: (json['module_data'] as Map<String, dynamic>?) ?? const {},
      moduleId: json['module_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'tts_audio_url': ttsAudioUrl,
        'tts_prompt': ttsPrompt,
        'module_type': moduleType.name,
        'module_data': moduleData,
        'module_id': moduleId,
      };

  @override
  String toString() => jsonEncode(toJson());
}
