import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:intl/intl.dart';

class RadiologyReportCreationScreen extends StatefulWidget {
  final String examinationId;

  const RadiologyReportCreationScreen({super.key, required this.examinationId});

  @override
  _RadiologyReportCreationScreenState createState() =>
      _RadiologyReportCreationScreenState();
}

class _RadiologyReportCreationScreenState
    extends State<RadiologyReportCreationScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isFinalized = false;
  String? _error;
  Map<String, dynamic> _examinationData = {};
  Map<String, dynamic> _reportData = {};

  // Form controllers
  final _findingsController = TextEditingController();
  final _impressionController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Templates
  final Map<String, Map<String, String>> _templates = {
    'Chest X-Ray': {
      'findings':
          'The lungs are clear without evidence of focal consolidation, pneumothorax, or pleural effusion. Heart size is normal. Mediastinal contours are unremarkable. No acute osseous abnormality.',
      'impression': 'No acute cardiopulmonary findings.',
      'recommendations': 'None.'
    },
    'Brain MRI': {
      'findings':
          'No evidence of acute infarction, hemorrhage, or mass effect. Ventricles and sulci are normal in size and configuration. No abnormal enhancement.',
      'impression': 'Unremarkable brain MRI.',
      'recommendations': 'None. Clinical follow-up as needed.'
    },
    'Abdominal CT': {
      'findings':
          'The liver, gallbladder, pancreas, spleen, and adrenal glands appear normal. No lymphadenopathy. The kidneys are normal in size and appearance. The visualized bowel is unremarkable.',
      'impression': 'Normal abdominal CT scan.',
      'recommendations': 'None.'
    }
  };

  @override
  void initState() {
    super.initState();
    _loadExaminationData();
  }

  @override
  void dispose() {
    _findingsController.dispose();
    _impressionController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  Future<void> _loadExaminationData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data loading - in real app would be API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock examination data
      final examinationData = {
        "id": widget.examinationId,
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
        "completedAt": "2025-04-26T15:00:00",
        "status": "completed",
        "clinicalInfo":
            "Suspected pneumonia, persistent cough for 2 weeks, fever, fatigue. Patient history includes smoking for 20 years, hypertension controlled with medication.",
        "patientHistory":
            "Previous chest X-ray from January 2025 showed no abnormalities. Patient reports progressively worsening symptoms over the past 14 days.",
        "technicalNotes":
            "Standard posteroanterior and lateral chest radiographs. Patient able to fully cooperate with procedure.",
        "radiologistNotes":
            "The patient's symptoms and clinical presentation are concerning for pneumonia.",
        "imageUrls": [
          "https://www.radiologyinfo.org/gallery-items/images/chest-xray-port.jpg",
          "https://www.radiologyinfo.org/gallery-items/images/chest-xray-lat.jpg",
        ],
      };

      // Initial empty report data
      final reportData = {
        "id": "R-${DateTime.now().millisecondsSinceEpoch}",
        "examinationId": widget.examinationId,
        "patientId": examinationData['patientId'],
        "createdAt": DateTime.now().toIso8601String(),
        "finalizedAt": null,
        "status": "draft",
        "findings": "",
        "impression": "",
        "recommendations": ""
      };

      setState(() {
        _examinationData = examinationData;
        _reportData = reportData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReport({bool finalize = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Update report data
      _reportData['findings'] = _findingsController.text;
      _reportData['impression'] = _impressionController.text;
      _reportData['recommendations'] = _recommendationsController.text;

      if (finalize) {
        _reportData['finalizedAt'] = DateTime.now().toIso8601String();
        _reportData['status'] = 'finalized';
      } else {
        _reportData['status'] = 'draft';
      }

      // Simulate saving to API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isSaving = false;
        _isFinalized = finalize;
      });

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(finalize
                ? 'Report finalized successfully'
                : 'Report saved as draft'),
            backgroundColor: finalize ? Colors.green : null,
          ),
        );

        if (finalize) {
          // Navigate back after finalizing
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.pop();
              context.push('/radiology-reports');
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = e.toString();
      });

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyTemplate(String templateName) {
    if (_templates.containsKey(templateName)) {
      setState(() {
        _findingsController.text = _templates[templateName]!['findings']!;
        _impressionController.text = _templates[templateName]!['impression']!;
        _recommendationsController.text =
            _templates[templateName]!['recommendations']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Templates',
            onSelected: _applyTemplate,
            itemBuilder: (BuildContext context) {
              return _templates.keys.map((String templateName) {
                return PopupMenuItem<String>(
                  value: templateName,
                  child: Text('$templateName Template'),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Draft',
            onPressed: _isSaving || _isFinalized
                ? null
                : () => _saveReport(finalize: false),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildReportForm(),
      bottomNavigationBar: _isLoading || _error != null || _isFinalized
          ? null
          : BottomAppBar(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : () => _previewReport(),
                        icon: const Icon(Icons.visibility),
                        label: const Text('PREVIEW'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _saveReport(finalize: true),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: const Text('FINALIZE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            onPressed: _loadExaminationData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientInfoCard(),
            const SizedBox(height: 16),
            _buildExaminationInfoCard(),
            const SizedBox(height: 16),
            _buildImagesSection(),
            const SizedBox(height: 16),
            _buildFindingsSection(),
            const SizedBox(height: 16),
            _buildImpressionSection(),
            const SizedBox(height: 16),
            _buildRecommendationsSection(),
            const SizedBox(height: 16),
            if (_isFinalized) _buildFinalizedBanner(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow(
              'Patient Name',
              _examinationData['patientName'],
            ),
            _buildInfoRow(
              'Patient ID',
              _examinationData['patientId'],
            ),
            _buildInfoRow(
              'Age/Gender',
              '${_examinationData['age']} years / ${_examinationData['gender']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExaminationInfoCard() {
    final scheduledDate = DateTime.parse(_examinationData['scheduledFor']);
    final completedDate = DateTime.parse(_examinationData['completedAt']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Examination Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow(
              'Examination ID',
              _examinationData['id'],
            ),
            _buildInfoRow(
              'Type',
              '${_examinationData['type']} - ${_examinationData['bodyPart']}',
            ),
            _buildInfoRow(
              'Requesting Doctor',
              _examinationData['requestingDoctor'],
            ),
            _buildInfoRow(
              'Scheduled Date',
              DateFormat('MMMM d, yyyy - h:mm a').format(scheduledDate),
            ),
            _buildInfoRow(
              'Completed Date',
              DateFormat('MMMM d, yyyy - h:mm a').format(completedDate),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text(
                'Clinical Information',
                style: TextStyle(fontSize: 16),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_examinationData['clinicalInfo']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    final imageUrls = _examinationData['imageUrls'] as List;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to full image viewer
                    context.push(
                        '/radiology-image-viewer/${widget.examinationId}');
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('View Full Size'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrls[index],
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Findings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            TextFormField(
              controller: _findingsController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter radiographic findings here...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter findings';
                }
                return null;
              },
              readOnly: _isFinalized,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpressionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Impression',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            TextFormField(
              controller: _impressionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your diagnostic impression here...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter impression';
                }
                return null;
              },
              readOnly: _isFinalized,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            TextFormField(
              controller: _recommendationsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Enter recommendations here...',
                border: OutlineInputBorder(),
              ),
              validator: (value) => null, // Optional field
              readOnly: _isFinalized,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalizedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Text(
            'Report Finalized',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('MM/dd/yyyy - h:mm a').format(DateTime.now()),
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previewReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Update report data for preview
    _reportData['findings'] = _findingsController.text;
    _reportData['impression'] = _impressionController.text;
    _reportData['recommendations'] = _recommendationsController.text;
    _reportData['createdAt'] = DateTime.now().toIso8601String();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 600,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report Preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXAMINATION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${_examinationData['type']} - ${_examinationData['bodyPart']}'),
                      const SizedBox(height: 16),
                      const Text(
                        'PATIENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${_examinationData['patientName']} (${_examinationData['patientId']})'),
                      Text(
                          'Age: ${_examinationData['age']}    Gender: ${_examinationData['gender']}'),
                      const SizedBox(height: 16),
                      const Text(
                        'FINDINGS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_reportData['findings']),
                      const SizedBox(height: 16),
                      const Text(
                        'IMPRESSION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_reportData['impression']),
                      const SizedBox(height: 16),
                      if (_reportData['recommendations'].isNotEmpty) ...[
                        const Text(
                          'RECOMMENDATIONS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_reportData['recommendations']),
                        const SizedBox(height: 16),
                      ],
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Generated on: ${DateFormat('MMMM d, yyyy - h:mm a').format(DateTime.now())}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This is a preview only. Please finalize the report to make it official.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('CONTINUE EDITING'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pop();
                      _saveReport(finalize: true);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('FINALIZE REPORT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
