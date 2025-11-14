import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../../config/env.dart';
import '../data/transcript_repository.dart';
import '../models/transcript_entry.dart';
import '../../../models/models.dart';

final transcriptRepositoryProvider = Provider<TranscriptRepository>((ref) {
  throw UnimplementedError('transcriptRepositoryProvider must be overridden.');
});

final pressToTalkControllerProvider =
    ChangeNotifierProvider<PressToTalkController>((ref) {
  final repo = ref.watch(transcriptRepositoryProvider);
  return PressToTalkController(transcriptRepository: repo);
});

enum PressToTalkPhase {
  idle,
  recording,
  thinking,
  playing,
  training,
  error,
}

class PressToTalkController extends ChangeNotifier {
  PressToTalkController({required TranscriptRepository transcriptRepository})
      : _transcriptRepository = transcriptRepository;

  final TranscriptRepository _transcriptRepository;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final http.Client _http = http.Client();
  String? _recordingPath;

  PressToTalkPhase _phase = PressToTalkPhase.idle;
  String? _errorMessage;
  bool _fcmRegistered = false;
  String? _seniorId;
  String? _guardianId;
  final List<TranscriptEntry> _transcripts = [];
  TrainingModuleResponse? _activeModule;

  PressToTalkPhase get phase => _phase;
  String? get errorMessage => _errorMessage;
  List<TranscriptEntry> get transcripts => List.unmodifiable(_transcripts);
  TrainingModuleResponse? get activeModule => _activeModule;
  String? get seniorId => _seniorId;
  String? get guardianId => _guardianId;

  bool get isBusy => switch (_phase) {
        PressToTalkPhase.idle => false,
        PressToTalkPhase.error => false,
        _ => true,
      };

  String get statusLabel => switch (_phase) {
        PressToTalkPhase.recording => 'Recording…',
        PressToTalkPhase.thinking => 'Thinking…',
        PressToTalkPhase.playing => 'Playing reply',
        PressToTalkPhase.training => 'Training module',
        PressToTalkPhase.error => _errorMessage ?? 'Error',
        _ => 'Press to Talk',
      };

  Future<void> configureIdentity({
    required String seniorId,
    required String guardianId,
  }) async {
    if (_seniorId == seniorId && _guardianId == guardianId) return;
    _seniorId = seniorId;
    _guardianId = guardianId;
    final cached = await _transcriptRepository.load(seniorId);
    _transcripts
      ..clear()
      ..addAll(cached);
    notifyListeners();
  }

  Future<void> ensureFcmListener() async {
    if (_fcmRegistered) return;
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _handleMessage(initial);
    }
    _fcmRegistered = true;
  }

  void _handleMessage(RemoteMessage message) {
    final action = message.data['action'];
    if (action == 'start_conversation') {
      requestGreeting();
    }
  }

  Future<void> startRecording() async {
    if (_phase == PressToTalkPhase.recording) return;
    _errorMessage = null;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _phase = PressToTalkPhase.error;
      _errorMessage = 'Microphone permission denied';
      notifyListeners();
      return;
    }

    final tempDir = await Directory.systemTemp.createTemp('cooltiger_rec');
    final path =
        '${tempDir.path}/clip-${DateTime.now().millisecondsSinceEpoch}.m4a';
    _recordingPath = path;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    _phase = PressToTalkPhase.recording;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    if (_phase != PressToTalkPhase.recording) return;
    final path = await _recorder.stop() ?? _recordingPath;
    _recordingPath = null;
    if (path == null) {
      _setError('Recording failed');
      return;
    }
    final file = File(path);
    final bytes = await file.readAsBytes();
    try {
      await file.parent.delete(recursive: true);
    } catch (_) {}
    await _sendAudio(bytes, filename: file.uri.pathSegments.last);
  }

  Future<void> requestGreeting() async {
    if (_seniorId == null || _guardianId == null) return;
    _phase = PressToTalkPhase.thinking;
    notifyListeners();
    try {
      final uri = Uri.parse('${Env.apiBaseUrl}/conversation/greeting').replace(
        queryParameters: {
          'seniorId': _seniorId,
          'guardianId': _guardianId,
        },
      );
      final response = await _http.post(uri);
      await _handleResponse(response);
    } catch (err) {
      _setError('Greeting failed: $err');
    }
  }

  Future<void> _sendAudio(Uint8List bytes, {required String filename}) async {
    if (_seniorId == null || _guardianId == null) {
      _setError('Missing senior identity');
      return;
    }
    _phase = PressToTalkPhase.thinking;
    notifyListeners();
    try {
      final uri = Uri.parse('${Env.apiBaseUrl}/conversation');
      final request = http.MultipartRequest('POST', uri)
        ..fields['seniorId'] = _seniorId!
        ..fields['guardianId'] = _guardianId!
        ..files.add(
          http.MultipartFile.fromBytes(
            'audio_file',
            bytes,
            filename: filename,
            contentType: MediaType('audio', 'aac'),
          ),
        );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 400) {
        throw Exception('Backend error ${response.statusCode}');
      }
      await _logTranscript('user', 'Voice message');
      await _handleResponse(response);
    } catch (err) {
      _setError('Conversation failed: $err');
    }
  }

  Future<void> _handleResponse(http.Response response) async {
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('application/json')) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      await _handleTrainingPayload(payload);
      return;
    }
    await _playAudioBytes(response.bodyBytes);
  }

  Future<void> _handleTrainingPayload(Map<String, dynamic> payload) async {
    final module = TrainingModuleResponse.fromJson(payload);
    _activeModule = module;
    await _logTranscript('ai', module.ttsPrompt);
    _phase = PressToTalkPhase.training;
    notifyListeners();
  }

  Future<void> _playAudioBytes(Uint8List bytes) async {
    if (bytes.isEmpty) return;
    _phase = PressToTalkPhase.playing;
    notifyListeners();
    final dataUri = Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg');
    await _player.setUrl(dataUri.toString());
    await _player.play();
    await _logTranscript('ai', 'Audio response');
    _phase = PressToTalkPhase.idle;
    notifyListeners();
  }

  Future<void> _logTranscript(String speaker, String text) async {
    if (_seniorId == null) return;
    final entry = TranscriptEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      speaker: speaker,
      text: text,
      timestamp: DateTime.now(),
    );
    _transcripts.add(entry);
    await _transcriptRepository.add(_seniorId!, entry);
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _phase = PressToTalkPhase.error;
    notifyListeners();
  }

  Future<void> markTrainingComplete({String note = 'Great work completing the exercise!'}) async {
    await _logTranscript('ai', note);
    _activeModule = null;
    _phase = PressToTalkPhase.idle;
    notifyListeners();
  }

  void dismissTrainingModule() {
    _activeModule = null;
    if (_phase == PressToTalkPhase.training) {
      _phase = PressToTalkPhase.idle;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _http.close();
    super.dispose();
  }
}
