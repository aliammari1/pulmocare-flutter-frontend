import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:dio/dio.dart';

class RadiologyExaminationList extends StatefulWidget {
  const RadiologyExaminationList({super.key});

  @override
  _RadiologyExaminationListState createState() =>
      _RadiologyExaminationListState();
}

class _RadiologyExaminationListState extends State<RadiologyExaminationList> {
  final Dio dio = DioHttpClient().dio;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _examinations = [];
  String _filterStatus = 'all';
  String _searchQuery = '';
  String _sortBy = 'scheduledFor';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadExaminations();
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
        _examinations = [
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
            "status": "scheduled",
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
            "status": "pending",
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
            "status": "in-progress",
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
            "status": "scheduled",
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
            "status": "pending",
            "requestedAt": "2025-04-25T16:30:00",
            "scheduledFor": "2025-04-26T09:30:00",
            "clinicalInfo": "Suspected fracture after falling while playing"
          },
          {
            "id": "e6",
            "patientName": "Sami Belhadj",
            "patientId": "P10128",
            "age": 52,
            "gender": "Male",
            "type": "CT Scan",
            "bodyPart": "Chest",
            "requestingDoctor": "Dr. Jane Smith",
            "priority": "high",
            "status": "completed",
            "requestedAt": "2025-04-22T08:30:00",
            "scheduledFor": "2025-04-25T14:30:00",
            "completedAt": "2025-04-25T14:30:00",
            "diagnosis": "No evidence of pulmonary embolism"
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
            "priority": "routine",
            "status": "completed",
            "requestedAt": "2025-04-20T11:15:00",
            "scheduledFor": "2025-04-25T11:15:00",
            "completedAt": "2025-04-25T11:15:00",
            "diagnosis": "Meniscal tear, grade II"
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
            "priority": "high",
            "status": "completed",
            "requestedAt": "2025-04-20T10:45:00",
            "scheduledFor": "2025-04-24T16:45:00",
            "completedAt": "2025-04-24T16:45:00",
            "diagnosis": "Degenerative changes at L4-L5"
          }
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredExaminations() {
    // Filter by status
    List<Map<String, dynamic>> filteredList = _filterStatus == 'all'
        ? _examinations
        : _examinations.where((e) => e['status'] == _filterStatus).toList();

    // Filter by search query (patient name, id, or examination type)
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((e) {
        final patientName = e['patientName'].toString().toLowerCase();
        final patientId = e['patientId'].toString().toLowerCase();
        final examinationType = e['type'].toString().toLowerCase();
        final bodyPart = e['bodyPart'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        return patientName.contains(query) ||
            patientId.contains(query) ||
            examinationType.contains(query) ||
            bodyPart.contains(query);
      }).toList();
    }

    // Sort the list
    filteredList.sort((a, b) {
      var aValue = a[_sortBy];
      var bValue = b[_sortBy];

      // Handle date comparison
      if (_sortBy == 'scheduledFor' || _sortBy == 'requestedAt') {
        aValue = DateTime.parse(aValue);
        bValue = DateTime.parse(bValue);
      }

      int comparison;
      if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = 0;
      }

      return _isAscending ? comparison : -comparison;
    });

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radiology Examinations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create/schedule new examination
          context.push('/schedule-examination');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
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
            onPressed: _loadExaminations,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final filteredExaminations = _getFilteredExaminations();

    return Column(
      children: [
        _buildSearchBar(),
        _buildStatusFilter(),
        Expanded(
          child: filteredExaminations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No examinations found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : _buildExaminationsList(filteredExaminations),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search patient name, ID, type...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Pending', 'pending'),
          _buildFilterChip('Scheduled', 'scheduled'),
          _buildFilterChip('In Progress', 'in-progress'),
          _buildFilterChip('Completed', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? value : 'all';
          });
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildExaminationsList(List<Map<String, dynamic>> examinations) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: examinations.length,
      itemBuilder: (context, index) {
        final examination = examinations[index];
        return _buildExaminationCard(examination);
      },
    );
  }

