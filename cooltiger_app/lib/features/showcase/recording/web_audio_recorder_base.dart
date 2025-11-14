import 'dart:typed_data';

abstract class WebAudioRecorder {
  bool get isSupported;
  bool get isRecording;
  Future<void> start();
  Future<Uint8List> stop();
}
