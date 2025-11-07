import 'package:doseko_checker/log_reg/login.dart';
import 'package:flutter/material.dart';
import 'package:doseko_checker/onboard/onboard1.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'onboard2.dart';
import 'onboard3.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

PageController pageController = PageController();

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 420,
                width: 465,
                decoration: const BoxDecoration(
                    borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(200)),
                    color: Color(0xFF1C39BB)),
              ),
            ),
            PageView(
              controller: pageController,
              children: const [
                Onboard1(),
                Onboard2(),
                Onboard3(),
              ],
            ),
            Container(
                alignment: const Alignment(0, 0.2),
                child:
                SmoothPageIndicator(controller: pageController, count: 3)),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 30, bottom: 30),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the Login Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  },
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1C39BB),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
