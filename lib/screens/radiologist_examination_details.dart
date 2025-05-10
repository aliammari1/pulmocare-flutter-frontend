import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:intl/intl.dart';

class RadiologyExaminationDetailsScreen extends StatefulWidget {
  final String examinationId;

  const RadiologyExaminationDetailsScreen(
      {super.key, required this.examinationId});

  @override
  _RadiologyExaminationDetailsScreenState createState() =>
      _RadiologyExaminationDetailsScreenState();
}

class _RadiologyExaminationDetailsScreenState
    extends State<RadiologyExaminationDetailsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _examinationData = {};
  List<String> _imageUrls = [];
  final bool _isReportExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadExaminationData();
  }

  Future<void> _loadExaminationData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Mock data - in real app this would be fetched from API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
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
        "completedAt": null,
        "status": "pending",
        "clinicalInfo":
            "Suspected pneumonia, persistent cough for 2 weeks, fever, fatigue. Patient history includes smoking for 20 years, hypertension controlled with medication.",
        "patientHistory":
            "Previous chest X-ray from January 2025 showed no abnormalities. Patient reports progressively worsening symptoms over the past 14 days.",
        "technicalNotes":
            "Standard posteroanterior and lateral chest radiographs. Patient able to fully cooperate with procedure.",
        "radiologistNotes": "",
      };

      // Mock image URLs
      final mockImages = [
        "https://www.radiologyinfo.org/gallery-items/images/chest-xray-port.jpg",
        "https://www.radiologyinfo.org/gallery-items/images/chest-xray-lat.jpg",
      ];

      setState(() {
        _examinationData = examinationData;
        _imageUrls = mockImages;
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
        title: Text('Examination ${widget.examinationId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: 'Create Report',
            onPressed: () {
              // Navigate to report creation screen
              context.push('/radiology-create-report/${widget.examinationId}');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildExaminationContent(),
      bottomNavigationBar: !_isLoading && _error == null
          ? BottomAppBar(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                        '/radiology-create-report/${widget.examinationId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('CREATE REPORT'),
                ),
              ),
            )
          : null,
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

  Widget _buildExaminationContent() {
    final requestedDate = DateTime.parse(_examinationData['requestedAt']);
    final scheduledDate = DateTime.parse(_examinationData['scheduledFor']);

    final priority = _examinationData['priority'] as String;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoCard(),
          const SizedBox(height: 16),
          _buildExaminationInfoCard(
              priorityColor, requestedDate, scheduledDate),
          const SizedBox(height: 16),
          _buildClinicalInfoCard(),
          const SizedBox(height: 16),
          _buildImagesSection(),
          const SizedBox(height: 16),
          _buildRadiologistNotesCard(),
        ],
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  radius: 30,
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _examinationData['patientName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          'Patient ID', _examinationData['patientId']),
                      _buildInfoRow('Age', '${_examinationData['age']} years'),
                      _buildInfoRow('Gender', _examinationData['gender']),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to patient details
                context.push('/patient/${_examinationData['patientId']}');
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Patient Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExaminationInfoCard(
      Color priorityColor, DateTime requestedDate, DateTime scheduledDate) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withOpacity(0.5),
          width: _examinationData['priority'] == 'urgent' ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Examination Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    _examinationData['priority'].toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Type', _examinationData['type']),
            _buildInfoRow('Body Part', _examinationData['bodyPart']),
            _buildInfoRow(
                'Requesting Doctor', _examinationData['requestingDoctor']),
            _buildInfoRow(
              'Requested Date',
              DateFormat('MMMM d, yyyy - h:mm a').format(requestedDate),
            ),
            _buildInfoRow(
              'Scheduled Date',
              DateFormat('MMMM d, yyyy - h:mm a').format(scheduledDate),
            ),
            _buildInfoRow(
              'Status',
              _examinationData['status'].toUpperCase(),
              valueColor: _getStatusColor(_examinationData['status']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const Text(
              'Clinical Indication',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(_examinationData['clinicalInfo']),
            const SizedBox(height: 16),
            const Text(
              'Patient History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(_examinationData['patientHistory']),
            const SizedBox(height: 16),
            const Text(
              'Technical Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(_examinationData['technicalNotes']),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        _showImageDialog(_imageUrls[index]);
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imageUrls[index],
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: 200,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Open full image viewer
                  context
                      .push('/radiology-image-viewer/${widget.examinationId}');
                },
                icon: const Icon(Icons.image_search),
                label: const Text('Open Image Viewer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiologistNotesCard() {
    final TextEditingController notesController = TextEditingController(
      text: _examinationData['radiologistNotes'],
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Radiologist Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            TextField(
              controller: notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Add your notes here...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {
                  _examinationData['radiologistNotes'] = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Save notes
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notes saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Notes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
