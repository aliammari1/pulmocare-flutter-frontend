import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:intl/intl.dart';

class RadiologyReportsScreen extends StatefulWidget {
  const RadiologyReportsScreen({super.key});

  @override
  _RadiologyReportsScreenState createState() => _RadiologyReportsScreenState();
}

class _RadiologyReportsScreenState extends State<RadiologyReportsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _allReports = [];
  List<Map<String, dynamic>> _filteredReports = [];
  late TabController _tabController;

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'date';
  bool _sortAscending = false;

  final List<String> _filterOptions = [
    'All',
    'Finalized',
    'Draft',
    'X-Ray',
    'MRI',
    'CT Scan',
    'Ultrasound'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filterReports();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data - in real app would fetch from API
      await Future.delayed(const Duration(seconds: 1));

      // Sample reports data
      final mockReports = [
        {
          "id": "R-2025042601",
          "examinationId": "e1",
          "patientName": "Ahmed Ben Ali",
          "patientId": "P10045",
          "age": 45,
          "gender": "Male",
          "type": "X-Ray",
          "bodyPart": "Chest",
          "createdAt": "2025-04-26T15:30:00",
          "finalizedAt": "2025-04-26T16:45:00",
          "status": "finalized",
          "findings":
              "The lungs are clear without evidence of focal consolidation, pneumothorax, or pleural effusion. Heart size is normal. Mediastinal contours are unremarkable. No acute osseous abnormality.",
          "impression": "No acute cardiopulmonary findings.",
          "recommendations": "Follow-up as clinically indicated.",
          "requestingDoctor": "Dr. Jane Smith",
        },
        {
          "id": "R-2025042502",
          "examinationId": "e2",
          "patientName": "Fatma Bouazizi",
          "patientId": "P10236",
          "age": 67,
          "gender": "Female",
          "type": "MRI",
          "bodyPart": "Brain",
          "createdAt": "2025-04-25T17:15:00",
          "finalizedAt": "2025-04-25T18:30:00",
          "status": "finalized",
          "findings":
              "No evidence of acute infarction, hemorrhage, or mass effect. Ventricles and sulci are normal in size and configuration. No abnormal enhancement. Age-related white matter changes noted.",
          "impression":
              "Age-related changes without evidence of acute intracranial abnormality.",
          "recommendations": "Clinical follow-up recommended.",
          "requestingDoctor": "Dr. Mohamed Ben Salem",
        },
        {
          "id": "R-2025042503",
          "examinationId": "e3",
          "patientName": "Youssef Trabelsi",
          "patientId": "P10198",
          "age": 32,
          "gender": "Male",
          "type": "CT Scan",
          "bodyPart": "Abdomen",
          "createdAt": "2025-04-25T18:00:00",
          "finalizedAt": null,
          "status": "draft",
          "findings":
              "Preliminary review shows appendix is enlarged and inflamed, measuring approximately 12mm in diameter with surrounding inflammatory changes.",
          "impression": "Findings consistent with acute appendicitis.",
          "recommendations": "Surgical consultation recommended.",
          "requestingDoctor": "Dr. Ahmed Khelifi",
        },
        {
          "id": "R-2025042401",
          "examinationId": "e7",
          "patientName": "Amina Sahli",
          "patientId": "P10189",
          "age": 35,
          "gender": "Female",
          "type": "MRI",
          "bodyPart": "Knee",
          "createdAt": "2025-04-24T12:30:00",
          "finalizedAt": "2025-04-24T14:15:00",
          "status": "finalized",
          "findings":
              "Horizontal tear of the posterior horn of the medial meniscus. The lateral meniscus is intact. ACL and PCL are intact. MCL and LCL are intact. No significant bone marrow edema. Small joint effusion present.",
          "impression":
              "Grade II medial meniscus tear affecting the posterior horn.",
          "recommendations": "Orthopedic consultation recommended.",
          "requestingDoctor": "Dr. Mohamed Ben Salem",
        },
        {
          "id": "R-2025042402",
          "examinationId": "e8",
          "patientName": "Karim Neji",
          "patientId": "P10256",
          "age": 41,
          "gender": "Male",
          "type": "X-Ray",
          "bodyPart": "Lumbar spine",
          "createdAt": "2025-04-24T17:00:00",
          "finalizedAt": null,
          "status": "draft",
          "findings":
              "Mild degenerative changes at L4-L5 with mild disc space narrowing. No acute fracture or dislocation. Normal alignment of the lumbar spine.",
          "impression": "Mild degenerative disc disease at L4-L5.",
          "recommendations":
              "Consider physical therapy. Anti-inflammatory medication as needed.",
          "requestingDoctor": "Dr. Ahmed Khelifi",
        },
        {
          "id": "R-2025042301",
          "examinationId": "e4",
          "patientName": "Leila Ben Salah",
          "patientId": "P10387",
          "age": 58,
          "gender": "Female",
          "type": "Ultrasound",
          "bodyPart": "Thyroid",
          "createdAt": "2025-04-23T16:15:00",
          "finalizedAt": "2025-04-23T17:30:00",
          "status": "finalized",
          "findings":
              "Diffusely enlarged thyroid gland with heterogeneous echotexture. Multiple hypoechoic nodules noted in both lobes, largest measuring 1.2 cm in the right lobe. No suspicious cervical lymphadenopathy.",
          "impression":
              "Multinodular goiter. Right thyroid nodule requires further evaluation.",
          "recommendations":
              "Fine needle aspiration of the dominant right thyroid nodule recommended.",
          "requestingDoctor": "Dr. Fatma Bouazizi",
        },
      ];

      setState(() {
        _allReports = mockReports;
        _filteredReports = List.from(_allReports);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterReports() {
    // Start with all reports
    List<Map<String, dynamic>> filtered = List.from(_allReports);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        return report['patientName']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            report['patientId']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            report['id']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            report['bodyPart']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Finalized') {
        filtered = filtered
            .where((report) => report['status'] == 'finalized')
            .toList();
      } else if (_selectedFilter == 'Draft') {
        filtered =
            filtered.where((report) => report['status'] == 'draft').toList();
      } else {
        // Filter by examination type
        filtered = filtered
            .where((report) => report['type'] == _selectedFilter)
            .toList();
      }
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date':
          final aDate = DateTime.parse(a['createdAt']);
          final bDate = DateTime.parse(b['createdAt']);
          return _sortAscending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        case 'patient':
          return _sortAscending
              ? a['patientName'].compareTo(b['patientName'])
              : b['patientName'].compareTo(a['patientName']);
        case 'type':
          return _sortAscending
              ? a['type'].compareTo(b['type'])
              : b['type'].compareTo(a['type']);
        default:
          return 0;
      }
    });

    setState(() {
      _filteredReports = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radiological Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildReportsContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/radiology-examinations');
        },
        tooltip: 'Create New Report',
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
            onPressed: _loadReports,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
          child: _filteredReports.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = _filteredReports[index];
                    return _buildReportCard(report);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search reports...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'All';
                  _filterReports();
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final createdDate = DateTime.parse(report['createdAt']);
    final isFinalized = report['status'] == 'finalized';
    final finalizedDate =
        isFinalized ? DateTime.parse(report['finalizedAt']) : null;

    Color statusColor = isFinalized ? Colors.green : Colors.amber;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to report details
          context.push('/radiology-report/${report['id']}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                          '${report['type']} - ${report['bodyPart']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Patient: ${report['patientName']} (${report['patientId']})',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      report['status'].toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created: ${DateFormat('MMM d, yyyy - h:mm a').format(createdDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (isFinalized) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Finalized: ${DateFormat('MMM d, yyyy - h:mm a').format(finalizedDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctor: ${report['requestingDoctor']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sort Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    leading: Radio<String>(
                      value: 'date',
                      groupValue: _sortBy,
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: _sortBy == 'date'
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sortBy == 'date') {
                            _sortAscending = !_sortAscending;
                          } else {
                            _sortBy = 'date';
                          }
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Patient Name'),
                    leading: Radio<String>(
                      value: 'patient',
                      groupValue: _sortBy,
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: _sortBy == 'patient'
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sortBy == 'patient') {
                            _sortAscending = !_sortAscending;
                          } else {
                            _sortBy = 'patient';
                          }
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Examination Type'),
                    leading: Radio<String>(
                      value: 'type',
                      groupValue: _sortBy,
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: _sortBy == 'type'
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sortBy == 'type') {
                            _sortAscending = !_sortAscending;
                          } else {
                            _sortBy = 'type';
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                          _filterReports();
                        },
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
}
