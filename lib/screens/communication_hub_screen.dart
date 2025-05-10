import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:medapp/services/auth_view_model.dart';

class CommunicationHubScreen extends StatefulWidget {
  const CommunicationHubScreen({super.key});

  @override
  State<CommunicationHubScreen> createState() => _CommunicationHubScreenState();
}

class _CommunicationHubScreenState extends State<CommunicationHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  // Mock data
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _teamDiscussions = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock loading delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for conversations
      _conversations = [
        {
          'id': 'c1',
          'name': 'Dr. Ahmed Khelifi',
          'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
          'lastMessage': 'Your test results look good. No need to worry.',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
          'unread': 2,
          'online': true,
          'specialization': 'Cardiologist'
        },
        {
          'id': 'c2',
          'name': 'Dr. Fatma Bouazizi',
          'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
          'lastMessage': 'Please remember to take your medication daily.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'unread': 0,
          'online': false,
          'specialization': 'Neurologist'
        },
        {
          'id': 'c3',
          'name': 'Nurse Sarah',
          'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
          'lastMessage': 'Your appointment has been confirmed for tomorrow.',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'unread': 1,
          'online': true,
          'specialization': 'Head Nurse'
        },
        {
          'id': 'c4',
          'name': 'Lab Technician Mohamed',
          'avatar': 'https://randomuser.me/api/portraits/men/75.jpg',
          'lastMessage': 'Your blood samples have been collected successfully.',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'unread': 0,
          'online': false,
          'specialization': 'Lab Technician'
        },
      ];

      // Mock data for team discussions
      _teamDiscussions = [
        {
          'id': 't1',
          'title': 'Treatment Plan Discussion',
          'lastActivity': DateTime.now().subtract(const Duration(hours: 1)),
          'participants': 4,
          'unread': 3,
          'description':
              'Discussion about treatment options for your condition',
          'tags': ['Treatment', 'Consultation']
        },
        {
          'id': 't2',
          'title': 'Medication Review',
          'lastActivity': DateTime.now().subtract(const Duration(days: 2)),
          'participants': 3,
          'unread': 0,
          'description':
              'Review of your current medications and possible adjustments',
          'tags': ['Medication', 'Review']
        },
        {
          'id': 't3',
          'title': 'Post-Surgery Recovery',
          'lastActivity': DateTime.now().subtract(const Duration(days: 5)),
          'participants': 5,
          'unread': 0,
          'description':
              'Discussion about recovery progress after your recent surgery',
          'tags': ['Recovery', 'Post-Op']
        },
      ];

      // Mock data for notifications
      _notifications = [
        {
          'id': 'n1',
          'title': 'Message from Dr. Ahmed Khelifi',
          'content': 'Dr. Ahmed has sent you your latest test results',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'read': false,
          'type': 'message'
        },
        {
          'id': 'n2',
          'title': 'Treatment Plan Updated',
          'content':
              'Your treatment plan has been updated. Please review the changes',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'read': true,
          'type': 'update'
        },
        {
          'id': 'n3',
          'title': 'Reminder: Team Discussion',
          'content':
              'Don\'t forget about the scheduled team discussion tomorrow',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'read': false,
          'type': 'reminder'
        },
        {
          'id': 'n4',
          'title': 'New Team Member Added',
          'content': 'Dr. Leila Trabelsi has been added to your care team',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'read': true,
          'type': 'team'
        },
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final role = authViewModel.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Communication Hub',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.message), text: 'Direct Messages'),
            Tab(icon: Icon(Icons.group), text: 'Team Discussions'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to communication settings
              _showSettingsDialog();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDirectMessagesTab(),
                    _buildTeamDiscussionsTab(),
                    _buildNotificationsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          // Create new message or team discussion
          _showNewCommunicationDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectMessagesTab() {
    if (_conversations.isEmpty) {
      return _buildEmptyState(
        'No messages yet',
        'Start a conversation with your healthcare providers',
        Icons.message_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationTile(conversation);
        },
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(conversation['avatar']),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback if image fails to load
              return;
            },
          ),
          if (conversation['online'])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conversation['specialization'],
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            conversation['lastMessage'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: conversation['unread'] > 0
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTimestamp(conversation['timestamp']),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (conversation['unread'] > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation['unread'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigate to the conversation
        _navigateToConversation(conversation);
      },
    );
  }

  Widget _buildTeamDiscussionsTab() {
    if (_teamDiscussions.isEmpty) {
      return _buildEmptyState(
        'No team discussions',
        'Participate in discussions with your care team',
        Icons.groups_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _teamDiscussions.length,
        itemBuilder: (context, index) {
          final discussion = _teamDiscussions[index];
          return _buildTeamDiscussionTile(discussion);
        },
      ),
    );
  }

  Widget _buildTeamDiscussionTile(Map<String, dynamic> discussion) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    discussion['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (discussion['unread'] > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${discussion['unread']} new',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  discussion['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${discussion['participants']} participants',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last active: ${_formatTimestamp(discussion['lastActivity'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (discussion['tags'] as List<String>).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            onTap: () {
              // Navigate to the team discussion
              _navigateToTeamDiscussion(discussion);
            },
          ),
          const Divider(height: 0),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.forum, size: 18),
                label: const Text('Join Discussion'),
                onPressed: () {
                  _navigateToTeamDiscussion(discussion);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
                onPressed: () {
                  // Implement sharing functionality
                  _shareDiscussion(discussion);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (_notifications.isEmpty) {
      return _buildEmptyState(
        'No notifications',
        'You will see important updates here',
        Icons.notifications_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    IconData iconData;
    Color iconColor;

    switch (notification['type']) {
      case 'message':
        iconData = Icons.message;
        iconColor = Colors.blue;
        break;
      case 'update':
        iconData = Icons.update;
        iconColor = Colors.green;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'team':
        iconData = Icons.people;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppTheme.primaryColor;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(
          iconData,
          color: iconColor,
        ),
      ),
      title: Text(
        notification['title'],
        style: TextStyle(
          fontWeight:
              notification['read'] ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification['content'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(notification['timestamp']),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
      trailing: notification['read']
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () {
        // Mark notification as read and navigate to the relevant content
        _handleNotificationTap(notification);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showNewCommunicationDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Start New'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      final formatter = DateFormat('MMM d, yyyy');
      return formatter.format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToConversation(Map<String, dynamic> conversation) {
    // In a real app, this would navigate to the conversation screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening conversation with ${conversation['name']}'),
      ),
    );
  }

  void _navigateToTeamDiscussion(Map<String, dynamic> discussion) {
    // In a real app, this would navigate to the team discussion screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening team discussion: ${discussion['title']}'),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark notification as read
    setState(() {
      notification['read'] = true;
    });

    // In a real app, this would navigate to the relevant content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening notification: ${notification['title']}'),
      ),
    );
  }

  void _shareDiscussion(Map<String, dynamic> discussion) {
    // In a real app, this would open sharing options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${discussion['title']}...'),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Communications'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search for messages, discussions, or people',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform search
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Communication Settings'),
        contentPadding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Preferences'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Contacts'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to blocked contacts
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archived Conversations'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to archived conversations
            },
          ),
          const Divider(),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNewCommunicationDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Communication',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(
                    Icons.message,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Start Direct Message'),
                subtitle:
                    const Text('Private conversation with a care provider'),
                onTap: () {
                  Navigator.pop(context);
                  // Show contact selection screen
                  _showContactSelectionDialog();
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor,
                  child: const Icon(
                    Icons.group_add,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Create Team Discussion'),
                subtitle:
                    const Text('Start a new discussion with the care team'),
                onTap: () {
                  Navigator.pop(context);
                  // Show team discussion creation dialog
                  _showCreateTeamDiscussionDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Contact'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              final contact = _conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(contact['avatar']),
                ),
                title: Text(contact['name']),
                subtitle: Text(contact['specialization']),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToConversation(contact);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDiscussionDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Team Discussion'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter discussion title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter discussion description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Treatment',
                  'Medication',
                  'Diagnosis',
                  'Recovery',
                  'Lifestyle',
                  'Prevention',
                ]
                    .map((tag) => FilterChip(
                          label: Text(tag),
                          selected: false,
                          onSelected: (selected) {
                            // Handle tag selection
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create new team discussion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team discussion created successfully'),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
