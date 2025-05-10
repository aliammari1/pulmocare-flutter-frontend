import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../services/auth_view_model.dart';
import 'dart:math' as math;

class CommunitySupportScreen extends StatefulWidget {
  const CommunitySupportScreen({super.key});

  @override
  State<CommunitySupportScreen> createState() => _CommunitySupportScreenState();
}

class _CommunitySupportScreenState extends State<CommunitySupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  // Mock data for community features
  List<Map<String, dynamic>> _supportGroups = [];
  List<Map<String, dynamic>> _discussionForums = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _resources = [];

  // Filter states
  String _currentCategoryFilter = 'All';
  final List<String> _categories = [
    'All',
    'Respiratory',
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'Mental Health',
    'Chronic Care',
    'Wellness'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for Support Groups
      _supportGroups = [
        {
          'id': 'sg1',
          'name': 'Asthma Support Community',
          'category': 'Respiratory',
          'members': 234,
          'description':
              'A supportive community for asthma patients to share experiences and coping strategies.',
          'meetingSchedule': 'Every Tuesday at 6:00 PM',
          'isVirtual': true,
          'image': 'assets/images/asthma_support.jpg',
          'tags': ['Asthma', 'Breathing', 'Chronic']
        },
        {
          'id': 'sg2',
          'name': 'Heart Health Warriors',
          'category': 'Cardiology',
          'members': 189,
          'description':
              'Support group for individuals with heart conditions focused on recovery and lifestyle management.',
          'meetingSchedule': 'First Monday of the month at 7:00 PM',
          'isVirtual': true,
          'image': 'assets/images/heart_health.jpg',
          'tags': ['Heart Disease', 'Recovery', 'Lifestyle']
        },
        {
          'id': 'sg3',
          'name': 'COPD Discussion Group',
          'category': 'Respiratory',
          'members': 156,
          'description':
              'A space for individuals with COPD to share experiences and learn new breathing techniques.',
          'meetingSchedule': 'Every Thursday at 5:30 PM',
          'isVirtual': false,
          'image': 'assets/images/copd_group.jpg',
          'tags': ['COPD', 'Lung Disease', 'Breathing']
        },
        {
          'id': 'sg4',
          'name': 'Anxiety & Stress Management',
          'category': 'Mental Health',
          'members': 312,
          'description':
              'Supportive community for anyone dealing with anxiety, stress, or panic attacks.',
          'meetingSchedule': 'Every Wednesday at 6:30 PM',
          'isVirtual': true,
          'image': 'assets/images/anxiety_group.jpg',
          'tags': ['Anxiety', 'Mental Health', 'Stress']
        },
        {
          'id': 'sg5',
          'name': 'Diabetes Care Collective',
          'category': 'Chronic Care',
          'members': 203,
          'description':
              'Group focused on diabetes management, nutrition, and lifestyle support.',
          'meetingSchedule': 'Second Saturday of the month at 10:00 AM',
          'isVirtual': false,
          'image': 'assets/images/diabetes_group.jpg',
          'tags': ['Diabetes', 'Nutrition', 'Lifestyle']
        },
      ];

      // Mock data for Discussion Forums
      _discussionForums = [
        {
          'id': 'df1',
          'title': 'Understanding New Asthma Medications',
          'category': 'Respiratory',
          'author': 'Dr. Emma Chen',
          'replies': 24,
          'lastActive': DateTime.now().subtract(const Duration(hours: 3)),
          'tags': ['Medication', 'Treatment', 'Research'],
          'isPinned': true
        },
        {
          'id': 'df2',
          'title': 'Coping with Seasonal Allergies',
          'category': 'Respiratory',
          'author': 'Sarah Johnson',
          'replies': 18,
          'lastActive': DateTime.now().subtract(const Duration(days: 1)),
          'tags': ['Allergies', 'Seasonal', 'Prevention'],
          'isPinned': false
        },
        {
          'id': 'df3',
          'title': 'Exercise Modifications for Heart Patients',
          'category': 'Cardiology',
          'author': 'Dr. Michael Roberts',
          'replies': 32,
          'lastActive': DateTime.now().subtract(const Duration(hours: 12)),
          'tags': ['Exercise', 'Recovery', 'Safety'],
          'isPinned': false
        },
        {
          'id': 'df4',
          'title': 'Anxiety Management Techniques',
          'category': 'Mental Health',
          'author': 'Dr. Lisa Wong',
          'replies': 47,
          'lastActive': DateTime.now().subtract(const Duration(hours: 1)),
          'tags': ['Techniques', 'Coping', 'Self-care'],
          'isPinned': true
        },
        {
          'id': 'df5',
          'title': 'Nutrition for Respiratory Conditions',
          'category': 'Respiratory',
          'author': 'Maria Gonzalez, RD',
          'replies': 15,
          'lastActive': DateTime.now().subtract(const Duration(days: 2)),
          'tags': ['Nutrition', 'Diet', 'Wellness'],
          'isPinned': false
        },
      ];

      // Mock data for Upcoming Events
      _upcomingEvents = [
        {
          'id': 'ev1',
          'title': 'Respiratory Health Conference',
          'category': 'Respiratory',
          'date': DateTime.now().add(const Duration(days: 14)),
          'location': 'Virtual Event',
          'description':
              'Annual conference covering the latest advancements in respiratory care and treatments.',
          'isRegistrationOpen': true,
          'isFree': false,
          'image': 'assets/images/conference.jpg'
        },
        {
          'id': 'ev2',
          'title': 'Breathing Workshop',
          'category': 'Respiratory',
          'date': DateTime.now().add(const Duration(days: 3)),
          'location': 'City General Hospital',
          'description':
              'Learn advanced breathing techniques to help manage respiratory conditions.',
          'isRegistrationOpen': true,
          'isFree': true,
          'image': 'assets/images/breathing_workshop.jpg'
        },
        {
          'id': 'ev3',
          'title': 'Living Well with COPD',
          'category': 'Respiratory',
          'date': DateTime.now().add(const Duration(days: 7)),
          'location': 'Community Center',
          'description':
              'Educational seminar focusing on lifestyle management for COPD patients.',
          'isRegistrationOpen': true,
          'isFree': true,
          'image': 'assets/images/copd_seminar.jpg'
        },
        {
          'id': 'ev4',
          'title': 'Mental Health Awareness Walk',
          'category': 'Mental Health',
          'date': DateTime.now().add(const Duration(days: 21)),
          'location': 'City Park',
          'description':
              'Community walk to raise awareness about mental health challenges and resources.',
          'isRegistrationOpen': true,
          'isFree': true,
          'image': 'assets/images/awareness_walk.jpg'
        },
        {
          'id': 'ev5',
          'title': 'Heart Health Cooking Demo',
          'category': 'Cardiology',
          'date': DateTime.now().add(const Duration(days: 5)),
          'location': 'Virtual Event',
          'description':
              'Learn how to prepare heart-healthy meals with a professional chef.',
          'isRegistrationOpen': false,
          'isFree': true,
          'image': 'assets/images/cooking_demo.jpg'
        },
      ];

      // Mock data for Resources
      _resources = [
        {
          'id': 'res1',
          'title': 'Understanding COPD',
          'category': 'Respiratory',
          'type': 'Guide',
          'source': 'American Lung Association',
          'description':
              'Comprehensive guide explaining COPD, its symptoms, treatments, and management strategies.',
          'url': 'https://www.lung.org/copd',
          'image': 'assets/images/copd_guide.jpg'
        },
        {
          'id': 'res2',
          'title': 'Asthma Medication Chart',
          'category': 'Respiratory',
          'type': 'PDF',
          'source': 'National Asthma Council',
          'description':
              'A printable chart showing different asthma medications, their usage, and potential side effects.',
          'url': 'https://www.nationalasthma.org.au/medications',
          'image': 'assets/images/asthma_chart.jpg'
        },
        {
          'id': 'res3',
          'title': 'Breathing Exercises for Respiratory Health',
          'category': 'Respiratory',
          'type': 'Video',
          'source': 'Respiratory Therapy Channel',
          'description':
              'Video demonstration of effective breathing exercises for various respiratory conditions.',
          'url': 'https://www.youtube.com/watch?v=example',
          'image': 'assets/images/breathing_video.jpg'
        },
        {
          'id': 'res4',
          'title': 'Understanding Cardiac Medications',
          'category': 'Cardiology',
          'type': 'Guide',
          'source': 'American Heart Association',
          'description':
              'Detailed guide to common heart medications and their effects.',
          'url': 'https://www.heart.org/medications',
          'image': 'assets/images/heart_meds.jpg'
        },
        {
          'id': 'res5',
          'title': 'Anxiety Management Toolkit',
          'category': 'Mental Health',
          'type': 'PDF',
          'source': 'Mental Health Foundation',
          'description':
              'Practical techniques and worksheets for managing anxiety and stress.',
          'url': 'https://www.mentalhealth.org/anxiety-toolkit',
          'image': 'assets/images/anxiety_toolkit.jpg'
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  List<Map<String, dynamic>> _filterByCategory(
      List<Map<String, dynamic>> items, String category, String key) {
    if (category == 'All') {
      return items;
    }
    return items.where((item) => item[key] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final role = authViewModel.role;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.support, color: AppTheme.textPrimaryColor),
            const SizedBox(width: 8),
            const Text('Community Support',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Support Groups'),
            Tab(icon: Icon(Icons.forum_outlined), text: 'Discussions'),
            Tab(icon: Icon(Icons.event_outlined), text: 'Events'),
            Tab(icon: Icon(Icons.book_outlined), text: 'Resources'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _currentCategoryFilter = value.toString();
              });
            },
            itemBuilder: (context) => _categories
                .map((category) => PopupMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          if (_currentCategoryFilter == category)
                            const Icon(Icons.check,
                                color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    ))
                .toList(),
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
                    _buildSupportGroupsTab(),
                    _buildDiscussionForumsTab(),
                    _buildEventsTab(),
                    _buildResourcesTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          _showCreateContentDialog();
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

  // Support Groups Tab
  Widget _buildSupportGroupsTab() {
    final filteredGroups =
        _filterByCategory(_supportGroups, _currentCategoryFilter, 'category');

    if (filteredGroups.isEmpty) {
      return _buildEmptyState(
        'No support groups available',
        'Try changing your filter or check back later',
        Icons.people_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredGroups.length,
        itemBuilder: (context, index) {
          final group = filteredGroups[index];
          return _buildSupportGroupCard(group);
        },
      ),
    );
  }

  Widget _buildSupportGroupCard(Map<String, dynamic> group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                topRight: Radius.circular(AppTheme.borderRadiusMedium),
              ),
              image: DecorationImage(
                image: AssetImage(
                    group['image']), // This would need real images to work
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppTheme.primaryColor.withOpacity(0.2),
                  BlendMode.srcOver,
                ),
                onError: (exception, stackTrace) => null,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusCircular),
                    ),
                    child: Text(
                      group['category'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(group['category']),
                      ),
                    ),
                  ),
                ),
                if (group['isVirtual'])
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusCircular),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Virtual',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  group['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group['meetingSchedule'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group['members']} members',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (group['tags'] as List<String>).map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: AppTheme.backgroundColor,
                      padding: EdgeInsets.zero,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondaryColor,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Group details opened'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Group Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Join request sent'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1, size: 16),
                        label: const Text('Join'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Discussion Forums Tab
  Widget _buildDiscussionForumsTab() {
    final filteredForums = _filterByCategory(
        _discussionForums, _currentCategoryFilter, 'category');

    if (filteredForums.isEmpty) {
      return _buildEmptyState(
        'No discussions available',
        'Try changing your filter or start a new discussion',
        Icons.forum_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredForums.length,
        itemBuilder: (context, index) {
          final forum = filteredForums[index];
          return _buildForumCard(forum);
        },
      ),
    );
  }

  Widget _buildForumCard(Map<String, dynamic> forum) {
    final lastActive = forum['lastActive'] as DateTime;
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    String timeText;
    if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeText = '${difference.inHours}h ago';
    } else {
      timeText = '${difference.inDays}d ago';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                if (forum['isPinned'])
                  Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.push_pin,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                Expanded(
                  child: Text(
                    forum['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(forum['category'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusCircular),
                      ),
                      child: Text(
                        forum['category'],
                        style: TextStyle(
                          fontSize: 11,
                          color: _getCategoryColor(forum['category']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'by ${forum['author']}',
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
                  children: (forum['tags'] as List<String>).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusCircular),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            onTap: () {
              // Navigate to discussion detail
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening discussion details'),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.dividerColor,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.forum,
                      size: 16,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${forum['replies']} replies',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Reply to discussion
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reply function triggered'),
                      ),
                    );
                  },
                  child: const Text('Reply'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Events Tab
  Widget _buildEventsTab() {
    final filteredEvents =
        _filterByCategory(_upcomingEvents, _currentCategoryFilter, 'category');

    if (filteredEvents.isEmpty) {
      return _buildEmptyState(
        'No events available',
        'Try changing your filter or check back later',
        Icons.event_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final eventDate = event['date'] as DateTime;
    final formattedDate = _formatDate(eventDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                  image: DecorationImage(
                    image: AssetImage(
                        event['image']), // This would need real images
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) => null,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(event['category'])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusCircular),
                            ),
                            child: Text(
                              event['category'],
                              style: TextStyle(
                                fontSize: 11,
                                color: _getCategoryColor(event['category']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (event['isFree'])
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusCircular),
                              ),
                              child: const Text(
                                'Free',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event['location'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Show event details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event details opened'),
                          ),
                        );
                      },
                      child: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: event['isRegistrationOpen']
                          ? () {
                              // Register for event
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registration form opened'),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                          event['isRegistrationOpen'] ? 'Register' : 'Closed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Resources Tab
  Widget _buildResourcesTab() {
    final filteredResources =
        _filterByCategory(_resources, _currentCategoryFilter, 'category');

    if (filteredResources.isEmpty) {
      return _buildEmptyState(
        'No resources available',
        'Try changing your filter or check back later',
        Icons.book_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredResources.length,
        itemBuilder: (context, index) {
          final resource = filteredResources[index];
          return _buildResourceCard(resource);
        },
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    IconData typeIcon;
    Color typeColor;

    switch (resource['type']) {
      case 'PDF':
        typeIcon = Icons.picture_as_pdf;
        typeColor = Colors.red;
        break;
      case 'Video':
        typeIcon = Icons.video_library;
        typeColor = Colors.red.shade700;
        break;
      case 'Guide':
        typeIcon = Icons.menu_book;
        typeColor = AppTheme.primaryColor;
        break;
      default:
        typeIcon = Icons.article;
        typeColor = AppTheme.textSecondaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () {
          // Open resource
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening resource'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  typeIcon,
                  size: 30,
                  color: typeColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(resource['category'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusCircular),
                          ),
                          child: Text(
                            resource['category'],
                            style: TextStyle(
                              fontSize: 11,
                              color: _getCategoryColor(resource['category']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusCircular),
                          ),
                          child: Text(
                            resource['type'],
                            style: TextStyle(
                              fontSize: 11,
                              color: typeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resource['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Source: ${resource['source']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resource['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // Share resource
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sharing resource'),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.share, size: 16),
                              const SizedBox(width: 4),
                              const Text('Share'),
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Download or view resource
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening resource'),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.file_download, size: 16),
                              const SizedBox(width: 4),
                              const Text('Download'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
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
                _showCreateContentDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Community Support'),
        content: TextField(
          autofocus: true,
          decoration: AppTheme.inputDecoration(
            hintText: 'Search for groups, discussions, events...',
            prefixIcon: Icons.search,
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
              // Perform search and update UI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search results would appear here'),
                ),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showCreateContentDialog() {
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
                'Create New',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.people,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text('Support Group'),
                subtitle: const Text('Create a new support group'),
                onTap: () {
                  Navigator.pop(context);
                  // Show create group form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Support group creation form would appear here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.forum,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                title: const Text('Discussion'),
                subtitle: const Text('Start a new discussion thread'),
                onTap: () {
                  Navigator.pop(context);
                  // Show create discussion form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Discussion creation form would appear here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                  child: Icon(
                    Icons.event,
                    color: AppTheme.accentColor,
                  ),
                ),
                title: const Text('Event'),
                subtitle: const Text('Schedule a new community event'),
                onTap: () {
                  Navigator.pop(context);
                  // Show create event form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event creation form would appear here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  child: const Icon(
                    Icons.upload_file,
                    color: Colors.teal,
                  ),
                ),
                title: const Text('Resource'),
                subtitle: const Text('Share a helpful resource'),
                onTap: () {
                  Navigator.pop(context);
                  // Show create resource form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resource upload form would appear here'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Respiratory':
        return AppTheme.pulmonaryColor;
      case 'Cardiology':
        return AppTheme.cardiologyColor;
      case 'Neurology':
        return AppTheme.neurologyColor;
      case 'Mental Health':
        return Colors.purple;
      case 'Pediatrics':
        return Colors.blue;
      case 'Chronic Care':
        return Colors.amber.shade700;
      case 'Wellness':
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }
}
