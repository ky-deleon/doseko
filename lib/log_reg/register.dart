import 'package:doseko_checker/log_reg/login.dart';
import 'package:doseko_checker/log_reg/register_process.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String errorMessage = '';
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  void register() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Regular expression for password validation:
    // At least 8 characters, one uppercase letter, and one number
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');

    // Validation for empty fields
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required.';
      });
      return;
    }

    // Email format validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    // Password match validation
    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    // Password strength validation
    if (!passwordRegex.hasMatch(password)) {
      setState(() {
        errorMessage = 'Password requires 8+ characters, a number, and an uppercase letter.';
      });
      return;
    }

    try {
      // Check if the email is already registered
      final List<String> methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        setState(() {
          errorMessage = 'Email is already registered.';
        });
        return;
      }

      // Create a new user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to the next screen upon successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterProcess()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth-specific errors
      if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'Email is already registered.';
        });
      } else {
        setState(() {
          errorMessage = 'Registration failed. Try again.';
        });
      }
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        errorMessage = 'An unexpected error occurred. Try again.';
      });
    }
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

          // Register CONTAINER
          Positioned(
            top: 170,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                Container(
                  height: 450,
                  width: 300,
                  padding: const EdgeInsets.only(top: 62, left: 30, right: 30, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurStyle: BlurStyle.outer,
                        blurRadius: 5.0,
                      ),
                    ],
                  ),

                  // Register CONTENTS
                  child: Column(
                    children: <Widget>[
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                          fontSize: 25,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // EMAIL TEXT FIELD
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffEDEDED),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail_rounded, size: 25, color: Color(0xff003399)),
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Nunito'),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock, size: 25, color: Color(0xff003399)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // CONFIRM PASSWORD TEXT FIELD
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffEDEDED),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock, size: 25, color: Color(0xff003399)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                });
                              },
                            ),
                            hintText: "Confirm Password",
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ERROR MESSAGE
                      SizedBox(
                        height: 40, // Fixed height for error message
                        child: Center(
                          child: errorMessage.isNotEmpty
                              ? Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Restrict error to two lines
                          )
                              : null, // Keeps space reserved when no error message
                        ),
                      ),

                      const SizedBox(height: 20),

                      // REGISTER BUTTON
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * .9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xff003399),
                        ),
                        child: TextButton(
                          onPressed: () {
                            register();
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                const Text(
                  "Already have an account?",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, fontFamily: 'Nunito', color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, fontFamily: 'Nunito', color: Color(0xff003399)),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Image.asset(
                'assets/images/register_img.png',
                height: 180,
              ))

        ],
      ),
    );
  }
}
