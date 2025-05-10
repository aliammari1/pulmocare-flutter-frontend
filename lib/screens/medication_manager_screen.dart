import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

class MedicationManagerScreen extends StatefulWidget {
  const MedicationManagerScreen({super.key});

  @override
  State<MedicationManagerScreen> createState() =>
      _MedicationManagerScreenState();
}

class _MedicationManagerScreenState extends State<MedicationManagerScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _filteredMedications = [];
  List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> _history = [];

  // For adding new medication
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedFrequency = 'Daily';
  List<String> _selectedDays = [];
  List<TimeOfDay> _selectedTimes = [];
  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Adherence data for charts
  List<Map<String, dynamic>> _adherenceData =
      []; // Changed from final to non-final

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() => _isLoading = true);

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate mock medications
    final medications = [
      {
        'id': 'm1',
        'name': 'Lisinopril',
        'dosage': '10mg',
        'type': 'Tablet',
        'frequency': 'Daily',
        'timeOfDay': [const TimeOfDay(hour: 8, minute: 0)],
        'days': [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ],
        'instructions': 'Take with food',
        'remainingPills': 24,
        'prescribedBy': 'Dr. Sarah Johnson',
        'startDate': DateTime.now().subtract(const Duration(days: 30)),
        'image': 'assets/images/med_lisinopril.jpg',
        'color': Colors.blue.toARGB32(),
      },
      {
        'id': 'm2',
        'name': 'Metformin',
        'dosage': '500mg',
        'type': 'Tablet',
        'frequency': 'Twice Daily',
        'timeOfDay': [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 19, minute: 0),
        ],
        'days': [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ],
        'instructions': 'Take with meals',
        'remainingPills': 42,
        'prescribedBy': 'Dr. Robert Chen',
        'startDate': DateTime.now().subtract(const Duration(days: 60)),
        'image': 'assets/images/med_metformin.jpg',
        'color': Colors.green.toARGB32(),
      },
      {
        'id': 'm3',
        'name': 'Atorvastatin',
        'dosage': '20mg',
        'type': 'Tablet',
        'frequency': 'Daily',
        'timeOfDay': [const TimeOfDay(hour: 20, minute: 30)],
        'days': [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ],
        'instructions': 'Take in the evening',
        'remainingPills': 18,
        'prescribedBy': 'Dr. Sarah Johnson',
        'startDate': DateTime.now().subtract(const Duration(days: 45)),
        'image': 'assets/images/med_atorvastatin.jpg',
        'color': Colors.orange.toARGB32(),
      },
      {
        'id': 'm4',
        'name': 'Albuterol',
        'dosage': '90mcg',
        'type': 'Inhaler',
        'frequency': 'As Needed',
        'timeOfDay': [],
        'days': [],
        'instructions': 'Two puffs as needed for shortness of breath',
        'remainingDoses': 120,
        'prescribedBy': 'Dr. Michael Lee',
        'startDate': DateTime.now().subtract(const Duration(days: 15)),
        'image': 'assets/images/med_albuterol.jpg',
        'color': Colors.red.toARGB32(),
      },
      {
        'id': 'm5',
        'name': 'Levothyroxine',
        'dosage': '75mcg',
        'type': 'Tablet',
        'frequency': 'Daily',
        'timeOfDay': [const TimeOfDay(hour: 7, minute: 0)],
        'days': [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ],
        'instructions': 'Take on empty stomach 30-60 minutes before breakfast',
        'remainingPills': 28,
        'prescribedBy': 'Dr. Patricia Wong',
        'startDate': DateTime.now().subtract(const Duration(days: 90)),
        'image': 'assets/images/med_levothyroxine.jpg',
        'color': Colors.purple.toARGB32(),
      },
    ];

    // Generate today's reminders
    final now = DateTime.now();
    final reminders = [];

    for (var med in medications) {
      if (med['frequency'] != 'As Needed') {
        // Check if today is in the schedule
        final dayName = DateFormat('EEEE').format(now);
        if (med['days'] != null &&
            (med['days'] as List<dynamic>).contains(dayName)) {
          // Add reminders for each time of day
          if (med['timeOfDay'] != null &&
              (med['timeOfDay'] as List).isNotEmpty) {
            final todList = med['timeOfDay'] as List;
            for (var i = 0; i < todList.length; i++) {
              final tod = todList[i] as TimeOfDay;
              final reminderTime =
                  DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
              final status = now.isAfter(reminderTime)
                  ? math.Random().nextBool()
                      ? 'taken'
                      : 'missed'
                  : 'upcoming';

              reminders.add({
                'id': 'r${med['id']}${tod.hour}${tod.minute}',
                'medicationId': med['id'],
                'medicationName': med['name'],
                'dosage': med['dosage'],
                'time': reminderTime,
                'status': status,
                'color': med['color'],
              });
            }
          }
        }
      }
    }

    // Sort reminders by time
    reminders.sort(
        (a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));

    // Generate mock history
    final history = [];
    for (var i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      for (var med in medications) {
        if (med['frequency'] == 'As Needed') continue;

        final dayName = DateFormat('EEEE').format(date);
        if (med['days'] != null &&
            (med['days'] as List<dynamic>).contains(dayName)) {
          if (med['timeOfDay'] != null &&
              (med['timeOfDay'] as List).isNotEmpty) {
            final todList = med['timeOfDay'] as List;
            for (var i = 0; i < todList.length; i++) {
              final tod = todList[i] as TimeOfDay;
              final historyTime = DateTime(
                  date.year, date.month, date.day, tod.hour, tod.minute);

              // Create more realistic history with occasional missed doses
              var status = 'taken';
              if (math.Random().nextInt(10) < 2) {
                // 20% chance of missing
                status = 'missed';
              }

              // Skip future entries
              if (historyTime.isBefore(DateTime.now())) {
                history.add({
                  'id': 'h${med['id']}${historyTime.millisecondsSinceEpoch}',
                  'medicationId': med['id'],
                  'medicationName': med['name'],
                  'dosage': med['dosage'],
                  'time': historyTime,
                  'status': status,
                  'color': med['color'],
                });
              }
            }
          }
        }
      }
    }

    // Sort history by date, most recent first
    history.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    // Generate adherence data
    final adherenceData = [];
    for (var i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayHistory = history
          .where((h) =>
              (h['time'] as DateTime).day == date.day &&
              (h['time'] as DateTime).month == date.month)
          .toList();

      final total = dayHistory.length;
      final taken = dayHistory.where((h) => h['status'] == 'taken').length;

      adherenceData.add({
        'date': date,
        'adherenceRate': total > 0 ? taken / total : 1.0,
      });
    }

    setState(() {
      _medications = medications;
      _filteredMedications = List.from(medications);
      _reminders = List<Map<String, dynamic>>.from(reminders);
      _history = List<Map<String, dynamic>>.from(history);
      _adherenceData = List<Map<String, dynamic>>.from(adherenceData);
      _isLoading = false;
    });
  }

  void _filterMedications(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMedications = List.from(_medications);
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredMedications = _medications
          .where((med) =>
              med['name'].toString().toLowerCase().contains(lowercaseQuery) ||
              med['dosage'].toString().toLowerCase().contains(lowercaseQuery) ||
              med['type'].toString().toLowerCase().contains(lowercaseQuery))
          .toList();
    });
  }

  void _markReminderStatus(Map<String, dynamic> reminder, String status) {
    setState(() {
      reminder['status'] = status;

      // Also update history
      _history.insert(0, {
        'id':
            'h${reminder['medicationId']}${DateTime.now().millisecondsSinceEpoch}',
        'medicationId': reminder['medicationId'],
        'medicationName': reminder['medicationName'],
        'dosage': reminder['dosage'],
        'time': DateTime.now(),
        'status': status,
        'color': reminder['color'],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status == 'taken'
            ? 'Marked ${reminder['medicationName']} as taken!'
            : 'Marked ${reminder['medicationName']} as skipped.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddMedicationBottomSheet() {
    _resetNewMedicationForm();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddMedicationForm(),
    );
  }

  void _resetNewMedicationForm() {
    _medicationNameController.clear();
    _dosageController.clear();
    _instructionsController.clear();
    _selectedFrequency = 'Daily';
    _selectedDays = List.from(_weekdays); // Default to all days
    _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)]; // Default to 8 AM
  }

  Widget _buildAddMedicationForm() {
    return StatefulBuilder(
      builder: (context, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add Medication',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Medication information
                      TextFormField(
                        controller: _medicationNameController,
                        decoration: const InputDecoration(
                          labelText: 'Medication Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter medication name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _dosageController,
                        decoration: const InputDecoration(
                          labelText: 'Dosage (e.g., 10mg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter dosage';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Frequency
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        value: _selectedFrequency,
                        items: ['Daily', 'Twice Daily', 'Weekly', 'As Needed']
                            .map((frequency) => DropdownMenuItem(
                                  value: frequency,
                                  child: Text(frequency),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFrequency = value;

                              // Reset times based on frequency
                              if (value == 'Twice Daily') {
                                _selectedTimes = [
                                  const TimeOfDay(hour: 8, minute: 0),
                                  const TimeOfDay(hour: 20, minute: 0),
                                ];
                              } else if (value == 'Daily') {
                                _selectedTimes = [
                                  const TimeOfDay(hour: 8, minute: 0)
                                ];
                              } else if (value == 'Weekly') {
                                _selectedDays = ['Monday'];
                                _selectedTimes = [
                                  const TimeOfDay(hour: 8, minute: 0)
                                ];
                              } else {
                                _selectedTimes = [];
                                _selectedDays = [];
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Days selection, only show if not "As Needed"
                      if (_selectedFrequency != 'As Needed') ...[
                        const Text(
                          'Days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _weekdays.map((day) {
                            final isSelected = _selectedDays.contains(day);
                            return FilterChip(
                              label: Text(day.substring(0, 3)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedDays.add(day);
                                  } else {
                                    _selectedDays.remove(day);
                                  }
                                });
                              },
                              checkmarkColor: Colors.white,
                              selectedColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Times selection
                        const Text(
                          'Times',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedTimes.asMap().entries.map(
                              (entry) {
                                final index = entry.key;
                                final time = entry.value;
                                return Chip(
                                  label: Text(time.format(context)),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                  onDeleted: _selectedTimes.length > 1
                                      ? () {
                                          setState(() {
                                            _selectedTimes.removeAt(index);
                                          });
                                        }
                                      : null,
                                );
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 16),
                              label: const Text('Add Time'),
                              onPressed: () async {
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (time != null) {
                                  setState(() {
                                    _selectedTimes.add(time);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _instructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Special Instructions',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info_outline),
                          hintText: 'e.g., Take with food',
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Add medication logic
                              setState(() {
                                final newMedicationId =
                                    'm${_medications.length + 1}';

                                final newMedication = {
                                  'id': newMedicationId,
                                  'name': _medicationNameController.text,
                                  'dosage': _dosageController.text,
                                  'type': 'Tablet', // Default
                                  'frequency': _selectedFrequency,
                                  'timeOfDay': _selectedTimes,
                                  'days': _selectedDays,
                                  'instructions': _instructionsController.text,
                                  'remainingPills': 30, // Default
                                  'prescribedBy': 'Self',
                                  'startDate': DateTime.now(),
                                  'color': Colors.primaries[math.Random()
                                          .nextInt(Colors.primaries.length)]
                                      .toARGB32(),
                                };

                                _medications.add(newMedication);
                                _filteredMedications = List.from(_medications);
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added ${_medicationNameController.text} to your medications'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add Medication'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medication Manager')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your medications...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notification settings
            },
            tooltip: 'Medication Reminders',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.medication), text: 'Medications'),
            Tab(icon: Icon(Icons.notifications), text: 'Today'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicationsTab(),
          _buildTodayTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicationBottomSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search medications',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterMedications('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterMedications,
          ),
        ),

        // Medications list
        Expanded(
          child: _filteredMedications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medications found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add medications using the button below',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                  itemCount: _filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = _filteredMedications[index];
                    final color = Color(medication['color']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          // Show medication details
                          _showMedicationDetails(medication);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Medication icon or color indicator
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: color.withValues(
                                          alpha: 26), // Fixed withOpacity
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.medication,
                                        color: color,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Medication info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          medication['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${medication['dosage']} ${medication['type']}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quantity remaining
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        medication.containsKey('remainingPills')
                                            ? '${medication['remainingPills']} left'
                                            : '${medication['remainingDoses']} left',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const Divider(height: 24),

                              // Frequency and schedule
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    medication['frequency'],
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.info_outline,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      medication['instructions'] ??
                                          'No special instructions',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                ),
        ),
      ],
    );
  }

  Widget _buildTodayTab() {
    final now = DateTime.now();
    final upcomingReminders = _reminders
        .where((r) =>
            r['status'] == 'upcoming' && (r['time'] as DateTime).day == now.day)
        .toList();

    final takenReminders = _reminders
        .where((r) =>
            r['status'] == 'taken' && (r['time'] as DateTime).day == now.day)
        .toList();

    final missedReminders = _reminders
        .where((r) =>
            r['status'] == 'missed' && (r['time'] as DateTime).day == now.day)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adherence chart
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Adherence',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: _buildAdherenceChart(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming reminders
          const Text(
            'Upcoming',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          upcomingReminders.isEmpty
              ? _buildEmptyReminderState('No upcoming medications for today')
              : Column(
                  children: upcomingReminders
                      .map((reminder) => _buildReminderCard(reminder))
                      .toList(),
                ),

          const SizedBox(height: 24),

          // Taken reminders
          const Text(
            'Taken',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          takenReminders.isEmpty
              ? _buildEmptyReminderState('No medications taken yet today')
              : Column(
                  children: takenReminders
                      .map((reminder) => _buildReminderCard(reminder))
                      .toList(),
                ),

          const SizedBox(height: 24),

          // Missed reminders
          const Text(
            'Missed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),

          missedReminders.isEmpty
              ? _buildEmptyReminderState('No missed medications today',
                  isError: false)
              : Column(
                  children: missedReminders
                      .map((reminder) => _buildReminderCard(reminder))
                      .toList(),
                ),

          const SizedBox(height: 80), // Extra space at bottom for FAB
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Calendar selector
        Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('View Calendar'),
                  onPressed: () {
                    // Calendar view
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calendar view coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Adherence stats
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor
                .withValues(alpha: 26), // Fixed withOpacity
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAdherenceStat(
                '30-Day',
                '87%',
                const Color(0xFF4CAF50),
              ),
              _buildAdherenceStat(
                '7-Day',
                '92%',
                const Color(0xFF2196F3),
              ),
              _buildAdherenceStat(
                'Yesterday',
                '100%',
                const Color(0xFF9C27B0),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // History entries
        Expanded(
          child: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medication history yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final historyItem = _history[index];
                    final time = historyItem['time'] as DateTime;

                    // Add date headers
                    final bool showHeader = index == 0 ||
                        !_isSameDay(
                            time, _history[index - 1]['time'] as DateTime);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatHistoryDate(time),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],

                        // History item
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Status icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: historyItem['status'] == 'taken'
                                        ? Colors.green.withValues(
                                            alpha: 26) // Fixed withOpacity
                                        : Colors.red.withValues(
                                            alpha: 26), // Fixed withOpacity
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    historyItem['status'] == 'taken'
                                        ? Icons.check
                                        : Icons.close,
                                    color: historyItem['status'] == 'taken'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Medication name and info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        historyItem['medicationName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        historyItem['dosage'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Time
                                Text(
                                  DateFormat('h:mm a').format(time),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final time = reminder['time'] as DateTime;
    final isUpcoming = reminder['status'] == 'upcoming';
    final isTaken = reminder['status'] == 'taken';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: reminder['status'] == 'missed'
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time column
            Column(
              children: [
                Text(
                  DateFormat('h:mm').format(time),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('a').format(time),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Divider
            Container(
              height: 40,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.shade300,
            ),

            // Medication info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['medicationName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    reminder['dosage'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator or action buttons
            if (isUpcoming)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    color: Colors.green,
                    onPressed: () => _markReminderStatus(reminder, 'taken'),
                    tooltip: 'Mark as taken',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    color: Colors.orange,
                    onPressed: () => _markReminderStatus(reminder, 'skipped'),
                    tooltip: 'Skip dose',
                  ),
                ],
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isTaken
                      ? Colors.green.withValues(alpha: 26) // Fixed withOpacity
                      : Colors.red.withValues(alpha: 26), // Fixed withOpacity
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTaken ? Icons.check : Icons.close,
                      size: 16,
                      color: isTaken ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isTaken ? 'Taken' : 'Missed',
                      style: TextStyle(
                        color: isTaken ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReminderState(String message, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 13) // Fixed withOpacity
            : Colors.grey.withValues(alpha: 13), // Fixed withOpacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha: 51) // Fixed withOpacity
              : Colors.grey.withValues(alpha: 51), // Fixed withOpacity
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? Colors.red.shade700 : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildAdherenceChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _adherenceData.length) {
                  final date = _adherenceData[index]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('E').format(date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == 0.5 || value == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(_adherenceData.length, (index) {
          final data = _adherenceData[index];
          final rate = data['adherenceRate'] as double;

          Color barColor;
          if (rate >= 0.8) {
            barColor = Colors.green;
          } else if (rate >= 0.5) {
            barColor = Colors.orange;
          } else {
            barColor = Colors.red;
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: rate,
                color: barColor,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAdherenceStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _showMedicationDetails(Map<String, dynamic> medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(medication['color'])
                                .withValues(alpha: 26), // Fixed withOpacity
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.medication,
                              color: Color(medication['color']),
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${medication['dosage']} ${medication['type']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Medication details
                    _buildDetailRow(
                      'Schedule',
                      medication['frequency'],
                      Icons.schedule,
                    ),

                    if (medication['frequency'] != 'As Needed') ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Days',
                        (medication['days'] as List).join(', '),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Times',
                        (medication['timeOfDay'] as List)
                            .map((tod) => (tod as TimeOfDay).format(context))
                            .join(', '),
                        Icons.access_time,
                      ),
                    ],

                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Prescribed by',
                      medication['prescribedBy'],
                      Icons.person,
                    ),

                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Started on',
                      DateFormat.yMMMd().format(medication['startDate']),
                      Icons.calendar_month,
                    ),

                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Instructions',
                      medication['instructions'] ?? 'No special instructions',
                      Icons.info_outline,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          'Edit',
                          Icons.edit,
                          () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit feature coming soon'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),

                        _buildActionButton(
                          'Delete',
                          Icons.delete,
                          () {
                            Navigator.pop(context);
                            // Show delete confirmation
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Medication?'),
                                content: Text(
                                    'Are you sure you want to delete ${medication['name']}? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _medications.removeWhere((med) =>
                                            med['id'] == medication['id']);
                                        _filteredMedications =
                                            List.from(_medications);
                                        _reminders.removeWhere((rem) =>
                                            rem['medicationId'] ==
                                            medication['id']);
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Deleted ${medication['name']}'),
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {
                                              setState(() {
                                                _medications.add(medication);
                                                _filteredMedications =
                                                    List.from(_medications);
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .primaryColor
                .withValues(alpha: 26), // Fixed withOpacity
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: color ?? Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHistoryDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date); // e.g. "Monday"
    } else {
      return DateFormat('MMMM d, yyyy').format(date); // e.g. "April 15, 2023"
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
