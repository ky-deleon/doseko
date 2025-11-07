import 'package:flutter/material.dart';

class Onboard1 extends StatelessWidget {
  const Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 90),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/onboard1_img.png',
              height: 260,
            ),
          ),
          const SizedBox(height: 140),
          const Text(
            'Welcome to DoseKo!',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 32),
          ),
          const SizedBox(height: 5),
          const Text(
            'Manage your medication with ease.',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
        ],
      ),
    );
  }
}
