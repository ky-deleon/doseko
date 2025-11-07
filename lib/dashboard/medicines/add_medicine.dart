import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({Key? key}) : super(key: key);

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final TextEditingController _medicineNameController = TextEditingController();
  String _medicineType = 'Pill(s)/Tablet(s)';
  String _unit = 'Dosage unit';
  final TextEditingController _dosageController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _specificDays = [];
  List<TimeOfDay> _intakeTimes = [const TimeOfDay(hour: 0, minute: 0)];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _doseAvailableController =
  TextEditingController();
  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String? _selectedImage;
  final Map<String, String> pillImages = {
    'Black': 'assets/images/black_pill_img.png',
    'Blue': 'assets/images/blue_pill_img.png',
    'Red': 'assets/images/red_pill_img.png',
    'Green': 'assets/images/green_pill_img.png',
    'Yellow': 'assets/images/yellow_pill_img.png',
    'Pink': 'assets/images/pink_pill_img.png',
    'Cyan': 'assets/images/cyan_pill_img.png',
    'Orange': 'assets/images/orange_pill_img.png',
    'Violet': 'assets/images/violet_pill_img.png',
    'Indigo': 'assets/images/indigo_pill_img.png',
  };

  final Map<String, String> bottleImages = {
    'Black': 'assets/images/black_bottle_img.png',
    'Blue': 'assets/images/blue_bottle_img.png',
    'Red': 'assets/images/red_bottle_img.png',
    'Green': 'assets/images/green_bottle_img.png',
    'Yellow': 'assets/images/yellow_bottle_img.png',
    'Pink': 'assets/images/pink_bottle_img.png',
    'Cyan': 'assets/images/cyan_bottle_img.png',
    'Orange': 'assets/images/orange_bottle_img.png',
    'Violet': 'assets/images/violet_bottle_img.png',
    'Indigo': 'assets/images/indigo_bottle_img.png',
  };

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _doseAvailableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    requestNotificationPermissions(); // Request permissions
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(initSettings);
  }

  void _clearFields() {
    _medicineNameController.clear();
    _dosageController.clear();
    _doseAvailableController.clear();
    _notesController.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
      _specificDays = [];
      _intakeTimes = [const TimeOfDay(hour: 0, minute: 0)];
      _selectedImage = null;
    });
  }

  Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint("Notification permission granted.");
    } else {
      debugPrint("Notification permission denied.");
    }
  }

  void _showAppearanceDialog() {
    final List<String> colors = [
      'Black',
      'Blue',
      'Red',
      'Green',
      'Yellow',
      'Pink',
      'Cyan',
      'Orange',
      'Violet',
      'Indigo'
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Medicine Appearance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    _selectMedicineAppearance(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Image.asset(
                          _medicineType == 'Bottle'
                              ? bottleImages[color] ?? ''
                              : pillImages[color] ?? '',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          color,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveMedicineToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      // Use email instead of UID
      final userEmail = user.email;
      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User email not available!')),
        );
        return;
      }

      final medicineData = {
        'medicineName': _medicineNameController.text.trim(),
        'selectedImage': _selectedImage,
        'medicineType': _medicineType,
        'unit': _unit,
        'dosage': _dosageController.text.trim(),
        'startDate': _startDate?.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'specificDays': _specificDays,
        'intakeTimes': _intakeTimes
            .map((time) => {'hour': time.hour, 'minute': time.minute})
            .toList(),
        'notes': _notesController.text.trim(),
        'doseAvailable': _doseAvailableController.text.trim(),
        'notificationId': notificationId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail) // Use email as the document ID
          .collection('medicines')
          .add(medicineData);

      debugPrint("Medicine saved successfully for user: $userEmail!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine saved successfully!')),
      );
    } catch (e) {
      debugPrint("Error saving medicine: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving medicine: ${e.toString()}')),
      );
    }
  }

  void _selectMedicineAppearance(String color) {
    setState(() {
      _selectedImage = _medicineType == 'Bottle'
          ? bottleImages[color]
          : pillImages[color];
    });
  }

  List<DateTime> generateMedicineSchedule() {
    if (_startDate == null || _endDate == null) return [];
    List<DateTime> schedule = [];

    DateTime currentDate = _startDate!;
    while (!currentDate.isAfter(_endDate!)) {
      schedule.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return schedule;
  }

  Future<void> scheduleNotification(
      TimeOfDay time, DateTime date, int id) async {
    final DateTime combinedDateTime = combineDateAndTime(date, time);

    // Ensure the combined date-time is valid
    if (combinedDateTime.isBefore(DateTime.now())) {
      debugPrint("Error: Cannot schedule a notification in the past. Skipped.");
      return;
    }

    final tz.TZDateTime tzScheduledDate =
    tz.TZDateTime.from(combinedDateTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id, // Unique notification ID
        'Medicine Reminder',
        'It’s time to take your medicine!',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_channel', // Channel ID
            'Medicine Reminders', // Channel name
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Notification scheduled: ID=$id at $tzScheduledDate");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  Future<void> scheduleInBatches(List<DateTime> schedule) async {
    if (schedule.isEmpty) {
      debugPrint("No valid dates to schedule.");
      return;
    }

    int notificationId = 0; // Unique ID for each notification
    for (final date in schedule) {
      for (final time in _intakeTimes) {
        await scheduleNotification(time, date, notificationId);
        notificationId++;
      }
      await Future.delayed(
          const Duration(milliseconds: 500)); // Prevent scheduler overload
    }
  }

  Future<DateTime?> _selectDate() async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    return selectedDate;
  }

  Future<TimeOfDay?> _selectTime(TimeOfDay initialTime) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    return newTime; // This will return the selected time
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
          "Add Medicine",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 22),
                child: Text(
                  'Medicine Name',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                  children: [
                    _selectedImage == null
                        ? const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xff003399),
                      size: 40,
                    )
                        : Image.asset(
                      _selectedImage!,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(
                        width: 10), // Space between the icon and the text field
                    Expanded(
                      child: TextFormField(
                        controller: _medicineNameController,
                        decoration: const InputDecoration(
                          hintText: "Enter medicine name",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                            fontFamily: 'Nunito',
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Match the right padding of text fields
                child: TextButton(
                  onPressed: _showAppearanceDialog,
                  child: const Text(
                    "Appearance",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff003399),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns fields at the top
                children: [
                  // Medicine Type Dropdown
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medicine Type',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                            children: [
                              Expanded(
                                child: DropdownButtonFormField(
                                  value: _medicineType,
                                  items: ['Pill(s)/Tablet(s)', 'Bottle']
                                      .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _medicineType = value.toString();
                                      _unit = _medicineType == 'Bottle' ? 'mL' : 'pc/s';
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Unit Display
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unit',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 53, // Same height as other fields
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
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
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _unit,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black54,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns at the top
                children: [
                  // Dosage Text Field
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dose Amount',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
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
                            controller: _dosageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Enter dosage",
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 17,
                                fontFamily: 'Nunito',
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Unit Dropdown
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dose Available',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
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
                            controller:
                            _doseAvailableController, // Use the new controller
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Input total dosage",
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize: 17,
                                fontFamily: 'Nunito',
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
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
            // START DATE
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
                        _startDate != null
                            ? DateFormat('MM/dd/yyyy').format(_startDate!)
                            : 'Select Start Date',
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
                      onPressed: () async {
                        final date = await _selectDate();
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                            print("Start Date: $_startDate");
                          });
                        }
                      },
                    ),
                  ],
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
                        _endDate != null
                            ? DateFormat('MM/dd/yyyy').format(_endDate!)
                            : 'Select End Date',
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
                      onPressed: () async {
                        final date = await _selectDate();
                        if (date != null) {
                          // Directly set the end date
                          setState(() {
                            _endDate = date;
                          });
                          print("End Date: $_endDate");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 22),
                child: Text(
                  'Intake Time',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Nunito'),
                ),
              ),
            ),

            ..._intakeTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.red.withOpacity(0.7),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold)),
                          content: const Text(
                              'Are you sure you want to delete this intake time?',
                              style: TextStyle(
                                  fontFamily: 'Nunito', fontSize: 16)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No',
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 15)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes',
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 15)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _intakeTimes.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Intake time deleted successfully!')),
                    );
                  },
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
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${index + 1}",
                                  style: const TextStyle(
                                    color: Color(0xff003399),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                TextSpan(
                                  text: ": ${time.format(context)}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xff003399),
                          ),
                          onPressed: () async {
                            final newTime = await _selectTime(time);
                            if (newTime != null) {
                              setState(() {
                                _intakeTimes[index] = newTime;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            TextButton(
              onPressed: () {
                setState(() =>
                    _intakeTimes.add(const TimeOfDay(hour: 17, minute: 0)));
              },
              child: const Text(
                "Add Another Intake Time",
                style: TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Notes (Optional)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20), // Match the left padding of text fields
                child: Text(
                  "Notes (optional)",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff003399),
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
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
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Type your notes here...",
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: ElevatedButton(
          onPressed: () async {
            if (_startDate == null || _endDate == null || _medicineNameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all required fields.')),
              );
              return;
            }

            if (_startDate!.isAfter(_endDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Start date cannot be after end date.')),
              );
              return;
            }

            final schedule = generateMedicineSchedule();
            if (schedule.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No valid dates to schedule.')),
              );
              return;
            }

            await scheduleInBatches(schedule); // Schedule notifications
            await _saveMedicineToFirestore(); // Save data to Firestore

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medicine schedule saved!')),
            );

            Navigator.pop(context, true); // Pass a result to trigger refresh
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff003399),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }
}
