import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medapp/theme/app_theme.dart';

class Examination {
  final String id;
  final String title;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final List<ExaminationItem> items;
  final String? notes;
  final List<String>? attachments;

  Examination({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.items,
    this.notes,
    this.attachments,
  });
}

class ExaminationItem {
  final String name;
  final String value;
  final String? normalRange;
  final String? unit;
  final bool isNormal;

  ExaminationItem({
    required this.name,
    required this.value,
    this.normalRange,
    this.unit,
    this.isNormal = true,
  });
}

class ExaminationDetailScreen extends StatefulWidget {
  final String examinationId;

  const ExaminationDetailScreen({
    super.key,
    required this.examinationId,
  });

  @override
  _ExaminationDetailScreenState createState() =>
      _ExaminationDetailScreenState();
}

class _ExaminationDetailScreenState extends State<ExaminationDetailScreen> {
  bool _isLoading = true;
  Examination? _examination;
  String? _error;
  bool _showResults = true;

  @override
  void initState() {
    super.initState();
    _loadExamination();
  }

  Future<void> _loadExamination() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // In a real app, you would fetch this from an API
      // For this demo, we'll simulate a network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data based on examination ID
      final examination = Examination(
        id: widget.examinationId,
        title: 'Complete Blood Count',
        doctorName: 'Dr. Sarah Johnson',
        specialty: 'Hematology',
        date: DateTime.now().subtract(const Duration(days: 3)),
        items: [
          ExaminationItem(
            name: 'Hemoglobin (Hgb)',
            value: '14.2',
            unit: 'g/dL',
            normalRange: '12.0-16.0',
            isNormal: true,
          ),
          ExaminationItem(
            name: 'Hematocrit (Hct)',
            value: '42',
            unit: '%',
            normalRange: '36-48',
            isNormal: true,
          ),
          ExaminationItem(
            name: 'Red Blood Cells (RBC)',
            value: '4.8',
            unit: 'million/μL',
            normalRange: '4.2-5.4',
            isNormal: true,
          ),
          ExaminationItem(
            name: 'White Blood Cells (WBC)',
            value: '11.5',
            unit: 'thousand/μL',
            normalRange: '4.5-11.0',
            isNormal: false,
          ),
          ExaminationItem(
            name: 'Platelets',
            value: '250',
            unit: 'thousand/μL',
            normalRange: '150-450',
            isNormal: true,
          ),
          ExaminationItem(
            name: 'Mean Corpuscular Volume (MCV)',
            value: '88',
            unit: 'fL',
            normalRange: '80-96',
            isNormal: true,
          ),
        ],
        notes:
            'Slight elevation in white blood cell count may indicate a mild infection. Follow up in 2 weeks if symptoms persist.',
        attachments: [
          'blood_test_result.pdf',
          'doctor_notes.pdf',
        ],
      );

      setState(() {
        _examination = examination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Details'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing functionality will be added soon'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download functionality will be added soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildExaminationDetails(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Failed to load examination details",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? "Unknown error",
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadExamination,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExaminationDetails() {
    if (_examination == null) {
      return const Center(
        child: Text("No examination data available"),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Results Toggle
          _buildResultsToggle(),
          const SizedBox(height: 8),

          // Results Section
          if (_showResults) ...[
            _buildResultsCard(),
            const SizedBox(height: 16),
          ],

          // Notes Section
          if (_examination!.notes != null) ...[
            _buildNotesCard(),
            const SizedBox(height: 16),
          ],

          // Attachments Section
          if (_examination!.attachments != null &&
              _examination!.attachments!.isNotEmpty) ...[
            _buildAttachmentsCard(),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Examination icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.science,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Examination details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _examination!.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date:',
                        DateFormat('MMM dd, yyyy').format(_examination!.date),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.person,
                        'Doctor:',
                        _examination!.doctorName,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.medical_services,
                        'Specialty:',
                        _examination!.specialty,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Test Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: _showResults,
          onChanged: (value) {
            setState(() {
              _showResults = value;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildResultsCard() {
    final abnormalItems =
        _examination!.items.where((item) => !item.isNormal).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag abnormalities if present
            if (abnormalItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Some results are outside the normal range',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Results table header
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Test',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Result',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Normal Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),

            // Results table rows
            ...List.generate(
              _examination!.items.length,
              (index) => _buildResultRow(_examination!.items[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(ExaminationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '${item.value} ${item.unit ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: item.isNormal ? Colors.black : Colors.red,
                  ),
                ),
                if (!item.isNormal)
                  const Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                    size: 16,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.normalRange ?? 'N/A',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note_alt_outlined,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Doctor\'s Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Text(
              _examination!.notes!,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.attachment_outlined,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            ...List.generate(
              _examination!.attachments!.length,
              (index) =>
                  _buildAttachmentItem(_examination!.attachments![index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String filename) {
    IconData iconData;
    Color iconColor;

    if (filename.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (filename.endsWith('.jpg') ||
        filename.endsWith('.png') ||
        filename.endsWith('.jpeg')) {
      iconData = Icons.image;
      iconColor = Colors.blue;
    } else if (filename.endsWith('.doc') || filename.endsWith('.docx')) {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    return ListTile(
      leading: Icon(
        iconData,
        color: iconColor,
      ),
      title: Text(filename),
      trailing: const Icon(Icons.download_outlined),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download functionality will be added soon'),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.question_answer),
            label: const Text('Ask Doctor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Contact doctor functionality will be added soon'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Share Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing functionality will be added soon'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
