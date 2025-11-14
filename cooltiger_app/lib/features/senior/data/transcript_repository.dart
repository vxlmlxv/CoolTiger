import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transcript_entry.dart';

class TranscriptRepository {
  TranscriptRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<List<TranscriptEntry>> load(String seniorId) async {
    final raw = _prefs.getStringList(_key(seniorId)) ?? <String>[];
    return raw
        .map((item) => TranscriptEntry.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(String seniorId, TranscriptEntry entry) async {
    final list = List<String>.from(_prefs.getStringList(_key(seniorId)) ?? <String>[]);
    list.add(jsonEncode(entry.toJson()));
    await _prefs.setStringList(_key(seniorId), list);
  }

  Future<void> clear(String seniorId) async {
    await _prefs.remove(_key(seniorId));
  }

  String _key(String seniorId) => 'transcripts_$seniorId';
}