  Widget _buildExaminationCard(Map<String, dynamic> examination) {
    final status = examination['status'] as String;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        statusIcon = Icons.calendar_today;
        break;
      case 'in-progress':
        statusColor = Colors.purple;
        statusIcon = Icons.loop;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    final scheduledDate = DateTime.parse(examination['scheduledFor']);
    final formattedDate = DateFormat('MMM d, yyyy').format(scheduledDate);
    final formattedTime = DateFormat('h:mm a').format(scheduledDate);

    return Slidable(
      key: ValueKey(examination['id']),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              // Navigate to edit examination details
              context.push('/edit-examination/${examination['id']}');
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              // Show confirmation dialog before cancelling
              _showCancelExaminationDialog(examination['id']);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Cancel',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: examination['priority'] == 'urgent'
                ? Colors.red
                : Colors.transparent,
            width: examination['priority'] == 'urgent' ? 2 : 0,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildLeadingIcon(examination),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${examination['type']} - ${examination['bodyPart']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(examination['priority']),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${examination['patientName']} (ID: ${examination['patientId']})',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.healing, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Dr: ${examination['requestingDoctor']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$formattedDate at $formattedTime',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            // Navigate to examination details
            context.push('/radiology-examination/${examination['id']}');
          },
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(Map<String, dynamic> examination) {
    final type = examination['type'];
    IconData typeIcon;

    switch (type.toLowerCase()) {
      case 'x-ray':
        typeIcon = Icons.broken_image;
        break;
      case 'ct scan':
        typeIcon = Icons.view_in_ar;
        break;
      case 'mri':
        typeIcon = Icons.panorama;
        break;
      case 'ultrasound':
        typeIcon = Icons.waves;
        break;
      case 'mammography':
        typeIcon = Icons.scatter_plot;
        break;
      default:
        typeIcon = Icons.medical_services;
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor:
          _getPriorityColor(examination['priority']).withOpacity(0.2),
      child: Icon(
        typeIcon,
        color: _getPriorityColor(examination['priority']),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final Color color = _getPriorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'routine':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Examinations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChipForDialog('All', 'all', setState),
                      _buildFilterChipForDialog('Pending', 'pending', setState),
                      _buildFilterChipForDialog(
                          'Scheduled', 'scheduled', setState),
                      _buildFilterChipForDialog(
                          'In Progress', 'in-progress', setState),
                      _buildFilterChipForDialog(
                          'Completed', 'completed', setState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.pop();
                          this.setState(() {
                            _filterStatus = 'all';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChipForDialog(
      String label, String value, StateSetter setModalState) {
    final isSelected = _filterStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          _filterStatus = selected ? value : 'all';
        });
        setState(() {
          _filterStatus = selected ? value : 'all';
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSortOption(
                    'Scheduled Date',
                    'scheduledFor',
                    setState,
                  ),
                  _buildSortOption(
                    'Patient Name',
                    'patientName',
                    setState,
                  ),
                  _buildSortOption(
                    'Request Date',
                    'requestedAt',
                    setState,
                  ),
                  _buildSortOption(
                    'Priority',
                    'priority',
                    setState,
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Order:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ChoiceChip(
                        label: const Text('Ascending'),
                        selected: _isAscending,
                        onSelected: (selected) {
                          setState(() {
                            _isAscending = true;
                          });
                          this.setState(() {
                            _isAscending = true;
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _isAscending
                              ? AppTheme.primaryColor
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Descending'),
                        selected: !_isAscending,
                        onSelected: (selected) {
                          setState(() {
                            _isAscending = false;
                          });
                          this.setState(() {
                            _isAscending = false;
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: !_isAscending
                              ? AppTheme.primaryColor
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.pop();
                          this.setState(() {
                            _sortBy = 'scheduledFor';
                            _isAscending = true;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
      String label, String value, StateSetter setModalState) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _sortBy,
      onChanged: (newValue) {
        setModalState(() {
          _sortBy = newValue!;
        });
        setState(() {
          _sortBy = newValue!;
        });
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showCancelExaminationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Examination'),
        content: const Text(
          'Are you sure you want to cancel this examination? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you would call an API to cancel the examination
              context.pop();
              _showSnackBar('Examination cancelled successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
