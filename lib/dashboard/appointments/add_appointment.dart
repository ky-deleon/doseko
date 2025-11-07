import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({Key? key}) : super(key: key);

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final TextEditingController _appointmentNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _submitAppointment() async {
    if (_appointmentNameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final appointmentData = {
      'appointmentName': _appointmentNameController.text.trim(),
      'notes': _notesController.text.trim(),
      'dateTime': DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ).toIso8601String(),
    };

    Navigator.pop(context, appointmentData); // Pass the data back to AppointmentPage
  }




  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        final formattedTime =
            '${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
        _timeController.text = formattedTime;
      });
    }
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
          "Add Appointment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: TextFormField(
                  controller: _appointmentNameController,
                  decoration: const InputDecoration(
                    hintText: "Appointment Name",
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontFamily: 'Nunito',
                    ),
                    border: InputBorder.none, // Removes the default border
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 31),
                child: Text(
                  'Notes (optional)',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff003399)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            const SizedBox(height: 10),

            //DATE
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 22),
                child: Text(
                  'Date',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Nunito'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        _dateController.text.isNotEmpty
                            ? _dateController.text
                            : 'Select Date',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Nunito',
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xff003399),
                        size: 23,
                      ),
                      onPressed: _pickDate,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            //DATE
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 22),
                child: Text(
                  'Time',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Nunito'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        _timeController.text.isNotEmpty
                            ? _timeController.text
                            : 'Select Time',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Nunito',
                          fontSize: 17,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.access_time,
                        color: Color(0xff003399),
                        size: 23,
                      ),
                      onPressed: _pickTime,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: _submitAppointment,
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
