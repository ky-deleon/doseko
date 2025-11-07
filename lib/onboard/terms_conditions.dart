import 'package:flutter/material.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: const Color(0xff003399), // Adjust as per your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms and Conditions for Doseko App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Introduction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome to Doseko! By using this app, you agree to be bound by the following terms and conditions. If you do not agree, please discontinue using the app immediately.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'User Responsibilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. You must provide accurate and complete information when registering or using the app. Misrepresentation may result in account suspension or termination.\n'
                    '2. You are responsible for maintaining the confidentiality of your login credentials. Notify us immediately of unauthorized access to your account.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'App Usage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Doseko is designed to assist users in tracking their health and wellness data. The app does not provide medical advice and should not replace professional medical consultations.\n'
                    '2. The app\'s features and services are provided for informational purposes only and are not a substitute for professional judgment.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Data Privacy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. All personal data entered into the app will be handled in accordance with our Privacy Policy.\n'
                    '2. We are committed to protecting your data and will not share your information with third parties without your consent.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Restrictions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. You agree not to misuse the app, including but not limited to:\n'
                    '- Hacking, spamming, or attempting to disrupt app services.\n'
                    '- Uploading malicious code or content.\n'
                    '2. Use of the app is subject to applicable local laws.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Termination',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We reserve the right to suspend or terminate accounts that violate these terms or are involved in fraudulent or unlawful activities.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Limitation of Liability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Doseko does not guarantee the accuracy or completeness of data provided within the app.\n'
                    '2. We are not responsible for any damages resulting from your use of the app, including health-related consequences.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Changes to Terms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We may update these terms periodically. Continued use of the app indicates acceptance of any changes.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'If you have questions or concerns regarding these Terms and Conditions, please contact us at support@doseko.com.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
