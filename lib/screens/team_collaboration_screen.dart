import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class TeamCollaborationScreen extends StatefulWidget {
  const TeamCollaborationScreen({super.key});

  @override
  _TeamCollaborationScreenState createState() =>
      _TeamCollaborationScreenState();
}

class _TeamCollaborationScreenState extends State<TeamCollaborationScreen> {
  final List<Map<String, dynamic>> _teamMembers = [
    {
      'name': 'Dr. Sarah Johnson',
      'role': 'Pulmonologist',
      'avatar': 'assets/docteur.png',
      'status': 'Online',
      'lastActive': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'name': 'Dr. Michael Chen',
      'role': 'Cardiologist',
      'avatar': 'assets/docteur (1).png',
      'status': 'Busy',
      'lastActive': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'name': 'Dr. Emily Rodriguez',
      'role': 'Dermatologist',
      'avatar': 'assets/docteur.png',
      'status': 'Away',
      'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'name': 'Dr. David Wilson',
      'role': 'Neurologist',
      'avatar': 'assets/docteur (1).png',
      'status': 'Offline',
      'lastActive': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'name': 'Dr. Lisa Martinez',
      'role': 'Oncologist',
      'avatar': 'assets/docteur.png',
      'status': 'Online',
      'lastActive': DateTime.now().subtract(const Duration(minutes: 15)),
    },
  ];

