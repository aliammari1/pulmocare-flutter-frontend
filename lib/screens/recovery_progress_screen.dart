import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class RecoveryProgressScreen extends StatefulWidget {
  final String? patientId;
  final String? conditionId;

  const RecoveryProgressScreen({
    Key? key,
    this.patientId,
    this.conditionId,
  }) : super(key: key);

  @override
  State<RecoveryProgressScreen> createState() => _RecoveryProgressScreenState();
}

class _RecoveryProgressScreenState extends State<RecoveryProgressScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  late TabController _tabController;

  // Mock data
  Map<String, dynamic> _recoveryData = {};
  List<Map<String, dynamic>> _milestones = [];
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _symptoms = [];

  // Progress metrics
  double _overallProgress = 0.0;
  int _daysSinceStart = 0;
  int _totalRecoveryDays = 60;
  String _currentPhase = "Initial Recovery";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRecoveryData();
  }

  Future<void> _loadRecoveryData() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock data - in real app this would come from your API based on patientId and conditionId
      final Random random = Random();
      final now = DateTime.now();
      final startDate =
          DateTime(now.year, now.month - 1, now.day - random.nextInt(10) - 15);

      _daysSinceStart = now.difference(startDate).inDays;
      _overallProgress = min(1.0, _daysSinceStart / _totalRecoveryDays);

      if (_overallProgress < 0.3) {
        _currentPhase = "Initial Recovery";
      } else if (_overallProgress < 0.7) {
        _currentPhase = "Middle Recovery";
      } else if (_overallProgress < 0.95) {
        _currentPhase = "Late Recovery";
      } else {
        _currentPhase = "Maintenance";
      }

      // Generate mock recovery data
      _recoveryData = {
        "patientId": widget.patientId ?? "P-128976",
        "condition": "Post-pneumonia recovery",
        "startDate": startDate,
        "expectedEndDate": startDate.add(Duration(days: _totalRecoveryDays)),
        "primaryPhysician": "Dr. Sophie Williams",
        "notes":
            "Patient is recovering well from severe pneumonia. Continue with prescribed medication and breathing exercises."
      };

      // Generate mock milestones
      _milestones = [
        {
          "title": "Initial Assessment",
          "description": "Complete initial evaluation and create recovery plan",
          "dueDate": startDate.add(const Duration(days: 1)),
          "completed": true,
        },
        {
          "title": "Breathing Without Assistance",
          "description":
              "Patient should be able to maintain oxygen saturation above 95% without supplemental oxygen",
          "dueDate": startDate.add(const Duration(days: 10)),
          "completed": _daysSinceStart > 10,
        },
        {
          "title": "Return to Light Activities",
          "description":
              "Patient should be able to perform light household activities without fatigue",
          "dueDate": startDate.add(const Duration(days: 25)),
          "completed": _daysSinceStart > 25,
        },
        {
          "title": "Full Lung Function",
          "description":
              "Pulmonary function tests should show return to baseline or near-baseline function",
          "dueDate": startDate.add(const Duration(days: 45)),
          "completed": _daysSinceStart > 45,
        },
        {
          "title": "Return to Normal Activity Level",
          "description":
              "Patient should be able to resume all pre-illness activities without limitations",
          "dueDate": startDate.add(Duration(days: _totalRecoveryDays)),
          "completed": _daysSinceStart > _totalRecoveryDays,
        },
      ];

      // Generate mock activities
      _activities = [
        {
          "title": "Walking",
          "description":
              "Start with 5 minutes, gradually increase to 30 minutes",
          "frequency": "Daily",
          "isCompleted": List.generate(7, (index) => random.nextBool()),
          "progressNotes": "Walking tolerance has improved to 20 minutes",
          "targetValue": 30,
          "currentValue": min(30, max(5, 5 + (_daysSinceStart ~/ 2))),
        },
        {
          "title": "Breathing Exercises",
          "description": "Deep breathing and incentive spirometry",
          "frequency": "Three times daily",
          "isCompleted": List.generate(7, (index) => random.nextBool()),
          "progressNotes":
              "Peak flow has improved from 60% to 75% of predicted",
          "targetValue": 10,
          "currentValue": min(10, max(0, _daysSinceStart ~/ 6)),
        },
        {
          "title": "Resistance Training",
          "description": "Light strength training for upper and lower body",
          "frequency": "Every other day",
          "isCompleted": List.generate(7, (index) => random.nextBool()),
          "progressNotes": "Now able to complete full set of exercises",
          "targetValue": 15,
          "currentValue": min(15, max(0, (_daysSinceStart - 10) ~/ 3)),
        },
      ];

      // Generate mock medications
      _medications = [
        {
          "name": "Azithromycin",
          "dosage": "250mg",
          "frequency": "Once daily",
          "remainingDays": max(0, 10 - _daysSinceStart),
          "adherence": random.nextDouble() * 0.2 + 0.8, // 80-100%
        },
        {
          "name": "Albuterol Inhaler",
          "dosage": "2 puffs",
          "frequency": "As needed for shortness of breath",
          "remainingDays": max(0, 30 - _daysSinceStart),
          "adherence": random.nextDouble() * 0.3 + 0.7, // 70-100%
        },
        {
          "name": "Vitamin D",
          "dosage": "2000 IU",
          "frequency": "Once daily",
          "remainingDays": max(0, 60 - _daysSinceStart),
          "adherence": random.nextDouble() * 0.3 + 0.7, // 70-100%
        },
      ];

      // Generate mock symptoms tracking
      _symptoms = [];

      // Generate cough severity data
      List<Map<String, dynamic>> coughData = [];
      for (int i = 0; i < min(30, _daysSinceStart); i++) {
        // Cough should generally improve over time with some fluctuations
        double baseSeverity = max(0, 8 - (i / 3.5));
        double randomFactor = random.nextDouble() * 2 - 1; // -1 to 1
        double severity = max(0, min(10, baseSeverity + randomFactor));

        coughData.add({
          "date": startDate.add(Duration(days: i)),
          "value": severity,
        });
      }

      // Generate fatigue data
      List<Map<String, dynamic>> fatigueData = [];
      for (int i = 0; i < min(30, _daysSinceStart); i++) {
        // Fatigue should improve more slowly
        double baseSeverity = max(0, 9 - (i / 5));
        double randomFactor = random.nextDouble() * 2 - 1; // -1 to 1
        double severity = max(0, min(10, baseSeverity + randomFactor));

        fatigueData.add({
          "date": startDate.add(Duration(days: i)),
          "value": severity,
        });
      }

      // Generate oxygen saturation data
      List<Map<String, dynamic>> oxygenData = [];
      for (int i = 0; i < min(30, _daysSinceStart); i++) {
        // Oxygen saturation should improve over time with fluctuations
        double baseValue = min(99, 92 + (i / 4));
        double randomFactor = random.nextDouble() * 2 - 1; // -1 to 1
        double value = max(90, min(100, baseValue + randomFactor));

        oxygenData.add({
          "date": startDate.add(Duration(days: i)),
          "value": value,
        });
      }

      // Add all symptoms
      _symptoms = [
        {
          "name": "Cough Severity",
          "description": "Rate your cough severity on a scale of 0-10",
          "unit": "",
          "targetDirection": "decrease",
          "targetValue": 0,
          "normalRange": "0-2",
          "data": coughData,
          "currentValue": coughData.isNotEmpty ? coughData.last["value"] : null,
        },
        {
          "name": "Fatigue Level",
          "description": "Rate your fatigue level on a scale of 0-10",
          "unit": "",
          "targetDirection": "decrease",
          "targetValue": 0,
          "normalRange": "0-3",
          "data": fatigueData,
          "currentValue":
              fatigueData.isNotEmpty ? fatigueData.last["value"] : null,
        },
        {
          "name": "Oxygen Saturation",
          "description": "Morning oxygen saturation percentage",
          "unit": "%",
          "targetDirection": "increase",
          "targetValue": 98,
          "normalRange": "95-100%",
          "data": oxygenData,
          "currentValue":
              oxygenData.isNotEmpty ? oxygenData.last["value"] : null,
        },
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = "Error loading recovery data: $e";
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Activities'),
            Tab(text: 'Symptoms'),
            Tab(text: 'Medications'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildActivitiesTab(),
                    _buildSymptomsTab(),
                    _buildMedicationsTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadRecoveryData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final startDate = _recoveryData["startDate"] as DateTime;
    final endDate = _recoveryData["expectedEndDate"] as DateTime;
    final formatter = DateFormat('MMM d, yyyy');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recovery Progress Card
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recovery Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _overallProgress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day $_daysSinceStart of $_totalRecoveryDays',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_overallProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Recovery phase
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Current Phase: $_currentPhase',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Recovery dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          formatter.format(startDate),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Expected Completion',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          formatter.format(endDate),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Recovery details
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recovery Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                    'Condition', _recoveryData["condition"] ?? 'Unknown'),
                _buildDetailRow('Primary Physician',
                    _recoveryData["primaryPhysician"] ?? 'Not assigned'),
                _buildDetailRow(
                    'Notes', _recoveryData["notes"] ?? 'No notes available'),
              ],
            ),
          ),
        ),

        // Milestones section
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recovery Milestones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._milestones
                    .map((milestone) => _buildMilestoneItem(milestone)),
              ],
            ),
          ),
        ),

        // Upcoming tasks/appointments
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Appointments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.meeting_room_outlined,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: const Text('Follow-up Appointment'),
                  subtitle: Text(
                      'With ${_recoveryData["primaryPhysician"] ?? "Doctor"} • ${formatter.format(DateTime.now().add(const Duration(days: 14)))}'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Details'),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  title: const Text('Pulmonary Function Test'),
                  subtitle: Text(
                      '${formatter.format(DateTime.now().add(const Duration(days: 21)))} • Pulmonology Department'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Details'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(Map<String, dynamic> milestone) {
    final DateTime dueDate = milestone["dueDate"] as DateTime;
    final bool isCompleted = milestone["completed"] as bool;
    final formatter = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.successColor : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppTheme.successColor : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone["title"] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone["description"] as String,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${formatter.format(dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successColor.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompleted ? 'Completed' : 'Pending',
              style: TextStyle(
                color: isCompleted ? AppTheme.successColor : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions card
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recovery Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'These activities are prescribed as part of your recovery plan. Tap on each activity to log your progress.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Activities List
        ..._activities.map((activity) => _buildActivityCard(activity)),

        // Button to log new activity
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              // Show dialog or navigate to add activity
            },
            icon: const Icon(Icons.add),
            label: const Text('Log Additional Activity'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final String title = activity["title"] as String;
    final String description = activity["description"] as String;
    final String frequency = activity["frequency"] as String;
    final List<bool> isCompleted = activity["isCompleted"] as List<bool>;
    final double progress = activity["currentValue"] / activity["targetValue"];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    frequency,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Progress: ${activity["currentValue"]} / ${activity["targetValue"]}'),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Streak/Completion tracking
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Week:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 0; i < 7; i++)
                      _buildCompletionCircle(
                        day: ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        isCompleted: isCompleted[i],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Show history
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Log today's activity
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Log Today'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCircle(
      {required String day, required bool isCompleted}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppTheme.successColor : Colors.transparent,
            border: Border.all(
              color: isCompleted ? AppTheme.successColor : Colors.grey[400]!,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSymptomsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions card
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Symptoms Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Track your symptoms to monitor your recovery progress. Your doctor will use this information during your follow-up appointments.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Symptoms graph cards
        ..._symptoms.map((symptom) => _buildSymptomCard(symptom)),

        // Log new symptoms button
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              // Show dialog or navigate to add symptom log
            },
            icon: const Icon(Icons.add),
            label: const Text('Record Today\'s Symptoms'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCard(Map<String, dynamic> symptom) {
    final String name = symptom["name"] as String;
    final String description = symptom["description"] as String;
    final String unit = symptom["unit"] as String;
    final List<Map<String, dynamic>> data =
        symptom["data"] as List<Map<String, dynamic>>;
    final String normalRange = symptom["normalRange"] as String;
    final String targetDirection = symptom["targetDirection"] as String;
    final double? currentValue = symptom["currentValue"] as double?;

    Color getValueColor(double? value) {
      if (value == null) return Colors.grey;

      if (name.contains("Oxygen")) {
        if (value >= 95) return AppTheme.successColor;
        if (value >= 90) return AppTheme.warningColor;
        return AppTheme.errorColor;
      } else {
        // For other symptoms where lower is better
        if (value <= 2) return AppTheme.successColor;
        if (value <= 5) return AppTheme.warningColor;
        return AppTheme.errorColor;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${targetDirection == "decrease" ? "Decrease" : "Increase"} • Normal Range: $normalRange',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentValue != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: getValueColor(currentValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: getValueColor(currentValue).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          currentValue.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: getValueColor(currentValue),
                          ),
                        ),
                        if (unit.isNotEmpty) ...[
                          const SizedBox(width: 2),
                          Text(
                            unit,
                            style: TextStyle(
                              fontSize: 12,
                              color: getValueColor(currentValue),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Chart for symptom tracking
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: name.contains("Oxygen") ? 2.0 : 2.0,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length ||
                              value.toInt() < 0) {
                            return const SizedBox.shrink();
                          }
                          if (value.toInt() % 5 != 0) {
                            return const SizedBox.shrink();
                          }

                          final date = data[value.toInt()]["date"] as DateTime;
                          return Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          String text = value.toInt().toString();
                          if (name.contains("Oxygen") && value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            text,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minY: name.contains("Oxygen") ? 90 : 0,
                  maxY: name.contains("Oxygen") ? 100 : 10,
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = data[spot.x.toInt()]["date"] as DateTime;
                          final formatter = DateFormat('MMM d');
                          return LineTooltipItem(
                            '${formatter.format(date)}: ${spot.y.toStringAsFixed(1)}${unit.isEmpty ? '' : ' $unit'}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), entry.value["value"]);
                      }).toList(),
                      isCurved: true,
                      color: targetDirection == "decrease"
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: targetDirection == "decrease"
                            ? AppTheme.errorColor.withOpacity(0.15)
                            : AppTheme.primaryColor.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Show detailed view
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Detailed View'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Record today's value
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Record Today'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions card
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.pulmonaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    color: AppTheme.pulmonaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medication Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Track your medications to ensure you\'re following your recovery plan. Don\'t skip doses without consulting your doctor.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Medication cards
        ..._medications.map((medication) => _buildMedicationCard(medication)),

        // Add medication button
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to add medication
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Other Medication'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final String name = medication["name"] as String;
    final String dosage = medication["dosage"] as String;
    final String frequency = medication["frequency"] as String;
    final int remainingDays = medication["remainingDays"] as int;
    final double adherence = medication["adherence"] as double;

    // Generate color based on adherence
    Color getAdherenceColor(double value) {
      if (value >= 0.85) return AppTheme.successColor;
      if (value >= 0.7) return AppTheme.warningColor;
      return AppTheme.errorColor;
    }

    final adherenceColor = getAdherenceColor(adherence);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.pulmonaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: AppTheme.pulmonaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dosage • $frequency',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (remainingDays > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.pulmonaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.pulmonaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '$remainingDays days left',
                      style: TextStyle(
                        color: AppTheme.pulmonaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Adherence bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Adherence Rate',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(adherence * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: adherenceColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: adherence,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(adherenceColor),
                  borderRadius: BorderRadius.circular(5),
                ),
                if (adherence < 0.85) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Try to take your medication as prescribed',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Log today's intake
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Log Intake'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
