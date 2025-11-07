import 'package:flutter/material.dart';

class Onboard3 extends StatelessWidget {
  const Onboard3({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 90),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/onboard3_img.png',
              height: 260,
            ),
          ),
          const SizedBox(height: 140),
          const Text(
            'Get started now!',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 32),
          ),
          const SizedBox(height: 5),
          const Text(
            'Take control of your health today!',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
        ],
      ),
    );
  }
}
