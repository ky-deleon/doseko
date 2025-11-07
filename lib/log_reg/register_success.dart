import 'package:doseko_checker/dashboard/navigation.dart';
import 'package:flutter/material.dart';


class RegisterSuccess extends StatefulWidget {
  const RegisterSuccess({super.key});

  @override
  State<RegisterSuccess> createState() => _RegisterSuccessState();
}

class _RegisterSuccessState extends State<RegisterSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
          Container(
            height: 100,
            width: 412,
            decoration: const BoxDecoration(
              color: Color(0xff003399),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurStyle: BlurStyle.outer,
                  blurRadius: 10.0,
                )
              ],
            ),
            child: const Align(
              alignment: Alignment(-0.9, 0.28),
            ),
          ),

          const SizedBox(height: 110),

          Image.asset(
            'assets/images/check_img.png',
            height: 160,
          ),

          const SizedBox(height: 20),

          const Text(
            "Congrats!",
            style: TextStyle(
              color: Color(0xff003399),
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              fontSize: 30,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "Your profile is ready to use.",
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              fontSize: 21,
            ),
          ),

          const SizedBox(height: 130),

          // NEXT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * .9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xff003399),
              ),
              child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),//replace home
                    );
                  },
                  child: const Text(
                    "Proceed to Home",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontSize: 17),
                  )),
            ),
          ),

        ],
      ),
    );
  }
}
