import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';

/// Login screen for existing users.
///
/// Provides email/password authentication using Firebase Auth.
/// After successful login, navigates to RoleRouter which determines
/// the appropriate home screen based on user role.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // DEMO MODE: Simulate login based on email
      if (kDemoMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Determine role based on email content
        final email = _emailController.text.trim().toLowerCase();
        String demoRole = 'senior'; // default

        if (email.contains('guardian') || email.contains('보호자')) {
          demoRole = 'guardian';
        } else if (email.contains('senior') || email.contains('어르신')) {
          demoRole = 'senior';
        } else {
          // Show role selection dialog
          final selectedRole = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('역할 선택', style: TextStyle(fontSize: 20)),
              content: const Text(
                'Demo 모드: 어떤 역할로 로그인할까요?',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('senior'),
                  child: const Text('어르신', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('guardian'),
                  child: const Text('보호자', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );

          if (selectedRole == null) {
            setState(() {
              _isLoading = false;
            });
            return;
          }
          demoRole = selectedRole;
        }

        // Navigate to RoleRouter with demo role
        Navigator.of(context).pushReplacementNamed(
          '/role-router',
          arguments: {'demoRole': demoRole},
        );
        return;
      }

      // REAL MODE: Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Navigate to RoleRouter which will determine the appropriate home screen
      Navigator.of(context).pushReplacementNamed('/role-router');

      // Option 2: Direct navigation (uncomment if RoleRouter is imported)
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const RoleRouter()),
      // );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getAuthErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '로그인 중 오류가 발생했습니다: ${e.toString()}';
      });
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      default:
        return '로그인에 실패했습니다: $code';
    }
  }

  void _navigateToSignup() {
    // TODO: Update route name based on your routing configuration
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App title
                    Text(
                      '효심이 로그인',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!value.contains('@')) {
                          return '유효한 이메일을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        // Allow Enter key to submit
                        if (!_isLoading) {
                          _handleLogin();
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('로그인', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),

                    // Signup link
                    TextButton(
                      onPressed: _isLoading ? null : _navigateToSignup,
                      child: const Text('처음이신가요? 회원가입'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
