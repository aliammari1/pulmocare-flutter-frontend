import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  int _rapportNotificationCount = 0;

  int get rapportNotificationCount => _rapportNotificationCount;

  void addRapportNotification() {
    _rapportNotificationCount++;
    notifyListeners();
  }

  void clearRapportNotifications() {
    _rapportNotificationCount = 0;
    notifyListeners();
  }
}
