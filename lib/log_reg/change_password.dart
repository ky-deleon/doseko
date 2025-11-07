import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  String feedbackMessage = '';

  Future<void> resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        feedbackMessage = 'Please enter your email.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        feedbackMessage =
        'Password reset email sent. Please check your inbox or spam folder.';
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          feedbackMessage = 'No user found with this email.';
        });
      } else {
        setState(() {
          feedbackMessage = 'Failed to send password reset email. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        feedbackMessage = 'An unexpected error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color(0xff003399),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                // Update the UI when email input changes
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            if (feedbackMessage.isNotEmpty)
              Text(
                feedbackMessage,
                style: TextStyle(
                  color: feedbackMessage.contains('sent') ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: emailController.text.trim().isEmpty
                  ? null // Disable button if email is empty
                  : resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff003399),
                disabledBackgroundColor: Colors.grey, // Button style when disabled
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
              child: const Text(
                "Send Reset Email",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
