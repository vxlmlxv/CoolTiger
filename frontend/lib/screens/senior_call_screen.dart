import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

import '../app_config.dart';

/// Model for conversation turns
class ConversationTurn {
  final String speaker; // "senior" or "ai"
  final String text;
  final String? ttsUrl;

  ConversationTurn({required this.speaker, required this.text, this.ttsUrl});
}

/// Demo responses for conversation simulation
const List<String> _demoAiResponses = [
  '안녕하세요, 오늘은 기분이 어떠세요?',
  '산책을 다녀오셨군요, 좋으셨겠어요!',
  '건강이 최우선이에요. 오늘 약은 드셨나요?',
  '날씨가 참 좋네요. 창문을 열어 환기시키는 것도 좋아요.',
  '가족들은 요즘 어떻게 지내시나요?',
  '오늘 점심은 무엇을 드셨어요?',
  '잘 들었습니다. 더 이야기 나누고 싶으신 게 있으신가요?',
];

/// AI companion call screen for seniors.
///
/// Provides voice-based interaction with an AI companion through
/// the FastAPI backend, with speech-to-text and text-to-speech capabilities.
class SeniorCallScreen extends StatefulWidget {
  final String seniorId;

  const SeniorCallScreen({super.key, required this.seniorId});

  @override
  State<SeniorCallScreen> createState() => _SeniorCallScreenState();
}

class _SeniorCallScreenState extends State<SeniorCallScreen> {
  final Dio _dio = Dio();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  bool _isCalling = false;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _callId;
  List<ConversationTurn> _conversation = [];
  String? _errorMessage;
  int _demoResponseIndex = 0;

  @override
  void dispose() {
    _recorder.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startCall() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // DEMO MODE: Simulate conversation start
      if (kDemoMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _callId = 'demo-call-${DateTime.now().millisecondsSinceEpoch}';
          _isCalling = true;
          _conversation.add(
            ConversationTurn(
              speaker: 'ai',
              text: _demoAiResponses[_demoResponseIndex],
              ttsUrl: null, // No TTS in demo mode
            ),
          );
          _demoResponseIndex =
              (_demoResponseIndex + 1) % _demoAiResponses.length;
        });
        _scrollToBottom();

        // Show demo indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('(Demo) TTS would play here'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // REAL MODE: Call backend API
      final response = await _dio.post(
        '$kBaseApiUrl/conversation/start',
        data: {'senior_id': widget.seniorId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _callId = data['call_id'];
          _isCalling = true;
          _conversation.add(
            ConversationTurn(
              speaker: 'ai',
              text: data['ai_text'] ?? '안녕하세요!',
              ttsUrl: data['tts_url'],
            ),
          );
        });

        // Auto-scroll to bottom
        _scrollToBottom();

