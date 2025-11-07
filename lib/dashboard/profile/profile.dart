import 'dart:io';
import 'package:doseko_checker/dashboard/help.dart';
import 'package:doseko_checker/dashboard/profile/about.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import 'health_details.dart';
import 'package:doseko_checker/log_reg/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "Loading...";
  String email = "Loading...";
  File? profileImage; // Stores the selected profile image

  late Future<void> userDataFuture; // Store the Future for user data

  @override
  void initState() {
    super.initState();
    userDataFuture = fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final email = user.email!;
        final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(email).get();

        setState(() {
          fullName = userDoc.get('fullname') ?? "No Name";
          this.email = email;
          profileImage = userDoc.get('profileImageUrl') != null
              ? File(userDoc.get('profileImageUrl')) // Assuming profileImageUrl is stored as a local path
              : null;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  void showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm Logout",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await logout();
            },
            child: const Text(
              "Log Out",
              style: TextStyle(fontFamily: 'Nunito'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for data
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle errors
          return const Scaffold(
            body: Center(
              child: Text(
                "Error loading data",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 18),
              ),
            ),
          );
        }

        // Build the UI once data is fetched
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff003399),
            toolbarHeight: 280,
            automaticallyImplyLeading: false,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white12,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null, // Displays local image
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName,
                    style: const TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontFamily: 'Nunito'),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(
                left: 20, right: 10, top: 15, bottom: 15),
            children: [
              _buildListTile(
                context,
                icon: Icons.edit,
                title: "Edit Profile",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(profileImage: profileImage),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      profileImage = result['profileImage'];
                    });
                  }
                  fetchUserData(); // Refresh profile data after editing
                },
              ),
              _buildListTile(
                context,
                icon: Icons.health_and_safety,
                title: "Health Details",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HealthDetailsPage()),
                  );
                },
              ),

              _buildListTile(
                context,
                icon: Icons.help,
                title: "FAQs",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Help()),
                  );
                },
              ),

              _buildListTile(
                context,
                icon: Icons.info,
                title: "About",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutPage()),
                  );
                },
              ),


              const Divider(color: Colors.grey),
              _buildListTile(
                context,
                icon: Icons.logout,
                title: "Log Out",
                onTap: () {
                  showLogoutConfirmationDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xff003399),
        size: 27,
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Nunito', fontSize: 17, color: Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
