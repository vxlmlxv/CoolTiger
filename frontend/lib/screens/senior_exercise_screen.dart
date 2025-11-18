import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Exercise guidance screen for seniors with video playback.
///
/// Provides an easy-to-use video player with large controls
/// optimized for senior users to follow along with exercises.
class SeniorExerciseScreen extends StatefulWidget {
  // TODO: Replace with actual exercise video URL from backend
  final String videoUrl;

  const SeniorExerciseScreen({
    super.key,
    this.videoUrl =
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  });

  @override
  State<SeniorExerciseScreen> createState() => _SeniorExerciseScreenState();
}

class _SeniorExerciseScreenState extends State<SeniorExerciseScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Initialize video player controller with network URL
      // TODO: For production, consider using AssetImage for local videos
      // or implement video caching for better performance
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();

      setState(() {
        _isInitialized = true;
      });

      // Optional: Auto-play when initialized
      // Uncomment the line below to enable auto-play
      // _controller.play();

      // Listen to playback completion
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          // Video completed
          if (mounted) {
            setState(() {
              // Reset to beginning
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '영상을 불러올 수 없습니다: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _rewind10Seconds() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);

    if (newPosition.isNegative) {
      _controller.seekTo(Duration.zero);
    } else {
      _controller.seekTo(newPosition);
    }
  }

  void _forward10Seconds() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);

    if (newPosition >= duration) {
      _controller.seekTo(duration);
    } else {
      _controller.seekTo(newPosition);
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 종료', style: TextStyle(fontSize: 22)),
        content: const Text('운동을 종료할까요?', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('종료', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('음성 명령', style: TextStyle(fontSize: 22)),
        content: const Text(
          '음성 명령 기능은 추후 제공 예정입니다.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _hasError
            ? _buildErrorView()
            : !_isInitialized
            ? _buildLoadingView()
            : _buildVideoView(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? '영상을 불러올 수 없습니다',
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 24),
              label: const Text('돌아가기', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
          SizedBox(height: 24),
          Text(
            '영상을 불러오는 중...',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    return Column(
      children: [
        // Video Player Area
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),

                  // Play overlay when paused
                  if (!_controller.value.isPlaying)
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Controls Area
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress Bar with Time Labels
              Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return Text(
                        _formatDuration(value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        final progress = value.duration.inMilliseconds > 0
                            ? value.position.inMilliseconds /
                                  value.duration.inMilliseconds
                            : 0.0;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.purple,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, VideoPlayerValue value, child) {
                      return Text(
                        _formatDuration(value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Playback Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rewind 10 seconds
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _rewind10Seconds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.replay_10, size: 32),
                          SizedBox(height: 4),
                          Text('10초 전', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Play/Pause button (circular)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return IconButton(
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Forward 10 seconds
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _forward10Seconds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forward_10, size: 32),
                          SizedBox(height: 4),
                          Text('10초 후', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // System Action Buttons
              Row(
                children: [
                  // Exit button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showExitDialog,
                      icon: const Icon(Icons.close, size: 28),
                      label: const Text('종료', style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Voice button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showVoiceDialog,
                      icon: const Icon(Icons.mic, size: 28),
                      label: const Text('음성', style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
