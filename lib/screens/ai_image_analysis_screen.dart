import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class AIImageAnalysisScreen extends StatefulWidget {
  const AIImageAnalysisScreen({super.key});

  @override
  State<AIImageAnalysisScreen> createState() => _AIImageAnalysisScreenState();
}

class _AIImageAnalysisScreenState extends State<AIImageAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAnalyzing = false;
  String? _selectedImage;
  List<Map<String, dynamic>> _detectedAnomalies = [];
  bool _showReferenceDatabases = false;

  // Sample images for the demo
  final List<String> _sampleImages = [
    'assets/images/sample_xray_1.jpg',
    'assets/images/sample_xray_2.jpg',
    'assets/images/sample_mri_1.jpg',
    'assets/images/sample_ct_1.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image to analyze')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _detectedAnomalies = [];
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock response data
    final List<Map<String, dynamic>> mockAnomalies = [
      {
        'id': 'anomaly_1',
        'type': 'Nodule',
        'location': 'Right Upper Lobe',
        'confidence': 0.94,
        'size': '8mm',
        'boundingBox': const Rect.fromLTWH(120, 90, 40, 40),
        'description': 'Solitary pulmonary nodule with well-defined margins.',
        'recommendations': [
          'Follow-up CT scan in 3 months',
          'Consider PET scan if size increases',
          'Correlation with previous imaging if available'
        ],
      },
      {
        'id': 'anomaly_2',
        'type': 'Opacity',
        'location': 'Left Lower Lobe',
        'confidence': 0.86,
        'size': '15mm x 20mm',
        'boundingBox': const Rect.fromLTWH(220, 240, 60, 80),
        'description': 'Ground-glass opacity with patchy consolidation.',
        'recommendations': [
          'Clinical correlation for infectious etiology',
          'Short-term follow-up imaging in 4-6 weeks',
          'Consider antibiotics if clinically indicated'
        ],
      },
      {
        'id': 'anomaly_3',
        'type': 'Effusion',
        'location': 'Right Pleural Space',
        'confidence': 0.78,
        'size': 'Small',
        'boundingBox': const Rect.fromLTWH(300, 200, 100, 150),
        'description':
            'Small pleural effusion without obvious mass or consolidation.',
        'recommendations': [
          'Consider thoracentesis if clinically indicated',
          'Monitor for changes in effusion size',
          'Evaluate for underlying cardiac or pulmonary disease'
        ],
      },
    ];

    setState(() {
      _isAnalyzing = false;
      _detectedAnomalies = mockAnomalies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Analysis Suite'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Analysis'),
            Tab(text: 'Reference'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnalysisTab(),
            _buildReferenceTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Column(
      children: [
        // Image selector and controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // This would open an image picker in a real app
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select Sample Image'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _sampleImages.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Image.asset(
                                  _sampleImages[index],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                                title: Text('Sample Image ${index + 1}'),
                                onTap: () {
                                  setState(() {
                                    _selectedImage = _sampleImages[index];
                                    _detectedAnomalies = [];
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Select Image'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.biotech),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: _selectedImage == null
              ? _buildEmptyState()
              : _buildImageAnalysis(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_search,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Select an image to begin analysis',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                // This would normally open a dialog to select from PACS or other sources
                setState(() {
                  // For demo, just set a sample image
                  _selectedImage = _sampleImages[0];
                });
              },
              icon: const Icon(Icons.cloud_download),
              label: const Text('Load from PACS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () {
                // Browse recent studies
              },
              icon: const Icon(Icons.history),
              label: const Text('Browse Recent Studies'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysis() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with anomaly overlays
          Container(
            height: 400,
            color: Colors.black,
            child: Stack(
              children: [
                // Main image
                Center(
                  child: Image.asset(
                    _selectedImage!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback for demo if image doesn't exist
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Text(
                            'Sample X-Ray Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Anomaly markers
                if (_detectedAnomalies.isNotEmpty)
                  ...List.generate(
                    _detectedAnomalies.length,
                    (index) => Positioned(
                      left: _detectedAnomalies[index]['boundingBox'].left,
                      top: _detectedAnomalies[index]['boundingBox'].top,
                      child: GestureDetector(
                        onTap: () =>
                            _showAnomalyDetails(_detectedAnomalies[index]),
                        child: Container(
                          width: _detectedAnomalies[index]['boundingBox'].width,
                          height:
                              _detectedAnomalies[index]['boundingBox'].height,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _getConfidenceColor(
                                  _detectedAnomalies[index]['confidence']),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.warning,
                              color: _getConfidenceColor(
                                  _detectedAnomalies[index]['confidence']),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Image controls overlay
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.zoom_in, color: Colors.white),
                          onPressed: () {
                            // Zoom in functionality
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.zoom_out, color: Colors.white),
                          onPressed: () {
                            // Zoom out functionality
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.rotate_right,
                              color: Colors.white),
                          onPressed: () {
                            // Rotate functionality
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            // Adjust contrast/brightness
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Analysis results
          if (_detectedAnomalies.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detected Anomalies (${_detectedAnomalies.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showReferenceDatabases =
                                  !_showReferenceDatabases;
                            });
                          },
                          icon: Icon(_showReferenceDatabases
                              ? Icons.expand_less
                              : Icons.expand_more),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _showReferenceDatabases
                                  ? 'Hide Reference Database'
                                  : 'Compare with Reference Database',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Reference database comparison section
                  if (_showReferenceDatabases)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reference Database Comparison',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Use column layout on narrow screens
                                if (constraints.maxWidth < 500) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Database Source',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                        value: 'National Radiological Database',
                                        isExpanded: true,
                                        isDense: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value:
                                                'National Radiological Database',
                                            child: Text(
                                              'National Radiological Database',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Hospital Archive',
                                            child: Text('Hospital Archive'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'AI Training Dataset',
                                            child: Text('AI Training Dataset'),
                                          ),
                                        ],
                                        onChanged: (value) {},
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.search),
                                        label: const Text('Find Similar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.secondaryColor,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                // Use row layout on wider screens
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Database Source',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                        value: 'National Radiological Database',
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value:
                                                'National Radiological Database',
                                            child: Text(
                                              'National Radiological Database',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Hospital Archive',
                                            child: Text('Hospital Archive'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'AI Training Dataset',
                                            child: Text('AI Training Dataset'),
                                          ),
                                        ],
                                        onChanged: (value) {},
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.search),
                                      label: const Text('Find Similar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppTheme.secondaryColor,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Similar cases found: 28',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 6, // Sample number of similar cases
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(Icons.image),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Case #${1000 + index}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${90 - index * 3}% Match',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // List of detected anomalies
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _detectedAnomalies.length,
                    itemBuilder: (context, index) {
                      final anomaly = _detectedAnomalies[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getConfidenceColor(anomaly['confidence'])
                                    .withOpacity(0.2),
                            child: Text(
                              '${(anomaly['confidence'] * 100).toInt()}%',
                              style: TextStyle(
                                color:
                                    _getConfidenceColor(anomaly['confidence']),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                              '${anomaly['type']} - ${anomaly['location']}'),
                          subtitle: Text('Size: ${anomaly['size']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showAnomalyDetails(anomaly),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Save Analysis'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Create Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferenceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reference Databases',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compare patient scans against curated databases for similar cases and patterns',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Search and filter bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search databases...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Database list
          Expanded(
            child: ListView(
              children: [
                _buildDatabaseCard(
                  'National Radiological Database',
                  'Comprehensive collection of 2.3M radiological images with validated findings',
                  Icons.public,
                  Colors.blue,
                  lastUpdated: 'Updated 2 days ago',
                  caseCount: '2,341,503',
                ),
                _buildDatabaseCard(
                  'Hospital Archive',
                  'Historical cases from your institution with annotations from senior radiologists',
                  Icons.local_hospital,
                  Colors.green,
                  lastUpdated: 'Updated today',
                  caseCount: '154,328',
                ),
                _buildDatabaseCard(
                  'AI Training Dataset',
                  'Curated dataset used for training AI models with ground truth annotations',
                  Icons.psychology,
                  Colors.purple,
                  lastUpdated: 'Updated 1 month ago',
                  caseCount: '880,245',
                ),
                _buildDatabaseCard(
                  'Rare Conditions Archive',
                  'Specialized collection focusing on rare radiological findings',
                  Icons.find_in_page,
                  Colors.orange,
                  lastUpdated: 'Updated 1 week ago',
                  caseCount: '34,892',
                ),
                _buildDatabaseCard(
                  'Pediatric Reference',
                  'Age-specific normal and abnormal findings for pediatric patients',
                  Icons.child_care,
                  Colors.cyan,
                  lastUpdated: 'Updated 3 days ago',
                  caseCount: '128,734',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseCard(
    String title,
    String description,
    IconData icon,
    Color color, {
    required String lastUpdated,
    required String caseCount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lastUpdated,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Cases: $caseCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                  ),
                  child: const Text('Use Database'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    // Mock data for analysis history
    final List<Map<String, dynamic>> recentAnalyses = [
      {
        'patientId': 'P-38291',
        'patientName': 'John Smith',
        'studyType': 'Chest X-Ray',
        'date': DateTime.now().subtract(const Duration(hours: 3)),
        'findings': 2,
        'status': 'Finalized',
      },
      {
        'patientId': 'P-42198',
        'patientName': 'Alice Johnson',
        'studyType': 'CT Scan - Head',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'findings': 1,
        'status': 'Pending Review',
      },
      {
        'patientId': 'P-29385',
        'patientName': 'Michael Brown',
        'studyType': 'MRI - Lumbar Spine',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'findings': 3,
        'status': 'Finalized',
      },
      {
        'patientId': 'P-53021',
        'patientName': 'Linda Davis',
        'studyType': 'Chest X-Ray',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'findings': 0,
        'status': 'Finalized',
      },
      {
        'patientId': 'P-67482',
        'patientName': 'Robert Wilson',
        'studyType': 'CT Scan - Abdominal',
        'date': DateTime.now().subtract(const Duration(days: 4)),
        'findings': 4,
        'status': 'Finalized',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analysis History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recent AI-assisted analyses performed',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Filter controls
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by patient name or ID',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  value: 'All',
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(
                        value: 'Finalized', child: Text('Finalized')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Analysis history list
          Expanded(
            child: ListView.builder(
              itemCount: recentAnalyses.length,
              itemBuilder: (context, index) {
                final analysis = recentAnalyses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: analysis['findings'] > 0
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      child: Text(
                        '${analysis['findings']}',
                        style: TextStyle(
                          color: analysis['findings'] > 0
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                        '${analysis['patientName']} (${analysis['patientId']})'),
                    subtitle: Text(
                      '${analysis['studyType']} • ${_formatDate(analysis['date'])}',
                    ),
                    trailing: Chip(
                      label: Text(
                        analysis['status'],
                        style: TextStyle(
                          color: analysis['status'] == 'Finalized'
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: analysis['status'] == 'Finalized'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onTap: () {
                      // Open analysis details
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAnomalyDetails(Map<String, dynamic> anomaly) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(anomaly['confidence'])
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: _getConfidenceColor(anomaly['confidence']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${anomaly['type']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Location: ${anomaly['location']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _getConfidenceColor(anomaly['confidence'])
                        .withOpacity(0.2),
                    child: Text(
                      '${(anomaly['confidence'] * 100).toInt()}%',
                      style: TextStyle(
                        color: _getConfidenceColor(anomaly['confidence']),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(anomaly['description']),
              const SizedBox(height: 16),
              const Text(
                'Size',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(anomaly['size']),
              const SizedBox(height: 16),
              const Text(
                'Recommendations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                anomaly['recommendations'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(anomaly['recommendations'][index]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Add to report
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Add to Report'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) {
      return Colors.red;
    } else if (confidence >= 0.7) {
      return Colors.orange;
    } else {
      return Colors.amber;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
