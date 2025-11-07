import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    // Initialize timezone and notification service during instantiation
    _initializeTimeZone();
  }

  Future<void> init() async {
    // Platform-specific initialization
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _initializeTimeZone() {
    // Ensure Timezone data is initialized
    tz.initializeTimeZones();
  }

  void _onNotificationResponse(NotificationResponse response) {
    print("Notification tapped with payload: ${response.payload}");
    // Handle notification response, e.g., navigate to a specific page
  }

  Future<void> scheduleNotification(
      DateTime scheduledTime, {
        required int id,
        required String title,
        required String body,
        String? payload,
      }) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print("Scheduled time is in the past: $tzScheduledTime. Notification not scheduled.");
      return;
    }

    print("Scheduling notification for: $tzScheduledTime");

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel', // Channel ID
      'Medicine Reminders', // Channel name
      channelDescription: 'Reminders to take your medicines on time',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print("Notification with ID $id canceled.");
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print("All notifications canceled.");
  }
}
