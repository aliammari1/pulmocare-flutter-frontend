import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _newSymptomController = TextEditingController();

  // Track active symptoms
  final List<String> _availableSymptoms = [
    'Headache',
    'Fatigue',
    'Nausea',
    'Dizziness',
    'Cough',
    'Fever',
    'Muscle Pain',
    'Joint Pain',
    'Shortness of Breath',
    'Chest Pain',
  ];

  // Today's symptoms and ratings
  final Map<String, int> _todaySymptoms = {};

  // Mock journal entries for demo
  final List<Map<String, dynamic>> _journalEntries = [
    {
      'date': DateTime.now().subtract(const Duration(days: 0)),
      'symptoms': {'Headache': 2, 'Fatigue': 3},
      'mood': 'Neutral',
      'notes':
          'Feeling a bit better today. Headache less severe but still tired.',
      'medications': ['Ibuprofen 400mg - morning'],
      'activities': ['Light walking - 10 minutes', 'Meditation'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'symptoms': {'Headache': 4, 'Fatigue': 4, 'Nausea': 2},
      'mood': 'Poor',
      'notes':
          'Bad headache all day. Feeling very tired and slightly nauseous.',
      'medications': ['Ibuprofen 400mg - morning and afternoon'],
      'activities': ['Bed rest most of the day'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'symptoms': {'Headache': 3, 'Fatigue': 2},
      'mood': 'Neutral',
      'notes': 'Woke up with mild headache. Improved after medication.',
      'medications': ['Ibuprofen 400mg - morning'],
      'activities': ['Short walk - 15 minutes', 'Reading'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'symptoms': {'Headache': 1},
      'mood': 'Good',
      'notes':
          'Feeling mostly good today with just a slight headache in the evening.',
      'medications': [],
      'activities': ['Walking - 30 minutes', 'Grocery shopping', 'Cooking'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'symptoms': {'Fatigue': 2, 'Muscle Pain': 3},
      'mood': 'Neutral',
      'notes': 'Some muscle pain after yesterday\'s activity. Slightly tired.',
      'medications': ['Acetaminophen 500mg - evening'],
      'activities': ['Rest day', 'Reading', 'TV'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'symptoms': {'Muscle Pain': 1},
      'mood': 'Good',
      'notes': 'Productive day. Did some light exercise which felt good.',
      'medications': [],
      'activities': ['Light exercise - 20 minutes', 'Housework', 'Cooking'],
    },
  ];

  // Selected time range for trends
  String _selectedTimeRange = '1 Week';
  String _selectedSymptomToTrack = 'Headache';
  String _selectedMood = 'Neutral';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Set today's symptoms from the most recent entry (if it's today)
    if (_journalEntries.isNotEmpty &&
        _isSameDay(_journalEntries[0]['date'], DateTime.now())) {
      _todaySymptoms
          .addAll(Map<String, int>.from(_journalEntries[0]['symptoms']));
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalController.dispose();
    _newSymptomController.dispose();
    super.dispose();
  }

  // Save today's journal entry
  void _saveJournalEntry() {
    if (_todaySymptoms.isEmpty && _journalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one symptom or journal note')),
      );
      return;
    }

    // Check if we already have an entry for today
    bool updatedExisting = false;
    if (_journalEntries.isNotEmpty &&
        _isSameDay(_journalEntries[0]['date'], DateTime.now())) {
      // Update the existing entry
      _journalEntries[0]['symptoms'] = Map<String, int>.from(_todaySymptoms);
      _journalEntries[0]['mood'] = _selectedMood;
      _journalEntries[0]['notes'] = _journalController.text;
      updatedExisting = true;
    } else {
      // Create a new entry
      _journalEntries.insert(0, {
        'date': DateTime.now(),
        'symptoms': Map<String, int>.from(_todaySymptoms),
        'mood': _selectedMood,
        'notes': _journalController.text,
        'medications': [],
        'activities': [],
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updatedExisting
            ? 'Journal entry updated'
            : 'New journal entry saved'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear journal text
    _journalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Tracker & Journal'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Journal'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildJournalTab(),
          _buildTrendsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveJournalEntry,
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Mood selector
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodButton('Poor', '😣', Colors.red),
              _buildMoodButton('Fair', '😕', Colors.orange),
              _buildMoodButton('Neutral', '😐', Colors.amber),
              _buildMoodButton('Good', '🙂', Colors.lightGreen),
              _buildMoodButton('Excellent', '😄', Colors.green),
            ],
          ),
          const Divider(height: 32),

          // Symptom tracking
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Symptoms',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddSymptomDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Symptom'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Active symptoms list
          _todaySymptoms.isEmpty
              ? _buildEmptySymptomState()
              : Column(
                  children: _todaySymptoms.entries.map((entry) {
                    return _buildSymptomSlider(entry.key, entry.value);
                  }).toList(),
                ),

          const Divider(height: 32),

          // Journal notes
          const Text(
            'Journal Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _journalController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add notes about how you\'re feeling today...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 16),

          // Quick actions
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickActionChip('Add medication', Icons.medication),
                      _buildQuickActionChip(
                          'Log activity', Icons.directions_walk),
                      _buildQuickActionChip(
                          'Record vital', Icons.monitor_heart),
                      _buildQuickActionChip('Set reminder', Icons.alarm),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildMoodButton(String mood, String emoji, Color color) {
    final isSelected = _selectedMood == mood;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.grey[200],
              border: Border.all(
                color: isSelected ? color : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mood,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySymptomState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.healing,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No symptoms tracked yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Symptom" to start tracking',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomSlider(String symptom, int value) {
    final List<String> severityLabels = [
      'None',
      'Mild',
      'Moderate',
      'Severe',
      'Very Severe'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                symptom,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _todaySymptoms.remove(symptom);
                  });
                },
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: severityLabels[value],
                  onChanged: (newValue) {
                    setState(() {
                      _todaySymptoms[symptom] = newValue.toInt();
                    });
                  },
                ),
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: value > 2 ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: severityLabels.map((label) {
                return Text(
                  label == 'None' || label == 'Very Severe' ? label : '',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSymptomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Symptom'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _newSymptomController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Symptom',
                        hintText: 'Enter symptom name',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Common Symptoms',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableSymptoms.length,
                        itemBuilder: (context, index) {
                          final symptom = _availableSymptoms[index];
                          final isAlreadyAdded =
                              _todaySymptoms.containsKey(symptom);

                          return ListTile(
                            title: Text(symptom),
                            trailing: isAlreadyAdded
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                            onTap: isAlreadyAdded
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _todaySymptoms[symptom] =
                                          1; // Default to mild
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_newSymptomController.text.isNotEmpty) {
                      Navigator.pop(context);
                      setState(() {
                        _todaySymptoms[_newSymptomController.text] =
                            1; // Default to mild
                      });
                      _newSymptomController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a symptom name')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Add Custom'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildJournalTab() {
    if (_journalEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No journal entries yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your health journal will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _journalEntries.length,
      itemBuilder: (context, index) {
        final entry = _journalEntries[index];
        final date = entry['date'] as DateTime;
        final Map<String, int> symptoms =
            Map<String, int>.from(entry['symptoms']);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showJournalDetails(entry),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildMoodIndicator(entry['mood']),
                    ],
                  ),
                  const Divider(height: 24),
                  symptoms.isNotEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: symptoms.entries.map((symptom) {
                            return _buildSymptomChip(
                              symptom.key,
                              symptom.value,
                            );
                          }).toList(),
                        )
                      : Text(
                          'No symptoms recorded',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                  if (entry['notes'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      entry['notes'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${symptoms.length} symptoms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(date),
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
          ),
        );
      },
    );
  }

  Widget _buildMoodIndicator(String mood) {
    IconData icon;
    Color color;

    switch (mood) {
      case 'Poor':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
      case 'Fair':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.orange;
        break;
      case 'Neutral':
        icon = Icons.sentiment_neutral;
        color = Colors.amber;
        break;
      case 'Good':
        icon = Icons.sentiment_satisfied;
        color = Colors.lightGreen;
        break;
      case 'Excellent':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            mood,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(String symptom, int severity) {
    // Color based on severity
    Color getColorForSeverity(int severity) {
      switch (severity) {
        case 0:
          return Colors.green;
        case 1:
          return Colors.lightGreen;
        case 2:
          return Colors.amber;
        case 3:
          return Colors.orange;
        case 4:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    final color = getColorForSeverity(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symptom,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withAlpha(204),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                severity.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJournalDetails(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final date = entry['date'] as DateTime;
        final symptoms = Map<String, int>.from(entry['symptoms']);

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(date),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    _buildMoodIndicator(entry['mood']),
                  ],
                ),
                const Divider(height: 32),

                // Symptoms
                const Text(
                  'Symptoms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                symptoms.isEmpty
                    ? Text(
                        'No symptoms recorded',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      )
                    : Column(
                        children: symptoms.entries.map((symptom) {
                          return _buildSymptomDetail(
                            symptom.key,
                            symptom.value,
                          );
                        }).toList(),
                      ),

                const Divider(height: 32),

                // Notes
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry['notes'].isNotEmpty
                      ? entry['notes']
                      : 'No notes recorded',
                  style: TextStyle(
                    fontStyle: entry['notes'].isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: entry['notes'].isEmpty
                        ? Colors.grey[600]
                        : Colors.black87,
                  ),
                ),

                if ((entry['medications'] as List).isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text(
                    'Medications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    (entry['medications'] as List).length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.medication,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(entry['medications'][index]),
                        ],
                      ),
                    ),
                  ),
                ],

                if ((entry['activities'] as List).isNotEmpty) ...[
                  const Divider(height: 32),
                  const Text(
                    'Activities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    (entry['activities'] as List).length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(entry['activities'][index]),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Entry'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSymptomDetail(String symptom, int severity) {
    final List<String> severityLabels = [
      'None',
      'Mild',
      'Moderate',
      'Severe',
      'Very Severe'
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(symptom),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: severity / 4,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                severity <= 1
                    ? Colors.green
                    : severity <= 2
                        ? Colors.amber
                        : severity <= 3
                            ? Colors.orange
                            : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              severityLabels[severity],
              style: TextStyle(
                fontSize: 12,
                color: severity <= 1
                    ? Colors.green
                    : severity <= 2
                        ? Colors.amber
                        : severity <= 3
                            ? Colors.orange
                            : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptom Trends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSymptomToTrack,
                  decoration: InputDecoration(
                    labelText: 'Symptom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: _getAvailableSymptomsForTrends()
                      .map<DropdownMenuItem<String>>((symptom) {
                    return DropdownMenuItem<String>(
                      value: symptom,
                      child: Text(symptom),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSymptomToTrack = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeRange,
                  decoration: InputDecoration(
                    labelText: 'Time Range',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: '1 Week', child: Text('1 Week')),
                    DropdownMenuItem(value: '2 Weeks', child: Text('2 Weeks')),
                    DropdownMenuItem(value: '1 Month', child: Text('1 Month')),
                    DropdownMenuItem(
                        value: '3 Months', child: Text('3 Months')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeRange = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart
          Expanded(
            child: _buildTrendChart(),
          ),

          const SizedBox(height: 16),

          // Stats summary
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary for $_selectedSymptomToTrack',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Average', '2.2', Colors.blue),
                      _buildStatItem('Highest', '4', Colors.red),
                      _buildStatItem('Lowest', '1', Colors.green),
                      _buildStatItem('Trend', 'Improving', Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Correlation section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.indigo.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Health Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your $_selectedSymptomToTrack appears to be correlated with your activity level. Days with light exercise show reduced severity.',
                    style: TextStyle(
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to detailed analysis
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Detailed Analysis'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
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

  List<String> _getAvailableSymptomsForTrends() {
    final Set<String> symptoms = {};

    for (final entry in _journalEntries) {
      final entrySymptoms = Map<String, int>.from(entry['symptoms']);
      symptoms.addAll(entrySymptoms.keys);
    }

    return symptoms.isEmpty ? ['No symptoms'] : symptoms.toList();
  }

  Widget _buildTrendChart() {
    // Prepare data for the selected symptom
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    int daysToShow;

    switch (_selectedTimeRange) {
      case '1 Week':
        daysToShow = 7;
        break;
      case '2 Weeks':
        daysToShow = 14;
        break;
      case '1 Month':
        daysToShow = 30;
        break;
      case '3 Months':
        daysToShow = 90;
        break;
      default:
        daysToShow = 7;
    }

    // Find symptom data in journal entries
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Find entry for this date
      bool found = false;
      for (final entry in _journalEntries) {
        if (_isSameDay(entry['date'], date)) {
          final symptoms = Map<String, int>.from(entry['symptoms']);
          if (symptoms.containsKey(_selectedSymptomToTrack)) {
            spots.add(FlSpot((daysToShow - i - 1).toDouble(),
                symptoms[_selectedSymptomToTrack]!.toDouble()));
            found = true;
            break;
          }
        }
      }

      if (!found && spots.isNotEmpty) {
        // Add a null point (gap) if no data for this day
        // spots.add(FlSpot(daysToShow - i - 1.toDouble(), double.nan));
      }
    }

    if (spots.isEmpty) {
      // No data available
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No trend data available for $_selectedSymptomToTrack',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Continue tracking to see trends over time',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Show only some dates to avoid crowding
                if (daysToShow <= 14 ||
                    value.toInt() % (daysToShow ~/ 7) == 0) {
                  final date = now
                      .subtract(Duration(days: daysToShow - 1 - value.toInt()));
                  return Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value <= 4 && value.toInt() == value) {
                  final labels = [
                    'None',
                    'Mild',
                    'Moderate',
                    'Severe',
                    'Very Severe'
                  ];
                  return Text(
                    labels[value.toInt()],
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withAlpha(50),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final date = now.subtract(
                    Duration(days: daysToShow - 1 - touchedSpot.x.toInt()));
                final severity = [
                  'None',
                  'Mild',
                  'Moderate',
                  'Severe',
                  'Very Severe'
                ][touchedSpot.y.toInt()];
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}\n$severity',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        minY: 0,
        maxY: 4,
        minX: 0,
        maxX: daysToShow - 1.0,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(25),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: AppTheme.primaryColor,
      ),
      label: Text(label),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label feature coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
