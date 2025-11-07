import 'dart:io';
import 'package:doseko_checker/dashboard/profile/change_password.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  final File? profileImage; // Profile image passed from ProfilePage

  const EditProfilePage({Key? key, this.profileImage}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String phoneErrorMessage = '';
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    profileImage = widget.profileImage;
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();
        setState(() {
          fullNameController.text = userDoc.get('fullname') ?? '';
          phoneController.text = userDoc.get('mobile') ?? '';
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImage = File(image.path); // Update the profile image
      });
    }
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

  Future<void> saveChanges() async {
    if (phoneController.text.length != 11) {
      setState(() {
        phoneErrorMessage = "Phone number must be exactly 11 digits.";
      });
      return;
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save profileImage path and other details
        final profileImagePath = profileImage?.path;
        await FirebaseFirestore.instance.collection('users').doc(user.email).update({
          'fullname': fullNameController.text,
          'mobile': phoneController.text,
          'profileImageUrl': profileImagePath, // Save image path
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, {
          'profileImage': profileImage,
        });
      }
    } catch (e) {
      print("Error saving changes: $e");
      _showAlert("Error", "Failed to save changes. Please try again.");
    }
  }


  void confirmSaveChanges() {
    if (fullNameController.text.isEmpty || phoneController.text.isEmpty) {
      _showAlert("Incomplete Fields", "Please fill out all fields before saving.");
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xff003399).withOpacity(0.26),
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!) // Display the passed profile image
                    : null,
                child: profileImage == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: pickImage,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change Image",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Nunito',
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    color: Color(0xff003399),
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Full Name",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildTextField(
                    "Full Name",
                    fullNameController,
                    textType: TextInputType.text,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$'))],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phone Number",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildTextField("Phone Number", phoneController, textType: TextInputType.phone),
                ],
              ),
            ),
            if (phoneErrorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5),
                child: Text(
                  phoneErrorMessage,
                  style: const TextStyle(color: Colors.red, fontFamily: 'Nunito', fontSize: 14),
                ),
              ),

            const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
              },
              child: const Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Change Password     ",
                  style: TextStyle(fontFamily: 'Nunito', color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType textType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: textType,
        inputFormatters: inputFormatters,
        onChanged: (value) {
          if (controller == phoneController && value.length == 11) {
            setState(() {
              phoneErrorMessage = ''; // Clear error message when valid
            });
          }
        },
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
