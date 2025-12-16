import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This screen allows users to create a new account.

// RegisterScreen is stateful to manage input and loading.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for input fields.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // Flag for loading state.
  bool isLoading = false;

  // Clean up controllers when the widget is removed.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // Function to handle registration.
  Future<void> onRegister() async {
    // Get trimmed text from controllers.
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // Check if all fields are filled.
    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    // Check password length.
    if (password.length < 6) {
      _showMessage('Password phải có ít nhất 6 ký tự');
      return;
    }

    // Check if passwords match.
    if (password != confirm) {
      _showMessage('Password không khớp');
      return;
    }

    try {
      // Set loading to true.
      setState(() => isLoading = true);

      // Create user with Firebase Auth.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If successful, show message and go to login.
      if (mounted) {
        _showMessage('Đăng ký thành công');
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors.
      _showMessage(e.message ?? 'Đăng ký thất bại');
    } catch (_) {
      // Handle other errors.
      _showMessage('Có lỗi xảy ra');
    } finally {
      // Set loading to false.
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Helper function to show messages to the user.
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Email input
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Password input
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Confirm password input
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nhập lại Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Register button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onRegister,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Đăng ký'),
              ),
            ),
            // Link to login
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Đã có tài khoản? Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
