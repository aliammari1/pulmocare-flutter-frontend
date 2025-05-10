import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:medapp/models/notification.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:medapp/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  List<Notification> _allNotifications = [];
  List<Notification> _unreadNotifications = [];
  final NotificationService _notificationService = NotificationService();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Initialize notification service
      await _notificationService.initialize();

      // Request permissions explicitly and show the result
      _hasPermission = await _notificationService.requestPermissions();

      if (!_hasPermission) {
        // Show permission request dialog if not granted
        _showPermissionDialog();
      }

      // Set up notification tap handler
      _notificationService.setOnNotificationTapped((payload) {
        if (payload != null && mounted) {
          context.push(payload);
        }
      });

      // Create welcome notification when this screen is first opened
      await _createWelcomeNotification();

      // Check for active notifications
      final activeNotifications =
          await _notificationService.getActiveNotifications();
      if (activeNotifications.isNotEmpty) {
        // Process active notifications
        for (var notification in activeNotifications) {
          print('Found active notification: ${notification.title}');
        }
      }

      // For demo purposes, uncomment the line below to create test notifications
      await _notificationService.createDemoNotifications();

      // Load notifications
      await _loadNotifications();
    } catch (e) {
      setState(() {
        _error = "Failed to initialize notifications: $e";
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Permission'),
            content: const Text(
                'To receive important medical notifications, please allow notification permissions.'),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () async {
                  context.pop();
                  // Open app settings
                  await openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> _createWelcomeNotification() async {
    // Only show welcome notification if we have permission
    if (_hasPermission) {
      await _notificationService.showGeneralNotification(
        title: 'Welcome to MedApp',
        message:
            'You have opened the notifications screen. Swipe down to refresh.',
        type: NotificationType.system,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get pending notifications from service
      final pendingNotifications =
          _notificationService.getPendingNotifications();

      // In a real app, you would fetch data from an API
      // For this example, we'll use mock data + any pending notifications
      await Future.delayed(const Duration(seconds: 1));

      final mockNotifications = [
        Notification(
          id: '1',
          title: 'Appointment Confirmed',
          message:
              'Your appointment with Dr. Smith has been confirmed for tomorrow at 10:00 AM.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: NotificationType.appointment,
          actionPath: '/appointment/1',
          isRead: false,
        ),
        Notification(
          id: '2',
          title: 'Prescription  Approved',
          message:
              'Your request for a prescription has been approved. You can pick it up at your pharmacy.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          type: NotificationType.prescription,
          actionPath: '/prescription/2',
          isRead: true,
        ),
        Notification(
          id: '3',
          title: 'New Message from Dr. Johnson',
          message:
              'You have received a new message from Dr. Johnson regarding your recent visit.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.message,
          actionPath: '/contact-doctor',
          actionData: {'doctorId': 'd123'},
          isRead: false,
        ),
        Notification(
          id: '4',
          title: 'Test Results Available',
          message:
              'Your recent blood test results are now available. Please review them at your convenience.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: NotificationType.result,
          actionPath: '/examination/abc123',
          isRead: false,
        ),
        Notification(
          id: '5',
          title: 'Medication Reminder',
          message: 'Remember to take your Lisinopril medication today.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          type: NotificationType.reminder,
          isRead: true,
        ),
        Notification(
          id: '6',
          title: 'System Maintenance',
          message:
              'The app will be undergoing maintenance tomorrow from 2:00 AM to 4:00 AM.',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          type: NotificationType.system,
          isRead: true,
        ),
      ];

      // Add pending notifications to the top of the list - with explicit casting
      final allNotifications = [
        ...pendingNotifications
            .map((pending) => pending as Notification)
            .toList(),
        ...mockNotifications
      ];

      setState(() {
        _allNotifications = allNotifications;
        _unreadNotifications =
            allNotifications.where((n) => !n.isRead).toList();
        _isLoading = false;
      });

      // Clear pending notifications as they've now been shown
      _notificationService.clearPendingNotifications();

      // Show a snackbar if we have new notifications
      if (pendingNotifications.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'You have ${pendingNotifications.length} new notification(s)'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                // Switch to unread tab if there are unread notifications
                if (_unreadNotifications.isNotEmpty) {
                  _tabController.animateTo(1);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Helper method to create a test notification (for testing)
  Future<void> _createTestNotification() async {
    await _notificationService.showGeneralNotification(
      title: 'Test Notification',
      message:
          'This is a test notification created at ${DateTime.now().toIso8601String()}',
      type: NotificationType.system,
    );

    // Reload to show the new notification
    await _loadNotifications();
  }

  Future<void> _markAsRead(String id) async {
    // In a real app, you would call an API to mark the notification as read
    setState(() {
      for (var i = 0; i < _allNotifications.length; i++) {
        if (_allNotifications[i].id == id) {
          final updated = Notification(
            id: _allNotifications[i].id,
            title: _allNotifications[i].title,
            message: _allNotifications[i].message,
            timestamp: _allNotifications[i].timestamp,
            type: _allNotifications[i].type,
            isRead: true,
            actionPath: _allNotifications[i].actionPath,
            actionData: _allNotifications[i].actionData,
          );
          _allNotifications[i] = updated;
          break;
        }
      }
      _unreadNotifications = _allNotifications.where((n) => !n.isRead).toList();
    });
  }

  Future<void> _markAllAsRead() async {
    // In a real app, you would call an API to mark all notifications as read
    setState(() {
      _allNotifications = _allNotifications.map((notification) {
        return Notification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          type: notification.type,
          isRead: true,
          actionPath: notification.actionPath,
          actionData: notification.actionData,
        );
      }).toList();
      _unreadNotifications = [];
    });
  }

  Future<void> _deleteNotification(String id) async {
    // In a real app, you would call an API to delete the notification
    setState(() {
      _allNotifications.removeWhere((n) => n.id == id);
      _unreadNotifications = _allNotifications.where((n) => !n.isRead).toList();
    });
  }

  Future<void> _deleteAllNotifications() async {
    // Show confirmation dialog before deleting all
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text(
            'Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _allNotifications = [];
        _unreadNotifications = [];
      });
    }
  }

  void _handleNotificationTap(Notification notification) {
    // Mark as read when tapped
    _markAsRead(notification.id);

    // Navigate to the relevant screen if action path is provided
    if (notification.actionPath != null) {
      context.push(notification.actionPath!, extra: notification.actionData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          // Add a test button in debug mode
          if (true) // Change to true for testing
            IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'Create test notification',
              onPressed: _createTestNotification,
            ),
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _unreadNotifications.isEmpty ? null : _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Delete all notifications',
            onPressed:
                _allNotifications.isEmpty ? null : _deleteAllNotifications,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All (${_allNotifications.length})',
            ),
            Tab(
              text: 'Unread (${_unreadNotifications.length})',
            ),
          ],
          labelColor: Colors.white,
          indicatorColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // All Notifications Tab
                    _allNotifications.isEmpty
                        ? _buildEmptyView('No notifications')
                        : _buildNotificationsList(_allNotifications),

                    // Unread Notifications Tab
                    _unreadNotifications.isEmpty
                        ? _buildEmptyView('No unread notifications')
                        : _buildNotificationsList(_unreadNotifications),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(color: Colors.red[700]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll be notified about appointments, messages, and more',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Notification> notifications) {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteNotification(notification.id),
            child: Card(
              elevation: notification.isRead ? 1 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: notification.isRead
                      ? Colors.transparent
                      : AppTheme.primaryColor.withOpacity(0.5),
                  width: notification.isRead ? 0 : 1,
                ),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: InkWell(
                onTap: () => _handleNotificationTap(notification),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildNotificationIcon(notification.type),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(notification.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isRead
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                      if (notification.actionPath != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.appointment:
        iconData = Icons.event;
        iconColor = Colors.blue;
        break;
      case NotificationType.prescription:
        iconData = Icons.medical_services;
        iconColor = Colors.green;
        break;
      case NotificationType.message:
        iconData = Icons.message;
        iconColor = Colors.orange;
        break;
      case NotificationType.result:
        iconData = Icons.analytics;
        iconColor = Colors.purple;
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        iconColor = Colors.red;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
