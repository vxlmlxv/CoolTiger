import 'dart:convert';

class TranscriptEntry {
  TranscriptEntry({
    required this.id,
    required this.speaker,
    required this.text,
    required this.timestamp,
  });

  factory TranscriptEntry.fromJson(Map<String, dynamic> json) => TranscriptEntry(
        id: json['id'] as String,
        speaker: json['speaker'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  final String id;
  final String speaker;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'speaker': speaker,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => jsonEncode(toJson());
}
