// Removed unused import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medical_report.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        // Handle notification tap
        if (details.payload != null) {
          // Navigate to report details
        }
      },
    );
  }

  Future<void> showReportDueNotification(MedicalReport report) async {
    const androidDetails = AndroidNotificationDetails(
      'reports_channel',
      'Medical Reports',
      channelDescription: 'Notifications for medical reports',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Medical Report Update',
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      report.hashCode,
      'Report Update Required',
      'Medical report for ${report.patientName} needs attention',
      details,
      payload: report.id,
    );
  }

  Future<void> showUrgentReportNotification(MedicalReport report) async {
    final androidDetails = const AndroidNotificationDetails(
      'urgent_reports',
      'Urgent Reports',
      channelDescription: 'Notifications for urgent medical reports',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Urgent Medical Report',
      enableLights: true,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      report.hashCode,
      'URGENT: Medical Report',
      'Urgent report for ${report.patientName} requires immediate attention',
      details,
      payload: report.id,
    );
  }

  Future<void> scheduleFollowUpReminder(
    MedicalReport report,
    DateTime followUpDate,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'followup_channel',
      'Follow-up Reminders',
      channelDescription: 'Reminders for patient follow-ups',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      report.hashCode,
      'Follow-up Reminder',
      'Follow-up appointment for ${report.patientName}',
      tz.TZDateTime.from(followUpDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: report.id,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
