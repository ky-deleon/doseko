import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doseko_checker/dashboard/appointments/appointments appbar/appointments_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_appointment.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDay = DateTime.now();
  Set<DateTime> _daysWithAppointments = {}; // Holds all dates with appointments
  List<Map<String, dynamic>> _allAppointments = [];
  List<String?> _appointmentStatuses = []; // Holds statuses for each appointment
  List<Map<String, dynamic>> _appointmentsForSelectedDay = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchAppointments();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleAppointmentNotification(String appointmentName, DateTime time) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleTime = tz.TZDateTime.from(time, tz.local);

    if (scheduleTime.isBefore(now)) return; // Skip past appointments

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'appointment_reminder_channel',
      'Appointment Reminder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      scheduleTime.hashCode, // Unique ID
      'Upcoming Appointment',
      'Your appointment "$appointmentName" is scheduled.',
      scheduleTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }


  Future<void> _fetchAppointments() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      debugPrint("User not logged in");
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointments')
          .get();

      List<Map<String, dynamic>> fetchedAppointments = [];
      Set<DateTime> fetchedDays = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('dateTime')) {
          final dateTime = (data['dateTime'] is String
              ? DateTime.parse(data['dateTime'])
              : (data['dateTime'] as Timestamp).toDate());
          fetchedAppointments.add({...data, 'id': doc.id});
          fetchedDays.add(DateTime(dateTime.year, dateTime.month, dateTime.day));
        }
      }

      setState(() {
        _allAppointments = fetchedAppointments;
        _appointmentStatuses = fetchedAppointments
            .map((appointment) => appointment['status'] as String?)
            .toList();
        _daysWithAppointments = fetchedDays;
        _fetchAppointmentsForSelectedDay();
      });
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
  }

  void _fetchAppointmentsForSelectedDay() {
    final filteredAppointments = _allAppointments.where((appointment) {
      final dateTime = (appointment['dateTime'] is String
          ? DateTime.parse(appointment['dateTime'])
          : (appointment['dateTime'] as Timestamp).toDate());
      return isSameDay(_selectedDay, dateTime);
    }).toList();

    setState(() {
      _appointmentsForSelectedDay = filteredAppointments;
    });
  }

  void _addNewAppointment(Map<String, dynamic> appointment) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      // Save appointment to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointments')
          .add(appointment);

      // Parse the appointment date-time string to DateTime
      final String dateTimeString = appointment['dateTime'];
      final DateTime appointmentDateTime = DateTime.parse(dateTimeString);

      // Add appointment to local list
      setState(() {
        _allAppointments.add({...appointment, 'id': docRef.id});
        _daysWithAppointments.add(DateTime(
          appointmentDateTime.year,
          appointmentDateTime.month,
          appointmentDateTime.day,
        ));
        _fetchAppointmentsForSelectedDay();
      });

      // Schedule notification for the appointment
      await _scheduleAppointmentNotification(
        appointment['appointmentName'],
        appointmentDateTime,
      );

      debugPrint('New appointment added successfully: ${docRef.id}');
    } catch (e) {
      debugPrint('Error adding new appointment: $e');
    }
  }


  void _updateAppointmentStatus(String id, String status, int index) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointments')
          .doc(id)
          .update({'status': status});

      setState(() {
        _appointmentStatuses[index] = status;
      });

      // Schedule notification for the appointment


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment marked as $status!')),
      );
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
    }
  }


  void _markAppointmentStatus(Map<String, dynamic> appointment, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Mark This Appointment!',
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
                "Are you sure you want to mark this appointment as:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateAppointmentStatus(
                          appointment['id'], 'Taken', index);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Taken', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateAppointmentStatus(
                          appointment['id'], 'Missed', index);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Missed', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteAppointment(String id) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointments')
          .doc(id)
          .delete();

      setState(() {
        _allAppointments.removeWhere((appointment) => appointment['id'] == id);
        _fetchAppointmentsForSelectedDay();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully!')),
      );
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        const SliverPersistentHeader(
          delegate: ApptAppbarContentPage(),
          pinned: true,
        ),
        SliverToBoxAdapter(
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context)
                        .size
                        .height, // Ensure it fills the screen height
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xff003399),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _selectedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _fetchAppointmentsForSelectedDay();
                                });
                              },
                              eventLoader: (day) {
                                return _daysWithAppointments.contains(day)
                                    ? ['Appointment']
                                    : [];
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
                            ),
                          ),
                        ),
                      ),
                      _appointmentsForSelectedDay.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/calendar_img.png',
                                height: 160),
                            const SizedBox(height: 10),
                            const Text(
                              'No Appointments Yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Add an appointment to see it here.',
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
                        itemCount: _appointmentsForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final appointment = _appointmentsForSelectedDay[index];
                          final dateTime = (appointment['dateTime'] is String
                              ? DateTime.parse(appointment['dateTime'])
                              : (appointment['dateTime'] as Timestamp).toDate());

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            child: Dismissible(
                              key: Key(appointment['id']),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                color: Colors.red.withOpacity(0.7),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Confirm Deletion',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this appointment?',
                                        style: TextStyle(fontSize: 16, fontFamily: 'Nunito'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('No', style: TextStyle(fontFamily: 'Nunito', fontSize: 15)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Yes', style: TextStyle(fontFamily: 'Nunito', fontSize: 15)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDismissed: (direction) {
                                _deleteAppointment(appointment['id']);
                              },
                              child: Card(
                                color: const Color(0xffEDEDED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.black26, width: 1),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.event, size: 40, color: Color(0xff003399)),
                                  title: Text(
                                    appointment['appointmentName'] ?? 'Unnamed Appointment',
                                    style: const TextStyle(
                                      color: Color(0xff003399),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Nunito',
                                      fontSize: 17,
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat.jm().format(dateTime),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Nunito',
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      _appointmentStatuses[index] == 'Taken'
                                          ? Icons.check_circle
                                          : _appointmentStatuses[index] == 'Missed'
                                          ? Icons.cancel
                                          : Icons.radio_button_unchecked,
                                    ),
                                    color: _appointmentStatuses[index] == 'Taken'
                                        ? Colors.green
                                        : _appointmentStatuses[index] == 'Missed'
                                        ? Colors.red
                                        : Colors.grey,
                                    onPressed: () => _markAppointmentStatus(appointment, index),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAppointment = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAppointmentPage()),
          );
          if (newAppointment != null) {
            _addNewAppointment(newAppointment); // Saves the data to Firestore and updates the UI
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
}