// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Guardian _$GuardianFromJson(Map<String, dynamic> json) => _Guardian(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$GuardianToJson(_Guardian instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
};

_SeniorSettings _$SeniorSettingsFromJson(Map<String, dynamic> json) =>
    _SeniorSettings(
      checkinTime: json['checkinTime'] as String,
      proactiveCall: json['proactiveCall'] as bool? ?? true,
    );

Map<String, dynamic> _$SeniorSettingsToJson(_SeniorSettings instance) =>
    <String, dynamic>{
      'checkinTime': instance.checkinTime,
      'proactiveCall': instance.proactiveCall,
    };

_Senior _$SeniorFromJson(Map<String, dynamic> json) => _Senior(
  id: json['id'] as String,
  guardianId: json['guardianId'] as String,
  name: json['name'] as String,
  settings: SeniorSettings.fromJson(json['settings'] as Map<String, dynamic>),
  personalHistory:
      json['personalHistory'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
);

Map<String, dynamic> _$SeniorToJson(_Senior instance) => <String, dynamic>{
  'id': instance.id,
  'guardianId': instance.guardianId,
  'name': instance.name,
  'settings': instance.settings,
  'personalHistory': instance.personalHistory,
};

_ConversationLog _$ConversationLogFromJson(Map<String, dynamic> json) =>
    _ConversationLog(
      id: json['id'] as String,
      seniorId: json['seniorId'] as String,
      guardianId: json['guardianId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      speaker: $enumDecode(_$ConversationSpeakerEnumMap, json['speaker']),
      transcript: json['transcript'] as String,
      audioUrl: json['audioUrl'] as String?,
      analysisStatus: json['analysisStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$ConversationLogToJson(_ConversationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seniorId': instance.seniorId,
      'guardianId': instance.guardianId,
      'timestamp': instance.timestamp.toIso8601String(),
      'speaker': _$ConversationSpeakerEnumMap[instance.speaker]!,
      'transcript': instance.transcript,
      'audioUrl': instance.audioUrl,
      'analysisStatus': instance.analysisStatus,
    };

const _$ConversationSpeakerEnumMap = {
  ConversationSpeaker.user: 'user',
  ConversationSpeaker.ai: 'ai',
};

_AnalysisMetrics _$AnalysisMetricsFromJson(Map<String, dynamic> json) =>
    _AnalysisMetrics(
      sentiment: json['sentiment'] as String,
      wordCount: (json['wordCount'] as num).toInt(),
      ttr: (json['ttr'] as num).toDouble(),
      speakingRate: (json['speakingRate'] as num).toInt(),
    );

Map<String, dynamic> _$AnalysisMetricsToJson(_AnalysisMetrics instance) =>
    <String, dynamic>{
      'sentiment': instance.sentiment,
      'wordCount': instance.wordCount,
      'ttr': instance.ttr,
      'speakingRate': instance.speakingRate,
    };

_AnalysisReport _$AnalysisReportFromJson(Map<String, dynamic> json) =>
    _AnalysisReport(
      id: json['id'] as String,
      seniorId: json['seniorId'] as String,
      guardianId: json['guardianId'] as String,
      date: DateTime.parse(json['date'] as String),
      metrics: AnalysisMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$AnalysisReportToJson(_AnalysisReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seniorId': instance.seniorId,
      'guardianId': instance.guardianId,
      'date': instance.date.toIso8601String(),
      'metrics': instance.metrics,
      'summary': instance.summary,
    };

_TrainingModuleResponse _$TrainingModuleResponseFromJson(
  Map<String, dynamic> json,
) => _TrainingModuleResponse(
  type: json['type'] as String,
  ttsAudioUrl: json['tts_audio_url'] as String,
  ttsPrompt: json['tts_prompt'] as String,
  moduleType: $enumDecode(_$TrainingModuleTypeEnumMap, json['module_type']),
  moduleData: json['module_data'] as Map<String, dynamic>,
  moduleId: json['moduleId'] as String?,
);

Map<String, dynamic> _$TrainingModuleResponseToJson(
  _TrainingModuleResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'tts_audio_url': instance.ttsAudioUrl,
  'tts_prompt': instance.ttsPrompt,
  'module_type': _$TrainingModuleTypeEnumMap[instance.moduleType]!,
  'module_data': instance.moduleData,
  'moduleId': instance.moduleId,
};

const _$TrainingModuleTypeEnumMap = {
  TrainingModuleType.cardMatch: 'cardMatch',
  TrainingModuleType.memoryRecall: 'memoryRecall',
  TrainingModuleType.custom: 'custom',
};
