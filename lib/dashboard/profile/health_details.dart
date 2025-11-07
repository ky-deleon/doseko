import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class HealthDetailsPage extends StatefulWidget {
  const HealthDetailsPage({Key? key}) : super(key: key);

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String? selectedGender;
  double bmi = 0.0;
  String bmiCategory = "Unknown";
  Color bmiColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.email).get();
        setState(() {
          ageController.text = userDoc.get('age') ?? '';
          heightController.text = userDoc.get('height') ?? '';
          weightController.text = userDoc.get('weight') ?? '';
          selectedGender = userDoc.get('gender') ?? 'Male';
          calculateBMI();
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  void calculateBMI() {
    final double? height = double.tryParse(heightController.text);
    final double? weight = double.tryParse(weightController.text);
    if (height != null && weight != null && height > 0) {
      setState(() {
        bmi = weight / pow(height / 100, 2);
        determineBMICategory();
      });
    }
  }

  void determineBMICategory() {
    if (bmi < 18.5) {
      bmiCategory = "Underweight";
      bmiColor = Colors.blue;
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      bmiCategory = "Normal weight";
      bmiColor = Colors.green;
    } else if (bmi >= 25 && bmi <= 29.9) {
      bmiCategory = "Overweight";
      bmiColor = Colors.orange;
    } else {
      bmiCategory = "Obesity";
      bmiColor = Colors.red;
    }
  }

  Future<void> saveChanges() async {
    if (ageController.text.isEmpty || heightController.text.isEmpty || weightController.text.isEmpty) {
      _showAlert("Incomplete Fields", "Please fill out all fields before saving.");
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.email).update({
          'age': ageController.text,
          'height': heightController.text,
          'weight': weightController.text,
          'gender': selectedGender ?? 'Unspecified',
        });
        calculateBMI();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Health details updated successfully!',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Navigate back to profile page
      }
    } catch (e) {
      print("Error saving health details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to save health details. Try again.',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void confirmSaveChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm Changes",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to save these changes?",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Nunito')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              saveChanges();
            },
            child: const Text("Save", style: TextStyle(fontFamily: 'Nunito')),
          ),
        ],
      ),
    );
  }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Nunito')),
        content: Text(content, style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontFamily: 'Nunito')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        centerTitle: true,
        title: const Text(
          "Edit Health Details",
          style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBMISection(),
            const SizedBox(height: 15),
            _buildGenderSelection(),
            const Text(
              "Age",
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildTextField("Age", ageController, TextInputType.number),
            const Text(
              "Height (in cm)",
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildTextField("Height (in cm)", heightController, TextInputType.number),
            const Text(
              "Weight (in kg)",
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildTextField("Weight (in kg)", weightController, TextInputType.number),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: confirmSaveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff003399),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'SAVE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Nunito'),
          ),
        ),
      ),
    );
  }

  Widget _buildBMISection() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bmiColor.withOpacity(0.2), // Light background color matching BMI category
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Your BMI",
            style: TextStyle(fontFamily: 'Nunito', fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(fontFamily: 'Nunito', fontSize: 35, fontWeight: FontWeight.bold, color: bmiColor),
          ),
          const SizedBox(height: 10),
          CircularProgressIndicator(
            value: (bmi / 30).clamp(0.0, 1.0),
            color: bmiColor,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            "Category: $bmiCategory",
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Male',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                  calculateBMI();
                });
              },
            ),
            const Text("Male", style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
            Radio<String>(
              value: 'Female',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                  calculateBMI();
                });
              },
            ),
            const Text("Female", style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => calculateBMI(),
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
