import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class EducationalCaseBuilderScreen extends StatefulWidget {
  const EducationalCaseBuilderScreen({super.key});

  @override
  State<EducationalCaseBuilderScreen> createState() =>
      _EducationalCaseBuilderScreenState();
}

class _EducationalCaseBuilderScreenState
    extends State<EducationalCaseBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clinicalHistoryController =
      TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _teachingPointsController =
      TextEditingController();
  final TextEditingController _referencesController = TextEditingController();

  List<Map<String, dynamic>> _imageSeries = [];
  List<String> _tags = [];
  String _selectedDifficulty = 'Intermediate';
  final List<String> _availableDifficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];
  final List<String> _availableCategories = [
    'Neuro',
    'Chest',
    'Abdominal',
    'MSK',
    'Cardiovascular',
    'Pediatric'
  ];
  String _selectedCategory = 'Chest';

  // Mock data
  List<Map<String, dynamic>> _availableStudies = [];
  List<Map<String, dynamic>> _recentCases = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clinicalHistoryController.dispose();
    _diagnosisController.dispose();
    _teachingPointsController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Simulate data loading with a slight delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate mock available studies
    final studies = List.generate(
      8,
      (index) => {
        'id': 'STU-${1000 + index}',
        'patientId': 'PID-${5000 + math.Random().nextInt(1000)}',
        'patientName': _getRandomPatientName(),
        'type': _getRandomStudyType(),
        'modality': _getRandomModality(),
        'date':
            DateTime.now().subtract(Duration(days: math.Random().nextInt(30))),
        'imageCount': 12 + math.Random().nextInt(24),
        'thumbnailUrl': 'assets/images/sample_scan_${index % 5 + 1}.jpg',
        'hasAnnotations': math.Random().nextBool(),
      },
    );

    // Generate mock recent cases
    final cases = List.generate(
      5,
      (index) => {
        'id': 'CASE-${2000 + index}',
        'title': _getRandomCaseTitle(),
        'category': _availableCategories[
            math.Random().nextInt(_availableCategories.length)],
        'difficulty': _availableDifficulties[
            math.Random().nextInt(_availableDifficulties.length)],
        'createdAt':
            DateTime.now().subtract(Duration(days: math.Random().nextInt(14))),
        'views': math.Random().nextInt(150),
        'thumbnailUrl': 'assets/images/case_${index + 1}.jpg',
        'status': index < 3 ? 'Published' : 'Draft',
      },
    );

    setState(() {
      _availableStudies = studies;
      _recentCases = cases;
      _isLoading = false;
    });
  }

  String _getRandomPatientName() {
    final List<String> firstNames = [
      'Anonymous',
      'Teaching',
      'Case',
      'Clinical',
      'Educational'
    ];
    final List<String> lastNames = [
      'Patient',
      'Subject',
      'Example',
      'Record',
      'Study'
    ];
    return '${firstNames[math.Random().nextInt(firstNames.length)]} ${lastNames[math.Random().nextInt(lastNames.length)]}';
  }

  String _getRandomStudyType() {
    final List<String> types = [
      'Brain MRI',
      'Chest CT',
      'Abdominal CT',
      'Spine MRI',
      'Knee MRI',
      'Chest X-ray',
      'PET-CT'
    ];
    return types[math.Random().nextInt(types.length)];
  }

  String _getRandomModality() {
    final List<String> modalities = ['CT', 'MRI', 'XR', 'US', 'NM', 'PET'];
    return modalities[math.Random().nextInt(modalities.length)];
  }

  String _getRandomCaseTitle() {
    final List<String> prefixes = [
      'Interesting',
      'Challenging',
      'Classic',
      'Rare',
      'Complex'
    ];
    final List<String> conditions = [
      'Pneumothorax',
      'Fracture',
      'Tumor',
      'Aneurysm',
      'Stroke',
      'Lesion'
    ];
    final List<String> suffixes = [
      'Case',
      'Presentation',
      'Finding',
      'Pathology',
      'Study'
    ];
    return '${prefixes[math.Random().nextInt(prefixes.length)]} ${conditions[math.Random().nextInt(conditions.length)]} ${suffixes[math.Random().nextInt(suffixes.length)]}';
  }

  void _saveCase() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simulate saving process
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // Fix: guard BuildContext after async gap
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset form or navigate back
      _resetForm();
    });
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _clinicalHistoryController.clear();
    _diagnosisController.clear();
    _teachingPointsController.clear();
    _referencesController.clear();
    setState(() {
      _tags = [];
      _imageSeries = [];
      _selectedCategory = 'Chest';
      _selectedDifficulty = 'Intermediate';
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _showAddImageSeriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image Series'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _availableStudies.length,
            itemBuilder: (context, index) {
              final study = _availableStudies[index];
              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    study['modality'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(study['type']),
                subtitle: Text(
                  '${DateFormat('MMM dd, yyyy').format(study['date'])} • ${study['imageCount']} images',
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageSeries.add(study);
                  });
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Educational Case Builder')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading resources...'),
            ],
          ),
        ),
      );
    }

    // Get screen width to handle responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 900; // Threshold for tablet/desktop view
    final isSmallScreen = screenWidth < 700; // Threshold for very small screens

    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Case Builder'),
        actions: [
          if (!isSmallScreen)
            TextButton.icon(
              onPressed: () {
                // Preview case
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preview feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          IconButton(
            onPressed: _saveCase,
            icon: const Icon(Icons.save),
            tooltip: 'Save Case',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use column layout for small screens, row for larger screens
          if (constraints.maxWidth < 800) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main editor panel
                  _buildEditorPanel(context),
                  // Resources panel
                  _buildResourcesPanel(context),
                ],
              ),
            );
          } else {
            // Row layout for larger screens
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left panel - Case editor
                Expanded(
                  flex: isTablet
                      ? 3
                      : 2, // Adjust the flex ratio based on screen size
                  child: _buildEditorPanel(context),
                ),
                // Right panel - Recent cases and resources
                Expanded(
                  flex: 1,
                  child: _buildResourcesPanel(context),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Extract editor panel to a separate method for reusability
  Widget _buildEditorPanel(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Case Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Brief Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Category and Difficulty - Make them wrap on smaller screens
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Stack vertically on small screens
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory,
                        items: _availableCategories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDifficulty,
                        items: _availableDifficulties
                            .map((difficulty) => DropdownMenuItem(
                                  value: difficulty,
                                  child: Text(difficulty),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedDifficulty = value);
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  // Side by side on larger screens
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCategory,
                          items: _availableCategories
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Difficulty',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDifficulty,
                          items: _availableDifficulties
                              .map((difficulty) => DropdownMenuItem(
                                    value: difficulty,
                                    child: Text(difficulty),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDifficulty = value);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Tags - Improved layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._tags.map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add Tag'),
                      onPressed: () {
                        final controller = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add Tag'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Enter tag',
                              ),
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _addTag(controller.text.trim());
                                  Navigator.pop(context);
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Clinical Content Section
            const Text(
              'Clinical Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _clinicalHistoryController,
              decoration: const InputDecoration(
                labelText: 'Clinical History',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter clinical history';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter diagnosis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _teachingPointsController,
              decoration: const InputDecoration(
                labelText: 'Teaching Points',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter teaching points';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _referencesController,
              decoration: const InputDecoration(
                labelText: 'References',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Images Section - Keep the responsive layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Image Series',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddImageSeriesDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _imageSeries.isEmpty
                ? Container(
                    height: 150,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No image series added',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _imageSeries.length,
                    itemBuilder: (context, index) {
                      final series = _imageSeries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              series['modality'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(series['type']),
                          subtitle: Text(
                            '${DateFormat('MMM dd, yyyy').format(series['date'])} • ${series['imageCount']} images',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                _imageSeries.removeAt(index);
                              });
                            },
                            tooltip: 'Remove',
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 32),

            // Action buttons with better responsive layout
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _resetForm,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveCase,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Extract resources panel to a separate method for reusability
  Widget _buildResourcesPanel(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Cases Section
            const Text(
              'Your Recent Cases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // For very small screens, show less cases
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MediaQuery.of(context).size.width < 600
                  ? math.min(3, _recentCases.length)
                  : _recentCases.length,
              itemBuilder: (context, index) {
                final caseData = _recentCases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                caseData['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: caseData['status'] == 'Published'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                caseData['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: caseData['status'] == 'Published'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${caseData['category']} • ${caseData['difficulty']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM dd').format(caseData['createdAt'])} • ${caseData['views']} views',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Resources Section - Optimize for smaller screens
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Make resource cards more compact on smaller screens
            LayoutBuilder(
              builder: (context, constraints) {
                final useCompactLayout = constraints.maxWidth < 300;
                return Column(
                  children: [
                    _buildResourceCard(
                      'Case Templates',
                      'Access pre-defined templates',
                      Icons.article_outlined,
                      Colors.blue,
                      isCompact: useCompactLayout,
                    ),
                    _buildResourceCard(
                      'Educational Guidelines',
                      'Best practices for teaching cases',
                      Icons.school_outlined,
                      Colors.purple,
                      isCompact: useCompactLayout,
                    ),
                    _buildResourceCard(
                      'Image Annotation Guide',
                      'How to effectively annotate images',
                      Icons.draw_outlined,
                      Colors.orange,
                      isCompact: useCompactLayout,
                    ),
                    _buildResourceCard(
                      'Community Cases',
                      'Browse cases from peers',
                      Icons.people_outline,
                      Colors.green,
                      isCompact: useCompactLayout,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(
      String title, String description, IconData icon, Color color,
      {bool isCompact = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Resource action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title will be available soon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 8.0 : 12.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 6.0 : 8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isCompact ? 16.0 : 24.0,
                ),
              ),
              SizedBox(width: isCompact ? 8.0 : 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 13.0 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isCompact || MediaQuery.of(context).size.width > 220)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isCompact ? 11.0 : 12.0,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: isCompact ? 16.0 : 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
