import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/radiology.dart';
import 'package:medapp/services/doctor_service.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PatientReportsScreen extends StatefulWidget {
  const PatientReportsScreen({super.key});

  @override
  _PatientReportsScreenState createState() => _PatientReportsScreenState();
}

class _PatientReportsScreenState extends State<PatientReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DoctorService _doctorService = DoctorService();

  List<RadiologyReport> _radiologyReports = [];
  List<Map<String, dynamic>> _labReports =
      []; // This would be a proper model in a real app

  bool _isLoadingRadiology = true;
  bool _isLoadingLab = true;
  String? _radiologyError;
  String? _labError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRadiologyReports();
    _loadLabReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRadiologyReports() async {
    try {
      setState(() {
        _isLoadingRadiology = true;
        _radiologyError = null;
      });

      // In a real app, you would load these from your API
      // For now, we'll simulate loading some mock data
      await Future.delayed(const Duration(seconds: 1));

      final reports = [
        RadiologyReport(
          id: '1',
          patientId: 'p123',
          patientName: 'John Doe',
          doctorId: 'd123',
          doctorName: 'Dr. Smith',
          radiologistId: 'r456',
          radiologistName: 'Dr. Jane Wilson',
          date: DateTime.now().subtract(const Duration(days: 7)),
          type: 'X-Ray',
          bodyPart: 'Chest',
          findings: 'No abnormalities detected',
          impression: 'Normal chest X-ray',
          recommendedActions: '',
          urgency: RadiologyUrgency.routine,
          status: RadiologyStatus.completed,
          imageUrls: ['https://example.com/xray1.jpg'],
        ),
        RadiologyReport(
          id: '2',
          patientId: 'p123',
          patientName: 'John Doe',
          doctorId: 'd456',
          doctorName: 'Dr. Johnson',
          radiologistId: 'r789',
          radiologistName: 'Dr. Mike Brown',
          date: DateTime.now().subtract(const Duration(days: 30)),
          type: 'MRI',
          bodyPart: 'Brain',
          findings: 'No evidence of acute intracranial abnormality',
          impression: 'Normal brain MRI',
          recommendedActions: 'Follow-up in 1 year',
          urgency: RadiologyUrgency.routine,
          status: RadiologyStatus.completed,
          imageUrls: [
            'https://example.com/mri1.jpg',
            'https://example.com/mri2.jpg'
          ],
        ),
      ];

      setState(() {
        _radiologyReports = reports;
        _isLoadingRadiology = false;
      });
    } catch (e) {
      setState(() {
        _radiologyError = e.toString();
        _isLoadingRadiology = false;
      });
    }
  }

  Future<void> _loadLabReports() async {
    try {
      setState(() {
        _isLoadingLab = true;
        _labError = null;
      });

      // In a real app, you would load these from your API
      // For now, we'll simulate loading some mock data
      await Future.delayed(const Duration(seconds: 1));

      final reports = [
        {
          'id': '1',
          'title': 'Complete Blood Count (CBC)',
          'date': DateTime.now().subtract(const Duration(days: 14)),
          'doctor': 'Dr. Smith',
          'status': 'completed',
          'results': [
            {
              'name': 'WBC',
              'value': '7.5',
              'unit': 'K/uL',
              'reference': '4.5-11.0'
            },
            {
              'name': 'RBC',
              'value': '5.2',
              'unit': 'M/uL',
              'reference': '4.5-5.9'
            },
            {
              'name': 'Hemoglobin',
              'value': '14.2',
              'unit': 'g/dL',
              'reference': '13.5-17.5'
            },
            {
              'name': 'Hematocrit',
              'value': '42',
              'unit': '%',
              'reference': '41-50'
            },
            {
              'name': 'Platelets',
              'value': '250',
              'unit': 'K/uL',
              'reference': '150-450'
            },
          ],
        },
        {
          'id': '2',
          'title': 'Lipid Panel',
          'date': DateTime.now().subtract(const Duration(days: 45)),
          'doctor': 'Dr. Johnson',
          'status': 'completed',
          'results': [
            {
              'name': 'Total Cholesterol',
              'value': '190',
              'unit': 'mg/dL',
              'reference': '<200'
            },
            {
              'name': 'LDL',
              'value': '110',
              'unit': 'mg/dL',
              'reference': '<100'
            },
            {'name': 'HDL', 'value': '55', 'unit': 'mg/dL', 'reference': '>40'},
            {
              'name': 'Triglycerides',
              'value': '120',
              'unit': 'mg/dL',
              'reference': '<150'
            },
          ],
        },
      ];

      setState(() {
        _labReports = reports;
        _isLoadingLab = false;
      });
    } catch (e) {
      setState(() {
        _labError = e.toString();
        _isLoadingLab = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Radiology'),
            Tab(text: 'Lab Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Radiology Reports Tab
          _isLoadingRadiology
              ? const Center(child: CircularProgressIndicator())
              : _radiologyError != null
                  ? _buildErrorView(_radiologyError!, _loadRadiologyReports)
                  : _radiologyReports.isEmpty
                      ? _buildEmptyView('No radiology reports found')
                      : _buildRadiologyReportsView(),

          // Lab Reports Tab
          _isLoadingLab
              ? const Center(child: CircularProgressIndicator())
              : _labError != null
                  ? _buildErrorView(_labError!, _loadLabReports)
                  : _labReports.isEmpty
                      ? _buildEmptyView('No lab reports found')
                      : _buildLabReportsView(),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load reports',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 72,
            color: Colors.grey[300],
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
            'Reports will appear here when available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiologyReportsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _radiologyReports.length,
      itemBuilder: (context, index) {
        final report = _radiologyReports[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => context.push('/radiology-report/${report.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          report.type.toLowerCase() == 'x-ray'
                              ? Icons.image
                              : report.type.toLowerCase() == 'mri'
                                  ? Icons.view_in_ar
                                  : report.type.toLowerCase() == 'ultrasound'
                                      ? Icons.waves
                                      : report.type.toLowerCase() == 'ct scan'
                                          ? Icons.view_array
                                          : Icons.medical_services,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${report.type} - ${report.bodyPart}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(report.date),
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(report.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow('Doctor', report.doctorName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Radiologist', report.radiologistName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Impression', report.impression),
                  if (report.recommendedActions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Follow-up: ${report.recommendedActions}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabReportsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _labReports.length,
      itemBuilder: (context, index) {
        final report = _labReports[index];
        final date = report['date'] as DateTime;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => context.push('/examination/${report['id']}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.science,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(date),
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildLabStatusBadge(report['status'] as String),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow('Doctor', report['doctor'] as String),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      'Results', '${(report['results'] as List).length} items'),

                  const SizedBox(height: 16),
                  // Preview of a few results
                  if ((report['results'] as List).isNotEmpty) ...[
                    const Text(
                      'Preview:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (report['results'] as List).length > 3
                          ? 3
                          : (report['results'] as List).length,
                      (i) {
                        final result = (report['results'] as List)[i]
                            as Map<String, dynamic>;
                        final isNormal = _isResultNormal(
                          result['value'] as String,
                          result['reference'] as String,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                '${result['name']}: ',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${result['value']} ${result['unit']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isNormal ? Colors.black : Colors.red,
                                ),
                              ),
                              if (!isNormal)
                                const Icon(
                                  Icons.warning_amber_outlined,
                                  size: 16,
                                  color: Colors.red,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    if ((report['results'] as List).length > 3) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tap to view all ${(report['results'] as List).length} results',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(RadiologyStatus status) {
    Color color;
    String text;

    switch (status) {
      case RadiologyStatus.reported:
        color = Colors.orange;
        text = 'Reported';
        break;
      case RadiologyStatus.scheduled:
        color = Colors.blue;
        text = 'Scheduled';
        break;
      case RadiologyStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case RadiologyStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case RadiologyStatus.requested:
        color = Colors.grey;
        text = 'Requested';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLabStatusBadge(String status) {
    Color color;
    String text = status;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in progress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text.capitalize(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to determine if a lab result is in the normal range
  bool _isResultNormal(String value, String reference) {
    try {
      final numValue = double.tryParse(value);

      if (numValue == null) return true;

      if (reference.startsWith('<')) {
        final limit = double.tryParse(reference.substring(1));
        return limit == null || numValue < limit;
      } else if (reference.startsWith('>')) {
        final limit = double.tryParse(reference.substring(1));
        return limit == null || numValue > limit;
      } else if (reference.contains('-')) {
        final parts = reference.split('-');
        if (parts.length != 2) return true;

        final lower = double.tryParse(parts[0]);
        final upper = double.tryParse(parts[1]);

        return lower == null ||
            upper == null ||
            (numValue >= lower && numValue <= upper);
      }

      return true;
    } catch (_) {
      return true;
    }
  }
}

// Helper extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? '' : this[0].toUpperCase() + substring(1);
  }
}
