import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doseko_checker/dashboard/medicines/add_medicine.dart';
import 'package:doseko_checker/dashboard/medicines/edit_card_med.dart';
import 'package:doseko_checker/dashboard/medicines/medicines appbar/medicines_content.dart';
import 'package:doseko_checker/dashboard/medicines/view_medicine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'medicines appbar/medicines_content.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({Key? key}) : super(key: key);

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<String, String> medicineStatuses =
      {}; // Map to track statuses by medicine ID
  DateTime _selectedDate = DateTime.now();
  List<QueryDocumentSnapshot> _filteredMedicines = [];
  Set<DateTime> _daysWithMedicines = {};
  Color? selectedRadioColor;
  Color? selectedAppointmentRadioColor;
  List<Map<String, dynamic>> _medicinesForSelectedDay = [];
  DateTime _focusedDay = DateTime.now(); // For managing the calendar's focus
  bool _isLoadingCards = false; // Spinner for cards only

  final Stream<QuerySnapshot> _medicinesStream = FirebaseFirestore.instance
      .collection('medicines') // Replace with your Firestore collection name
      .snapshots();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchMedicineDays();
    _fetchMedicinesForSelectedDate(); // Load initial cards for the selected day
  }

  @override
  void dispose() {
    // Clean up timers, streams, or other async operations
    super.dispose();
  }

  /// Initialize local notifications
  void _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification interaction
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  /// Schedule a notification for a specific medicine
  Future<void> _scheduleNotification(String medicineName, DateTime time) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleTime = tz.TZDateTime.from(time, tz.local);
    if (scheduleTime.isBefore(now))
      return; // Don't schedule notifications for the past

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      scheduleTime.hashCode, // Unique ID
      'Time to take your medicine!',
      'Don’t forget to take $medicineName.',
      scheduleTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact, // Add this parameter
    );
  }

  Future<void> _scheduleRefillReminder(String medicineId, int remainingDose) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'refill_reminder_channel',
        'Refill Reminder',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        medicineId.hashCode, // Unique ID for the notification
        'Time to Refill Medicine!',
        'Your medicine stock is low. Only $remainingDose doses left. Please refill soon.',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error scheduling refill reminder: $e');
    }
  }


  Future<void> addMedicine(
      String name, String type, DateTime startDate, DateTime endDate) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      debugPrint('Error: User not authenticated');
      return;
    }

    // Prepare the medicine data to be added
    final medicineData = {
      'medicineName': name,
      'medicineType': type,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'intakeTimes': [
        {'hour': 9, 'minute': 0},
        {'hour': 21, 'minute': 0},
      ],
    };

    debugPrint('Saving medicine data: $medicineData');

    try {
      // Add the medicine data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('medicines')
          .add(medicineData);

      debugPrint('Medicine added successfully');

      // Immediately refresh the calendar and medicine list
      _fetchMedicineDays(); // Update the calendar with new medicine days
      _fetchMedicinesForSelectedDate(); // Refresh the medicines for the selected date

      // Trigger UI update to ensure the calendar reflects changes
      setState(() {});
    } catch (e) {
      debugPrint('Error adding medicine: $e');
    }
  }

  Future<void> _fetchMedicineDays() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      debugPrint('Error: User not authenticated');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('medicines')
          .get();

      final Set<DateTime> fetchedDays = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('startDate') && data.containsKey('endDate')) {
          final startDate = DateTime.parse(data['startDate']);
          final endDate = DateTime.parse(data['endDate']);

          for (var date = startDate;
              !date.isAfter(endDate);
              date = date.add(const Duration(days: 1))) {
            fetchedDays.add(DateTime(date.year, date.month, date.day));
          }
        }
      }

      setState(() {
        _daysWithMedicines = fetchedDays;
      });
    } catch (e) {
      debugPrint('Error fetching medicine days: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: User not authenticated'),
        ),
      );
    }

    int? _getStatusFromString(String? status) {
      if (status == "Taken") {
        return 1;
      } else if (status == "Missed") {
        return 0;
      }
      return null; // Default for no status
    }

    String _getStatusString(int? status) {
      if (status == 1) {
        return "Taken";
      } else if (status == 0) {
        return "Missed";
      }
      return "None"; // Default for no status
    }


    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPersistentHeader(
            delegate: MedAppbarContentPage(),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Calendar Widget
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getMedicineStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDate = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              _fetchMedicinesForSelectedDate();
                            },
                            eventLoader: (day) => [],
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                            ),
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Color(0xff003399),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }

                        Set<DateTime> daysWithMedicines = {};
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data.containsKey('startDate') &&
                              data.containsKey('endDate')) {
                            final startDate = DateTime.parse(data['startDate']);
                            final endDate = DateTime.parse(data['endDate']);

                            for (var date = startDate;
                                !date.isAfter(endDate);
                                date = date.add(const Duration(days: 1))) {
                              daysWithMedicines.add(
                                  DateTime(date.year, date.month, date.day));
                            }
                          }
                        }

                        return TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(day, _selectedDate),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDate =
                                  selectedDay; // Update selected date
                              _focusedDay =
                                  focusedDay; // Keep calendar focus consistent
                            });

                            _fetchMedicinesForSelectedDate(); // Fetch medicines for the selected date
                          },
                          eventLoader: (day) {
                            return _daysWithMedicines.contains(day) ? ['Medicine'] : [];
                          },
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                          ),
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Color(0xff003399),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                _medicinesForSelectedDay.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/medicine_img.png',
                                height: 160),
                            const SizedBox(height: 10),
                            const Text(
                              'No Medicines Yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Add a medicine to see it here.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _medicinesForSelectedDay.length,
    itemBuilder: (context, index) {
    final medicine = _medicinesForSelectedDay[index];
    final medicineId = medicine['id']?.toString() ?? '';
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final String status = medicine['statusByDate']?[dateKey] ?? 'None'; // Status for selected date

    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    child: Card(
    color: const Color(0xffEDEDED),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: const BorderSide(color: Colors.black26, width: 1),
    ),
    child: Stack(
    children: [
    // Medicine Information
    ListTile(
    leading: (medicine['selectedImage'] != null &&
    medicine['selectedImage'] is String)
    ? Image.asset(
    medicine['selectedImage'], // Display the image
    width: 40,
    height: 40,
    fit: BoxFit.cover,
    )
        : const Icon(Icons.medication, size: 40), // Fallback icon
    title: Text(
    medicine['medicineName']?.toString() ?? 'Unknown Name',
    style: const TextStyle(
    color: Color(0xff003399),
    fontWeight: FontWeight.bold,
    fontFamily: 'Nunito',
    fontSize: 17,
    ),
    ),
    subtitle: Text(
    'Type: ${medicine['medicineType']?.toString() ?? 'Unknown'}\nStatus: $status',
    style: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'Nunito',
    fontSize: 15,
    ),
    ),
    onTap: () {
    debugPrint('Navigating with Medicine ID: $medicineId');
    if (medicineId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Error: Medicine ID is missing')),
    );
    return;
    }
    Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ViewMedicinePage(
      medicineId: medicineId,
      medicineNameController: TextEditingController(
        text: medicine['medicineName'] ?? '',
      ),
      selectedImage: medicine['selectedImage'] ?? '',
      medicineType: medicine['medicineType'] ?? '',
      unit: medicine['unit'] ?? '',
          dosageController: TextEditingController(
            text: medicine['dosage']?.toString() ?? '',
          ),
          doseAvailable: (medicine['doseAvailable'] ?? 0).toString(), // Ensure consistent type
          startDate: medicine['startDate'] != null
          ? DateTime.parse(medicine['startDate'])
          : null,
      endDate: medicine['endDate'] != null
          ? DateTime.parse(medicine['endDate'])
          : null,
      frequency: medicine['frequency'] ?? '',
      intakeTimes: (medicine['intakeTimes'] as List<dynamic>?)
          ?.map((time) => TimeOfDay(
        hour: time['hour'] ?? 0,
        minute: time['minute'] ?? 0,
      ))
          .toList() ??
          [],
      onDelete: () {
        setState(() {
          _medicinesForSelectedDay.removeWhere(
                  (m) => m['id'] == medicineId);
        });
      },
    ),
    ),
    );
    },
    ),
    // Radio Button
    Positioned(
    right: 10,
    top: 10,
    child: IconButton(
    icon: Icon(
    status == 'Taken'
    ? Icons.check_circle
        : status == 'Missed'
    ? Icons.cancel
        : Icons.radio_button_unchecked,
    size: 25, // Icon size
    ),
    color: status == 'Taken'
    ? Colors.green
        : status == 'Missed'
    ? Colors.red
        : Colors.grey,
    onPressed: () => _showMarkMedicineDialog(
    context, medicine, _selectedDate, index),
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),

    ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicinePage()),
          );

          if (result == true) {
            // Refresh calendar and cards after adding medicine
            _fetchMedicineDays();
            _fetchMedicinesForSelectedDate();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xff003399),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getMedicinesStream() {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('medicines')
        .snapshots();
  }

  List<Medicine> _filterMedicinesByDate(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Medicine(
        name: data['medicineName'] ?? 'Unknown Name',
        type: data['medicineType'] ?? 'Unknown Type',
        dosage: data['dosage']?.toString() ?? 'Unknown Dosage',
        unit: data['unit'] ?? 'Unknown Unit',
        startDate: data['startDate'] != null
            ? (data['startDate'] as Timestamp).toDate()
            : null,
        endDate: data['endDate'] != null
            ? (data['endDate'] as Timestamp).toDate()
            : null,
        frequency: data['frequency'] ?? 'Unknown Frequency',
        intakeTimes: data['intakeTimes'] != null
            ? (data['intakeTimes'] as List)
                .map((time) => TimeOfDay(
                      hour: time['hour'] as int,
                      minute: time['minute'] as int,
                    ))
                .toList()
            : [],
      );
    }).toList();
  }

  Stream<QuerySnapshot> getMedicineStream() {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('medicines')
        .snapshots();
  }

  Future<void> _fetchMedicinesForSelectedDate() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      debugPrint('Error: User not authenticated');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('medicines')
          .get();

      // Process data
      final fetchedMedicines = querySnapshot.docs.map((doc) {
        final medicine = {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };

        return medicine;
      }).where((medicine) {
        final String? startDateStr = medicine['startDate'] as String?;
        final String? endDateStr = medicine['endDate'] as String?;

        if (startDateStr == null || endDateStr == null) return false;

        final DateTime? startDate = DateTime.tryParse(startDateStr);
        final DateTime? endDate = DateTime.tryParse(endDateStr);

        if (startDate == null || endDate == null) return false;

        final DateTime normalizedStartDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final DateTime normalizedEndDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        );

        // Check if the selected date falls within the start and end dates (inclusive)
        return _selectedDate.isAtSameMomentAs(normalizedStartDate) ||
            (_selectedDate.isAfter(normalizedStartDate) &&
                _selectedDate
                    .isBefore(normalizedEndDate.add(const Duration(days: 1))));
      }).toList();

      if (mounted) {
        setState(() {
          _medicinesForSelectedDay = fetchedMedicines; // Update state safely
        });
      }
    } catch (e) {
      debugPrint('Error fetching medicines: $e');
    }
  }

  void _updateMedicineStatus(String id, String status, DateTime date, int index) {
    final medicine = _medicinesForSelectedDay[index];
    final int doseTaken = (medicine['dosage'] is int)
        ? medicine['dosage']
        : int.tryParse(medicine['dosage']?.toString() ?? '') ?? 0;

    final int doseAvailable = (medicine['doseAvailable'] is int)
        ? medicine['doseAvailable']
        : int.tryParse(medicine['doseAvailable']?.toString() ?? '') ?? 0;

    // Mark as "Taken" or "Missed"
    _updateDosageOnTaken(id, doseTaken, doseAvailable); // Call this when "Taken"

    // Update status logic
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in!')),
      );
      return;
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('medicines')
        .doc(id)
        .update({'statusByDate.$dateKey': status});
  }


  void _updateDosageOnTaken(String medicineId, int doseTaken, int doseAvailable) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in!')),
      );
      return;
    }

    int newDoseAvailable = doseAvailable - doseTaken;
    if (newDoseAvailable < 0) newDoseAvailable = 0;

    try {
      // Update the remaining dosage in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('medicines')
          .doc(medicineId)
          .update({'doseAvailable': newDoseAvailable});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosage updated. Remaining: $newDoseAvailable')),
      );

      // Check if refill reminder should be triggered
      if (doseTaken > 0 && newDoseAvailable <= (doseAvailable * 0.4).ceil()) {
        _scheduleRefillReminder(medicineId, newDoseAvailable); // Call the refill reminder
      }

      // Refresh UI
      _fetchMedicinesForSelectedDate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating dosage: ${e.toString()}')),
      );
    }
  }


  void _showMarkMedicineDialog(
      BuildContext context, Map<String, dynamic> medicine, DateTime date, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Mark This Medicine!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff003399),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to mark this medicine as:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateMedicineStatus(medicine['id'], 'Taken', date, index); // Corrected
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Taken',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateMedicineStatus(medicine['id'], 'Missed', date, index); // Corrected
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Missed',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  void _markMedicineStatus(Map<String, dynamic> medicine, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Mark This Medicine!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff003399),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to mark this medicine as:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final DateTime date = _selectedDate; // Ensure `date` is a DateTime
                      _updateMedicineStatus(medicine['id'], 'Taken', date, index);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Taken',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final DateTime date = _selectedDate; // Ensure `date` is a DateTime
                      _updateMedicineStatus(medicine['id'], 'Taken', date, index);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Missed',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteMedicine(BuildContext context, String medicineId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Medicine',
            style: TextStyle(
              color: Color(0xff003399),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this medicine?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete the medicine document from Firestore
                  final email = FirebaseAuth.instance.currentUser?.email;
                  if (email != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(email)
                        .collection('medicines')
                        .doc(medicineId)
                        .delete();

                    // Close the dialog
                    Navigator.pop(context);

                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Medicine deleted successfully')),
                    );
                  }
                } catch (e) {
                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting medicine: $e')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper function to get formatted intake times
  String _getFormattedIntakeTimes(Map<String, dynamic> medicine) {
    final intakeTimes = medicine['intakeTimes'] as List?;
    String formattedIntakeTimes = 'No Times Set';

    if (intakeTimes != null && intakeTimes.isNotEmpty) {
      formattedIntakeTimes = intakeTimes.map((time) {
        if (time is Map<String, dynamic>) {
          // Case: Map with hour and minute
          final hour = time['hour'] as int? ?? 0;
          final minute = time['minute'] as int? ?? 0;

          // Create a DateTime object for today at the given hour and minute
          final now = DateTime.now();
          final timeDate = DateTime(now.year, now.month, now.day, hour, minute);

          return DateFormat('h:mm a').format(timeDate); // Format the DateTime
        } else if (time is int) {
          // Case: Timestamp (milliseconds since epoch)
          final timeDate = DateTime.fromMillisecondsSinceEpoch(time);
          return DateFormat('h:mm a').format(timeDate); // Format the DateTime
        } else {
          debugPrint('Unsupported time format: $time');
          return 'Unknown'; // Return empty if unsupported
        }
      }).join(', '); // Join all formatted intake times with a comma
    }

    return formattedIntakeTimes;
  }

}
