import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';

/// Demo landing screen for testing without Firebase/backend.
///
/// Allows quick role selection to test senior or guardian flows
/// without needing authentication.
class DemoLandingScreen extends StatelessWidget {
  const DemoLandingScreen({super.key});

  void _loginAsSenior(BuildContext context) {
    // DEMO MODE: Navigate directly to senior home
    Navigator.of(
      context,
    ).pushReplacementNamed('/role-router', arguments: {'demoRole': 'senior'});
  }

  void _loginAsGuardian(BuildContext context) {
    // DEMO MODE: Navigate directly to guardian home
    Navigator.of(
      context,
    ).pushReplacementNamed('/role-router', arguments: {'demoRole': 'guardian'});
  }

  void _goToRealLogin(BuildContext context) {
    // Switch to real login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('효심이 - Demo Mode'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Demo mode indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amber.shade700,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.science, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'DEMO MODE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    '효심이',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI 시니어 케어 시스템',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Demo Mode 안내',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Firebase/Backend 없이 UI 테스트 가능\n'
                          '• 더미 데이터로 모든 기능 체험\n'
                          '• 실제 음성 인식/TTS는 제한적 동작\n'
                          '• app_config.dart에서 kDemoMode 변경 가능',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Role selection buttons
                  const Text(
                    '역할을 선택하세요',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Senior button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _loginAsSenior(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.elderly, size: 48),
                          SizedBox(height: 8),
                          Text(
                            '어르신으로 시작',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'AI 통화, 퀴즈, 운동 기능 체험',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Guardian button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _loginAsGuardian(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.family_restroom, size: 48),
                          SizedBox(height: 8),
                          Text(
                            '보호자로 시작',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('모니터링 대시보드 체험', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  if (!kDemoMode) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Real login option
                    TextButton.icon(
                      onPressed: () => _goToRealLogin(context),
                      icon: const Icon(Icons.login),
                      label: const Text('실제 계정으로 로그인'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
