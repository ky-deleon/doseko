import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "About",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
            child: Column(
              children: [
                Stack(
                  children: <Widget> [
                    _buildAboutDoseKoSection(),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/images/doseko_img.png',
                        height: 100,
                      ),
                    ),

                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Key Features",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          color: Color(0xff003399), // Same as AppBar color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeaturesGrid(),
                    const SizedBox(height: 15),
                    Image.asset(
                      'assets/images/googleplay_img.png',
                      height: 80,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutDoseKoSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff003399),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DoseKo",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nunito'
              ),
            ),
            SizedBox(height: 10),
            Text(
              "DoseKo is your trusted companion for managing medications, ensuring users never miss a dose with features like reminders and tracking. "
                  "Developed by a dedicated team—Butial, R., De Leon, K., and Magno, R.—the app combines simplicity and efficiency. "
                  "From notifications to refill alerts, DoseKo makes healthcare management easy, catering to individuals of all ages and lifestyles.",
              style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Nunito'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return GridView(
      shrinkWrap: true, // Adjust height dynamically
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1, // Square containers
      ),
      children: [
        _buildFeatureCard(
          icon: Icons.alarm,
          title: "Medication Reminder",
        ),
        _buildFeatureCard(
          icon: Icons.track_changes,
          title: "Dosage Tracking",
        ),
        _buildFeatureCard(
          icon: Icons.event,
          title: "Appointment Reminder",
        ),
        _buildFeatureCard(
          icon: Icons.notifications_active,
          title: "Refill Alerts",
        ),
        _buildFeatureCard(
          icon: Icons.person,
          title: "User Profile",
        ),
        _buildFeatureCard(
          icon: Icons.lock,
          title: "Secure Data",
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(8), // Adjusted padding
      decoration: BoxDecoration(
        color: const Color(0xff003399), // Same as AppBar color
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Nunito'
            ),
          ),
        ],
      ),
    );
  }
}
