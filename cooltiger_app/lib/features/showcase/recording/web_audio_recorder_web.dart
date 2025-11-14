// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import 'web_audio_recorder_base.dart';

class BrowserWebAudioRecorder implements WebAudioRecorder {
  html.MediaRecorder? _recorder;
  webrtc.MediaStream? _stream;
  final List<html.Blob> _chunks = <html.Blob>[];
  Completer<Uint8List>? _stopCompleter;

  @override
  bool get isRecording => _recorder?.state == 'recording';

  @override
  bool get isSupported =>
      html.MediaRecorder.isTypeSupported('audio/webm;codecs=opus') ||
      html.MediaRecorder.isTypeSupported('audio/webm');

  @override
  Future<void> start() async {
    if (!isSupported) {
      throw UnsupportedError('Browser does not support MediaRecorder audio/webm.');
    }
    if (isRecording) return;

    final dynamic rawStream = await webrtc.navigator.mediaDevices.getUserMedia({'audio': true});
    if (rawStream is! html.MediaStream) {
      throw UnsupportedError('Unable to access browser media stream.');
    }
    final html.MediaStream stream = rawStream;
    _stream = rawStream as webrtc.MediaStream?; // keep reference for cleanup
    _chunks.clear();
    _stopCompleter = Completer<Uint8List>();

    final recorder = html.MediaRecorder(
      stream,
      {'mimeType': 'audio/webm;codecs=opus'},
    );

    recorder.addEventListener('dataavailable', (event) {
      final dynamic dataEvent = event;
      final html.Blob? data = dataEvent?.data as html.Blob?;
      if (data != null && data.size > 0) {
        _chunks.add(data);
      }
    });

    recorder.addEventListener('stop', (_) async {
      final blob = html.Blob(_chunks, 'audio/webm');
      final bytes = await _blobToBytes(blob);
      if (!(_stopCompleter?.isCompleted ?? true)) {
        _stopCompleter?.complete(bytes);
      }
      _chunks.clear();
    });

    recorder.addEventListener('error', (event) {
      if (!(_stopCompleter?.isCompleted ?? true)) {
        _stopCompleter?.completeError(event);
      }
    });

    recorder.start();
    _recorder = recorder;
  }

  @override
  Future<Uint8List> stop() async {
    final recorder = _recorder;
    if (recorder == null) {
      return Uint8List(0);
    }
    recorder.stop();
    _recorder = null;
    final result = await (_stopCompleter?.future ?? Future.value(Uint8List(0)));
    await _closeStream();
    return result;
  }

  Future<void> _closeStream() async {
    final stream = _stream;
    if (stream == null) return;
    for (final track in stream.getTracks()) {
      track.stop();
    }
    _stream = null;
  }

  Future<Uint8List> _blobToBytes(html.Blob blob) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();
    reader.onError.listen((event) {
      if (!completer.isCompleted) {
        completer.completeError(reader.error ?? 'MediaRecorder read error');
      }
    });
    reader.onLoadEnd.listen((event) {
      if (!completer.isCompleted) {
        final buffer = reader.result as ByteBuffer;
        completer.complete(buffer.asUint8List());
      }
    });
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }
}

WebAudioRecorder createWebAudioRecorder() => BrowserWebAudioRecorder();
