import 'package:flutter/material.dart';
import 'package:medapp/theme/app_theme.dart';
import 'dart:math';

class WellnessRecommendationScreen extends StatefulWidget {
  const WellnessRecommendationScreen({super.key});

  @override
  State<WellnessRecommendationScreen> createState() =>
      _WellnessRecommendationScreenState();
}

class _WellnessRecommendationScreenState
    extends State<WellnessRecommendationScreen> {
  final List<Map<String, dynamic>> _wellnessCategories = [
    {
      'title': 'Physical Activity',
      'icon': Icons.directions_run,
      'color': const Color(0xFF4CAF50),
      'recommendations': [
        'Take a 30-minute walk daily',
        'Try strength training twice a week',
        'Practice stretching exercises every morning',
        'Consider yoga or pilates for flexibility',
        'Take the stairs instead of elevator when possible'
      ]
    },
    {
      'title': 'Nutrition',
      'icon': Icons.restaurant,
      'color': const Color(0xFFF44336),
      'recommendations': [
        'Include more leafy greens in your diet',
        'Stay hydrated with at least 8 glasses of water daily',
        'Limit processed food consumption',
        'Include a variety of fruits in your daily intake',
        'Consider plant-based protein sources'
      ]
    },
    {
      'title': 'Mental Health',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF2196F3),
      'recommendations': [
        'Practice mindfulness meditation for 10 minutes daily',
        'Keep a gratitude journal',
        'Limit social media use before bedtime',
        'Take short breaks during work hours',
        'Connect with friends and family regularly'
      ]
    },
    {
      'title': 'Sleep',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF9C27B0),
      'recommendations': [
        'Maintain a consistent sleep schedule',
        'Aim for 7-9 hours of sleep nightly',
        'Create a relaxing bedtime routine',
        'Keep bedroom dark and cool',
        'Avoid caffeine in the afternoon'
      ]
    },
  ];

  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  String _dailyTip = '';
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate data loading
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate daily wellness tip
    final allTips = _wellnessCategories
        .expand((category) => category['recommendations'] as List<String>)
        .toList();
    setState(() {
      _dailyTip = allTips[_random.nextInt(allTips.length)];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Recommendations'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailyTipCard(),
                  _buildCategorySelector(),
                  _buildRecommendationList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show custom wellness recommendation dialog
          _showCustomRecommendationDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Custom Plan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B4F6C),
            const Color(0xFF01BAEF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Wellness Tip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _dailyTip,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    final allTips = _wellnessCategories
                        .expand((category) =>
                            category['recommendations'] as List<String>)
                        .toList();
                    _dailyTip = allTips[_random.nextInt(allTips.length)];
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'New Tip',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _wellnessCategories.length,
        itemBuilder: (context, index) {
          final category = _wellnessCategories[index];
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? category['color'] : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category['color'].withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationList() {
    final selectedCategory = _wellnessCategories[_selectedCategoryIndex];
    final recommendations = selectedCategory['recommendations'] as List<String>;
    final categoryColor = selectedCategory['color'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selectedCategory['title']} Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.map((recommendation) =>
              _buildRecommendationItem(recommendation, categoryColor)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomRecommendationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Wellness Plan'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coming soon: Personalized wellness recommendations based on your medical records, lifestyle, and goals.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'This feature will allow you to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Set specific wellness goals'),
              Text('• Get personalized activity recommendations'),
              Text('• Track your progress over time'),
              Text('• Receive reminders and motivation'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, LOOKING FORWARD TO IT'),
          ),
        ],
      ),
    );
  }
}
