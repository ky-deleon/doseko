import 'package:doseko_checker/dashboard/navigation.dart';
import 'package:doseko_checker/onboard/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'onboard/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied ||
      await Permission.notification.isRestricted ||
      await Permission.notification.isLimited) {
    await Permission.notification.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notification service
  final NotificationService notificationService = NotificationService();
  await notificationService.init();

  // Request notification permission
  await requestNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xff003399),
        colorScheme: const ColorScheme.light(
          primary: Color(0xff003399),
          secondary: Color(0xff003399),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff003399),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff003399),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color(0xff003399),
            fontFamily: 'Nunito',
          ),
          suffixIconColor: Color(0xff003399),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.white),
          fillColor: MaterialStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        timePickerTheme: const TimePickerThemeData(
          dialTextColor: Color(0xff003399),
          dialHandColor: Color(0xff003399),
        ),
        datePickerTheme: const DatePickerThemeData(
          dayStyle: TextStyle(
            color: Color(0xff003399),
            fontFamily: 'Nunito',
            fontSize: 16,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthHandler(),
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const MainPage(); // Navigate to Home if logged in
        } else {
          return const Onboarding(); // Navigate to Onboarding if not logged in
        }
      },
    );
  }

  Future<User?> _checkUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }
}
