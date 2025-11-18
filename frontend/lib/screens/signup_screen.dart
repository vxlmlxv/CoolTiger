import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_config.dart';

/// Signup screen for new user registration with role-based fields.
///
/// Supports two user roles:
/// - Senior: Users who will receive AI companion calls
/// - Guardian: Caretakers who monitor seniors
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _seniorIdController = TextEditingController();
  final _guardianIdController = TextEditingController();
  final _ageController = TextEditingController();
  final _callTimeController = TextEditingController();

  String _selectedRole = 'senior';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _seniorIdController.dispose();
    _guardianIdController.dispose();
    _ageController.dispose();
    _callTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
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
      // DEMO MODE: Simulate signup without Firebase
      if (kDemoMode) {
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        // Navigate based on selected role
        if (_selectedRole == 'senior') {
          Navigator.of(context).pushReplacementNamed('/senior-home');
        } else {
          Navigator.of(context).pushReplacementNamed('/guardian-home');
        }
        return;
      }

      // REAL MODE: Create user with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final uid = userCredential.user!.uid;
      final email = _emailController.text.trim();

      // Prepare user document data based on role
      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
        'role': _selectedRole,
        'name': _nameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_selectedRole == 'guardian') {
        // Guardian-specific fields
        userData['linkedSeniorId'] = _seniorIdController.text.trim();
        userData['preferredCallTime'] = _callTimeController.text.trim();
      } else {
        // Senior-specific fields
        userData['linkedSeniorId'] = uid; // Use own UID as senior ID
        userData['linkedGuardianId'] = _guardianIdController.text.trim();
        userData['age'] = int.tryParse(_ageController.text.trim()) ?? 0;
      }

      // Write to users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      // If senior, also create a document in seniors collection
      if (_selectedRole == 'senior') {
        final seniorData = {
          'seniorId': uid,
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'guardianId': _guardianIdController.text.trim(),
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          // TODO: Add additional senior profile fields as needed
          // (preferences, medical history, emergency contacts, etc.)
        };

        await FirebaseFirestore.instance
            .collection('seniors')
            .doc(uid)
            .set(seniorData);
      }

      if (!mounted) return;

      // Navigate to appropriate home screen based on role
      if (_selectedRole == 'senior') {
        // Navigate to Senior Home
        Navigator.of(context).pushReplacementNamed('/senior-home');
      } else {
        // Navigate to Guardian Home
        // TODO: Implement GuardianHomeScreen if not already defined
        Navigator.of(context).pushReplacementNamed('/guardian-home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getAuthErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '회원가입 중 오류가 발생했습니다: ${e.toString()}';
      });
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      default:
        return '회원가입에 실패했습니다: $code';
    }
  }

  Future<void> _selectCallTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _callTimeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
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
                      '효심이 회원가입',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role selector
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: '역할',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'senior', child: Text('어르신')),
                        DropdownMenuItem(value: 'guardian', child: Text('보호자')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Name field (common for both roles)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == 'senior' ? '이름' : '보호자 이름',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role-specific fields
                    if (_selectedRole == 'guardian') ...[
                      // Guardian: Senior ID
                      TextFormField(
                        controller: _seniorIdController,
                        decoration: const InputDecoration(
                          labelText: '어르신 ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          helperText: '돌봄을 제공할 어르신의 ID를 입력하세요',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '어르신 ID를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Guardian: Preferred call time
                      TextFormField(
                        controller: _callTimeController,
                        decoration: const InputDecoration(
                          labelText: '선호 통화 시간',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                          helperText: '어르신과 통화하기 좋은 시간 (예: 14:00)',
                        ),
                        readOnly: true,
                        onTap: _selectCallTime,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '선호 통화 시간을 선택해주세요';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // Senior: Age
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: '나이',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.cake),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '나이를 입력해주세요';
                          }
                          final age = int.tryParse(value.trim());
                          if (age == null || age <= 0) {
                            return '유효한 나이를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Senior: Guardian ID
                      TextFormField(
                        controller: _guardianIdController,
                        decoration: const InputDecoration(
                          labelText: '보호자 ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          helperText: '보호자의 ID를 입력하세요 (선택사항)',
                        ),
                        // Optional field for senior
                      ),
                    ],
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

                    // Signup button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('회원가입', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),

                    // Login link
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            },
                      child: const Text('이미 계정이 있으신가요? 로그인'),
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
