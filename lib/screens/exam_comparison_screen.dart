import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExamComparisonScreen extends StatefulWidget {
  final String examId;

  const ExamComparisonScreen({super.key, required this.examId});

  @override
  _ExamComparisonScreenState createState() => _ExamComparisonScreenState();
}

class _ExamComparisonScreenState extends State<ExamComparisonScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentExam;
  List<Map<String, dynamic>> _previousExams = [];
  Map<String, dynamic>? _selectedPreviousExam;
  double _zoomLevel = 1.0;
  double _brightness = 0.0;
  double _contrast = 1.0;

  int _currentSliceIndex = 15;
  int _previousSliceIndex = 15;
  final int _totalSlices = 30;

  final List<String> _annotationOptions = [
    'Measure',
    'Arrow',
    'Circle',
    'Text',
    'Highlight',
  ];
  String? _selectedAnnotation;

  @override
  void initState() {
    super.initState();
    _loadExamData();
  }

  Future<void> _loadExamData() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;

        _currentExam = {
          'id': widget.examId,
          'patientId': 'P-78245',
          'patientName': 'James Wilson',
          'modality': 'CT Scan',
          'bodyPart': 'Chest',
          'date': '2025-04-15',
          'radiologist': 'Dr. Emily Parker',
          'status': 'Completed',
          'slices': List.generate(30, (index) => 'slice_$index'),
          'findings':
              'Multiple bilateral pulmonary nodules with irregular margins.',
          'comparison':
              'Previous exam from 2024-10-10 shows progression of disease with increase in size of largest nodule from 1.8cm to 2.3cm.',
        };

        _previousExams = [
          {
            'id': 'E-45678',
            'modality': 'CT Scan',
            'bodyPart': 'Chest',
            'date': '2024-10-10',
            'slices': List.generate(30, (index) => 'prev_slice_$index'),
            'findings':
                'Multiple bilateral pulmonary nodules, largest measuring 1.8cm in right upper lobe.',
          },
          {
            'id': 'E-34567',
            'modality': 'CT Scan',
            'bodyPart': 'Chest',
            'date': '2024-04-22',
            'slices': List.generate(30, (index) => 'prev_slice2_$index'),
            'findings':
                'Small pulmonary nodule (1.2cm) in right upper lobe, likely benign.',
          },
        ];

        _selectedPreviousExam = _previousExams[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: Text(
          _isLoading ? 'Loading Exam...' : 'Compare Exam: ${widget.examId}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Export Comparison',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comparison exported to PACS')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Comparison',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white70))
            : Column(
                children: [
                  _buildInfoBar(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildExamViewerColumn(
                            title: 'Current Exam (${_currentExam!["date"]})',
                            sliceIndex: _currentSliceIndex,
                            isCurrentExam: true,
                          ),
                        ),
                        Container(width: 1, color: Colors.white30),
                        Expanded(
                          child: _buildExamViewerColumn(
                            title:
                                'Previous Exam (${_selectedPreviousExam!["date"]})',
                            sliceIndex: _previousSliceIndex,
                            isCurrentExam: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildControlBar(),
                  _buildAnnotationsBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF050A30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Patient: ${_currentExam!["patientName"]} (ID: ${_currentExam!["patientId"]})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.medical_services,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Modality: ${_currentExam!["modality"]}',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bloodtype, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Region: ${_currentExam!["bodyPart"]}',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedPreviousExam,
                  dropdownColor: const Color(0xFF1A1F3C),
                  style: const TextStyle(color: Colors.white),
                  icon:
                      const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  underline: Container(height: 1, color: Colors.white30),
                  isExpanded: true,
                  onChanged: (Map<String, dynamic>? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPreviousExam = newValue;
                      });
                    }
                  },
                  items: _previousExams
                      .map<DropdownMenuItem<Map<String, dynamic>>>((exam) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: exam,
                      child: Text(
                        '${exam["date"]} - ${exam["modality"]}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  hint: const Text(
                    'Select previous exam',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Sync Slices'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                ),
                onPressed: () {
                  setState(() {
                    _previousSliceIndex = _currentSliceIndex;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamViewerColumn({
    required String title,
    required int sliceIndex,
    required bool isCurrentExam,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.black,
          width: double.infinity,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Image viewer with mock CT scan
                  InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.8,
                    onInteractionEnd: (details) {
                      // Update zoom level in real app
                    },
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix([
                            _contrast,
                            0,
                            0,
                            0,
                            _brightness * 255,
                            0,
                            _contrast,
                            0,
                            0,
                            _brightness * 255,
                            0,
                            0,
                            _contrast,
                            0,
                            _brightness * 255,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: Image.network(
                            'https://www.researchgate.net/publication/343949797/figure/fig2/AS:931234113949699@1599132942295/Typical-lung-cancer-CT-scan-images-of-benign-and-malignant-pulmonary-nodules-cropped-to.jpg',
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Slice indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Slice $sliceIndex / $_totalSlices',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Slice navigation
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up,
                              color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              if (isCurrentExam) {
                                _currentSliceIndex = (_currentSliceIndex - 1)
                                    .clamp(0, _totalSlices - 1);
                              } else {
                                _previousSliceIndex = (_previousSliceIndex - 1)
                                    .clamp(0, _totalSlices - 1);
                              }
                            });
                          },
                        ),
                        SizedBox(
                          height: constraints.maxHeight * 0.4,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: sliceIndex.toDouble(),
                              min: 0,
                              max: (_totalSlices - 1).toDouble(),
                              activeColor: Colors.white,
                              inactiveColor: Colors.white24,
                              onChanged: (value) {
                                setState(() {
                                  if (isCurrentExam) {
                                    _currentSliceIndex = value.toInt();
                                  } else {
                                    _previousSliceIndex = value.toInt();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white70),
                          onPressed: () {
                            setState(() {
                              if (isCurrentExam) {
                                _currentSliceIndex = (_currentSliceIndex + 1)
                                    .clamp(0, _totalSlices - 1);
                              } else {
                                _previousSliceIndex = (_previousSliceIndex + 1)
                                    .clamp(0, _totalSlices - 1);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Key findings indicator (demonstrate on current exam only)
                  if (isCurrentExam)
                    Positioned(
                      top: constraints.maxHeight * 0.3,
                      left: constraints.maxWidth * 0.4,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Nodule - 2.3cm, irregular margins')),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.report_problem,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Image/slice findings
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          width: double.infinity,
          color: Colors.black45,
          child: Text(
            isCurrentExam
                ? _currentExam!['findings']
                : _selectedPreviousExam!['findings'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF050A30),
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Zoom controls
              const Text(
                'Zoom:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 150,
                child: Slider(
                  value: _zoomLevel,
                  min: 0.5,
                  max: 3.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  label: '${_zoomLevel.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    setState(() {
                      _zoomLevel = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Brightness controls
              const Text(
                'Brightness:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 150,
                child: Slider(
                  value: _brightness,
                  min: -0.5,
                  max: 0.5,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setState(() {
                      _brightness = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Contrast controls
              const Text(
                'Contrast:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 150,
                child: Slider(
                  value: _contrast,
                  min: 0.5,
                  max: 2.0,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    setState(() {
                      _contrast = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnotationsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Annotations:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 16),
              ..._annotationOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(option),
                    selected: _selectedAnnotation == option,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAnnotation = selected ? option : null;
                      });
                    },
                    selectedColor: const Color(0xFF2E8BC0),
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: _selectedAnnotation == option
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 24),
              TextButton.icon(
                icon: const Icon(Icons.format_align_left, color: Colors.white),
                label: const Text(
                  'Add Note',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // Show note dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Add Comparison Note'),
                      content: const TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter your comparison findings...',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Note added to comparison')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8BC0),
                          ),
                          child: const Text('SAVE'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