        // Auto-play initial greeting if TTS URL is available
        if (data['tts_url'] != null) {
          _playTts(data['tts_url']);
        }
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = '통화 시작 실패: ${e.message}';
      });
      _showErrorSnackBar(_errorMessage!);
    } catch (e) {
      setState(() {
        _errorMessage = '통화 시작 중 오류 발생: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording and send to backend
      await _stopRecordingAndSend();
    } else {
      // Start recording
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check and request permission
      if (await _recorder.hasPermission()) {
        // Start recording in WAV format for better compatibility
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: 'recording.wav', // For web, this is ignored
        );

        setState(() {
          _isRecording = true;
        });
      } else {
        _showErrorSnackBar('마이크 권한이 필요합니다');
      }
    } catch (e) {
      _showErrorSnackBar('녹음 시작 실패: ${e.toString()}');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Stop recording
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
      });

      // DEMO MODE: Simulate AI response
      if (kDemoMode) {
        await Future.delayed(const Duration(milliseconds: 800));

        setState(() {
          // Add senior's message (demo placeholder)
          _conversation.add(
            ConversationTurn(speaker: 'senior', text: '(더미 음성 입력)'),
          );

          // Add AI's response
          _conversation.add(
            ConversationTurn(
              speaker: 'ai',
              text: _demoAiResponses[_demoResponseIndex],
              ttsUrl: null,
            ),
          );
          _demoResponseIndex =
              (_demoResponseIndex + 1) % _demoAiResponses.length;
        });

        _scrollToBottom();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('(Demo) TTS would play here'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // REAL MODE: Send to backend
      if (path == null) {
        _showErrorSnackBar('녹음된 오디오가 없습니다');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // For web, we need to read the bytes differently
      // The path contains the audio data for web
      final audioBytes = await _readAudioFile(path);

      if (audioBytes == null) {
        _showErrorSnackBar('오디오 파일을 읽을 수 없습니다');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Send to backend
      final formData = FormData.fromMap({
        'senior_id': widget.seniorId,
        'call_id': _callId,
        'audio': MultipartFile.fromBytes(audioBytes, filename: 'recording.wav'),
      });

      final response = await _dio.post(
        '$kBaseApiUrl/conversation/reply',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          // Add senior's message (placeholder since backend doesn't return transcript yet)
          _conversation.add(
            ConversationTurn(speaker: 'senior', text: '(음성 전달됨)'),
          );

          // Add AI's response
          _conversation.add(
            ConversationTurn(
              speaker: 'ai',
              text: data['ai_text'] ?? '네, 알겠습니다.',
              ttsUrl: data['tts_url'],
            ),
          );
        });

        // Auto-scroll to bottom
        _scrollToBottom();

        // Auto-play AI response if TTS URL is available
        if (data['tts_url'] != null) {
          _playTts(data['tts_url']);
        }
      }
    } on DioException catch (e) {
      _showErrorSnackBar('음성 전송 실패: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('음성 처리 중 오류: ${e.toString()}');
    } finally {
      setState(() {
        _isRecording = false;
        _isLoading = false;
      });
    }
  }

  Future<Uint8List?> _readAudioFile(String path) async {
    try {
      // For web platform, the path might be a blob URL or the actual bytes
      // This is a simplified implementation
      // TODO: Implement proper audio file reading for web platform
      // You may need to use platform-specific code here
      return null; // Placeholder
    } catch (e) {
      debugPrint('Error reading audio file: $e');
      return null;
    }
  }

  Future<void> _playTts(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }

    try {
      // TODO: Once backend implements cloud storage for TTS audio,
      // this will play the audio from the URL
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing TTS audio: $e');
      // Don't show error to user for TTS playback issues
    }
  }

  Future<void> _endCall() async {
    if (_callId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // DEMO MODE: Simulate call ending
      if (kDemoMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _conversation.add(
            ConversationTurn(
              speaker: 'system',
              text: '통화 요약: 오늘 어르신과 좋은 대화를 나누었습니다. 기분이 좋아 보이셨어요.',
            ),
          );
        });
        _scrollToBottom();

        _showSuccessSnackBar('(Demo) 통화가 종료되었습니다');

        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isCalling = false;
          _callId = null;
          _demoResponseIndex = 0;
        });
        return;
      }

      // REAL MODE: Call backend
      final response = await _dio.post(
        '$kBaseApiUrl/conversation/end',
        data: {'senior_id': widget.seniorId, 'call_id': _callId},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Add summary as a system message
        if (data['summary'] != null) {
          setState(() {
            _conversation.add(
              ConversationTurn(
                speaker: 'system',
                text: '통화 요약: ${data['summary']}',
              ),
            );
          });
          _scrollToBottom();
        }

        // Show success message
        _showSuccessSnackBar('통화가 종료되었습니다');

        // Reset state after a short delay
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isCalling = false;
          _callId = null;
          // Optionally clear conversation: _conversation.clear();
        });
      }
    } on DioException catch (e) {
      _showErrorSnackBar('통화 종료 실패: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('통화 종료 중 오류: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Title
              Text(
                '효심이 안부 전화',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 24),

              // Top area - Start call or mic button
              if (!_isCalling) ...[
                // Start call button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startCall,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.phone, size: 32),
                              SizedBox(width: 12),
                              Text(
                                '통화 시작하기',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ] else ...[
                // Mic button (during call)
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _toggleRecording,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isRecording ? '녹음 중...' : '눌러서 말하기',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Middle area - Conversation
              if (_isCalling) ...[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _conversation.isEmpty
                        ? Center(
                            child: Text(
                              '대화를 시작해보세요',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _conversation.length,
                            itemBuilder: (context, index) {
                              final turn = _conversation[index];
                              return _buildMessageBubble(turn, index);
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom area - End call button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _endCall,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.call_end, size: 24),
                              SizedBox(width: 8),
                              Text(
                                '통화 종료',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ConversationTurn turn, int index) {
    final isAi = turn.speaker == 'ai';
    final isSystem = turn.speaker == 'system';

    if (isSystem) {
      // System message (e.g., summary)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              turn.text,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isAi
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.smart_toy, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAi
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAi ? Colors.blue[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(turn.text, style: const TextStyle(fontSize: 18)),
                ),
                if (isAi && turn.ttsUrl != null) ...[
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () => _playTts(turn.ttsUrl),
                    icon: const Icon(Icons.volume_up, size: 20),
                    label: const Text(
                      'AI 답변 듣기',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isAi) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.person, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }
}
