import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

class FollowUpSchedulerScreen extends StatefulWidget {
  const FollowUpSchedulerScreen({super.key});

  @override
  _FollowUpSchedulerScreenState createState() =>
      _FollowUpSchedulerScreenState();
}

class _FollowUpSchedulerScreenState extends State<FollowUpSchedulerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  List<Map<String, dynamic>> _scheduledFollowUps = [];

  Map<DateTime, List<Map<String, dynamic>>> _followUpEvents = {};

  String _selectedFilterStatus = 'All';
  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Missed'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Mock data for patients
    _allPatients = [
      {
        'id': 'P001',
        'name': 'Sarah Johnson',
        'age': 42,
        'gender': 'Female',
        'condition': 'Hypertension',
        'lastVisit': '2025-03-15',
        'phone': '(555) 123-4567',
        'status': 'Stable',
      },
      {
        'id': 'P002',
        'name': 'Michael Chen',
        'age': 65,
        'gender': 'Male',
        'condition': 'Type 2 Diabetes',
        'lastVisit': '2025-04-02',
        'phone': '(555) 987-6543',
        'status': 'Monitoring',
      },
      {
        'id': 'P003',
        'name': 'Emily Rodriguez',
        'age': 29,
        'gender': 'Female',
        'condition': 'Asthma',
        'lastVisit': '2025-04-10',
        'phone': '(555) 456-7890',
        'status': 'Stable',
      },
      {
        'id': 'P004',
        'name': 'David Park',
        'age': 58,
        'gender': 'Male',
        'condition': 'Coronary Artery Disease',
        'lastVisit': '2025-03-28',
        'phone': '(555) 789-0123',
        'status': 'Post-procedure',
      },
      {
        'id': 'P005',
        'name': 'Olivia Wilson',
        'age': 37,
        'gender': 'Female',
        'condition': 'Migraine',
        'lastVisit': '2025-04-05',
        'phone': '(555) 234-5678',
        'status': 'Active treatment',
      },
    ];

    _filteredPatients = List.from(_allPatients);

    // Mock data for scheduled follow-ups
    final today = DateTime.now();

    _scheduledFollowUps = [
      {
        'id': 'F001',
        'patientId': 'P001',
        'patientName': 'Sarah Johnson',
        'date': DateTime(today.year, today.month, today.day + 2),
        'time': '10:30 AM',
        'reason': '3-month hypertension check',
        'status': 'Confirmed',
        'notes': 'Check medication efficacy, may need dosage adjustment',
      },
      {
        'id': 'F002',
        'patientId': 'P002',
        'patientName': 'Michael Chen',
        'date': DateTime(today.year, today.month, today.day),
        'time': '2:15 PM',
        'reason': 'Diabetes monitoring',
        'status': 'Confirmed',
        'notes': 'Review latest HbA1c results',
      },
      {
        'id': 'F003',
        'patientId': 'P003',
        'patientName': 'Emily Rodriguez',
        'date': DateTime(today.year, today.month, today.day + 5),
        'time': '11:00 AM',
        'reason': 'Pulmonary function test',
        'status': 'Pending',
        'notes': 'Assess response to new inhaler',
      },
      {
        'id': 'F004',
        'patientId': 'P004',
        'patientName': 'David Park',
        'date': DateTime(today.year, today.month, today.day - 2),
        'time': '9:45 AM',
        'reason': 'Post-stent evaluation',
        'status': 'Completed',
        'notes': 'Review ECG and chest pain status',
      },
      {
        'id': 'F005',
        'patientId': 'P005',
        'patientName': 'Olivia Wilson',
        'date': DateTime(today.year, today.month, today.day + 1),
        'time': '3:30 PM',
        'reason': 'Migraine treatment follow-up',
        'status': 'Confirmed',
        'notes': 'Assess efficacy of new preventive medication',
      },
      {
        'id': 'F006',
        'patientId': 'P001',
        'patientName': 'Sarah Johnson',
        'date': DateTime(today.year, today.month, today.day - 7),
        'time': '1:00 PM',
        'reason': 'Blood pressure check',
        'status': 'Missed',
        'notes': 'Patient did not show up, need to reschedule',
      },
    ];

    // Create events map for calendar
    _followUpEvents = {};
    for (var followUp in _scheduledFollowUps) {
      final date = followUp['date'] as DateTime;
      // Normalize date to remove time component
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (_followUpEvents[normalizedDate] != null) {
        _followUpEvents[normalizedDate]!.add(followUp);
      } else {
        _followUpEvents[normalizedDate] = [followUp];
      }
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _followUpEvents[normalizedDay] ?? [];
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _allPatients
          .where((patient) =>
              patient['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              patient['id']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterFollowUps(String status) {
    setState(() {
      _selectedFilterStatus = status;
    });
  }

  void _showAddFollowUpDialog(BuildContext context,
      {Map<String, dynamic>? patient}) {
    final selectedPatient = patient ?? _allPatients.first;
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedReason = 'Regular check-up';
    String notes = '';

    final reasonOptions = [
      'Regular check-up',
      'Medication review',
      'Test results review',
      'Post-procedure evaluation',
      'Treatment adjustment',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(patient != null
                ? 'Schedule Follow-Up: ${patient['name']}'
                : 'Schedule New Follow-Up'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (patient == null) ...[
                    const Text('Patient:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: selectedPatient,
                      items: _allPatients.map((patient) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: patient,
                          child: Text('${patient['name']} (${patient['id']})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          // Handle patient selection if needed
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Date:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate != null) {
                        setStateDialog(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Time:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (pickedTime != null) {
                        setStateDialog(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        selectedTime.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Reason:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    items: reasonOptions.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedReason = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    maxLines: 3,
                    onChanged: (value) {
                      notes = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Add any additional notes or instructions...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8BC0),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Add the follow-up to the list
                  final newFollowUp = {
                    'id': 'F${_scheduledFollowUps.length + 1}'.padLeft(4, '0'),
                    'patientId': selectedPatient['id'],
                    'patientName': selectedPatient['name'],
                    'date': selectedDate,
                    'time': selectedTime.format(context),
                    'reason': selectedReason,
                    'status': 'Pending',
                    'notes': notes,
                  };

                  setState(() {
                    _scheduledFollowUps.add(newFollowUp);

                    // Update events map for calendar
                    final normalizedDate = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day);
                    if (_followUpEvents[normalizedDate] != null) {
                      _followUpEvents[normalizedDate]!.add(newFollowUp);
                    } else {
                      _followUpEvents[normalizedDate] = [newFollowUp];
                    }
                  });

                  context.pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Follow-up appointment scheduled')),
                  );
                },
                child: const Text('SCHEDULE'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showFollowUpDetails(
      BuildContext context, Map<String, dynamic> followUp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Follow-up: ${followUp['patientName']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Patient ID', followUp['patientId']),
                _buildDetailRow('Date',
                    '${followUp['date'].year}/${followUp['date'].month}/${followUp['date'].day}'),
                _buildDetailRow('Time', followUp['time']),
                _buildDetailRow('Reason', followUp['reason']),
                _buildDetailRow('Status', followUp['status']),
                _buildDetailRow('Notes', followUp['notes']),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Update Status:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Replacing Row with Wrap to prevent overflow
                Wrap(
                  spacing: 8, // horizontal spacing between buttons
                  runSpacing: 8, // vertical spacing between lines
                  children: [
                    _buildStatusButton('Pending', followUp),
                    _buildStatusButton('Confirmed', followUp),
                    _buildStatusButton('Completed', followUp),
                    _buildStatusButton('Missed', followUp),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Add Note',
                    hintText: 'Add a new note about this follow-up...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8BC0),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_noteController.text.isNotEmpty) {
                  // Add note functionality would go here
                  setState(() {
                    followUp['notes'] += '\n${_noteController.text}';
                    _noteController.clear();
                  });

                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note added successfully')),
                  );
                } else {
                  context.pop();
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, Map<String, dynamic> followUp) {
    final isCurrentStatus = followUp['status'] == status;

    Color getStatusColor() {
      switch (status) {
        case 'Pending':
          return Colors.orange;
        case 'Confirmed':
          return Colors.blue;
        case 'Completed':
          return Colors.green;
        case 'Missed':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!isCurrentStatus) {
          setState(() {
            followUp['status'] = status;
          });
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status updated to $status')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isCurrentStatus ? getStatusColor() : Colors.transparent,
          border: Border.all(color: getStatusColor()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isCurrentStatus ? Colors.white : getStatusColor(),
            fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFollowUps() {
    if (_selectedFilterStatus == 'All') {
      return _scheduledFollowUps;
    } else {
      return _scheduledFollowUps
          .where((followUp) => followUp['status'] == _selectedFilterStatus)
          .toList();
    }
  }

  List<Map<String, dynamic>> _getTodaysFollowUps() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    return _scheduledFollowUps.where((followUp) {
      final followUpDate = followUp['date'] as DateTime;
      final normalizedFollowUpDate =
          DateTime(followUpDate.year, followUpDate.month, followUpDate.day);
      return normalizedFollowUpDate.isAtSameMomentAs(normalizedToday);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todaysFollowUps = _getTodaysFollowUps();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: const Text(
          'Follow-Up Scheduler',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'CALENDAR'),
            Tab(text: 'PATIENTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Calendar Tab
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Color(0xFF2E8BC0),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF050A30),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF2E8BC0),
                    shape: BoxShape.circle,
                  ),
                ),
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),

              // Filter bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      'Filter:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions.map((option) {
                            final isSelected = _selectedFilterStatus == option;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(option),
                                selected: isSelected,
                                onSelected: (selected) {
                                  _filterFollowUps(option);
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor:
                                    const Color(0xFF2E8BC0).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF2E8BC0),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF2E8BC0)
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: Color(0xFF2E8BC0)),
                      onPressed: () {
                        _showAddFollowUpDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // Follow-ups list for selected day
              Expanded(
                child: _selectedDay != null
                    ? _buildFollowUpList(_getEventsForDay(_selectedDay!),
                        showDate: false)
                    : const Center(
                        child: Text('Select a day to view follow-ups')),
              ),
            ],
          ),

          // Patients Tab
          Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterPatients,
                        decoration: InputDecoration(
                          hintText: 'Search patients...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Today's follow-ups
              if (todaysFollowUps.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  color: const Color(0xFF050A30),
                  child: Text(
                    "Today's Follow-ups (${todaysFollowUps.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (todaysFollowUps.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: todaysFollowUps.length,
                    itemBuilder: (context, index) {
                      final followUp = todaysFollowUps[index];

                      return Card(
                        margin: const EdgeInsets.only(right: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: followUp['status'] == 'Confirmed'
                                ? Colors.blue
                                : Colors.transparent,
                            width: followUp['status'] == 'Confirmed' ? 2 : 0,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            _showFollowUpDetails(context, followUp);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      followUp['time'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: followUp['status'] == 'Confirmed'
                                            ? Colors.blue
                                            : followUp['status'] == 'Completed'
                                                ? Colors.green
                                                : followUp['status'] == 'Missed'
                                                    ? Colors.red
                                                    : Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        followUp['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  followUp['patientName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  followUp['reason'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Handle call patient action
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Calling patient...')),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(60, 30),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.call,
                                              size: 14,
                                              color: Color(0xFF2E8BC0)),
                                          SizedBox(width: 4),
                                          Text('Call',
                                              style: TextStyle(
                                                  color: Color(0xFF2E8BC0),
                                                  fontSize: 12)),
                                        ],
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

              // Patient list header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                color: const Color(0xFFE5E5E5),
                child: Text(
                  'Patients (${_filteredPatients.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Patient list
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      title: Text(
                        patient['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${patient['age']} years • ${patient['gender']}'),
                          Text(
                            'Last visit: ${patient['lastVisit']} • ${patient['condition']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: OutlinedButton(
                        onPressed: () {
                          _showAddFollowUpDialog(context, patient: patient);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E8BC0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Schedule',
                          style: TextStyle(color: Color(0xFF2E8BC0)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpList(List<Map<String, dynamic>> followUps,
      {bool showDate = true}) {
    final filteredFollowUps = _selectedFilterStatus == 'All'
        ? followUps
        : followUps
            .where((fu) => fu['status'] == _selectedFilterStatus)
            .toList();

    if (filteredFollowUps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_available,
                size: 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilterStatus == 'All'
                    ? 'No follow-ups scheduled for this day'
                    : 'No $_selectedFilterStatus follow-ups for this day',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddFollowUpDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Schedule Follow-up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8BC0),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: filteredFollowUps.length,
      itemBuilder: (context, index) {
        final followUp = filteredFollowUps[index];

        Color getStatusColor() {
          switch (followUp['status']) {
            case 'Pending':
              return Colors.orange;
            case 'Confirmed':
              return Colors.blue;
            case 'Completed':
              return Colors.green;
            case 'Missed':
              return Colors.red;
            default:
              return Colors.grey;
          }
        }

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              _showFollowUpDetails(context, followUp);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            followUp['patientName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (showDate)
                            Text(
                              '${followUp['date'].day}/${followUp['date'].month}/${followUp['date'].year}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          followUp['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        followUp['time'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(followUp['reason']),
                    ],
                  ),
                  if (followUp['notes'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Notes: ${followUp['notes']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // Call patient
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling patient...')),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2E8BC0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Send message to patient
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Messaging feature coming soon')),
                          );
                        },
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Message'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2E8BC0),
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
}
