import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class RadiologyExaminationListScreen extends StatefulWidget {
  const RadiologyExaminationListScreen({super.key});

  @override
  _RadiologyExaminationListScreenState createState() =>
      _RadiologyExaminationListScreenState();
}

class _RadiologyExaminationListScreenState
    extends State<RadiologyExaminationListScreen>
    with SingleTickerProviderStateMixin {
  final Dio dio = DioHttpClient().dio;
  bool _isLoading = true;
  String? _error;

  // Tab controller
  late TabController _tabController;

  // Filter and search
  String _searchQuery = '';
  String _selectedPriority = 'All';
  String _selectedType = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _priorities = ['All', 'Urgent', 'High', 'Routine'];
  final List<String> _types = [
    'All',
    'X-Ray',
    'CT Scan',
    'MRI',
    'Ultrasound',
    'Mammography'
  ];

  // Examination data
  List<Map<String, dynamic>> _pendingExaminations = [];
  List<Map<String, dynamic>> _completedExaminations = [];
  List<Map<String, dynamic>> _filteredPending = [];
  List<Map<String, dynamic>> _filteredCompleted = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Apply filters when tab changes
      applyFilters();
    });
    _loadExaminations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExaminations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // In a real app, you would fetch this data from your API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for examinations
      setState(() {
        _pendingExaminations = [
          {
            "id": "e1",
            "patientName": "Ahmed Ben Ali",
            "patientId": "P10045",
            "age": 45,
            "gender": "Male",
            "type": "X-Ray",
            "bodyPart": "Chest",
            "requestingDoctor": "Dr. Jane Smith",
            "priority": "urgent",
            "requestedAt": "2025-04-25T10:30:00",
            "scheduledFor": "2025-04-26T14:15:00",
            "clinicalInfo": "Suspected pneumonia, persistent cough for 2 weeks"
          },
          {
            "id": "e2",
            "patientName": "Fatma Bouazizi",
            "patientId": "P10236",
            "age": 67,
            "gender": "Female",
            "type": "MRI",
            "bodyPart": "Brain",
            "requestingDoctor": "Dr. Mohamed Ben Salem",
            "priority": "routine",
            "requestedAt": "2025-04-24T15:45:00",
            "scheduledFor": "2025-04-27T09:00:00",
            "clinicalInfo":
                "Recurring headaches, evaluation for potential vascular abnormalities"
          },
          {
            "id": "e3",
            "patientName": "Youssef Trabelsi",
            "patientId": "P10198",
            "age": 32,
            "gender": "Male",
            "type": "CT Scan",
            "bodyPart": "Abdomen",
            "requestingDoctor": "Dr. Ahmed Khelifi",
            "priority": "high",
            "requestedAt": "2025-04-25T09:15:00",
            "scheduledFor": "2025-04-26T16:30:00",
            "clinicalInfo": "Abdominal pain, suspected appendicitis"
          },
          {
            "id": "e4",
            "patientName": "Leila Ben Salah",
            "patientId": "P10387",
            "age": 58,
            "gender": "Female",
            "type": "Ultrasound",
            "bodyPart": "Thyroid",
            "requestingDoctor": "Dr. Fatma Bouazizi",
            "priority": "routine",
            "requestedAt": "2025-04-23T14:00:00",
            "scheduledFor": "2025-04-28T11:45:00",
            "clinicalInfo":
                "Enlarged thyroid, follow-up from previous abnormal bloodwork"
          },
          {
            "id": "e5",
            "patientName": "Omar Ghanmi",
            "patientId": "P10412",
            "age": 8,
            "gender": "Male",
            "type": "X-Ray",
            "bodyPart": "Right arm",
            "requestingDoctor": "Dr. Leila Trabelsi",
            "priority": "urgent",
            "requestedAt": "2025-04-25T16:30:00",
            "scheduledFor": "2025-04-26T09:30:00",
            "clinicalInfo": "Suspected fracture after falling while playing"
          }
        ];

        _completedExaminations = [
          {
            "id": "e6",
            "patientName": "Sami Belhadj",
            "patientId": "P10128",
            "age": 52,
            "gender": "Male",
            "type": "CT Scan",
            "bodyPart": "Chest",
            "requestingDoctor": "Dr. Jane Smith",
            "completedAt": "2025-04-25T14:30:00",
            "diagnosis": "No evidence of pulmonary embolism",
            "status": "finalized"
          },
          {
            "id": "e7",
            "patientName": "Amina Sahli",
            "patientId": "P10189",
            "age": 35,
            "gender": "Female",
            "type": "MRI",
            "bodyPart": "Knee",
            "requestingDoctor": "Dr. Mohamed Ben Salem",
            "completedAt": "2025-04-25T11:15:00",
            "diagnosis": "Meniscal tear, grade II",
            "status": "finalized"
          },
          {
            "id": "e8",
            "patientName": "Karim Neji",
            "patientId": "P10256",
            "age": 41,
            "gender": "Male",
            "type": "X-Ray",
            "bodyPart": "Lumbar spine",
            "requestingDoctor": "Dr. Ahmed Khelifi",
            "completedAt": "2025-04-24T16:45:00",
            "diagnosis": "Degenerative changes at L4-L5",
            "status": "preliminary"
          },
          {
            "id": "e9",
            "patientName": "Maria González",
            "patientId": "P10567",
            "age": 29,
            "gender": "Female",
            "type": "Ultrasound",
            "bodyPart": "Pelvis",
            "requestingDoctor": "Dr. Fatma Bouazizi",
            "completedAt": "2025-04-23T09:30:00",
            "diagnosis": "Normal study, no abnormalities detected",
            "status": "finalized"
          },
          {
            "id": "e10",
            "patientName": "Mohamed Abidi",
            "patientId": "P10347",
            "age": 62,
            "gender": "Male",
            "type": "X-Ray",
            "bodyPart": "Chest",
            "requestingDoctor": "Dr. Ahmed Khelifi",
            "completedAt": "2025-04-22T15:45:00",
            "diagnosis":
                "Possible small right lower lobe infiltrate, clinical correlation recommended",
            "status": "preliminary"
          }
        ];

        // Initialize filtered lists
        _filteredPending = List.from(_pendingExaminations);
        _filteredCompleted = List.from(_completedExaminations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      _filteredPending = _pendingExaminations.where((examination) {
        // Filter by search query
        final nameMatches = examination['patientName']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final idMatches = examination['patientId']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final bodyPartMatches = examination['bodyPart']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final doctorMatches = examination['requestingDoctor']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final matchesSearch = _searchQuery.isEmpty ||
            nameMatches ||
            idMatches ||
            bodyPartMatches ||
            doctorMatches;

        // Filter by priority
        final matchesPriority = _selectedPriority == 'All' ||
            examination['priority'] == _selectedPriority.toLowerCase();

        // Filter by type
        final matchesType =
            _selectedType == 'All' || examination['type'] == _selectedType;

        // Filter by date range
        bool matchesDateRange = true;
        if (_startDate != null || _endDate != null) {
          final examinationDate = DateTime.parse(examination['scheduledFor']);

          if (_startDate != null && examinationDate.isBefore(_startDate!)) {
            matchesDateRange = false;
          }

          if (_endDate != null) {
            // Add 1 day to make it inclusive
            final endDatePlusOne = _endDate!.add(const Duration(days: 1));
            if (examinationDate.isAfter(endDatePlusOne)) {
              matchesDateRange = false;
            }
          }
        }

        return matchesSearch &&
            matchesPriority &&
            matchesType &&
            matchesDateRange;
      }).toList();

      _filteredCompleted = _completedExaminations.where((examination) {
        // Filter by search query
        final nameMatches = examination['patientName']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final idMatches = examination['patientId']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final bodyPartMatches = examination['bodyPart']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final doctorMatches = examination['requestingDoctor']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final matchesSearch = _searchQuery.isEmpty ||
            nameMatches ||
            idMatches ||
            bodyPartMatches ||
            doctorMatches;

        // Filter by type
        final matchesType =
            _selectedType == 'All' || examination['type'] == _selectedType;

        // Filter by date range
        bool matchesDateRange = true;
        if (_startDate != null || _endDate != null) {
          final examinationDate = DateTime.parse(examination['completedAt']);

          if (_startDate != null && examinationDate.isBefore(_startDate!)) {
            matchesDateRange = false;
          }

          if (_endDate != null) {
            // Add 1 day to make it inclusive
            final endDatePlusOne = _endDate!.add(const Duration(days: 1));
            if (examinationDate.isAfter(endDatePlusOne)) {
              matchesDateRange = false;
            }
          }
        }

        return matchesSearch && matchesType && matchesDateRange;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examinations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPendingExaminations(),
                          _buildCompletedExaminations(),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          // Navigate to add examination screen or show dialog
          _showAddExaminationDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadExaminations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            applyFilters();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search examinations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      applyFilters();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPendingExaminations() {
    if (_filteredPending.isEmpty) {
      return _buildEmptyState(
        'No pending examinations found',
        'Try adjusting your filters or search query',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPending.length,
      itemBuilder: (context, index) {
        final examination = _filteredPending[index];
        final priority = examination['priority'] as String;
        Color priorityColor;

        switch (priority) {
          case 'urgent':
            priorityColor = Colors.red;
            break;
          case 'high':
            priorityColor = Colors.orange;
            break;
          default:
            priorityColor = Colors.green;
        }

        final scheduledDate = DateTime.parse(examination['scheduledFor']);
        final formattedDate = DateFormat('MMM d, yyyy').format(scheduledDate);
        final formattedTime = DateFormat('h:mm a').format(scheduledDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: priorityColor.withOpacity(0.3),
              width: priority == 'urgent' ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        priority == 'urgent'
                            ? Icons.priority_high
                            : (priority == 'high'
                                ? Icons.arrow_upward
                                : Icons.arrow_forward),
                        color: priorityColor,
                        size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${priority.toUpperCase()} PRIORITY',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  '${examination['type']} - ${examination['bodyPart']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        'Patient: ${examination['patientName']} (${examination['age']}${examination['gender'] == 'Male' ? 'M' : 'F'})'),
                    const SizedBox(height: 2),
                    Text('ID: ${examination['patientId']}'),
                    const SizedBox(height: 2),
                    Text('Requested by: ${examination['requestingDoctor']}'),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '$formattedDate at $formattedTime',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
              const Divider(height: 1),
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // View details
                      context
                          .push('/radiology-examination/${examination['id']}');
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Create report
                      context.push('/create-report/${examination['id']}');
                    },
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Create Report'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedExaminations() {
    if (_filteredCompleted.isEmpty) {
      return _buildEmptyState(
        'No completed examinations found',
        'Try adjusting your filters or search query',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCompleted.length,
      itemBuilder: (context, index) {
        final examination = _filteredCompleted[index];
        final status = examination['status'] as String;
        final isFinalized = status == 'finalized';

        final completedDate = DateTime.parse(examination['completedAt']);
        final formattedDate = DateFormat('MMM d, yyyy').format(completedDate);
        final formattedTime = DateFormat('h:mm a').format(completedDate);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isFinalized
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFinalized ? Icons.check_circle : Icons.pending_actions,
                      color: isFinalized ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFinalized ? 'FINALIZED' : 'PRELIMINARY',
                      style: TextStyle(
                        color: isFinalized ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  '${examination['type']} - ${examination['bodyPart']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        'Patient: ${examination['patientName']} (${examination['age']}${examination['gender'] == 'Male' ? 'M' : 'F'})'),
                    const SizedBox(height: 2),
                    Text('ID: ${examination['patientId']}'),
                    const SizedBox(height: 2),
                    Text('Diagnosis: ${examination['diagnosis']}'),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '$formattedDate at $formattedTime',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
              const Divider(height: 1),
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // View examination
                      context
                          .push('/radiology-examination/${examination['id']}');
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Examination'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // View report
                      context.push('/radiology-report/${examination['id']}');
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('View Report'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty ||
              _selectedPriority != 'All' ||
              _selectedType != 'All' ||
              _startDate != null ||
              _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedPriority = 'All';
                    _selectedType = 'All';
                    _startDate = null;
                    _endDate = null;
                    applyFilters();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Filters'),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Examinations'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_tabController.index == 0) ...[
                    const Text('Priority'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _priorities.map((priority) {
                        return ChoiceChip(
                          label: Text(priority),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Examination Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _types.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedType = type;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Date Range'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              _startDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                  : 'Select',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              _endDate != null
                                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                  : 'Select',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                  setState(() {
                    _selectedPriority = 'All';
                    _selectedType = 'All';
                    _startDate = null;
                    _endDate = null;
                    applyFilters();
                  });
                },
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                  applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddExaminationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Examination'),
        content: const SingleChildScrollView(
          child: Text(
            'To add an examination, please coordinate with the requesting physician to enter the patient information and clinical details.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              // Navigate to the form to add examination
              // In a real app, you would navigate to a form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Manually'),
          ),
        ],
      ),
    );
  }

  // This method would get examination data from the API
  // Future<Map<String, dynamic>> _getExaminationById(String id) async {
  //   try {
  //     final response = await dio.get('${Config.apiUrl}/examinations/$id');
  //     return response.data;
  //   } catch (e) {
  //     throw Exception('Failed to load examination: $e');
  //   }
  // }
}
