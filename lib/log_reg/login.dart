import 'package:doseko_checker/dashboard/navigation.dart';
import 'package:doseko_checker/log_reg/change_password.dart';
import 'package:doseko_checker/log_reg/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isPasswordVisible = false; // To toggle password visibility
  bool isLoading = false; // To show a loading indicator

  Future<void> signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Basic validations
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please fill out all fields.';
      });
      return;
    }

    // Validate email format
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
      errorMessage = ''; // Clear previous error message
    });

    try {
      // Attempt to sign in
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Log successful sign-in
      print("User signed in: ${userCredential.user?.email}");

      // Navigate to DisplayScreen if successful
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      setState(() {
        if (e.code == 'invalid-credential') {
          errorMessage = 'Invalid credentials. Please try again.';
        } else {
          errorMessage = 'Login failed. Please try again later.';
        }
      });
      print("FirebaseAuthException: ${e.code}");
    } catch (e) {
      // Catch unexpected errors
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
      });
      print("Unexpected error: $e");
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 430,
              width: 412,
              decoration: const BoxDecoration(
                color: Color(0xff003399),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),

          // LOGIN CONTAINER
          Positioned(
            top: 170,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                Container(
                  height: 422,
                  width: 300,
                  padding: const EdgeInsets.only(
                      top: 90, left: 30, right: 30, bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black54,
                            blurStyle: BlurStyle.outer,
                            blurRadius: 5.00)
                      ]),

                  // LOGIN CONTENTS
                  child: Column(
                    children: <Widget>[
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // EMAIL TEXT FIELD
                      Container(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xffEDEDED),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurStyle: BlurStyle.outer,
                                  blurRadius: 2.00)
                            ],
                          ),
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.mail_rounded,
                                  size: 25, color: Color(0xff003399)),
                              hintText: "Email",
                              hintStyle: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontFamily: 'Nunito'),
                              border: InputBorder.none,
                            ),
                          )),

                      const SizedBox(height: 20),

                      // PASSWORD TEXT FIELD
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffEDEDED),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 2.00,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible, // Toggle visibility
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.lock,
                              size: 25,
                              color: Color(0xff003399),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      // FORGET PASSWORD
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPassword()),
                          );
                        },
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black54,
                                fontFamily: 'Nunito'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Error Message
                      SizedBox(
                        height: 40, // Fixed height for error message
                        child: Center(
                          child: errorMessage.isNotEmpty
                              ? Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontFamily: 'Nunito',
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // LOGIN BUTTON
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff003399),
                        ),
                        child: TextButton(
                          onPressed: () => signIn(),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      fontFamily: 'Nunito',
                      color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to the Register Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Register(),
                      ),
                    );
                  },
                  child: const Text(
                    "REGISTER",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        fontFamily: 'Nunito',
                        color: Color(0xff003399)),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
              left: 0,
              right: 0,
              top: 80,
              child: Image.asset(
                'assets/images/login_img.png',
                height: 180,
              ))
        ],
      ),
    );
  }
}