  final List<Map<String, dynamic>> _activeDiscussions = [
    {
      'title': 'Complex Case Review - Patient #4582',
      'participants': [
        'Dr. Sarah Johnson',
        'Dr. Michael Chen',
        'Dr. Emily Rodriguez'
      ],
      'lastMessage':
          'I think we should consider additional testing before finalizing the diagnosis.',
      'lastMessageBy': 'Dr. Michael Chen',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 15)),
      'unreadCount': 3,
    },
    {
      'title': 'Treatment Plan Discussion - Oncology Dept.',
      'participants': ['Dr. Lisa Martinez', 'Dr. David Wilson'],
      'lastMessage':
          'The latest research suggests a combination therapy might be more effective in this case.',
      'lastMessageBy': 'Dr. Lisa Martinez',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 0,
    },
    {
      'title': 'Radiology Consultation - Case #7291',
      'participants': ['Dr. Sarah Johnson', 'Dr. David Wilson'],
      'lastMessage':
          'I\'ve uploaded the latest scans. Could you take a look and give your opinion?',
      'lastMessageBy': 'Dr. Sarah Johnson',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
    },
  ];

  final List<Map<String, dynamic>> _upcomingMeetings = [
    {
      'title': 'Weekly Department Meeting',
      'time': DateTime.now().add(const Duration(days: 1, hours: 3)),
      'duration': 60,
      'location': 'Conference Room A',
      'participants': 12,
      'isVirtual': false,
    },
    {
      'title': 'Case Review - Patient #6291',
      'time': DateTime.now().add(const Duration(hours: 4)),
      'duration': 30,
      'location': 'Online - Zoom',
      'participants': 5,
      'isVirtual': true,
    },
    {
      'title': 'Research Collaboration Session',
      'time': DateTime.now().add(const Duration(days: 2)),
      'duration': 90,
      'location': 'Research Wing, Room 302',
      'participants': 8,
      'isVirtual': false,
    },
  ];

  final List<Map<String, dynamic>> _sharedDocuments = [
    {
      'title': 'Treatment Guidelines 2025',
      'type': 'PDF',
      'size': '3.2 MB',
      'sharedBy': 'Dr. Sarah Johnson',
      'dateShared': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'title': 'Patient Case Study - Novel Approach',
      'type': 'DOCX',
      'size': '1.8 MB',
      'sharedBy': 'Dr. Michael Chen',
      'dateShared': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'title': 'Research Data Analysis - Q1 2025',
      'type': 'XLSX',
      'size': '4.7 MB',
      'sharedBy': 'Dr. Lisa Martinez',
      'dateShared': DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      'title': 'Clinical Trial Results',
      'type': 'PDF',
      'size': '8.5 MB',
      'sharedBy': 'Dr. Emily Rodriguez',
      'dateShared': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Collaboration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Filter options will appear here')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Search functionality will appear here')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamMembersSection(),
            const SizedBox(height: 24),
            _buildActiveDiscussionsSection(),
            const SizedBox(height: 24),
            _buildUpcomingMeetingsSection(),
            const SizedBox(height: 24),
            _buildSharedDocumentsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateDiscussionDialog();
        },
        tooltip: 'Start New Discussion',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTeamMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Increased height from 100 to 120
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _teamMembers.length,
            itemBuilder: (context, index) {
              final member = _teamMembers[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Use minimum space needed
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(member['avatar']),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getStatusColor(member['status']),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60, // Constrain text width
                      child: Text(
                        member['name'].split(' ')[0], // First name only
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // Handle text overflow
                      ),
                    ),
                    Text(
                      member['status'],
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(member['status']),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDiscussionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Discussions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activeDiscussions.length,
          itemBuilder: (context, index) {
            final discussion = _activeDiscussions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Opening discussion: ${discussion['title']}')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              discussion['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Prevent title overflow
                            ),
                          ),
                          if (discussion['unreadCount'] > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${discussion['unreadCount']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Participants: ${discussion['participants'].join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow
                            .ellipsis, // Prevent participants overflow
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    discussion['lastMessageBy'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Prevent name overflow
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(
                                      discussion['lastMessageTime']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              discussion['lastMessage'],
                              style: const TextStyle(fontSize: 14),
                              maxLines: 3, // Limit to 3 lines
                              overflow: TextOverflow
                                  .ellipsis, // Show ellipsis for long messages
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Meetings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calendar view will open here')),
                );
              },
              child: const Text('Calendar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _upcomingMeetings.length,
          itemBuilder: (context, index) {
            final meeting = _upcomingMeetings[index];
            final isToday = meeting['time'].day == DateTime.now().day;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Opening meeting details: ${meeting['title']}')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align items to top
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isToday
                                  ? 'TODAY'
                                  : DateFormat('MMM').format(meeting['time']),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.blue[800]
                                    : Colors.grey[800],
                              ),
                            ),
                            Text(
                              DateFormat('d').format(meeting['time']),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? Colors.blue[800]
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meeting['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Handle title overflow
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${DateFormat('h:mm a').format(meeting['time'])} · ${meeting['duration']} min',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis, // Handle time overflow
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  meeting['isVirtual']
                                      ? Icons.videocam
                                      : Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    meeting['location'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis, // Handle location overflow
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Add space between text and button
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Align to top
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${meeting['participants']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Joining meeting...')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: meeting['isVirtual']
                                  ? Colors.blue
                                  : Colors.grey[300],
                              foregroundColor: meeting['isVirtual']
                                  ? Colors.white
                                  : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child:
                                Text(meeting['isVirtual'] ? 'JOIN' : 'DETAILS'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSharedDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shared Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _sharedDocuments.length,
          itemBuilder: (context, index) {
            final document = _sharedDocuments[index];
            final Color color = _getDocumentColor(document['type']);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Opening document: ${document['title']}')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getDocumentIcon(document['type']),
                              color: color,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 20, // Smaller icon
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        document['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1, // Restrict to 1 line for consistency
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${document['type']} · ${document['size']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${document['sharedBy'].split(' ')[0]} · ${_formatDateShared(document['dateShared'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showCreateDiscussionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start New Discussion'),
          content: const Text(
              'This feature will allow you to start a new discussion or chat with team members.'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('New discussion creation coming soon!')),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Online':
        return Colors.green;
      case 'Busy':
        return Colors.red;
      case 'Away':
        return Colors.orange;
      case 'Offline':
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  String _formatDateShared(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
        return Icons.description;
      case 'XLSX':
        return Icons.table_chart;
      case 'PPT':
        return Icons.slideshow;
      case 'IMG':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'DOCX':
        return Colors.blue;
      case 'XLSX':
        return Colors.green;
      case 'PPT':
        return Colors.orange;
      case 'IMG':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
