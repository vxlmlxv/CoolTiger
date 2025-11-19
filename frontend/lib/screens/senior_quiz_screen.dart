import 'package:flutter/material.dart';

/// Model for quiz data
class QuizData {
  final String id;
  final String? imageUrl;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String hintText;

  QuizData({
    required this.id,
    this.imageUrl,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.hintText,
  });
}

/// Cognitive ability quiz screen for seniors.
///
/// Provides an interactive quiz experience with visual feedback,
/// hints, and voice input capabilities (future).
class SeniorQuizScreen extends StatefulWidget {
  const SeniorQuizScreen({super.key});

  @override
  State<SeniorQuizScreen> createState() => _SeniorQuizScreenState();
}

class _SeniorQuizScreenState extends State<SeniorQuizScreen> {
  // Quiz data - TODO: Replace with backend API call to /quiz/list
  final List<QuizData> _quizzes = [
    QuizData(
      id: 'q1',
      imageUrl: null,
      questionText: '오늘은 무슨 요일인가요?',
      options: ['월요일', '화요일', '수요일', '목요일'],
      correctAnswerIndex: 2, // 수요일
      hintText: '오늘이 주중이라면, 월화수목금 중에 있을 거예요.',
    ),
    QuizData(
      id: 'q2',
      imageUrl: null,
      questionText: '다음 중 계절이 아닌 것은?',
      options: ['봄', '여름', '가을', '구름'],
      correctAnswerIndex: 3, // 구름
      hintText: '계절은 1년에 4번 바뀝니다.',
    ),
    QuizData(
      id: 'q3',
      imageUrl: null,
      questionText: '100에서 7을 빼면?',
      options: ['93', '92', '94', '91'],
      correctAnswerIndex: 0, // 93
      hintText: '100 - 7 = ?',
    ),
    QuizData(
      id: 'q4',
      imageUrl: null,
      questionText: '사과는 무슨 색깔일까요?',
      options: ['파란색', '빨간색', '노란색', '보라색'],
      correctAnswerIndex: 1, // 빨간색
      hintText: '가장 흔한 사과의 색을 생각해보세요.',
    ),
  ];

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _isCorrect = false;
  bool _showHint = false;
  Set<int> _disabledOptions = {};

  QuizData get _currentQuiz => _quizzes[_currentIndex];
  bool get _hasNextQuestion => _currentIndex < _quizzes.length - 1;

  @override
  void initState() {
    super.initState();
    // TODO: Load quiz from backend API
    // _loadQuizFromBackend();
  }

  // TODO: Implement backend integration
  // Future<void> _loadQuizFromBackend() async {
  //   try {
  //     final response = await dio.get('$backendUrl/quiz/list?senior_id=...');
  //     setState(() {
  //       _quizzes = (response.data['quiz']['questions'] as List)
  //           .map((q) => QuizData.fromJson(q))
  //           .toList();
  //     });
  //   } catch (e) {
  //     // Handle error
  //   }
  // }

  void _selectOption(int index) {
    // Don't allow selection if already correct or option is disabled
    if (_isCorrect || _disabledOptions.contains(index)) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    if (index == _currentQuiz.correctAnswerIndex) {
      // Correct answer
      setState(() {
        _isCorrect = true;
      });

      // TODO: Play correct sound
      // _playCorrectSound();

      // Show success feedback
      _showSuccessSnackBar('정답입니다! 🎉');

      // Optional: Auto-advance after delay
      // Future.delayed(const Duration(seconds: 2), () {
      //   if (mounted) _nextQuestion();
      // });
    } else {
      // Incorrect answer
      setState(() {
        _disabledOptions.add(index);
      });

      // Show error feedback with animation
      _showIncorrectFeedback();
    }
  }

  void _showIncorrectFeedback() {
    _showErrorSnackBar('다시 한번 생각해보세요');

    // TODO: Play incorrect sound
    // _playIncorrectSound();

    // Reset selected index after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _selectedIndex = null;
        });
      }
    });
  }

  void _nextQuestion() {
    if (!_isCorrect) {
      _showErrorSnackBar('정답을 선택해주세요');
      return;
    }

    if (_hasNextQuestion) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _isCorrect = false;
        _showHint = false;
        _disabledOptions.clear();
      });
    } else {
      _showQuizCompletedDialog();
    }
  }

  void _showHintDialog() {
    setState(() {
      _showHint = true;
    });

    // TODO: Track hint usage for scoring
    // _usedHints[_currentIndex] = true;
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('음성 답변', style: TextStyle(fontSize: 22)),
        content: const Text(
          '음성으로 답변하는 기능이 곧 제공됩니다.',
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('퀴즈 종료', style: TextStyle(fontSize: 22)),
        content: const Text(
          '퀴즈를 종료할까요?\n진행 상황은 저장되지 않습니다.',
          style: TextStyle(fontSize: 18),
        ),
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

  void _showQuizCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          '🎉 퀴즈 완료!',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '모든 문제를 완료했습니다.\n수고하셨습니다!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '총 ${_quizzes.length}문제 완료',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Restart quiz
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 0;
                _selectedIndex = null;
                _isCorrect = false;
                _showHint = false;
                _disabledOptions.clear();
              });
            },
            child: const Text('다시 시작', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('홈으로', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getOptionColor(int index) {
    if (_selectedIndex == index) {
      if (_isCorrect) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }
    if (_disabledOptions.contains(index)) {
      return Colors.grey;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Quiz Card
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cognitive Ability Quiz',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 28),
                              onPressed: () {
                                // TODO: Show menu (settings, help, etc.)
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Image placeholder
                        if (_currentQuiz.imageUrl != null)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: Image.network(
                              _currentQuiz.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildImagePlaceholder(),
                            ),
                          )
                        else
                          _buildImagePlaceholder(),
                        const SizedBox(height: 24),

                        // Question section
                        Text(
                          'Question ${_currentIndex + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentQuiz.questionText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Hint area
                        if (_showHint)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentQuiz.hintText,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),

                        // Next Question button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCorrect ? _nextQuestion : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: Text(
                              _hasNextQuestion ? 'Next Question' : 'Finish',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Answer Grid (2x2)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: _currentQuiz.options.length,
                itemBuilder: (context, index) {
                  return _buildOptionButton(index);
                },
              ),
              const SizedBox(height: 16),

              // Bottom Action Bar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showExitDialog,
                      icon: const Icon(Icons.exit_to_app, size: 24),
                      label: const Text('End', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showHint ? null : _showHintDialog,
                      icon: const Icon(Icons.lightbulb_outline, size: 24),
                      label: const Text('Hint', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showVoiceDialog,
                      icon: const Icon(Icons.mic, size: 24),
                      label: const Text(
                        'Voice',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    final color = _getOptionColor(index);
    final isDisabled = _disabledOptions.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _selectOption(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _currentQuiz.options[index],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
