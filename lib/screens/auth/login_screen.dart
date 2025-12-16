import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

// This screen allows users to log in to the app using their email and password.

// LoginScreen is a stateful widget because it needs to manage user input and loading state.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to get text from the input fields.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // Flag to show loading spinner while logging in.
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          children: [
            // Title of the screen
            const Text(
              "Đăng nhập Garage",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32), // Space between title and fields
            // Email input field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16), // Space between fields
            // Password input field (hidden text)
            TextField(
              controller: passwordController,
              obscureText: true, // Hide the password
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24), // Space before button
            // Login button, full width
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login, // Disable if loading
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      ) // Show spinner
                    : const Text("Đăng nhập"), // Button text
              ),
            ),

            // Link to register screen
            TextButton(
              onPressed: () => context.go('/register'), // Navigate to register
              child: const Text('Chưa có tài khoản? Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle login when button is pressed.
  Future<void> login() async {
    // Set loading to true to show spinner
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      // Try to sign in with Firebase Auth using email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // Remove extra spaces
        password: passwordController.text.trim(),
      );

      // If successful, go to dashboard
      if (mounted) {
        context.go('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      // If there's an error, show a message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      }
    } finally {
      // Always set loading to false when done
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
