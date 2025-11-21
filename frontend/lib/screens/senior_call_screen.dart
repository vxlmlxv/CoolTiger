import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'dart:convert';

import '../app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:io' show File; // For non-web platforms
import 'package:path_provider/path_provider.dart'; // For temp directory
import 'package:universal_html/html.dart' as html show AudioElement;

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
          debugPrint('initial tts url played}');
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
          // Add senior's message with actual transcript
          _conversation.add(
            ConversationTurn(
              speaker: 'senior',
              text: data['senior_text'] ?? '(음성 전달됨)',
            ),
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

        // Auto-play AI response immediately (supports base64 data URLs)
        if (data['tts_url'] != null && data['tts_url'].toString().isNotEmpty) {
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
      if (kIsWeb) {
        // For web: path is a blob URL from record package
        // Fetch the blob and convert to bytes
        final response = await http.get(Uri.parse(path));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
        debugPrint('Failed to fetch audio blob: ${response.statusCode}');
        return null;
      } else {
        // For mobile/desktop: read file normally
        final file = File(path);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
        return null;
      }
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
      // Handle base64 data URLs (format: data:audio/mp3;base64,<base64_string>)
      if (url.startsWith('data:audio/')) {
        debugPrint('Received base64 audio data (length: ${url.length})');

        // Decode base64 string
        final base64Data = url.split(',').last;
        final audioBytes = base64Decode(base64Data);
        debugPrint('Decoded audio bytes: ${audioBytes.length}');

        // For web: Create a temporary audio element and play
        if (kIsWeb) {
          // Use the HTML audio element directly for web
          // This is more reliable than just_audio for data URLs
          final audioElement = html.AudioElement(url);
          audioElement.play();
          debugPrint('Playing TTS audio using HTML AudioElement on web');
        } else {
          // For mobile/desktop: decode base64 and save to temp file
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
          );
          await tempFile.writeAsBytes(audioBytes);
          await _audioPlayer.setFilePath(tempFile.path);
          await _audioPlayer.play();
          debugPrint(
            'Playing TTS audio from temp file (${audioBytes.length} bytes)',
          );
        }
      } else {
        // Regular HTTP/HTTPS URL
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        debugPrint('Playing TTS audio from URL: $url');
      }
    } catch (e) {
      debugPrint('Error playing TTS audio: $e');
      _showErrorSnackBar('오디오 재생 실패: ${e.toString()}');
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

  /// Show time picker for "Do later" option
  Future<void> _showDoLaterTimePicker() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.5),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      // Format the time for display
      final hour = selectedTime.hour;
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$period $displayHour:$minute에 다시 알려드리겠습니다',
              style: const TextStyle(fontSize: 18),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF6750A4),
          ),
        );
      }

      // TODO: Schedule notification for the selected time
      debugPrint('Scheduled notification for: $period $displayHour:$minute');
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxHeight < 720 || constraints.maxWidth < 380;
          final content = _isCalling
              ? _buildInCallSection(isCompact)
              : _buildStartCallSection(isCompact);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: content,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartCallSection(bool isCompact) {
    final nameSize = isCompact ? 36.0 : 50.0;
    final subtitleSize = isCompact ? 28.0 : 40.0;
    final illustrationSize = isCompact ? 190.0 : 243.0;
    final iconSize = isCompact ? 90.0 : 120.0;
    final buttonFontSize = isCompact ? 24.0 : 32.0;
    final buttonIconSize = isCompact ? 20.0 : 24.0;
    final spacingLarge = isCompact ? 32.0 : 58.0;
    final spacingMedium = isCompact ? 16.0 : 24.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '효심이 안부 전화',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Greeting text
          Text(
            '홍길동님',
            style: TextStyle(
              fontSize: nameSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
              color: const Color(0xFF1C1C2B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          Text(
            '상담 시간이에요!',
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              color: const Color(0xFF1C1C2B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacingLarge),

          // Illustration placeholder (centered purple container)
          Container(
            width: illustrationSize,
            height: illustrationSize,
            decoration: BoxDecoration(
              color: const Color(0xFFEADDFF), // M3 primary-container
              borderRadius: BorderRadius.circular(120),
            ),
            child: Center(
              child: Icon(
                Icons.phone_in_talk,
                size: iconSize,
                color: const Color(0xFF4F378A), // M3 on-primary-container
              ),
            ),
          ),
          SizedBox(height: spacingLarge),

          // Action buttons
          Column(
            children: [
              // Start button (시작하기)
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _startCall,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF49454F),
                        ),
                      )
                    : Icon(
                        Icons.check,
                        size: buttonIconSize,
                        color: const Color(0xFF49454F),
                      ),
                label: Text(
                  _isLoading ? '연결 중...' : '시작하기',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                    color: const Color(0xFF49454F),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  backgroundColor: const Color(
                    0xFFFF8D28,
                  ).withValues(alpha: 0.91),
                  side: const BorderSide(
                    color: Color(0xFFCAC4D0),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              SizedBox(height: spacingMedium),

              // Do later button (다음에 하기)
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _showDoLaterTimePicker,
                icon: Icon(
                  Icons.close,
                  size: buttonIconSize,
                  color: const Color(0xFF49454F),
                ),
                label: Text(
                  '다음에 하기',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                    color: const Color(0xFF49454F),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(
                    color: Color(0xFFCAC4D0),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacingLarge),
        ],
      ),
    );
  }

  Widget _buildInCallSection(bool isCompact) {
    final micSize = isCompact ? 100.0 : 120.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '효심이 안부 전화',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Mic button (during call)
        Center(
          child: GestureDetector(
            onTap: _isLoading ? null : _toggleRecording,
            child: Container(
              width: micSize,
              height: micSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                      size: micSize / 2,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isRecording ? '녹음 중...' : '눌러서 말하기',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Conversation area
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
