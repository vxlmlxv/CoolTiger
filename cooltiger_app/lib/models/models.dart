import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum ConversationSpeaker { user, ai }

enum TrainingModuleType { cardMatch, memoryRecall, custom }

@freezed
class Guardian with _$Guardian {
  const factory Guardian({
    required String id,
    required String email,
    required String name,
  }) = _Guardian;

  factory Guardian.fromJson(Map<String, dynamic> json) => _$GuardianFromJson(json);
}

@freezed
class SeniorSettings with _$SeniorSettings {
  const factory SeniorSettings({
    required String checkinTime,
    @Default(true) bool proactiveCall,
  }) = _SeniorSettings;

  factory SeniorSettings.fromJson(Map<String, dynamic> json) => _$SeniorSettingsFromJson(json);
}

@freezed
class Senior with _$Senior {
  const factory Senior({
    required String id,
    required String guardianId,
    required String name,
    required SeniorSettings settings,
    @Default(<String, dynamic>{}) Map<String, dynamic> personalHistory,
  }) = _Senior;

  factory Senior.fromJson(Map<String, dynamic> json) => _$SeniorFromJson(json);
}

@freezed
class ConversationLog with _$ConversationLog {
  const factory ConversationLog({
    required String id,
    required String seniorId,
    required String guardianId,
    required DateTime timestamp,
    required ConversationSpeaker speaker,
    required String transcript,
    String? audioUrl,
    @Default('pending') String analysisStatus,
  }) = _ConversationLog;

  factory ConversationLog.fromJson(Map<String, dynamic> json) => _$ConversationLogFromJson(json);
}

@freezed
class AnalysisMetrics with _$AnalysisMetrics {
  const factory AnalysisMetrics({
    required String sentiment,
    required int wordCount,
    required double ttr,
    required int speakingRate,
  }) = _AnalysisMetrics;

  factory AnalysisMetrics.fromJson(Map<String, dynamic> json) => _$AnalysisMetricsFromJson(json);
}

@freezed
class AnalysisReport with _$AnalysisReport {
  const factory AnalysisReport({
    required String id,
    required String seniorId,
    required String guardianId,
    required DateTime date,
    required AnalysisMetrics metrics,
    required String summary,
  }) = _AnalysisReport;

  factory AnalysisReport.fromJson(Map<String, dynamic> json) => _$AnalysisReportFromJson(json);
}

@freezed
class TrainingModuleResponse with _$TrainingModuleResponse {
  const factory TrainingModuleResponse({
    required String type,
    @JsonKey(name: 'tts_audio_url') required String ttsAudioUrl,
    @JsonKey(name: 'tts_prompt') required String ttsPrompt,
    @JsonKey(name: 'module_type') required TrainingModuleType moduleType,
    @JsonKey(name: 'module_data') required Map<String, dynamic> moduleData,
    String? moduleId,
  }) = _TrainingModuleResponse;

  factory TrainingModuleResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingModuleResponseFromJson(json);
}
