import 'dart:typed_data';

import 'web_audio_recorder_base.dart';

class UnsupportedWebAudioRecorder implements WebAudioRecorder {
  @override
  bool get isRecording => false;

  @override
  bool get isSupported => false;

  @override
  Future<void> start() async {
    throw UnsupportedError('Web audio recording is not supported on this platform.');
  }

  @override
  Future<Uint8List> stop() async => Uint8List(0);
}

WebAudioRecorder createWebAudioRecorder() => UnsupportedWebAudioRecorder();
