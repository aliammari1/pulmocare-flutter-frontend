import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthLiteracyScreen extends StatefulWidget {
  const HealthLiteracyScreen({Key? key}) : super(key: key);

  @override
  _HealthLiteracyScreenState createState() => _HealthLiteracyScreenState();
}

class _HealthLiteracyScreenState extends State<HealthLiteracyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock topics for education content
  final List<Map<String, dynamic>> _educationalTopics = [
    {
      'title': 'Understanding Blood Pressure',
      'category': 'Cardiology',
      'level': 'Beginner',
      'icon': Icons.favorite_border,
      'color': AppTheme.cardiologyColor,
      'duration': '5 min',
      'description':
          'Learn what blood pressure readings mean and why they are important for your health.',
    },
    {
      'title': 'Managing Respiratory Infections',
      'category': 'Pulmonology',
      'level': 'Intermediate',
      'icon': Icons.air,
      'color': AppTheme.pulmonaryColor,
      'duration': '8 min',
      'description':
          'Understand the difference between viral and bacterial infections and when to seek medical attention.',
    },
    {
      'title': 'Understanding Your Medications',
      'category': 'Pharmacy',
      'level': 'Beginner',
      'icon': Icons.medication_outlined,
      'color': AppTheme.primaryColor,
      'duration': '6 min',
      'description':
          'Learn about your prescriptions, potential side effects, and proper usage guidelines.',
    },
    {
      'title': 'Managing Chronic Pain',
      'category': 'Pain Management',
      'level': 'Advanced',
      'icon': Icons.healing,
      'color': AppTheme.neurologyColor,
      'duration': '10 min',
      'description':
          'Explore strategies for long-term pain management beyond medication.',
    },
    {
      'title': 'Nutrition Basics for Recovery',
      'category': 'Nutrition',
      'level': 'Beginner',
      'icon': Icons.restaurant_menu,
      'color': AppTheme.immunologyColor,
      'duration': '7 min',
      'description':
          'Discover the foundations of a balanced diet that supports healing and recovery.',
    },
    {
      'title': 'Preventive Health Screenings',
      'category': 'Preventive Care',
      'level': 'Intermediate',
      'icon': Icons.checklist_rtl,
      'color': AppTheme.successColor,
      'duration': '5 min',
      'description':
          'Learn which health screenings you need at different ages.',
    },
  ];

  // Mock recently viewed content
  final List<Map<String, dynamic>> _recentlyViewed = [
    {
      'title': 'Understanding Blood Test Results',
      'progress': 0.8,
      'image': 'assets/images/blood_test.jpg',
    },
    {
      'title': 'COVID-19 Recovery Guidelines',
      'progress': 0.5,
      'image': 'assets/images/covid.jpg',
    },
  ];

  // Mock health quizzes
  final List<Map<String, dynamic>> _healthQuizzes = [
    {
      'title': 'Heart Health Basics',
      'questions': 10,
      'points': 50,
      'image': 'assets/images/heart.jpg',
    },
    {
      'title': 'Medication Safety',
      'questions': 8,
      'points': 40,
      'image': 'assets/images/medication.jpg',
    },
    {
      'title': 'Understanding Diabetes',
      'questions': 12,
      'points': 60,
      'image': 'assets/images/diabetes.jpg',
    },
  ];

  // Mock health categories
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Heart Health',
      'icon': Icons.favorite,
      'color': AppTheme.cardiologyColor,
    },
    {
      'name': 'Lung Health',
      'icon': Icons.air,
      'color': AppTheme.pulmonaryColor,
    },
    {
      'name': 'Medication',
      'icon': Icons.medication,
      'color': AppTheme.primaryColor,
    },
    {
      'name': 'Nutrition',
      'icon': Icons.restaurant_menu,
      'color': AppTheme.immunologyColor,
    },
    {
      'name': 'Mental Health',
      'icon': Icons.psychology,
      'color': AppTheme.neurologyColor,
    },
    {
      'name': 'First Aid',
      'icon': Icons.medical_services,
      'color': AppTheme.errorColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearchExpanded
            ? const Text('Health Education')
            : TextField(
                controller: _searchController,
                autofocus: true,
                decoration: AppTheme.inputDecoration(
                  hintText: 'Search health topics...',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icons.search,
                  filled: false,
                  enabledBorder: false,
                  borderRadius: BorderRadius.circular(30),
                ),
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: AppTheme.fontSizeMedium,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchExpanded ? Icons.close : Icons.search,
            ),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Navigate to saved articles
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Library'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForYouTab(),
          _buildLibraryTab(),
          _buildQuizzesTab(),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health plan progress
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              side: BorderSide(color: AppTheme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.school,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Health Literacy Plan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '3 of 5 topics completed this week',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircularProgressIndicator(
                        value: 0.6,
                        backgroundColor: AppTheme.disabledColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: AppTheme.disabledColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Continue learning
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Continue Learning'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recently viewed
          const Text(
            'Continue Learning',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentlyViewed.length,
              itemBuilder: (context, index) {
                final item = _recentlyViewed[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusLarge),
                    color: Colors.white,
                    boxShadow: AppTheme.elevationLow,
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft:
                                  Radius.circular(AppTheme.borderRadiusLarge),
                              bottomLeft:
                                  Radius.circular(AppTheme.borderRadiusLarge),
                            ),
                            child: Container(
                              width: 100,
                              height: 120,
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.article_outlined,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(item['progress'] * 100).toInt()}% complete',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: item['progress'],
                                  backgroundColor: AppTheme.disabledColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                  minHeight: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusLarge,
                            ),
                            onTap: () {
                              // Open article
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Recommended for you
          const Text(
            'Recommended for You',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Show only a few recommendations
            itemBuilder: (context, index) {
              final topic = _educationalTopics[index];
              return _buildTopicCard(topic);
            },
          ),

          const SizedBox(height: 24),

          // Today's health tip
          Card(
            elevation: 0,
            color: AppTheme.successColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              side: BorderSide(
                color: AppTheme.successColor.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tips_and_updates,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Today's Health Tip",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Try to take a 10-minute walk after each meal to help lower blood sugar levels and improve digestion.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        // View more tips
                      },
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('More Tips'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          const Text(
            'Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
          const SizedBox(height: 24),

          // All educational topics
          const Text(
            'All Topics',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _educationalTopics.length,
            itemBuilder: (context, index) {
              final topic = _educationalTopics[index];
              return _buildTopicCard(topic);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizzesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              side: BorderSide(color: AppTheme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '745',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Health IQ Score',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildScoreBadge('Heart Health', 85),
                      const SizedBox(width: 16),
                      _buildScoreBadge('Nutrition', 78),
                      const SizedBox(width: 16),
                      _buildScoreBadge('Medication', 92),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Available quizzes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health Quizzes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all quizzes
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _healthQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = _healthQuizzes[index];
              return _buildQuizCard(quiz);
            },
          ),

          const SizedBox(height: 24),

          // Achievements
          const Text(
            'Your Achievements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              side: BorderSide(color: AppTheme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAchievement(
                          'Health Expert', Icons.military_tech, 5),
                      _buildAchievement('Quiz Master', Icons.bookmark, 12),
                      _buildAchievement(
                          'Knowledge Seeker', Icons.menu_book, 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      // View all achievements
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('View All Achievements'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String category, int score) {
    Color color;
    if (score >= 90) {
      color = AppTheme.successColor;
    } else if (score >= 75) {
      color = AppTheme.warningColor;
    } else {
      color = AppTheme.errorColor;
    }

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        side: BorderSide(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        onTap: () {
          // Open topic
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: topic['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  topic['icon'],
                  color: topic['color'],
                  size: 28,
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
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: topic['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            topic['category'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: topic['color'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            topic['level'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          topic['duration'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: BorderSide(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        onTap: () {
          // Open category
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        side: BorderSide(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        onTap: () {
          // Start quiz
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  topRight: Radius.circular(AppTheme.borderRadiusLarge),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.quiz_outlined,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz['questions']} Questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.stars,
                        size: 14,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz['points']} pts',
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
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  bottomRight: Radius.circular(AppTheme.borderRadiusLarge),
                ),
              ),
              child: const Text(
                'Start Quiz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievement(String title, IconData icon, int count) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count Earned',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
