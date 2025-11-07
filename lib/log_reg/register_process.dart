import 'package:doseko_checker/log_reg/register_success.dart';
import 'package:doseko_checker/onboard/terms_conditions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterProcess extends StatefulWidget {
  const RegisterProcess({super.key});

  @override
  State<RegisterProcess> createState() => _RegisterProcessState();
}

class _RegisterProcessState extends State<RegisterProcess> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? fullnameError;
  String? mobileError;
  String? ageError;
  String? heightError;
  String? weightError;
  String? selectedGender; // Variable to store selected gender
  String? genderError; // Variable for gender validation error
  bool isMale = false;
  bool isFemale = false;
  bool isTermsAccepted = false; // Add this state variable in your class

  Future<void> saveUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String email = user.email!;
    final Map<String, dynamic> userData = {
      'fullname': fullnameController.text.trim(),
      'mobile': mobileController.text.trim(),
      'age': ageController.text.trim(),
      'height': heightController.text.trim(),
      'weight': weightController.text.trim(),
      'gender': selectedGender?.trim() ?? "Unspecified",
    };

    await FirebaseFirestore.instance.collection('users').doc(email).set(userData);
    print('User data saved for $email');
  }


  bool validateFields() {
    bool isValid = true;

    setState(() {
      fullnameError = fullnameController.text.isEmpty ? 'Full name is required' : null;
      mobileError = mobileController.text.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(mobileController.text)
          ? 'Enter a valid mobile number'
          : null;
      ageError = ageController.text.isEmpty || int.tryParse(ageController.text) == null
          ? 'Enter a valid age'
          : null;
      heightError = heightController.text.isEmpty || double.tryParse(heightController.text) == null
          ? 'Enter a valid height'
          : null;
      weightError = weightController.text.isEmpty || double.tryParse(weightController.text) == null
          ? 'Enter a valid weight'
          : null;
      genderError = (selectedGender == null) ? 'Please select your gender' : null;
    });

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(fullnameController.text)) {
      setState(() {
        fullnameError = 'Full Name should only contain letters';
      });
      isValid = false;
    } else {
      setState(() {
        fullnameError = null;
      });
    }

    // Check if any field is empty
    if (fullnameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        ageController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty) {
      setState(() {
        if (fullnameController.text.isEmpty) fullnameError = 'Full name is required';
        if (mobileController.text.isEmpty) mobileError = 'Mobile number is required';
        if (ageController.text.isEmpty) ageError = 'Age is required';
        if (heightController.text.isEmpty) heightError = 'Height is required';
        if (weightController.text.isEmpty) weightError = 'Weight is required';
      });
      return false; // Return false if any field is empty
    }

    return isValid &&
        fullnameError == null &&
        mobileError == null &&
        ageError == null &&
        heightError == null &&
        weightError == null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to prevent overflow
        child: Column(
          children: <Widget>[
            const SizedBox(height: 35),
            const Text("Fill in your bio to", maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 25)),
            const Text("get started", maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 25)),
            const Text("This data will be displayed in your", maxLines: 2, style: TextStyle(color: Color(0xff646464), fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 14)),
            const Text("account profile for security", maxLines: 2, style: TextStyle(color: Color(0xff646464), fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 14)),
            const SizedBox(height: 20),

            // FULL NAME TEXT FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurStyle: BlurStyle.outer, blurRadius: 2.00)
                      ],
                    ),
                    child: TextFormField(
                      controller: fullnameController,
                      decoration: const InputDecoration(
                        hintText: "Full Name",
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Nunito'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  if (fullnameError != null) // Show error message
                    Text(
                      fullnameError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // MOBILE NUMBER TEXT FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurStyle: BlurStyle.outer, blurRadius: 2.00)
                      ],
                    ),
                    child: TextFormField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                        hintText: "Mobile Number",
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Nunito'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (mobileError != null) // Show error message
                    Text(
                      mobileError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // AGE TEXT FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurStyle: BlurStyle.outer, blurRadius: 2.00)
                      ],
                    ),
                    child: TextFormField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        hintText: "Age",
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Nunito'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (ageError != null) // Show error message
                    Text(
                      ageError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // HEIGHT TEXT FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurStyle: BlurStyle.outer, blurRadius: 2.00)
                      ],
                    ),
                    child: TextFormField(
                      controller: heightController,
                      decoration: const InputDecoration(
                        hintText: "Height in cm",
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Nunito'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (heightError != null) // Show error message
                    Text(
                      heightError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // WEIGHT TEXT FIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurStyle: BlurStyle.outer, blurRadius: 2.00)
                      ],
                    ),
                    child: TextFormField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        hintText: "Weight in kg",
                        hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Nunito'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (weightError != null) // Show error message
                    Text(
                      weightError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Gender Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gender Label
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 5),
                    child: const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffEDEDED),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurStyle: BlurStyle.outer, blurRadius: 2.00)
                      ],
                    ),
                    child: Column(
                      children: [
                        // Male Radio Button
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Male',
                              groupValue: selectedGender, // Variable to store selected gender
                              onChanged: (String? value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                              activeColor: const Color(0xff003399), // Radio button color
                            ),
                            const Text(
                              'Male',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Nunito',
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),

                        // Female Radio Button
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Female',
                              groupValue: selectedGender, // Variable to store selected gender
                              onChanged: (String? value) {
                                setState(() {
                                  selectedGender = value!;
                                });
                              },
                              activeColor: const Color(0xff003399), // Radio button color
                            ),
                            const Text(
                              'Female',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Nunito',
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Display gender error if any
                  if (genderError != null)
                    Text(
                      genderError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Row(
                children: [
                  Checkbox(
                    value: isTermsAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        isTermsAccepted = value ?? false;
                      });
                    },
                    activeColor: const Color(0xff003399),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the Terms and Conditions page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsConditions()),
                      );
                    },
                    child: const Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        color: Colors.blue, // Make the text look clickable
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: // NEXT BUTTON
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * .9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff003399),
          ),
          child: TextButton(
            onPressed: () async {

              if (!isTermsAccepted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You must accept the Terms and Conditions")),
                );
                return;
              }

              // Validate fields
              bool isFieldsValid = validateFields();

              // Proceed only if all fields are valid
              if (isFieldsValid && fullnameError == null) {
                // Save user data to Firestore
                await saveUserData();

                // Navigate to the next screen (e.g., RegisterSuccess)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterSuccess()),
                );
              }
            },
            child: const Center(
              child: Text(
                "Register",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}