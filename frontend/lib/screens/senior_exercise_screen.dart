import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../widgets/bottom_action_button.dart';
import '../widgets/senior_app_bar.dart';

/// Exercise guidance screen for seniors with video playback.
///
/// Provides an easy-to-use video player with large controls
/// optimized for senior users to follow along with exercises.
class SeniorExerciseScreen extends StatefulWidget {
  // TODO: Replace with actual exercise video URL from backend
  final String videoUrl;
  final bool useYoutubePlayer = false;

  const SeniorExerciseScreen({
    super.key,

    // this.videoUrl =
    //   'https://youtube.com/shorts/elABjEdqRz4?si=PmSxwwVhHier045J',
    this.videoUrl =
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  });

  @override
  State<SeniorExerciseScreen> createState() => _SeniorExerciseScreenState();
}

class _SeniorExerciseScreenState extends State<SeniorExerciseScreen> {
  VideoPlayerController? _controller;
  YoutubePlayerController? _ytController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool get _isUsingYoutube => widget.useYoutubePlayer;
  VideoPlayerController get _videoController => _controller!;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (_isUsingYoutube) {
        final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
        if (videoId == null) {
          throw Exception('유효한 유튜브 링크가 아닙니다.');
        }
        _ytController =
            YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                hideControls: true,
                controlsVisibleAtStart: false,
                mute: false,
              ),
            )..addListener(() {
              if (!_isInitialized && _ytController!.value.isReady && mounted) {
                setState(() {
                  _isInitialized = true;
                });
              }
            });
      } else {
        // Initialize video player controller with network URL
        // TODO: For production, consider using AssetImage for local videos
        // or implement video caching for better performance
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );

        await _videoController.initialize();

        setState(() {
          _isInitialized = true;
        });

        // Listen to playback completion
        _videoController.addListener(() {
          if (_videoController.value.position >=
              _videoController.value.duration) {
            if (mounted) {
              setState(() {
                // Reset to beginning
              });
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '영상을 불러올 수 없습니다: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ytController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isUsingYoutube) {
        if (_ytController?.value.isPlaying ?? false) {
          _ytController?.pause();
        } else {
          _ytController?.play();
        }
      } else {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
        } else {
          _videoController.play();
        }
      }
    });
  }

  void _rewind10Seconds() {
    final currentPosition = _isUsingYoutube
        ? _ytController!.value.position
        : _videoController.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);

    if (newPosition.isNegative) {
      _isUsingYoutube
          ? _ytController?.seekTo(Duration.zero)
          : _videoController.seekTo(Duration.zero);
    } else {
      _isUsingYoutube
          ? _ytController?.seekTo(newPosition)
          : _videoController.seekTo(newPosition);
    }
  }

  void _forward10Seconds() {
    final currentPosition = _isUsingYoutube
        ? _ytController!.value.position
        : _videoController.value.position;
    final duration = _isUsingYoutube
        ? _ytController!.metadata.duration
        : _videoController.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);

    if (newPosition >= duration) {
      _isUsingYoutube
          ? _ytController?.seekTo(duration)
          : _videoController.seekTo(duration);
    } else {
      _isUsingYoutube
          ? _ytController?.seekTo(newPosition)
          : _videoController.seekTo(newPosition);
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
      backgroundColor: const Color(0xFFF5F3F7), // Light purple background
      appBar: const SeniorAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _hasError
              ? _buildErrorView()
              : !_isInitialized
              ? _buildLoadingView()
              : _buildVideoView(),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: MediaQuery.of(context).size.height - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? '영상을 불러올 수 없습니다',
            style: const TextStyle(fontSize: 20, color: Color(0xFF1D1B20)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 24),
            label: const Text('돌아가기', style: TextStyle(fontSize: 20)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      padding: const EdgeInsets.all(32),
      height: MediaQuery.of(context).size.height - 200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF6750A4), strokeWidth: 4),
          SizedBox(height: 24),
          Text(
            '영상을 불러오는 중...',
            style: TextStyle(fontSize: 20, color: Color(0xFF1D1B20)),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    return Column(
      children: [
        // Video Player Area
        Center(
          child: AspectRatio(
            aspectRatio: _isUsingYoutube
                ? 16 / 9
                : (_videoController.value.isInitialized
                      ? _videoController.value.aspectRatio
                      : 16 / 9),
            child: _isUsingYoutube
                ? YoutubePlayerBuilder(
                    player: YoutubePlayer(
                      controller: _ytController!,
                      showVideoProgressIndicator: false,
                      progressIndicatorColor: Colors.purple,
                      topActions: const [],
                      bottomActions: const [],
                    ),
                    builder: (context, player) {
                      final isPlaying = _ytController?.value.isPlaying ?? false;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          player,
                          if (!isPlaying)
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
                      );
                    },
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_videoController),
                      // Play overlay when paused
                      if (!_videoController.value.isPlaying)
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
                    valueListenable: _isUsingYoutube
                        ? _ytController!
                        : _videoController,
                    builder: (context, dynamic value, child) {
                      final position = _isUsingYoutube
                          ? value.position as Duration
                          : (value as VideoPlayerValue).position;
                      return Text(
                        _formatDuration(position),
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
                      valueListenable: _isUsingYoutube
                          ? _ytController!
                          : _videoController,
                      builder: (context, dynamic value, child) {
                        final position = _isUsingYoutube
                            ? value.position as Duration
                            : (value as VideoPlayerValue).position;
                        final duration = _isUsingYoutube
                            ? value.metaData.duration as Duration
                            : (value as VideoPlayerValue).duration;
                        final progress = duration.inMilliseconds > 0
                            ? position.inMilliseconds / duration.inMilliseconds
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
                    valueListenable: _isUsingYoutube
                        ? _ytController!
                        : _videoController,
                    builder: (context, dynamic value, child) {
                      final duration = _isUsingYoutube
                          ? value.metaData.duration as Duration
                          : (value as VideoPlayerValue).duration;
                      return Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

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
                      valueListenable: _isUsingYoutube
                          ? _ytController!
                          : _videoController,
                      builder: (context, dynamic value, child) {
                        final isPlaying = _isUsingYoutube
                            ? (value as YoutubePlayerValue).isPlaying
                            : (value as VideoPlayerValue).isPlaying;
                        return IconButton(
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
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
              const SizedBox(height: 20),

              // Bottom Action Buttons (종료, 음성)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BottomActionButton(
                      icon: Icons.close,
                      label: '종료',
                      onPressed: _showExitDialog,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: BottomActionButton(
                      icon: Icons.mic,
                      label: '음성',
                      onPressed: _showVoiceDialog,
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
