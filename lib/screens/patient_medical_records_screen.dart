import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PatientMedicalRecordsScreen extends StatefulWidget {
  const PatientMedicalRecordsScreen({super.key});

  @override
  _PatientMedicalRecordsScreenState createState() =>
      _PatientMedicalRecordsScreenState();
}

class _PatientMedicalRecordsScreenState
    extends State<PatientMedicalRecordsScreen> with TickerProviderStateMixin {
  final Dio dio = DioHttpClient().dio;
  bool _isLoading = true;
  String? _error;

  // Medical record data
  List<Map<String, dynamic>> _consultations = [];
  List<Map<String, dynamic>> _radiologyRecords = [];
  List<Map<String, dynamic>> _labTests = [];
  List<Map<String, dynamic>> _allRecords = [];

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMedicalRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // In a real app, you would fetch this data from your API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for medical records
      final mockConsultations = [
        {
          "id": "c1",
          "date": "2025-04-15",
          "doctorName": "Dr. Ahmed Khelifi",
          "specialty": "Dermatology",
          "diagnosis": "Contact Dermatitis",
          "symptoms": "Skin rash, itching, redness",
          "treatment": "Topical corticosteroid cream, antihistamines",
          "notes": "Follow up in 2 weeks if symptoms persist",
          "type": "consultation"
        },
        {
          "id": "c2",
          "date": "2025-03-22",
          "doctorName": "Dr. Jane Smith",
          "specialty": "Cardiology",
          "diagnosis": "Mild hypertension",
          "symptoms": "Occasional headaches, dizziness",
          "treatment": "Lifestyle modifications, diet changes",
          "notes": "Monitor blood pressure weekly",
          "type": "consultation"
        },
        {
          "id": "c3",
          "date": "2025-02-10",
          "doctorName": "Dr. Mohamed Ben Salem",
          "specialty": "Orthopedic Surgery",
          "diagnosis": "Ankle sprain",
          "symptoms": "Pain, swelling, difficulty walking",
          "treatment": "RICE protocol, pain relievers, ankle brace",
          "notes": "Physical therapy recommended",
          "type": "consultation"
        },
      ];

      final mockRadiologyRecords = [
        {
          "id": "r1",
          "date": "2025-04-18",
          "type": "X-Ray",
          "bodyPart": "Chest",
          "radiologistName": "Dr. Fatma Bouazizi",
          "requestedBy": "Dr. Leila Trabelsi",
          "findings": "No abnormalities detected",
          "conclusion": "Normal chest X-ray",
          "status": "Completed",
          "type": "radiology"
        },
        {
          "id": "r2",
          "date": "2025-03-05",
          "type": "MRI",
          "bodyPart": "Knee",
          "radiologistName": "Dr. Ahmed Khelifi",
          "requestedBy": "Dr. Mohamed Ben Salem",
          "findings": "Mild meniscal tear, no ligament damage",
          "conclusion": "Grade II meniscal tear",
          "status": "Completed",
          "type": "radiology"
        },
        {
          "id": "r3",
          "date": "2025-01-20",
          "type": "Ultrasound",
          "bodyPart": "Abdomen",
          "radiologistName": "Dr. Fatma Bouazizi",
          "requestedBy": "Dr. Jane Smith",
          "findings": "Normal liver, spleen, and pancreas appearance",
          "conclusion": "Normal abdominal ultrasound",
          "status": "Completed",
          "type": "radiology"
        },
      ];

      final mockLabTests = [
        {
          "id": "l1",
          "date": "2025-04-20",
          "type": "Blood Test",
          "requestedBy": "Dr. Ahmed Khelifi",
          "results": [
            {
              "name": "Hemoglobin",
              "value": "14.2 g/dL",
              "range": "13.5-17.5 g/dL",
              "status": "normal"
            },
            {
              "name": "White Blood Cells",
              "value": "7.5 x10^9/L",
              "range": "4.5-11.0 x10^9/L",
              "status": "normal"
            },
            {
              "name": "Platelets",
              "value": "250 x10^9/L",
              "range": "150-450 x10^9/L",
              "status": "normal"
            }
          ],
          "interpretation": "Normal complete blood count",
          "type": "lab"
        },
        {
          "id": "l2",
          "date": "2025-03-15",
          "type": "Lipid Panel",
          "requestedBy": "Dr. Jane Smith",
          "results": [
            {
              "name": "Total Cholesterol",
              "value": "195 mg/dL",
              "range": "<200 mg/dL",
              "status": "normal"
            },
            {
              "name": "LDL",
              "value": "130 mg/dL",
              "range": "<130 mg/dL",
              "status": "borderline"
            },
            {
              "name": "HDL",
              "value": "50 mg/dL",
              "range": ">40 mg/dL",
              "status": "normal"
            },
            {
              "name": "Triglycerides",
              "value": "140 mg/dL",
              "range": "<150 mg/dL",
              "status": "normal"
            }
          ],
          "interpretation":
              "Borderline LDL levels, otherwise normal lipid profile",
          "type": "lab"
        },
        {
          "id": "l3",
          "date": "2025-02-05",
          "type": "Urinalysis",
          "requestedBy": "Dr. Leila Trabelsi",
          "results": [
            {
              "name": "pH",
              "value": "6.0",
              "range": "4.5-8.0",
              "status": "normal"
            },
            {
              "name": "Protein",
              "value": "Negative",
              "range": "Negative",
              "status": "normal"
            },
            {
              "name": "Glucose",
              "value": "Negative",
              "range": "Negative",
              "status": "normal"
            }
          ],
          "interpretation": "Normal urinalysis results",
          "type": "lab"
        },
      ];

      // Combine all records for the "All" tab
      final allRecords = [
        ...mockConsultations,
        ...mockRadiologyRecords,
        ...mockLabTests
      ];

      // Sort all records by date (newest first)
      allRecords.sort((a, b) => DateTime.parse(b['date'] as String)
          .compareTo(DateTime.parse(a['date'] as String)));

      setState(() {
        _consultations = mockConsultations;
        _radiologyRecords = mockRadiologyRecords;
        _labTests = mockLabTests;
        _allRecords = allRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredRecords() {
    final currentTab = _tabController.index;
    List<Map<String, dynamic>> records;

    switch (currentTab) {
      case 0:
        records = _allRecords;
        break;
      case 1:
        records = _consultations;
        break;
      case 2:
        records = _radiologyRecords;
        break;
      case 3:
        records = _labTests;
        break;
      default:
        records = _allRecords;
    }

    if (_searchQuery.isEmpty) {
      return records;
    }

    return records.where((record) {
      // Search by doctor/radiologist name
      final doctorName = record['doctorName'] ??
          record['radiologistName'] ??
          record['requestedBy'] ??
          '';
      final doctorMatches =
          doctorName.toLowerCase().contains(_searchQuery.toLowerCase());

      // Search by diagnosis/findings
      final diagnosis =
          record['diagnosis'] ?? record['findings'] ?? record['type'] ?? '';
      final diagnosisMatches =
          diagnosis.toLowerCase().contains(_searchQuery.toLowerCase());

      // Search by date
      final dateMatches =
          record['date'].toLowerCase().contains(_searchQuery.toLowerCase());

      return doctorMatches || diagnosisMatches || dateMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Records'),
            Tab(text: 'Consultations'),
            Tab(text: 'Radiology'),
            Tab(text: 'Lab Tests'),
          ],
          onTap: (_) {
            setState(() {});
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildMedicalRecordsView(),
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
            onPressed: _loadMedicalRecords,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsView() {
    final filteredRecords = _getFilteredRecords();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: filteredRecords.isEmpty
              ? _buildEmptyState()
              : _buildRecordsList(filteredRecords),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search medical records...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;

    switch (_tabController.index) {
      case 0:
        message = 'No medical records found';
        break;
      case 1:
        message = 'No consultation records found';
        break;
      case 2:
        message = 'No radiology records found';
        break;
      case 3:
        message = 'No lab test results found';
        break;
      default:
        message = 'No records found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_information,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Your medical records will appear here',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _searchQuery.isNotEmpty
              ? OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Search'),
                )
              : OutlinedButton.icon(
                  onPressed: _loadMedicalRecords,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<Map<String, dynamic>> records) {
    final groupedRecords = _groupRecordsByMonth(records);
    final sortedMonths = groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedMonths.length,
      itemBuilder: (context, monthIndex) {
        final month = sortedMonths[monthIndex];
        final monthRecords = groupedRecords[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _formatMonthYear(month),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthRecords.length,
              itemBuilder: (context, recordIndex) {
                final record = monthRecords[recordIndex];
                final isFirst = recordIndex == 0;
                final isLast = recordIndex == monthRecords.length - 1;

                return _buildTimelineItem(record, isFirst, isLast);
              },
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupRecordsByMonth(
      List<Map<String, dynamic>> records) {
    final groupedRecords = <DateTime, List<Map<String, dynamic>>>{};

    for (var record in records) {
      final date = DateTime.parse(record['date']);
      final monthStart = DateTime(date.year, date.month, 1);

      if (groupedRecords[monthStart] == null) {
        groupedRecords[monthStart] = [];
      }

      groupedRecords[monthStart]!.add(record);
    }

    // Sort records within each month by date (newest first)
    groupedRecords.forEach((month, records) {
      records.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    });

    return groupedRecords;
  }

  String _formatMonthYear(DateTime date) {
    final formatter = DateFormat('MMMM yyyy');
    return formatter.format(date);
  }

  Widget _buildTimelineItem(
      Map<String, dynamic> record, bool isFirst, bool isLast) {
    final recordType = record['type'];
    IconData icon;
    Color color;

    switch (recordType) {
      case 'consultation':
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'radiology':
        icon = Icons.image;
        color = Colors.purple;
        break;
      case 'lab':
        icon = Icons.science;
        color = Colors.teal;
        break;
      default:
        icon = Icons.folder;
        color = Colors.grey;
    }

    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 30,
        height: 30,
        indicator: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: color,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.grey.withOpacity(0.4),
        thickness: 1.5,
      ),
      afterLineStyle: LineStyle(
        color: Colors.grey.withOpacity(0.4),
        thickness: 1.5,
      ),
      endChild: _buildRecordCard(record),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final date = DateTime.parse(record['date']);
    final formattedDate = DateFormat.yMMMd().format(date);
    final recordType = record['type'];

    Widget cardContent;
    String title;
    String subtitle;

    switch (recordType) {
      case 'consultation':
        title = 'Consultation - ${record['specialty']}';
        subtitle = record['diagnosis'];
        cardContent = _buildConsultationContent(record);
        break;
      case 'radiology':
        title = '${record['type']} - ${record['bodyPart']}';
        subtitle = record['conclusion'];
        cardContent = _buildRadiologyContent(record);
        break;
      case 'lab':
        title = record['type'];
        subtitle = record['interpretation'];
        cardContent = _buildLabTestContent(record);
        break;
      default:
        title = 'Medical Record';
        subtitle = '';
        cardContent = const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showRecordDetailDialog(record);
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              cardContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationContent(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Doctor: ${record['doctorName']}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.healing,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Treatment: ${record['treatment']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadiologyContent(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Radiologist: ${record['radiologistName']}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.medical_services,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Requested by: ${record['requestedBy']}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabTestContent(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Requested by: ${record['requestedBy']}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(record['results'] as List).length} Results',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showRecordDetailDialog(Map<String, dynamic> record) {
    final recordType = record['type'];
    String title;

    switch (recordType) {
      case 'consultation':
        title = 'Consultation Details';
        break;
      case 'radiology':
        title = 'Radiology Examination Details';
        break;
      case 'lab':
        title = 'Lab Test Results';
        break;
      default:
        title = 'Medical Record Details';
    }

    final date = DateTime.parse(record['date']);
    final formattedDate = DateFormat.yMMMMd().format(date);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $formattedDate',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailContent(record),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> record) {
    final recordType = record['type'];

    switch (recordType) {
      case 'consultation':
        return _buildConsultationDetails(record);
      case 'radiology':
        return _buildRadiologyDetails(record);
      case 'lab':
        return _buildLabTestDetails(record);
      default:
        return const Text('No details available');
    }
  }

  Widget _buildConsultationDetails(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Doctor', record['doctorName']),
        _buildDetailItem('Specialty', record['specialty']),
        _buildDetailItem('Diagnosis', record['diagnosis']),
        _buildDetailItem('Symptoms', record['symptoms']),
        _buildDetailItem('Treatment', record['treatment']),
        _buildDetailItem('Notes', record['notes']),
      ],
    );
  }

  Widget _buildRadiologyDetails(Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
            'Examination Type', '${record['type']} - ${record['bodyPart']}'),
        _buildDetailItem('Radiologist', record['radiologistName']),
        _buildDetailItem('Requested By', record['requestedBy']),
        _buildDetailItem('Findings', record['findings']),
        _buildDetailItem('Conclusion', record['conclusion']),
        _buildDetailItem('Status', record['status']),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            context.pop();
            context.push('/radiology-image/${record['id']}');
          },
          icon: const Icon(Icons.image),
          label: const Text('View Images'),
        ),
      ],
    );
  }

  Widget _buildLabTestDetails(Map<String, dynamic> record) {
    final results = record['results'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Test Type', record['type']),
        _buildDetailItem('Requested By', record['requestedBy']),
        _buildDetailItem('Interpretation', record['interpretation']),
        const SizedBox(height: 16),
        const Text(
          'Results:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        result['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        result['value'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        result['range'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildStatusIndicator(result['status']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'normal':
        color = Colors.green;
        text = 'Normal';
        break;
      case 'high':
        color = Colors.red;
        text = 'High';
        break;
      case 'low':
        color = Colors.orange;
        text = 'Low';
        break;
      case 'borderline':
        color = Colors.amber;
        text = 'Borderline';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
