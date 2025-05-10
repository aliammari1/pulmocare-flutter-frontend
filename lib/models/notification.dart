class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionPath;
  final Map<String, dynamic>? actionData;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionPath,
    this.actionData,
  });
}

enum NotificationType {
  appointment,
  prescription,
  message,
  result,
  reminder,
  system,
}

class PendingNotification extends Notification {
  PendingNotification({
    required String id,
    required String title,
    required String message,
    required DateTime timestamp,
    required NotificationType type,
    String? actionPath,
    Map<String, dynamic>? actionData,
  }) : super(
          id: id,
          title: title,
          message: message,
          timestamp: timestamp,
          type: type,
          isRead: false,
          actionPath: actionPath,
          actionData: actionData,
        );
}
