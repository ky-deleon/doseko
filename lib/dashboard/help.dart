import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqList = [
      {
        "question": "What is DoseKo?",
        "answer":
        "DoseKo is a medication management app that helps users organize and track their prescriptions.",
      },
      {
        "question": "Who is DoseKo designed for?",
        "answer":
        "DoseKo is designed for anyone who needs to manage medications, including elderly users and caregivers.",
      },
      {
        "question": "How do I add a new medication?",
        "answer":
        "Tap the 'Add Medication' button and fill out the required fields, such as name and schedule.",
      },
      {
        "question": "Can DoseKo remind me to take my medication?",
        "answer":
        "Yes, DoseKo sends notifications to remind you to take your medication on time.",
      },
      {
        "question": "Can I manage multiple medications in DoseKo?",
        "answer":
        "Yes, DoseKo allows users to manage and set reminders for different medications simultaneously, making it suitable for complex regimens.",
      },
      {
        "question": "How does the refill reminder work?",
        "answer":
        "Set the refill quantity when adding a medication, and DoseKo will notify you when it's time to refill.",
      },
      {
        "question": "How secure is my data on DoseKo?",
        "answer":
        "Your data is encrypted and securely stored, with privacy as a top priority.",
      },
    ];

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
          "FAQs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Column(
            children: faqList.map((faq) {
              return FAQTile(
                question: faq['question']!,
                answer: faq['answer']!,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({required this.question, required this.answer, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1C39BB), width: 1.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'Nunito',
          ),
        ),
        children: [
          Container(
            color: const Color(0xFF1C39BB),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
