import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditCardPage extends StatefulWidget {
  final String appointmentName;
  final DateTime dateTime;
  final String? notes;

  const EditCardPage({
    Key? key,
    required this.appointmentName,
    required this.dateTime,
    this.notes,
  }) : super(key: key);

  @override
  _EditCardPageState createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  late TextEditingController _appointmentNameController;
  late TextEditingController _notesController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _appointmentNameController = TextEditingController(text: widget.appointmentName);
    _notesController = TextEditingController(text: widget.notes);
    _selectedDateTime = widget.dateTime;
  }

  @override
  void dispose() {
    _appointmentNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _saveChanges() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      // Update the appointment in Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointments')
          .where('appointmentName', isEqualTo: widget.appointmentName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'appointmentName': _appointmentNameController.text,
          'dateTime': _selectedDateTime.toIso8601String(),
          'notes': _notesController.text,
          'status': 'Not Set', // Reset status
        });
      }

      // Return to the previous screen and refresh the data
      Navigator.pop(context, true); // Pass `true` to indicate an update was made
    } catch (e) {
      print('Error saving changes: $e');
    }
  }

  Future<void> _deleteAppointment() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      // Delete the appointment from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointments')
          .where('appointmentName', isEqualTo: widget.appointmentName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }

      // Return to the previous screen and refresh the data
      Navigator.pop(context, true); // Pass `true` to indicate a deletion was made
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Appointment'),
        backgroundColor: const Color(0xff003399),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _appointmentNameController,
              decoration: const InputDecoration(
                labelText: 'Appointment Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    hintText: DateFormat('yMMMMd').format(_selectedDateTime),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectTime,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.access_time),
                    hintText: DateFormat('h:mm a').format(_selectedDateTime),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff003399),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _deleteAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
