import 'package:flutter/material.dart';
import 'package:doseko_checker/dashboard/help.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ApptAppbarTextPage extends StatelessWidget {

  const ApptAppbarTextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('MM-dd-yy').format(DateTime.now()); // Format current date

    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Appointment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 24,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Help()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              currentDate, // Dynamically display the current date
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(width: 0.5, color: color),
    borderRadius: BorderRadius.circular(12),
  );
}
