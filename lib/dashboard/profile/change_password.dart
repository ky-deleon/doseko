import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String currentPasswordError = '';
  String newPasswordError = '';
  String generalError = '';
  bool isLoading = false;

  Future<bool> validateCurrentPassword(String currentPassword) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<void> changePassword() async {
    final String currentPassword = currentPasswordController.text.trim();
    final String newPassword = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    // Password constraint regex: at least 8 characters, one uppercase letter, and one number
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');

    setState(() {
      currentPasswordError = '';
      newPasswordError = '';
      generalError = '';
    });

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        generalError = 'All fields are required.';
      });
      return;
    }

    if (!await validateCurrentPassword(currentPassword)) {
      setState(() {
        currentPasswordError = 'Current password is incorrect.';
      });
      return;
    }

    if (!passwordRegex.hasMatch(newPassword)) {
      setState(() {
        newPasswordError = 'Password must be at least 8 characters, include one uppercase letter and one number.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        newPasswordError = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        Navigator.pop(context); // Go back to the previous screen
      }
    } catch (e) {
      setState(() {
        generalError = 'An error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        centerTitle: true,
        title: const Text(
          "Change Password",
          style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField("Current Password", currentPasswordController),
            if (currentPasswordError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  currentPasswordError,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'Nunito'),
                ),
              ),
            _buildPasswordField("New Password", newPasswordController),
            _buildPasswordField("Confirm Password", confirmPasswordController),
            if (newPasswordError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  newPasswordError,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'Nunito'),
                ),
              ),
            if (generalError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  generalError,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'Nunito'),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: isLoading ? null : changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff003399),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
            'SAVE',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Nunito'),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black, fontSize: 17, fontFamily: 'Nunito'),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
