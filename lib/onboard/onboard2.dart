import 'package:flutter/material.dart';

class Onboard2 extends StatelessWidget {
  const Onboard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 90),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/onboard2_img.png',
              height: 260,
            ),
          ),
          const SizedBox(height: 140),
          const Text(
            'Stay on track!',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 32),
          ),
          const SizedBox(height: 5),
          const Text(
            'Never miss, stay in bliss.',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
          ),
        ],
      ),
    );
  }
}
