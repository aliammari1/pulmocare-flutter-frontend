import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medapp/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';

class AdvancedImageAnalysisScreen extends StatefulWidget {
  const AdvancedImageAnalysisScreen({super.key});

  @override
  State<AdvancedImageAnalysisScreen> createState() =>
      _AdvancedImageAnalysisScreenState();
}

class _AdvancedImageAnalysisScreenState
    extends State<AdvancedImageAnalysisScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _recentImages = [
    {
      'id': '1',
      'patientName': 'John Smith',
      'patientId': 'P10023',
      'examType': 'Chest X-Ray',
      'date': '2025-04-23',
      'status': 'Pending Analysis',
      // Use an optional asset path that might not exist
      'thumbnailPath': 'assets/images/xray_sample1.jpg',
    },
    {
      'id': '2',
      'patientName': 'Mary Johnson',
      'patientId': 'P10045',
      'examType': 'CT Scan - Lungs',
      'date': '2025-04-24',
      'status': 'Pending Analysis',
      // Use an optional asset path that might not exist
      'thumbnailPath': 'assets/images/ct_sample1.jpg',
    },
    {
      'id': '3',
      'patientName': 'Robert Chen',
      'patientId': 'P10067',
      'examType': 'MRI - Thoracic',
      'date': '2025-04-25',
      'status': 'In Progress',
      // Use an optional asset path that might not exist
      'thumbnailPath': 'assets/images/mri_sample1.jpg',
    },
  ];

  final List<String> _analyticTools = [
    'Nodule Detection',
    'Pneumonia Assessment',
    'Lung Capacity Analysis',
    'COPD Progression',
    'Infiltration Pattern Recognition',
    'Pleural Effusion Quantification',
    'COVID-19 Markers',
    '3D Reconstruction'
  ];

  String _selectedTool = 'Nodule Detection';
  double _zoomLevel = 1.0;
  double _brightness = 0.0;
  double _contrast = 1.0;
  bool _showGrid = false;
  bool _showAnnotations = true;
  bool _showMeasurements = false;
  int _selectedImageIndex = 0;

  // New properties for enhanced functionality
  TabController? _toolTabController;
  bool _isComparisonMode = false;
  int _comparisonImageIndex = -1;
  bool _isDrawerOpen = true;
  bool _isAnalysisCompleted = false;
  final Map<String, List<String>> _analyticsResults = {
    'Nodule Detection': [
      'Detected 2 potential nodules in right lung',
      'Abnormal density pattern in lower left quadrant',
      'No signs of pleural effusion'
    ],
    'Pneumonia Assessment': [
      'Low probability of bacterial pneumonia',
      'Minor inflammation detected in lower right lung',
      'Recommend follow-up in 4 weeks'
    ],
    'COPD Progression': [
      'Moderate progression since last examination',
      'Increased hyperinflation observed',
      'Bullae formation in upper lobes'
    ],
    'COVID-19 Markers': [
      'No typical COVID-19 patterns detected',
      'Normal lung parenchyma in most regions',
      'Minor atelectasis in posterior segments'
    ],
  };

  // Additional properties for responsive UI
  bool _showImagesPanel = true;
  TabController? _navigationController; // Changed from late to nullable
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();

    // Find the initial index for the selected tool
    int initialIndex = _analyticTools.indexOf(_selectedTool);
    if (initialIndex < 0) initialIndex = 0;

    // Create the TabController with the correct initial index
    _toolTabController = TabController(
      length: _analyticTools.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    // Add listener for tab changes
    _toolTabController?.addListener(() {
      // Only update when the tab actually changes
      if (_toolTabController!.indexIsChanging ||
          _toolTabController!.index != _analyticTools.indexOf(_selectedTool)) {
        if (mounted) {
          setState(() {
            _selectedTool = _analyticTools[_toolTabController!.index];
          });
        }
      }
    });

    // Initialize navigation controller for bottom tabs
    _navigationController = TabController(length: 3, vsync: this);
    _navigationController?.addListener(() {
      // Use null-safe call
      if (_navigationController?.indexIsChanging == false) {
        setState(() {
          _currentNavIndex = _navigationController?.index ?? 0;
        });
      }
    });
  }

  // Add this method to update tab selection when _selectedTool changes
  void _updateSelectedTab() {
    final index = _analyticTools.indexOf(_selectedTool);
    if (index >= 0 &&
        _toolTabController != null &&
        _toolTabController!.index != index) {
      _toolTabController!.animateTo(index);
    }
  }

  @override
  void didUpdateWidget(AdvancedImageAnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure tab controller is updated if needed
    _updateSelectedTab();
  }

  @override
  void dispose() {
    _toolTabController?.dispose();
    _navigationController?.dispose(); // Use null-safe call
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Advanced Image Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isSmallScreen)
            IconButton(
              icon: Icon(_showImagesPanel ? Icons.image : Icons.view_array),
              onPressed: () =>
                  setState(() => _showImagesPanel = !_showImagesPanel),
              tooltip: _showImagesPanel ? 'Show Analysis View' : 'Show Images',
            ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => _toggleComparisonMode(),
            tooltip: 'Compare Images',
            color: _isComparisonMode ? Colors.amber : null,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showAnalysisHistory(),
            tooltip: 'Analysis History',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveAnalysis(),
            tooltip: 'Save Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalysis(),
            tooltip: 'Share Analysis',
          ),
        ],
      ),
      body: isSmallScreen
          ? _buildMobileLayout(screenSize)
          : _buildTabletLayout(screenSize),
      bottomNavigationBar: isSmallScreen ? _buildBottomNavigation() : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _runAnalysis(),
        tooltip: 'Run Analysis',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    // Ensure navigation controller is initialized
    if (_navigationController == null) {
      _navigationController = TabController(length: 3, vsync: this);
    }

    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) {
        setState(() {
          _currentNavIndex = index;
          _navigationController?.animateTo(index); // Use null-safe call

          if (index == 0) {
            _showImagesPanel = true;
          } else if (index == 1) {
            _showImagesPanel = false;
          }
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.image),
          label: 'Images',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analysis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size screenSize) {
    if (_currentNavIndex == 0 || _showImagesPanel) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              leading: const Icon(Icons.search),
              hintText: 'Search images...',
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          Expanded(
            child: _buildImageGallery(false),
          ),
        ],
      );
    } else if (_currentNavIndex == 1) {
      return Column(
        children: [
          // Tool selection tabs - scrollable for mobile
          Container(
            color: Colors.grey[100],
            height: 64,
            child: TabBar(
              controller: _toolTabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _analyticTools.map((tool) {
                return Tab(
                  icon: Icon(_getToolIcon(tool)),
                  text: tool,
                );
              }).toList(),
              onTap: (index) {
                setState(() {
                  _selectedTool = _analyticTools[index];
                });
              },
              indicatorWeight: 3,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[700],
            ),
          ),

          Expanded(
            child: _isComparisonMode
                ? _buildComparisonView()
                : _buildSingleImageView(false),
          ),
        ],
      );
    } else {
      // Settings tab
      return _buildSettingsView();
    }
  }

  Widget _buildTabletLayout(Size screenSize) {
    // Use a responsive layout where all components are visible
    return Row(
      children: [
        // Side panel for images - collapsible but always visible on tablets/desktops
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isDrawerOpen ? 280 : 60,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with toggle
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _isDrawerOpen ? 16 : 8,
                    vertical: 4,
                  ),
                  title: _isDrawerOpen
                      ? const Text('Patient Images',
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : null,
                  leading: IconButton(
                    icon: Icon(_isDrawerOpen
                        ? Icons.chevron_left
                        : Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _isDrawerOpen = !_isDrawerOpen;
                      });
                    },
                    tooltip: _isDrawerOpen ? 'Collapse Panel' : 'Expand Panel',
                  ),
                  trailing: _isDrawerOpen
                      ? IconButton(
                          icon: const Icon(Icons.add_photo_alternate),
                          onPressed: () => _addNewImage(),
                          tooltip: 'Add New Image',
                        )
                      : null,
                ),
                const Divider(height: 1),

                // Images grid/list
                Expanded(
                  child: _isDrawerOpen
                      ? _buildImageGallery(true)
                      : _buildCollapsedImageList(),
                ),
              ],
            ),
          ),
        ),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Tool selection tabs
              Container(
                color: Colors.grey[100],
                child: TabBar(
                  controller: _toolTabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _analyticTools.map((tool) {
                    return Tab(
                      icon: Icon(_getToolIcon(tool)),
                      text: tool,
                      height: 64,
                    );
                  }).toList(),
                  onTap: (index) {
                    setState(() {
                      _selectedTool = _analyticTools[index];
                    });
                  },
                  indicatorWeight: 3,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[700],
                ),
              ),

              // Image viewer and controls
              Expanded(
                child: _isComparisonMode
                    ? _buildComparisonView()
                    : _buildSingleImageView(true),
              ),
            ],
          ),
        ),

        // Analysis panel (only visible on wider screens)
        if (screenSize.width > 900 && _isAnalysisCompleted)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: _buildAnalysisResultsPanel(),
          ),
      ],
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Analysis Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Image display settings
        const Text(
          'Image Display',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildAdjustmentSlider(
          icon: Icons.brightness_6,
          label: 'Brightness',
          value: _brightness,
          min: -1.0,
          max: 1.0,
          onChanged: (value) => setState(() => _brightness = value),
        ),
        _buildAdjustmentSlider(
          icon: Icons.contrast,
          label: 'Contrast',
          value: _contrast,
          min: 0.5,
          max: 2.0,
          onChanged: (value) => setState(() => _contrast = value),
        ),

        // Display options
        const SizedBox(height: 24),
        const Text(
          'Display Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Show Grid'),
          subtitle: const Text('Display measurement grid overlay'),
          value: _showGrid,
          onChanged: (value) => setState(() => _showGrid = value),
        ),
        SwitchListTile(
          title: const Text('Show Annotations'),
          subtitle: const Text('Display AI-detected anomalies'),
          value: _showAnnotations,
          onChanged: (value) => setState(() => _showAnnotations = value),
        ),
        SwitchListTile(
          title: const Text('Show Measurements'),
          subtitle: const Text('Display size measurements'),
          value: _showMeasurements,
          onChanged: (value) => setState(() => _showMeasurements = value),
        ),

        // Analysis options
        const SizedBox(height: 24),
        const Text(
          'Analysis Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('AI Sensitivity'),
          subtitle: Slider(
            value: 0.7,
            onChanged: (value) {},
            divisions: 10,
            label: 'Medium',
          ),
        ),
        ListTile(
          title: const Text('Detection Threshold'),
          subtitle: Slider(
            value: 0.5,
            onChanged: (value) {},
            divisions: 10,
            label: 'Default',
          ),
        ),

        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('Restore Default Settings'),
            onPressed: () {
              // Implement restore defaults
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSingleImageView(bool isWideScreen) {
    return Column(
      children: [
        // Image viewer with controls
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Container(color: Colors.black),

              // Image content
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: _buildImageWithEffects(),
              ),

              // Overlays
              if (_showGrid)
                CustomPaint(
                  painter: GridPainter(),
                  size: Size.infinite,
                ),

              if (_showAnnotations) _buildAnnotations(),

              if (_showMeasurements)
                CustomPaint(
                  painter: MeasurementPainter(),
                  size: Size.infinite,
                ),

              // Image controls overlay - positioned differently on mobile
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildImageControlButton(
                            Icons.zoom_in,
                            'Zoom In',
                            () => setState(() => _zoomLevel =
                                (_zoomLevel + 0.25).clamp(0.5, 3.0))),
                        _buildImageControlButton(
                            Icons.zoom_out,
                            'Zoom Out',
                            () => setState(() => _zoomLevel =
                                (_zoomLevel - 0.25).clamp(0.5, 3.0))),
                        _buildImageControlButton(
                            Icons.rotate_90_degrees_ccw, 'Rotate', () {}),
                        _buildImageControlButton(Icons.flip, 'Mirror', () {}),
                        _buildImageControlButton(Icons.color_lens, 'Color Map',
                            () => _showColorMapSelector()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Controls and results
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient info bar - simplified on small screens
              _buildPatientInfoBar(isWideScreen),

              const Divider(height: 24),

              // Image adjustment controls
              if (!isWideScreen)
                // Simplified controls for mobile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.grid_on),
                      onPressed: () => setState(() => _showGrid = !_showGrid),
                      tooltip: 'Toggle Grid',
                      color: _showGrid
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: () =>
                          setState(() => _showAnnotations = !_showAnnotations),
                      tooltip: 'Toggle Annotations',
                      color: _showAnnotations
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.straighten),
                      onPressed: () => setState(
                          () => _showMeasurements = !_showMeasurements),
                      tooltip: 'Toggle Measurements',
                      color: _showMeasurements
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        setState(() {
                          _currentNavIndex = 2;
                          _navigationController
                              ?.animateTo(2); // Use null-safe call
                        });
                      },
                      tooltip: 'Settings',
                    ),
                  ],
                )
              else
                // Full controls for tablet/desktop
                ExpansionTile(
                  title: const Text(
                    'Image Adjustments',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false,
                  children: [
                    _buildAdjustmentSlider(
                      icon: Icons.brightness_6,
                      label: 'Brightness',
                      value: _brightness,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (value) => setState(() => _brightness = value),
                    ),
                    _buildAdjustmentSlider(
                      icon: Icons.contrast,
                      label: 'Contrast',
                      value: _contrast,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (value) => setState(() => _contrast = value),
                    ),
                    const SizedBox(height: 8),

                    // Toggle controls
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Grid'),
                          selected: _showGrid,
                          onSelected: (selected) =>
                              setState(() => _showGrid = selected),
                          avatar: _showGrid ? const Icon(Icons.grid_on) : null,
                        ),
                        FilterChip(
                          label: const Text('Annotations'),
                          selected: _showAnnotations,
                          onSelected: (selected) =>
                              setState(() => _showAnnotations = selected),
                          avatar: _showAnnotations
                              ? const Icon(Icons.edit_note)
                              : null,
                        ),
                        FilterChip(
                          label: const Text('Measurements'),
                          selected: _showMeasurements,
                          onSelected: (selected) =>
                              setState(() => _showMeasurements = selected),
                          avatar: _showMeasurements
                              ? const Icon(Icons.straighten)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),

              // Analysis results - always show on mobile if completed
              if (_isAnalysisCompleted)
                isWideScreen && MediaQuery.of(context).size.width > 900
                    ? const SizedBox
                        .shrink() // Results shown in side panel on large screens
                    : ExpansionTile(
                        title: Text(
                          'Analysis Results: $_selectedTool',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        initiallyExpanded: true,
                        children: [
                          _buildCondensedResults(),
                        ],
                      ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoBar(bool isWideScreen) {
    final currentImage = _recentImages[_selectedImageIndex];

    if (!isWideScreen) {
      // Simplified version for mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentImage['patientName']} (${currentImage['patientId']})',
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 12,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${currentImage['date']} · ${currentImage['examType']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      );
    }

    // Full version for tablet/desktop
    return Row(
      children: [
        const Icon(
          Icons.person_outline,
          size: 20,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          '${currentImage['patientName']} (${currentImage['patientId']})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        const Icon(
          Icons.calendar_today,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          '${currentImage['date']}',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        const Spacer(),
        ElevatedButton.icon(
          icon: const Icon(Icons.fact_check, size: 16),
          label: const Text('View Study'),
          onPressed: () => _viewFullStudy(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonView() {
    if (_comparisonImageIndex < 0 ||
        _comparisonImageIndex >= _recentImages.length ||
        _comparisonImageIndex == _selectedImageIndex) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.compare, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Select a different image to compare',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Exit Comparison Mode'),
              onPressed: () => _toggleComparisonMode(),
            ),
          ],
        ),
      );
    }

    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Expanded(
          child: isSmallScreen
              // Stack images vertically on small screens
              ? Column(
                  children: [
                    // Current image (top)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildComparisonImageStack(
                            _selectedImageIndex, 'Current'),
                      ),
                    ),

                    // Comparison image (bottom)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildComparisonImageStack(
                            _comparisonImageIndex, 'Previous'),
                      ),
                    ),
                  ],
                )
              // Stack images horizontally on larger screens
              : Row(
                  children: [
                    // Original image
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildComparisonImageStack(
                            _selectedImageIndex, 'Current'),
                      ),
                    ),

                    // Comparison image
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildComparisonImageStack(
                            _comparisonImageIndex, 'Previous'),
                      ),
                    ),
                  ],
                ),
        ),

        // Comparison controls - simplified for small screens
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSmallScreen)
                Text(
                  'Comparing images from different dates',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

              isSmallScreen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current: ${_recentImages[_selectedImageIndex]['date']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          'Previous: ${_recentImages[_comparisonImageIndex]['date']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_vert),
                          onPressed: () {
                            // Swap the images
                            final temp = _selectedImageIndex;
                            setState(() {
                              _selectedImageIndex = _comparisonImageIndex;
                              _comparisonImageIndex = temp;
                            });
                          },
                          tooltip: 'Swap Images',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Current:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
                                  Text(
                                      '${_recentImages[_selectedImageIndex]['date']}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Previous:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
                                  Text(
                                      '${_recentImages[_comparisonImageIndex]['date']}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: () {
                            // Swap the images
                            final temp = _selectedImageIndex;
                            setState(() {
                              _selectedImageIndex = _comparisonImageIndex;
                              _comparisonImageIndex = temp;
                            });
                          },
                          tooltip: 'Swap Images',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _toggleComparisonMode(),
                          tooltip: 'Exit Comparison',
                        ),
                      ],
                    ),

              const SizedBox(height: 16),
              // Responsive button layout for different screen sizes
              isSmallScreen
                  ? Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.difference),
                          label: const Text('Show Differences'),
                          onPressed: () => _highlightDifferences(),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.animation),
                                label: const Text('Animation'),
                                onPressed: () => _showAnimatedComparison(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.document_scanner),
                                label: const Text('Report'),
                                onPressed: () => _generateComparisonReport(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.difference),
                          label: const Text('Show Differences'),
                          onPressed: () => _highlightDifferences(),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.animation),
                          label: const Text('Animation View'),
                          onPressed: () => _showAnimatedComparison(),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.document_scanner),
                          label: const Text('Comparison Report'),
                          onPressed: () => _generateComparisonReport(),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonImageStack(int imageIndex, String label) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 120,
                  color: Colors.white.withOpacity(0.3),
                ),
                Text(
                  '${_recentImages[imageIndex]['examType']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_recentImages[imageIndex]['date']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(bool isWideScreen) {
    // Determine the layout based on screen size
    final bool useTile = MediaQuery.of(context).size.width < 400;

    if (useTile) {
      // Use list tiles on very small screens
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _recentImages.length,
        itemBuilder: (context, index) {
          final image = _recentImages[index];
          final isSelected = _selectedImageIndex == index;
          final isComparisonSelected = _comparisonImageIndex == index;

          return ListTile(
            selected: isSelected,
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(
                _getImageTypeIcon(image['examType']),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              '${image['examType']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${image['patientName']} • ${image['date']}'),
            trailing: isComparisonSelected
                ? const Icon(Icons.compare_arrows, color: Colors.amber)
                : null,
            onTap: () {
              setState(() {
                if (_isComparisonMode && _selectedImageIndex != index) {
                  _comparisonImageIndex = index;
                } else {
                  _selectedImageIndex = index;
                }

                // On mobile, switch to analysis tab after selecting image
                // Add null check for navigation controller
                if (MediaQuery.of(context).size.width < 600) {
                  _currentNavIndex = 1;
                  _showImagesPanel = false;
                  _navigationController?.animateTo(1); // Use null-safe call
                }
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isComparisonSelected
                        ? Colors.amber
                        : Colors.transparent,
                width: 2,
              ),
            ),
          );
        },
      );
    } else {
      // Use grid view on larger screens
      final crossAxisCount =
          isWideScreen ? 2 : (MediaQuery.of(context).size.width > 400 ? 2 : 1);

      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _recentImages.length,
        itemBuilder: (context, index) {
          final image = _recentImages[index];
          final isSelected = _selectedImageIndex == index;
          final isComparisonSelected = _comparisonImageIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (_isComparisonMode && _selectedImageIndex != index) {
                  _comparisonImageIndex = index;
                } else {
                  _selectedImageIndex = index;
                }

                // On mobile, switch to analysis tab after selecting image
                // Add null check for navigation controller
                if (MediaQuery.of(context).size.width < 600) {
                  _currentNavIndex = 1;
                  _showImagesPanel = false;
                  _navigationController?.animateTo(1); // Use null-safe call
                }
              });
            },
            child: Card(
              elevation: isSelected || isComparisonSelected ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isComparisonSelected
                          ? Colors.amber
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      width: double.infinity,
                      child: Center(
                        child: Icon(
                          _getImageTypeIcon(image['examType']),
                          size: 48,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                  // Info section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${image['examType']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isComparisonSelected)
                              const Icon(
                                Icons.compare_arrows,
                                color: Colors.amber,
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${image['patientName']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${image['date']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(image['status'])
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${image['status']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(image['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildCollapsedImageList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _recentImages.length,
      itemBuilder: (context, index) {
        final image = _recentImages[index];
        final isSelected = _selectedImageIndex == index;
        final isComparisonSelected = _comparisonImageIndex == index;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : isComparisonSelected
                    ? Colors.amber.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              _getImageTypeIcon(image['examType']),
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isComparisonSelected
                      ? Colors.amber
                      : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if (_isComparisonMode && _selectedImageIndex != index) {
                  _comparisonImageIndex = index;
                } else {
                  _selectedImageIndex = index;
                }
              });
            },
            tooltip: '${image['examType']} - ${image['date']}',
          ),
        );
      },
    );
  }

  // Widget _buildPatientInfoBar() {
  //   final currentImage = _recentImages[_selectedImageIndex];

  //   return Row(
  //     children: [
  //       const Icon(
  //         Icons.person_outline,
  //         size: 20,
  //         color: Colors.grey,
  //       ),
  //       const SizedBox(width: 8),
  //       Text(
  //         '${currentImage['patientName']} (${currentImage['patientId']})',
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(width: 16),
  //       const Icon(
  //         Icons.calendar_today,
  //         size: 16,
  //         color: Colors.grey,
  //       ),
  //       const SizedBox(width: 4),
  //       Text(
  //         '${currentImage['date']}',
  //         style: TextStyle(fontSize: 12, color: Colors.grey[700]),
  //       ),
  //       const Spacer(),
  //       ElevatedButton.icon(
  //         icon: const Icon(Icons.fact_check, size: 16),
  //         label: const Text('View Study'),
  //         onPressed: () => _viewFullStudy(),
  //         style: ElevatedButton.styleFrom(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //           textStyle: const TextStyle(fontSize: 12),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildAdjustmentSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label),
                    Text(value.toStringAsFixed(1)),
                  ],
                ),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: 20,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () {
              if (label == 'Brightness') {
                onChanged(0.0);
              } else if (label == 'Contrast') {
                onChanged(1.0);
              }
            },
            tooltip: 'Reset',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithEffects() {
    // In a real app, you would apply brightness and contrast to an actual image
    // This is just a placeholder demonstration
    final selectedImage = _recentImages[_selectedImageIndex];

    return ColorFiltered(
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
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Transform.scale(
                scale: _zoomLevel,
                child: Icon(
                  _getImageTypeIcon(selectedImage['examType']),
                  size: 200,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            Center(
              child: Text(
                '${selectedImage['examType']}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotations() {
    return Stack(
      children: [
        Positioned(
          top: 60,
          left: 150,
          child: _buildAnnotationMarker(
            'Nodule detected',
            'Size: 5.2mm, Confidence: 87%',
            Colors.red,
          ),
        ),
        Positioned(
          bottom: 120,
          right: 180,
          child: _buildAnnotationMarker(
            'Abnormal density',
            'Pattern consistent with fibrosis',
            Colors.orange,
          ),
        ),
        if (_isAnalysisCompleted)
          Positioned(
            bottom: 200,
            left: 120,
            child: _buildAnnotationMarker(
              'Normal region',
              'No abnormalities detected',
              Colors.green,
            ),
          ),
      ],
    );
  }

  Widget _buildAnnotationMarker(String title, String detail, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageControlButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildAnalysisResultsPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 8,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Analysis Results',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _selectedTool,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          const Divider(),

          // Key findings section
          const Text(
            'Key Findings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _analyticsResults[_selectedTool]?.length ?? 0,
              itemBuilder: (context, index) {
                final finding = _analyticsResults[_selectedTool]?[index] ?? '';
                final color = index == 0
                    ? Colors.red
                    : index == 1
                        ? Colors.orange
                        : Colors.green;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          radius: 12,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(finding),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // AI confidence score
          const Text(
            'AI Confidence Score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.87,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%'),
              Text('87%', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('100%'),
            ],
          ),
          const SizedBox(height: 24),

          // Action buttons
          ElevatedButton.icon(
            icon: const Icon(Icons.document_scanner),
            label: const Text('Generate Detailed Report'),
            onPressed: () => _generateReport(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Send to PACS'),
            onPressed: () => _sendToPACS(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.history),
            label: const Text('View Analysis History'),
            onPressed: () => _showAnalysisHistory(),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCondensedResults() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display findings
          for (int i = 0;
              i < (_analyticsResults[_selectedTool]?.length ?? 0);
              i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: i == 0
                        ? Colors.red.withOpacity(0.2)
                        : i == 1
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: i == 0
                            ? Colors.red
                            : i == 1
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _analyticsResults[_selectedTool]?[i] ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
          const Row(
            children: [
              Text('AI Confidence: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('87%'),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _generateReport(),
                  child: const Text('Report'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDetailedResults(),
                  child: const Text('Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Utility methods
  IconData _getImageTypeIcon(dynamic examType) {
    switch (examType) {
      case 'Chest X-Ray':
        return Icons.panorama;
      case 'CT Scan - Lungs':
        return Icons.view_in_ar;
      case 'MRI - Thoracic':
        return Icons.scatter_plot;
      default:
        return Icons.image;
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status) {
      case 'Pending Analysis':
        return Colors.amber[800]!;
      case 'In Progress':
        return Colors.blue[800]!;
      case 'Completed':
        return Colors.green[800]!;
      default:
        return Colors.grey;
    }
  }

  // Action methods
  void _toggleComparisonMode() {
    setState(() {
      _isComparisonMode = !_isComparisonMode;
      if (!_isComparisonMode) {
        // Reset comparison image when exiting comparison mode
        _comparisonImageIndex = -1;
      } else if (_comparisonImageIndex < 0) {
        // If entering comparison mode, select the first image that's not the current one
        for (int i = 0; i < _recentImages.length; i++) {
          if (i != _selectedImageIndex) {
            _comparisonImageIndex = i;
            break;
          }
        }
      }
    });
  }

  void _runAnalysis() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    Text(
                      'Running $_selectedTool',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Analyzing image patterns...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate analysis processing
    Future.delayed(const Duration(seconds: 2), () {
      context.pop(); // Close loading dialog

      setState(() {
        _isAnalysisCompleted = true;
        _recentImages[_selectedImageIndex]['status'] = 'Completed';

        // Make sure tab is in sync
        _updateSelectedTab();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedTool completed successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VIEW RESULTS',
            textColor: Colors.white,
            onPressed: () => _showDetailedResults(),
          ),
        ),
      );
    });
  }

  void _showDetailedResults() {
    if (!_isAnalysisCompleted) return;

    // This would show a modal with detailed results
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.analytics, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTool,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Analysis completed on ${_recentImages[_selectedImageIndex]['date']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                // Results content would go here
                const Text(
                  'Detailed Analysis Results',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Just example UI - would be replaced with actual results
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (String finding
                          in _analyticsResults[_selectedTool] ?? [])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(finding)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                        _generateReport();
                      },
                      child: const Text('Generate Report'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewImage() {
    // Show a dialog to upload or import a new image
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload from Local Storage'),
                onTap: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Upload functionality would be implemented here')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Import from PACS'),
                onTap: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('PACS integration would be implemented here')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Import from Scanner'),
                onTap: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Scanner integration would be implemented here')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showColorMapSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color Map'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
                _colorMapOption('Original', Colors.black),
                _colorMapOption('Thermal', Colors.red),
                _colorMapOption('Rainbow', Colors.purple),
                _colorMapOption('Inverted', Colors.white),
                _colorMapOption('Grayscale', Colors.grey),
                _colorMapOption('Bone', Colors.blueGrey),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _colorMapOption(String name, Color primaryColor) {
    return InkWell(
      onTap: () {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied $name color map')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: primaryColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(name),
        ],
      ),
    );
  }

  void _highlightDifferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Highlighting image differences')),
    );
  }

  void _showAnimatedComparison() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing animated comparison')),
    );
  }

  void _generateComparisonReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating comparison report')),
    );
  }

  void _viewFullStudy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening full patient study')),
    );
  }

  void _sendToPACS() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending results to PACS system')),
    );
  }

  void _showAnalysisHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Analysis History'),
          content:
              const Text('This feature will show previous analyses performed.'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _saveAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Analysis saved successfully'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _shareAnalysis() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Analysis'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share this analysis with:'),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Referring Doctor'),
                subtitle: Text('Dr. Jennifer Wilson'),
                trailing: Icon(Icons.check_circle),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Pulmonology Department'),
                trailing: Icon(Icons.check_box_outline_blank),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            ElevatedButton(
              child: Text('Share'),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generate Report'),
          content: const Text(
              'This will generate a structured report based on the current analysis.'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Report generated successfully'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  IconData _getToolIcon(String tool) {
    switch (tool) {
      case 'Nodule Detection':
        return Icons.search;
      case 'Pneumonia Assessment':
        return Icons.air;
      case 'Lung Capacity Analysis':
        return Icons.pie_chart;
      case 'COPD Progression':
        return Icons.trending_up;
      case 'Infiltration Pattern Recognition':
        return Icons.grid_view;
      case 'Pleural Effusion Quantification':
        return Icons.opacity;
      case 'COVID-19 Markers':
        return Icons.coronavirus;
      case '3D Reconstruction':
        return Icons.view_in_ar;
      default:
        return Icons.healing;
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }

    // Draw horizontal lines
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MeasurementPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.0;

    // Draw a sample measurement line
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.6),
      paint,
    );

    // Draw small circles at endpoints
    final circlePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.4), 4.0, circlePaint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.6), 4.0, circlePaint);

    // Draw measurement text
    const textStyle = TextStyle(
      color: Colors.yellow,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '5.2 mm',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 100,
    );
    textPainter.paint(
      canvas,
      Offset(size.width * 0.4, size.height * 0.5),
    );

    // Draw another measurement - circle for area
    final areaPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.3), 30.0, areaPaint);

    // Draw outline
    final outlinePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.3), 30.0, outlinePaint);

    // Draw area text
    final areaTextSpan = TextSpan(
      text: 'Area: 18.3 cm²',
      style: textStyle,
    );
    final areaTextPainter = TextPainter(
      text: areaTextSpan,
      textDirection: TextDirection.ltr,
    );
    areaTextPainter.layout(
      minWidth: 0,
      maxWidth: 150,
    );
    areaTextPainter.paint(
      canvas,
      Offset(size.width * 0.7 - 40, size.height * 0.3 - 40),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
