import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'log_side_effect.dart';
import 'package:doseko_checker/dashboard/help.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<Map<String, dynamic>> logs = [];
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      fetchLogs();
    }
  }

  void fetchLogs() async {
    if (currentUser == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .collection('logs')
        .get();

    setState(() {
      logs = snapshot.docs
          .map((doc) =>
      {
        'id': doc.id,
        'date': doc['date'],
        'symptoms': List<String>.from(doc['symptoms']),
        'notes': doc['notes'] ?? '',
      })
          .toList();

      // Sort logs by date (most recent first)
      logs.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA); // Recent date first
      });
    });
  }

  void deleteLog(String id) async {
    if (currentUser == null) return;

    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text(
              "Delete Log",
              style: TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Are you sure you want to delete this log?",
              style: TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                    "Delete", style: TextStyle(fontFamily: 'Nunito', fontSize: 15)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                    "Cancel", style: TextStyle(fontFamily: 'Nunito', fontSize: 15)),
              ),
            ],
          ),
    );

    if (confirmDelete == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.email)
          .collection('logs')
          .doc(id)
          .delete();

      fetchLogs();
    }
  }

  void editLog(String id, String date, List<String> symptoms,
      String notes) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LogFormPage(
              logId: id,
              existingDate: date,
              existingSymptoms: symptoms,
              existingNotes: notes,
            ),
      ),
    );
    fetchLogs();
  }

  void navigateToLogForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogFormPage()),
    );
    fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff003399),
        toolbarHeight: 75,
        title: const Text(
          'Log Activity',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Help()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: currentUser == null
            ? buildEmptyState()
            : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.email)
              .collection('logs')
              .orderBy('date', descending: true) // Ensures latest first
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return buildEmptyState();
            }

            logs = snapshot.data!.docs.map((doc) {
              return {
                'id': doc.id,
                'date': doc['date'],
                'symptoms': List<String>.from(doc['symptoms']),
                'notes': doc['notes'] ?? '',
              };
            }).toList();

            return buildLogList();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToLogForm,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xff003399),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }


  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/log_img.png',
            height: 160,
          ),
          const SizedBox(height: 10),
          const Text(
            'No logs yet',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'If you experienced side-effects or symptoms, tap the Add button to keep track of them.',
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'Nunito',
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogList() {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          // Increased padding between cards
          child: Stack(
            children: [
              Card(
                color: const Color(0xffEDEDED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.black26, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 15, right: 5),
                  child: ListTile(
                    title: Text(
                      log['date'],
                      style: const TextStyle(
                        color: Color(0xff003399),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...log['symptoms']
                              .map(
                                (symptom) =>
                                Text(
                                  '• $symptom',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Nunito',
                                    fontSize: 17, // Increased bullet text size
                                  ),
                                ),
                          )
                              .toList(),
                          if (log['notes'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 10),
                              child: Text(
                                'Notes: ${log['notes']}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Nunito',
                                  fontSize: 15, // Minimized notes text size
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    onTap: () =>
                        editLog(
                          log['id'],
                          log['date'],
                          List<String>.from(log['symptoms']),
                          log['notes'],
                        ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () => deleteLog(log['id']),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
