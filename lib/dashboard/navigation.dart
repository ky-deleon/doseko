import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'appointments/appointment.dart';
import 'log activity/log_activity.dart'; // Import individual pages
import 'medicines/medicines.dart';
import 'profile/profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // List of pages to load for each tab
  final List<Widget> _pages = [
    LogPage(),
    AppointmentPage(),
    MedicinePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25, top: 15),
          child: GNav(
            backgroundColor: Colors.white,
            color: const Color(0xff003399),
            activeColor: const Color(0xff003399),
            tabBackgroundColor: const Color(0xff003399).withOpacity(0.13),
            gap: 5,
            padding: const EdgeInsets.all(16),
            iconSize: 26,
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              color: Color(0xff003399),
            ),
            tabs: const [
              GButton(
                icon: Icons.list_alt,
                text: 'Log',
              ),
              GButton(
                icon: Icons.calendar_today,
                text: 'Appt',
              ),
              GButton(
                icon: Icons.medication,
                text: 'Meds',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
