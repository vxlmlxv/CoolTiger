import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:just_audio/just_audio.dart';

import '../../../config/env.dart';
import '../../senior/models/transcript_entry.dart';
import '../../../models/models.dart';
import 'package:cooltiger_app/features/showcase/recording/web_audio_recorder.dart';

final showcaseControllerProvider =
    ChangeNotifierProvider.autoDispose<ShowcaseController>((ref) {
  final controller = ShowcaseController(
    recorder: createWebAudioRecorder(),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

enum ShowcaseState {
  idle,
  recording,
  thinking,
  playing,
  training,
  unsupported,
  error,
}

class ShowcaseController extends ChangeNotifier {
  ShowcaseController({required WebAudioRecorder recorder}) : _recorder = recorder {
    if (!_recorder.isSupported) {
      _state = ShowcaseState.unsupported;
    }
  }

  final WebAudioRecorder _recorder;
  final http.Client _client = http.Client();
  final AudioPlayer _player = AudioPlayer();

  ShowcaseState _state = ShowcaseState.idle;
  String? _error;
  List<TranscriptEntry> _transcripts = [];
  TrainingModuleResponse? _activeModule;

  ShowcaseState get state => _state;
  String? get error => _error;
  List<TranscriptEntry> get transcripts => List.unmodifiable(_transcripts);
  TrainingModuleResponse? get activeModule => _activeModule;
  bool get isRecording => _state == ShowcaseState.recording;

  Future<void> startRecording() async {
    if (!_recorder.isSupported) {
      _setState(ShowcaseState.unsupported, error: 'Browser lacks MediaRecorder support.');
      return;
    }
    if (_state == ShowcaseState.recording) return;
    try {
      await _recorder.start();
      _setState(ShowcaseState.recording);
    } catch (err) {
      _setState(ShowcaseState.error, error: 'Failed to access microphone: $err');
    }
  }

  Future<void> stopAndUpload() async {
    if (_state != ShowcaseState.recording) return;
    try {
      final bytes = await _recorder.stop();
      if (bytes.isEmpty) {
        _setState(ShowcaseState.error, error: 'No audio captured');
        return;
      }
      await _upload(bytes);
    } catch (err) {
      _setState(ShowcaseState.error, error: 'Upload failed: $err');
    }
  }

  Future<void> _upload(Uint8List bytes) async {
    _setState(ShowcaseState.thinking);
    _activeModule = null;
    notifyListeners();
    final uri = Uri.parse('${Env.apiBaseUrl}/conversation');
    final request = http.MultipartRequest('POST', uri)
      ..fields['seniorId'] = 'showcase-senior'
      ..fields['guardianId'] = 'showcase-guardian'
      ..files.add(http.MultipartFile.fromBytes(
        'audio_file',
        bytes,
        filename: 'browser.webm',
        contentType: MediaType('audio', 'webm'),
      ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 400) {
      throw Exception('Backend returned ${response.statusCode}');
    }
    await _logTranscript('user', 'Browser voice clip');
    await _handleResponse(response);
  }

  Future<void> _handleResponse(http.Response response) async {
    final type = response.headers['content-type'] ?? '';
    if (type.contains('application/json')) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final module = TrainingModuleResponse.fromJson(payload);
      _activeModule = module;
      await _logTranscript('ai', module.ttsPrompt);
      _setState(ShowcaseState.training);
      return;
    }
    await _playAudio(response.bodyBytes);
  }

  Future<void> _playAudio(Uint8List bytes) async {
    _setState(ShowcaseState.playing);
    final dataUri = Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg');
    await _player.setUrl(dataUri.toString());
    await _player.play();
    await _logTranscript('ai', 'Audio response');
    _setState(ShowcaseState.idle);
  }

  Future<void> _logTranscript(String speaker, String text) async {
    final entry = TranscriptEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      speaker: speaker,
      text: text,
      timestamp: DateTime.now(),
    );
    _transcripts = [..._transcripts, entry];
    notifyListeners();
  }

  void _setState(ShowcaseState newState, {String? error}) {
    _state = newState;
    _error = error;
    notifyListeners();
  }

  Future<void> markTrainingComplete({String note = 'Training module finished'}) async {
    await _logTranscript('ai', note);
    _activeModule = null;
    _setState(ShowcaseState.idle);
  }

  @override
  void dispose() {
    _player.dispose();
    _client.close();
    super.dispose();
  }
}
