import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogFormPage extends StatefulWidget {
  final String? logId;
  final String? existingDate;
  final List<String>? existingSymptoms;
  final String? existingNotes;

  LogFormPage({this.logId, this.existingDate, this.existingSymptoms, this.existingNotes});

  @override
  _LogFormPageState createState() => _LogFormPageState();
}

class _LogFormPageState extends State<LogFormPage> {
  List<String> sideEffects = [
    "Headache",
    "Fever",
    "Nausea",
    "Drowsiness",
    "Dizziness",
    "Dry Mouth",
    "Constipation",
    "Insomnia",
    "Rash",
    "Weight Gain",
    "Weight Loss",
    "Blurred Vision",
    "Mood Changes",
    "Fatigue",
    "Appetite Changes",
    "Abdominal Pain",
    "Cough",
    "Joint Pain",
    "Muscle Aches",
    "Sexual Dysfunction",
    "Diarrhea"
  ];

  List<String> selectedEffects = [];
  DateTime selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingDate != null) {
      selectedDate = DateFormat('dd-MMMM-yyyy').parse(widget.existingDate!);
    }
    if (widget.existingSymptoms != null) {
      selectedEffects = List<String>.from(widget.existingSymptoms!);
    }
    if (widget.existingNotes != null) {
      _notesController.text = widget.existingNotes!;
    }
  }

  void saveLog() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is logged in.")),
      );
      return;
    }

    final String userEmail = currentUser.email!;
    final formattedDate = DateFormat('dd-MMMM-yyyy').format(selectedDate);

    final logData = {
      'date': formattedDate,
      'symptoms': selectedEffects,
      'notes': _notesController.text,
    };

    if (widget.logId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('logs')
          .doc(widget.logId)
          .update(logData);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('logs')
          .add(logData);
    }

    Navigator.pop(context);
  }

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
          "Log Side Effects",
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Date: ${DateFormat('dd-MMMM-yyyy').format(selectedDate)}',
                  style: const TextStyle(
                    color: Color(0xff003399),
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today, color: Color(0xff003399), size: 23),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: const Color(0xff003399),
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xff003399),
                            secondary: Color(0xff003399),
                          ),
                          buttonTheme: const ButtonThemeData(
                            textTheme: ButtonTextTheme.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ),
            const Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 10),
              child: ListView.builder(
                itemCount: sideEffects.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(
                      sideEffects[index],
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17,
                      ),
                    ),
                    value: selectedEffects.contains(sideEffects[index]),
                    activeColor: const Color(0xff003399),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedEffects.add(sideEffects[index]);
                        } else {
                          selectedEffects.remove(sideEffects[index]);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 36),
                child: Text(
                  'Notes (optional)',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Color(0xff003399)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurStyle: BlurStyle.outer,
                      blurRadius: 2.00,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your notes here...',
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontFamily: 'Nunito',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: saveLog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff003399),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'SAVE',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Nunito'
            ),
          ),
        ),
      ),
    );
  }
}
