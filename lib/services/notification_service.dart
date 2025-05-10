import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medapp/models/notification.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medical_report.dart';
import '../screens/notifications_screen.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  final List<PendingNotification> _pendingNotifications = [];

  // Navigation callback for notifications
  Function(String?)? onNotificationTapped;

  // Request notification permissions explicitly
  Future<bool> requestPermissions() async {
    // Request notification permission
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

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
        if (details.payload != null && onNotificationTapped != null) {
          onNotificationTapped!(details.payload);
        }
      },
    );

    // Check if we have permission
    await requestPermissions();

    _isInitialized = true;
  }

  // Set the navigation callback
  void setOnNotificationTapped(Function(String?) callback) {
    onNotificationTapped = callback;
  }

  // Check for active notifications
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (!_isInitialized) await initialize();

    try {
      final List<ActiveNotification> activeNotifications =
          await _notificationsPlugin.getActiveNotifications();
      return activeNotifications;
    } catch (e) {
      // Platform may not support this feature
      return [];
    }
  }

  // Get pending notifications that haven't been seen yet
  List<PendingNotification> getPendingNotifications() {
    return List.from(_pendingNotifications);
  }

  // Clear pending notifications after they've been shown
  void clearPendingNotifications() {
    _pendingNotifications.clear();
  }

  Future<void> showReportDueNotification(MedicalReport report) async {
    await initialize();

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

    final notificationId = report.hashCode;
    final title = 'Report Update Required';
    final message = 'Medical report for ${report.patientName} needs attention';

    await _notificationsPlugin.show(
      notificationId,
      title,
      message,
      details,
      payload: report.id,
    );

    // Add to pending notifications
    _pendingNotifications.add(PendingNotification(
      id: notificationId.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: NotificationType.result,
      actionPath: '/medical-report/${report.id}',
    ));
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

  // Add method to create general notification
  Future<void> showGeneralNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? actionPath,
    Map<String, dynamic>? actionData,
  }) async {
    await initialize();

    NotificationDetails details = await _getNotificationDetails(type);
    final notificationId = Random().nextInt(100000);

    await _notificationsPlugin.show(
      notificationId,
      title,
      message,
      details,
      payload: actionPath,
    );

    // Add to pending notifications
    _pendingNotifications.add(PendingNotification(
      id: notificationId.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      actionPath: actionPath,
      actionData: actionData,
    ));
  }

  // Helper to get notification details based on type
  Future<NotificationDetails> _getNotificationDetails(
      NotificationType type) async {
    String channelId;
    String channelName;
    String channelDescription;

    switch (type) {
      case NotificationType.appointment:
        channelId = 'appointment_channel';
        channelName = 'Appointments';
        channelDescription = 'Notifications for appointments';
        break;
      case NotificationType.prescription:
        channelId = 'prescription_channel';
        channelName = 'Prescriptions';
        channelDescription = 'Notifications for prescriptions';
        break;
      case NotificationType.message:
        channelId = 'message_channel';
        channelName = 'Messages';
        channelDescription = 'Notifications for messages';
        break;
      case NotificationType.result:
        channelId = 'result_channel';
        channelName = 'Results';
        channelDescription = 'Notifications for medical results';
        break;
      case NotificationType.reminder:
        channelId = 'reminder_channel';
        channelName = 'Reminders';
        channelDescription = 'Medication and appointment reminders';
        break;
      case NotificationType.system:
      default:
        channelId = 'system_channel';
        channelName = 'System';
        channelDescription = 'System notifications';
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
  }

  // Create demo notifications for testing
  Future<void> createDemoNotifications() async {
    await showGeneralNotification(
      title: 'Appointment Reminder',
      message: 'Your appointment with Dr. Smith is tomorrow at 10:00 AM',
      type: NotificationType.appointment,
      actionPath: '/appointment/123',
    );

    await showGeneralNotification(
      title: 'New Test Results',
      message: 'Your blood test results are now available',
      type: NotificationType.result,
      actionPath: '/results/456',
    );

    await showGeneralNotification(
      title: 'Prescription Ready',
      message: 'Your prescription is ready for pickup at the pharmacy',
      type: NotificationType.prescription,
      actionPath: '/prescription/789',
    );
  }
}



// Class to bridge between local notification system and app notifications
