import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AdvancedVisualizationLabScreen extends StatefulWidget {
  const AdvancedVisualizationLabScreen({super.key});

  @override
  State<AdvancedVisualizationLabScreen> createState() =>
      _AdvancedVisualizationLabScreenState();
}

class _AdvancedVisualizationLabScreenState
    extends State<AdvancedVisualizationLabScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _imageStudies = [];
  bool _isLoading = true;
  bool _isToolPanelExpanded = false;
  int _selectedImageIndex = 0;
  int _selectedToolIndex = 0;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _zoom = 1.0;
  double _rotation = 0.0;
  bool _isInverted = false;
  bool _isInThreeDMode = false;
  bool _is3DLoading = false;
  bool _showCrosshairs = false;
  String _selectedColorMap = 'Grayscale';
  int _selectedLayer = 0;
  bool _isSidePanelCollapsed = false;
  double _sidePanelWidth = 280;

  final List<String> _colorMaps = [
    'Grayscale',
    'Jet',
    'Rainbow',
    'Hot',
    'Cool',
    'Bone',
    'Plasma',
    'Viridis',
  ];

  final List<String> _measurementTools = [
    'Distance',
    'Angle',
    'Area',
    'Volume',
    'Density',
    'Profile',
  ];

  final List<String> _visualizationTools = [
    'Pan',
    'Zoom',
    'Window/Level',
    'Rotate',
    'Magnify',
    'Crop',
  ];

  final List<String> _segmentationTools = [
    'Auto Segment',
    'Manual Draw',
    'Threshold',
    'Region Growing',
    'Machine Learning',
  ];

  // New state variables
  late TabController _mainTabController;
  late TabController _viewModeTabController;
  int _selectedViewMode = 0;
  List<String> _viewModes = ['Single View', 'Side by Side', 'Quad View'];
  bool _showAdvancedTools = false;
  String _activeToolCategory = 'Visualization';
  String _searchQuery = '';
  Map<String, String> _keyboardShortcuts = {
    'Ctrl+1': 'Single View',
    'Ctrl+2': 'Side by Side',
    'Ctrl+3': 'Quad View',
    'Ctrl+Z': 'Zoom',
    'Ctrl+R': 'Rotate',
    'Ctrl+B': 'Brightness',
    'Ctrl+I': 'Invert Colors',
    'Ctrl+3D': '3D Mode',
    'Spacebar': 'Pan Mode',
    'Esc': 'Reset View',
  };

  // Mobile optimization variables
  bool _showStudyList = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadImages();
    _mainTabController = TabController(length: 3, vsync: this);
    _viewModeTabController = TabController(length: 3, vsync: this);
    _viewModeTabController.addListener(_handleViewModeChange);

    // For mobile, start with side panel collapsed
    _isSidePanelCollapsed = true;

    // Initialize with single view for mobile
    _selectedViewMode = 0;
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _viewModeTabController.dispose();
    super.dispose();
  }

  void _handleViewModeChange() {
    setState(() {
      _selectedViewMode = _viewModeTabController.index;
    });
  }

  void _filterStudies(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _setToolCategory(String category) {
    setState(() {
      _activeToolCategory = category;
    });
  }

  Future<void> _loadImages() async {
    // Simulate loading imaging studies
    await Future.delayed(const Duration(seconds: 2));

    final studies = _generateMockStudies();

    setState(() {
      _imageStudies.addAll(studies);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _generateMockStudies() {
    final studies = <Map<String, dynamic>>[];

    for (int i = 0; i < 10; i++) {
      final studyType = _getRandomStudyType();
      final patientName = _getRandomPatientName();
      final date =
          DateTime.now().subtract(Duration(days: math.Random().nextInt(30)));

      studies.add({
        'id': 'STD${1000 + i}',
        'patientName': patientName,
        'patientId': 'P${1000 + i}',
        'type': studyType,
        'date': date,
        'imageCount': 10 + math.Random().nextInt(90),
        'hasAnnotations': math.Random().nextBool(),
        'hasMeasurements': math.Random().nextBool(),
        'isComplete': math.Random().nextBool(),
        'modality': _getModalityForStudyType(studyType),
        'description': 'Advanced medical imaging study for detailed analysis',
        'referringPhysician': _getRandomDoctorName()
      });
    }

    return studies;
  }

  String _getRandomStudyType() {
    final studyTypes = [
      'Brain MRI',
      'Chest CT',
      'Abdominal CT',
      'Lung CT',
      'Spine MRI',
      'Cardiac MRI',
      'Pelvic MRI',
      'DEXA Scan',
      'Full Body PET-CT',
      'Angiography',
    ];

    return studyTypes[math.Random().nextInt(studyTypes.length)];
  }

  String _getModalityForStudyType(String studyType) {
    if (studyType.contains('CT')) {
      return 'Computed Tomography';
    } else if (studyType.contains('MRI')) {
      return 'Magnetic Resonance';
    } else if (studyType.contains('PET')) {
      return 'Positron Emission Tomography';
    } else if (studyType.contains('DEXA')) {
      return 'Dual-energy X-ray Absorptiometry';
    } else if (studyType.contains('Angiography')) {
      return 'Digital Subtraction Angiography';
    }
    return 'Advanced Imaging';
  }

  String _getRandomPatientName() {
    final firstNames = [
      'James',
      'Mary',
      'John',
      'Patricia',
      'Robert',
      'Jennifer',
      'Michael',
      'Linda',
      'William',
      'Elizabeth'
    ];

    final lastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Jones',
      'Brown',
      'Davis',
      'Miller',
      'Wilson',
      'Moore',
      'Taylor'
    ];

    return '${firstNames[math.Random().nextInt(firstNames.length)]} ${lastNames[math.Random().nextInt(lastNames.length)]}';
  }

  String _getRandomDoctorName() {
    final firstNames = [
      'Sarah',
      'Michael',
      'Lisa',
      'Robert',
      'Emily',
      'David',
      'Jennifer',
      'Thomas',
      'Maria',
      'Richard'
    ];

    final lastNames = [
      'Johnson',
      'Chen',
      'Wong',
      'Miller',
      'Davis',
      'Garcia',
      'Rodriguez',
      'Wilson',
      'Anderson',
      'Taylor'
    ];

    return 'Dr. ${firstNames[math.Random().nextInt(firstNames.length)]} ${lastNames[math.Random().nextInt(lastNames.length)]}';
  }

  void _toggleToolPanel() {
    setState(() {
      _isToolPanelExpanded = !_isToolPanelExpanded;
    });
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _selectTool(int index) {
    setState(() {
      _selectedToolIndex = index;
    });
  }

  void _updateBrightness(double value) {
    setState(() {
      _brightness = value;
    });
  }

  void _updateContrast(double value) {
    setState(() {
      _contrast = value;
    });
  }

  void _updateZoom(double value) {
    setState(() {
      _zoom = value;
    });
  }

  void _updateRotation(double value) {
    setState(() {
      _rotation = value;
    });
  }

  void _toggleInversion() {
    setState(() {
      _isInverted = !_isInverted;
    });
  }

  void _toggle3DMode() {
    setState(() {
      _is3DLoading = true;
    });

    // Simulate 3D rendering
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isInThreeDMode = !_isInThreeDMode;
        _is3DLoading = false;
      });
    });
  }

  void _toggleCrosshairs() {
    setState(() {
      _showCrosshairs = !_showCrosshairs;
    });
  }

  void _setColorMap(String colorMap) {
    setState(() {
      _selectedColorMap = colorMap;
    });
  }

  void _selectLayer(int layer) {
    setState(() {
      _selectedLayer = layer;
    });
  }

  void _showStudyInfoDialog(Map<String, dynamic> study) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Patient Name', study['patientName']),
                _buildInfoRow('Patient ID', study['patientId']),
                _buildInfoRow('Study Type', study['type']),
                _buildInfoRow('Modality', study['modality']),
                _buildInfoRow('Date', study['date'].toString().split(' ')[0]),
                _buildInfoRow('Images', study['imageCount'].toString()),
                _buildInfoRow(
                    'Referring Physician', study['referringPhysician']),
                _buildInfoRow(
                    'Annotations', study['hasAnnotations'] ? 'Yes' : 'No'),
                _buildInfoRow(
                    'Measurements', study['hasMeasurements'] ? 'Yes' : 'No'),
                _buildInfoRow(
                    'Status', study['isComplete'] ? 'Complete' : 'In Progress'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isSmallScreen = screenWidth < 1100;

    // Always use smaller panel width on mobile
    if (isMobile && !_isSidePanelCollapsed) {
      _sidePanelWidth = screenWidth * 0.85;
    } else if (isTablet && !_isSidePanelCollapsed) {
      _sidePanelWidth = 280;
    } else if (!isSmallScreen && !_isSidePanelCollapsed) {
      _sidePanelWidth = 280;
    } else {
      _sidePanelWidth = 0; // Fully collapsed on mobile
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Visualization Lab'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading medical imaging studies...'),
              SizedBox(height: 8),
              Text('Please wait while we prepare your workspace',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title:
            Text(isMobile ? 'Med Visualization' : 'Advanced Visualization Lab'),
        elevation: 0,
        leading: isMobile
            ? IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    _showStudyList = !_showStudyList;
                  });
                },
              )
            : null,
        bottom: isMobile
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    controller: _mainTabController,
                    tabs: [
                      Tab(icon: Icon(Icons.visibility), text: 'Visualization'),
                      Tab(icon: Icon(Icons.edit), text: 'Analysis'),
                      Tab(icon: Icon(Icons.settings), text: 'Settings'),
                    ],
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                  ),
                ),
              ),
        actions: _buildAppBarActions(isMobile),
      ),
      body: isMobile
          ? _buildMobileLayout(screenWidth, screenHeight)
          : TabBarView(
              controller: _mainTabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // Visualization Tab
                _buildVisualizationTab(isSmallScreen, screenWidth),

                // Analysis Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Analysis Tools', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text(
                          'Advanced measurement and analysis tools will be available here',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),

                // Settings Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Settings', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text(
                          'Application preferences and configuration options will be available here',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isMobile
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.image),
                    tooltip: 'Studies',
                    onPressed: () {
                      setState(() {
                        _showStudyList = !_showStudyList;
                      });
                    },
                    color:
                        _showStudyList ? Theme.of(context).primaryColor : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.view_carousel),
                    tooltip: 'View Mode',
                    onPressed: () {
                      _showViewModeBottomSheet(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.tune),
                    tooltip: 'Tools',
                    onPressed: _toggleToolPanel,
                    color: _isToolPanelExpanded
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    tooltip: 'More',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildMoreOptionsSheet(),
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              mini: true,
              child: Icon(_showAdvancedTools ? Icons.close : Icons.add),
              onPressed: () {
                setState(() {
                  _showAdvancedTools = !_showAdvancedTools;
                });
              },
            )
          : null,
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Main visualization area
        _buildMobileVisualizationArea(),

        // Overlay for study list (slide in from left)
        if (_showStudyList)
          Positioned.fill(
            child: Stack(
              children: [
                // Semi-transparent backdrop
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showStudyList = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),

                // Study list panel
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: screenWidth * 0.85,
                  child: Material(
                    elevation: 16,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Studies',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _showStudyList = false;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search studies...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                              onChanged: _filterStudies,
                            ),
                          ),
                          Expanded(
                            child: _buildExpandedStudyList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Tool panel
        if (_isToolPanelExpanded)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: screenWidth * 0.85,
            child: _buildMobileToolPanel(),
          ),

        // Quick tools menu (when activated)
        if (_showAdvancedTools)
          Positioned(
            bottom: 60,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickToolButton(Icons.invert_colors, 'Invert',
                    _isInverted, () => _toggleInversion()),
                SizedBox(height: 8),
                _buildQuickToolButton(Icons.view_in_ar, '3D Mode',
                    _isInThreeDMode, () => _toggle3DMode()),
                SizedBox(height: 8),
                _buildQuickToolButton(Icons.add, 'Crosshair', _showCrosshairs,
                    () => _toggleCrosshairs()),
                SizedBox(height: 8),
                _buildQuickToolButton(Icons.zoom_in, 'Zoom', false, () {
                  setState(() {
                    _zoom = math.min(_zoom + 0.1, 3.0);
                  });
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickToolButton(
      IconData icon, String tooltip, bool isActive, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: isActive ? Colors.white : Colors.grey[800],
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildMobileVisualizationArea() {
    return Column(
      children: [
        // Main image display area
        Expanded(
          child: _buildSingleView(true),
        ),

        // Bottom control bar with layer navigation
        Container(
          height: 56,
          color: Colors.grey[900],
          child: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.keyboard_arrow_left, color: Colors.white),
                onPressed: _selectedLayer > 0
                    ? () => _selectLayer(_selectedLayer - 1)
                    : null,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.blue[100],
                    trackHeight: 3.0,
                    thumbColor: Colors.white,
                    overlayColor: Colors.blue.withAlpha(32),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14.0),
                  ),
                  child: Slider(
                    min: 0,
                    max: 99,
                    value: _selectedLayer.toDouble(),
                    onChanged: (value) => _selectLayer(value.toInt()),
                  ),
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                onPressed: _selectedLayer < 99
                    ? () => _selectLayer(_selectedLayer + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileToolPanel() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      elevation: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tool panel header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Image Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _toggleToolPanel,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Tool categories - as tabs for mobile
          DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Visual'),
                    Tab(text: 'Measure'),
                    Tab(text: 'Advanced'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Container(
                  height: 500, // Fixed height for mobile
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: TabBarView(
                    children: [
                      _buildVisualizationTools(true),
                      _buildMeasurementTools(true),
                      _buildSegmentationTools(true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showViewModeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select View Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              ...List.generate(
                _viewModes.length,
                (index) => ListTile(
                  leading: Icon(
                    index == 0
                        ? Icons.fullscreen
                        : index == 1
                            ? Icons.view_agenda
                            : Icons.grid_view,
                    color: _selectedViewMode == index
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  title: Text(_viewModes[index]),
                  selected: _selectedViewMode == index,
                  onTap: () {
                    setState(() {
                      _selectedViewMode = index;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreOptionsSheet() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'More Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Color Map'),
            subtitle: Text(_selectedColorMap),
            onTap: () {
              Navigator.pop(context);
              _showColorMapSelector(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('Download Image'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading image...')));
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Sharing image...')));
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help & Shortcuts'),
            onTap: () {
              Navigator.pop(context);
              _showKeyboardShortcutsDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showColorMapSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Color Map',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorMaps.map((colorMap) {
                  return ChoiceChip(
                    label: Text(colorMap),
                    selected: _selectedColorMap == colorMap,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColorMap = colorMap;
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildAppBarActions(bool isMobile) {
    if (isMobile) {
      return [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            if (_imageStudies.isNotEmpty) {
              _showStudyInfoDialog(_imageStudies[_selectedImageIndex]);
            }
          },
          tooltip: 'Info',
        ),
      ];
    }

    // Return desktop actions
    return [
      IconButton(
        icon: const Icon(Icons.help_outline),
        onPressed: () => _showKeyboardShortcutsDialog(),
        tooltip: 'Help & Shortcuts',
      ),
      IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          if (_imageStudies.isNotEmpty) {
            _showStudyInfoDialog(_imageStudies[_selectedImageIndex]);
          }
        },
        tooltip: 'Study Information',
      ),
      ...[
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Downloading image...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Download Image',
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sharing image...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Share Image',
        ),
        IconButton(
          icon: const Icon(Icons.print),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sending to printer...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Print Image',
        ),
      ],
    ];
  }

  Widget _buildVisualizationTab(bool isSmallScreen, double screenWidth) {
    return Column(
      children: [
        // View mode selector
        Container(
          color: Colors.grey[100],
          padding: EdgeInsets.symmetric(vertical: 8),
          child: TabBar(
            controller: _viewModeTabController,
            tabs: _viewModes.map((mode) => Tab(text: mode)).toList(),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[700],
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),

        // Main content area
        Expanded(
          child: Row(
            children: [
              // Study browser
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _sidePanelWidth,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    if (!_isSidePanelCollapsed) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search studies...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: _filterStudies,
                        ),
                      ),

                      // Filters and sorting
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text('Sort by:'),
                            SizedBox(width: 4),
                            DropdownButton<String>(
                              value: 'Date',
                              isDense: true,
                              underline: SizedBox(),
                              items:
                                  ['Date', 'Name', 'Type'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (newValue) {},
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.filter_list, size: 16),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Filter options will be added soon'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              tooltip: 'Filter',
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],

                    // Study list
                    Expanded(
                      child: !_isSidePanelCollapsed
                          ? _buildExpandedStudyList()
                          : _buildCollapsedStudyList(),
                    ),
                  ],
                ),
              ),

              // Toggle button for side panel
              if (!isSmallScreen)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSidePanelCollapsed = !_isSidePanelCollapsed;
                    });
                  },
                  child: Container(
                    width: 20,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        _isSidePanelCollapsed
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

              // Main visualization area
              Expanded(
                child: _buildMainVisualizationArea(isSmallScreen, screenWidth),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedStudyList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _imageStudies.length,
      itemBuilder: (context, index) {
        final study = _imageStudies[index];

        // Filter studies based on search query if needed
        if (_searchQuery.isNotEmpty) {
          final String patientName =
              study['patientName'].toString().toLowerCase();
          final String studyType = study['type'].toString().toLowerCase();
          final String patientId = study['patientId'].toString().toLowerCase();

          if (!patientName.contains(_searchQuery) &&
              !studyType.contains(_searchQuery) &&
              !patientId.contains(_searchQuery)) {
            return SizedBox.shrink();
          }
        }

        final isSelected = _selectedImageIndex == index;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: isSelected ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: InkWell(
            onTap: () => _selectImage(index),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        study['modality']
                            .toString()
                            .substring(0, 2)
                            .toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          study['type'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          study['patientName'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${study['date'].toString().split(' ')[0]} • ${study['imageCount']} images',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (study['hasAnnotations'])
                        Tooltip(
                          message: 'Has annotations',
                          child: Icon(
                            Icons.comment,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                        ),
                      SizedBox(height: 4),
                      if (study['hasMeasurements'])
                        Tooltip(
                          message: 'Has measurements',
                          child: Icon(
                            Icons.straighten,
                            size: 14,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedStudyList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _imageStudies.length,
      itemBuilder: (context, index) {
        final study = _imageStudies[index];
        final isSelected = _selectedImageIndex == index;

        return Material(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          child: InkWell(
            onTap: () => _selectImage(index),
            child: Tooltip(
              message: "${study['type']} - ${study['patientName']}",
              child: Container(
                height: 60,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: Colors.blue,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      study['modality']
                          .toString()
                          .substring(0, 2)
                          .toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainVisualizationArea(bool isSmallScreen, double screenWidth) {
    return Stack(
      children: [
        // View area with multiple view modes
        Column(
          children: [
            // Main visualization area
            Expanded(
              child: _selectedViewMode == 0
                  ? _buildSingleView(isSmallScreen)
                  : _selectedViewMode == 1
                      ? _buildSideBySideView(isSmallScreen)
                      : _buildQuadView(isSmallScreen),
            ),

            // Bottom navigation bar for toolset access and layer navigation
            _buildBottomToolbar(isSmallScreen),
          ],
        ),

        // Floating tool button
        Positioned(
          bottom: 80,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showAdvancedTools)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildToolButton(
                          Icons.view_in_ar, '3D View', () => _toggle3DMode()),
                      _buildToolButton(
                          Icons.add, 'Crosshair', () => _toggleCrosshairs()),
                      _buildToolButton(Icons.invert_colors, 'Invert',
                          () => _toggleInversion()),
                      _buildToolButton(Icons.straighten, 'Measure', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Measuring tool activated')),
                        );
                      }),
                    ],
                  ),
                ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showAdvancedTools = !_showAdvancedTools;
                  });
                },
                child: Icon(_showAdvancedTools ? Icons.close : Icons.add),
              ),
            ],
          ),
        ),

        // Tool panel with improved organization
        if (_isToolPanelExpanded) _buildToolPanel(isSmallScreen, screenWidth),
      ],
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onPressed) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildSingleView(bool isSmallScreen) {
    return _buildImageView(0, isSmallScreen, fullScreen: true);
  }

  Widget _buildSideBySideView(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(child: _buildImageView(0, isSmallScreen)),
        VerticalDivider(width: 1, color: Colors.grey[700]),
        Expanded(child: _buildImageView(1, isSmallScreen)),
      ],
    );
  }

  Widget _buildQuadView(bool isSmallScreen) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImageView(0, isSmallScreen)),
              VerticalDivider(width: 1, color: Colors.grey[700]),
              Expanded(child: _buildImageView(1, isSmallScreen)),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[700]),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImageView(2, isSmallScreen)),
              VerticalDivider(width: 1, color: Colors.grey[700]),
              Expanded(child: _buildImageView(3, isSmallScreen)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageView(int viewIndex, bool isSmallScreen,
      {bool fullScreen = false}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main image
        Container(
          color: Colors.black,
          child: Center(
            child: Stack(
              children: [
                Transform.rotate(
                  angle: _rotation * math.pi / 180,
                  child: Transform.scale(
                    scale: _zoom,
                    child: Container(
                      width: fullScreen ? 500 : 300,
                      height: fullScreen ? 500 : 300,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: _isInverted
                              ? [Colors.white, Colors.white.withOpacity(0.7)]
                              : [Colors.black, Colors.black.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(
                          color: _isInThreeDMode
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: _is3DLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isInThreeDMode)
                                  Text(
                                    '3D Volume Rendering',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: fullScreen ? 24 : 18,
                                    ),
                                  ),
                                Text(
                                  'View ${viewIndex + 1}: ${viewIndex == 0 ? "Axial" : viewIndex == 1 ? "Coronal" : viewIndex == 2 ? "Sagittal" : "3D"}',
                                  style: TextStyle(
                                    color: _isInverted
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fullScreen ? 16 : 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _imageStudies.isNotEmpty
                                      ? _imageStudies[_selectedImageIndex]
                                          ['type']
                                      : '',
                                  style: TextStyle(
                                    color: _isInverted
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: fullScreen ? 14 : 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Layer: ${_selectedLayer + 1} / 100',
                                  style: TextStyle(
                                    color: _isInverted
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: fullScreen ? 14 : 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Color Map: $_selectedColorMap',
                                  style: TextStyle(
                                    color: _isInverted
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: fullScreen ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                // Crosshairs
                if (_showCrosshairs)
                  IgnorePointer(
                    child: Center(
                      child: Stack(
                        children: [
                          // Vertical line
                          Center(
                            child: Container(
                              width: 1,
                              height: double.infinity,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),

                          // Horizontal line
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // View information overlay (top-left)
        if (_imageStudies.isNotEmpty)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _imageStudies[_selectedImageIndex]['patientName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fullScreen ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _imageStudies[_selectedImageIndex]['patientId'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fullScreen ? 10 : 8,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // View controls (bottom-right)
        Positioned(
          bottom: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fullScreen || !isSmallScreen)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            _zoom = math.min(_zoom + 0.1, 3.0);
                          });
                        },
                        tooltip: 'Zoom In',
                        constraints:
                            BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.zoom_out, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            _zoom = math.max(_zoom - 0.1, 0.5);
                          });
                        },
                        tooltip: 'Zoom Out',
                        constraints:
                            BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        icon: Icon(Icons.rotate_right,
                            color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            _rotation = (_rotation + 90) % 360;
                          });
                        },
                        tooltip: 'Rotate',
                        constraints:
                            BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(bool isSmallScreen) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Layer navigation
          Expanded(
            flex: 3,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left,
                      color: Colors.white),
                  onPressed: _selectedLayer > 0
                      ? () => _selectLayer(_selectedLayer - 1)
                      : null,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.blue[100],
                      trackHeight: 3.0,
                      thumbColor: Colors.white,
                      overlayColor: Colors.blue.withAlpha(32),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14.0),
                    ),
                    child: Slider(
                      min: 0,
                      max: 99,
                      value: _selectedLayer.toDouble(),
                      onChanged: (value) => _selectLayer(value.toInt()),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right,
                      color: Colors.white),
                  onPressed: _selectedLayer < 99
                      ? () => _selectLayer(_selectedLayer + 1)
                      : null,
                ),
              ],
            ),
          ),

          // Vertical divider
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[700],
          ),

          // Main tools
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.tune, color: Colors.white),
                  onPressed: _toggleToolPanel,
                  tooltip: 'Adjustments',
                ),
                IconButton(
                  icon: Icon(Icons.invert_colors,
                      color: _isInverted ? Colors.blue : Colors.white),
                  onPressed: _toggleInversion,
                  tooltip: 'Invert Colors',
                ),
                IconButton(
                  icon: Icon(Icons.view_in_ar,
                      color: _isInThreeDMode ? Colors.blue : Colors.white),
                  onPressed: _toggle3DMode,
                  tooltip: '3D Mode',
                ),
                IconButton(
                  icon: Icon(Icons.add,
                      color: _showCrosshairs ? Colors.blue : Colors.white),
                  onPressed: _toggleCrosshairs,
                  tooltip: 'Crosshair',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolPanel(bool isSmallScreen, double screenWidth) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 60, // Leave space for bottom toolbar
      width: isSmallScreen ? screenWidth * 0.85 : 320,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        elevation: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tool panel header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Image Tools',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleToolPanel,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Tool categories
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  _buildToolCategoryTab('Visualization', Icons.visibility),
                  _buildToolCategoryTab('Measurement', Icons.straighten),
                  _buildToolCategoryTab('Segmentation', Icons.brush),
                ],
              ),
            ),

            // Tool content
            Expanded(
              child: _activeToolCategory == 'Visualization'
                  ? _buildVisualizationTools(isSmallScreen)
                  : _activeToolCategory == 'Measurement'
                      ? _buildMeasurementTools(isSmallScreen)
                      : _buildSegmentationTools(isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCategoryTab(String label, IconData icon) {
    final isSelected = _activeToolCategory == label;
    return Expanded(
      child: InkWell(
        onTap: () => _setToolCategory(label),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
            color: isSelected ? Colors.white : Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizationTools(bool isSmallScreen) {
    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      children: [
        const Text(
          'Adjustments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildSlider(
          label: 'Brightness',
          icon: Icons.brightness_6,
          value: _brightness,
          min: -1.0,
          max: 1.0,
          onChanged: _updateBrightness,
        ),
        _buildSlider(
          label: 'Contrast',
          icon: Icons.contrast,
          value: _contrast,
          min: 0.5,
          max: 1.5,
          onChanged: _updateContrast,
        ),
        _buildSlider(
          label: 'Zoom',
          icon: Icons.zoom_in,
          value: _zoom,
          min: 0.5,
          max: 3.0,
          onChanged: _updateZoom,
        ),
        _buildSlider(
          label: 'Rotation',
          icon: Icons.rotate_90_degrees_ccw,
          value: _rotation,
          min: 0,
          max: 360,
          onChanged: _updateRotation,
        ),
        const SizedBox(height: 24),
        const Text(
          'Color Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: isSmallScreen ? 6 : 8,
          runSpacing: isSmallScreen ? 6 : 8,
          children: _colorMaps
              .map(
                (colorMap) => ChoiceChip(
                  label: Text(
                    colorMap,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  selected: _selectedColorMap == colorMap,
                  onSelected: (selected) {
                    if (selected) {
                      _setColorMap(colorMap);
                    }
                  },
                  labelPadding: isSmallScreen
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 0)
                      : null,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Display Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchOption(
          label: 'Invert Colors',
          icon: Icons.invert_colors,
          value: _isInverted,
          onChanged: (value) {
            setState(() {
              _isInverted = value;
            });
          },
        ),
        _buildSwitchOption(
          label: '3D Rendering',
          icon: Icons.view_in_ar,
          value: _isInThreeDMode,
          onChanged: (value) {
            _toggle3DMode();
          },
        ),
        _buildSwitchOption(
          label: 'Show Crosshairs',
          icon: Icons.add,
          value: _showCrosshairs,
          onChanged: (value) {
            setState(() {
              _showCrosshairs = value;
            });
          },
        ),
        _buildSwitchOption(
          label: 'High Quality Rendering',
          icon: Icons.high_quality,
          value: true,
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Rendering quality changed'),
              behavior: SnackBarBehavior.floating,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildMeasurementTools(bool isSmallScreen) {
    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      children: [
        const Text(
          'Measurement Tools',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _measurementTools.length,
            (index) => ActionChip(
              avatar: Icon(
                [
                  Icons.straighten,
                  Icons.architecture,
                  Icons.crop_free,
                  Icons.view_in_ar,
                  Icons.opacity,
                  Icons.show_chart,
                ][index],
                size: 16,
              ),
              label: Text(_measurementTools[index]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_measurementTools[index]} tool selected'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Measurements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.grey[100],
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No measurements recorded',
                  style: TextStyle(
                      color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'Use the measurement tools above to add measurements to this study.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Calibration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchOption(
          label: 'Show scale',
          icon: Icons.straighten,
          value: false,
          onChanged: (value) {
            // Add functionality later
          },
        ),
      ],
    );
  }

  Widget _buildSegmentationTools(bool isSmallScreen) {
    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      children: [
        const Text(
          'Segmentation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _segmentationTools.length,
            (index) => ActionChip(
              avatar: Icon(
                [
                  Icons.auto_awesome,
                  Icons.brush,
                  Icons.tune,
                  Icons.grain,
                  Icons.psychology,
                ][index],
                size: 16,
              ),
              label: Text(_segmentationTools[index]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_segmentationTools[index]} tool selected'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Brush Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildSlider(
          label: 'Brush Size',
          icon: Icons.brush,
          value: 0.5,
          min: 0.1,
          max: 1.0,
          onChanged: (value) {
            // Will be implemented later
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Colors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.yellow,
            Colors.purple,
            Colors.orange
          ]
              .map((color) => InkWell(
                    onTap: () {
                      // Color selection logic
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save Segmentation'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Segmentation saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showKeyboardShortcutsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keyboard Shortcuts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),
                ...(_keyboardShortcuts.entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(entry.value),
                            ],
                          ),
                        ))
                    .toList()),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 1100;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isSmallScreen ? 16 : 18),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(label, style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
              const Spacer(),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey[300],
              trackHeight: isSmallScreen ? 1.5 : 2.0,
              thumbColor: Theme.of(context).primaryColor,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 1100;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      child: Row(
        children: [
          Icon(icon, size: isSmallScreen ? 16 : 18),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Text(label, style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
          const Spacer(),
          Transform.scale(
            scale: isSmallScreen ? 0.8 : 1.0,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
