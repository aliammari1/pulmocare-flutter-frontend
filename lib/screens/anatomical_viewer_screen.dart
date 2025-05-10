import 'package:flutter/material.dart';
import 'package:medapp/theme/app_theme.dart';
import 'dart:math' as math;

class AnatomicalViewerScreen extends StatefulWidget {
  const AnatomicalViewerScreen({super.key});

  @override
  State<AnatomicalViewerScreen> createState() => _AnatomicalViewerScreenState();
}

class _AnatomicalViewerScreenState extends State<AnatomicalViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final List<Map<String, dynamic>> _anatomyModels = [
    {
      'name': 'Respiratory System',
      'thumbnail': 'assets/models/respiratory_thumb.png',
      'description':
          'Complete 3D model of the human respiratory system with detailed airways and lungs.',
      'category': 'Respiratory',
      'complexity': 'Advanced',
    },
    {
      'name': 'Heart Anatomy',
      'thumbnail': 'assets/models/heart_thumb.png',
      'description':
          'Detailed cardiac model with chambers, valves, and major vessels.',
      'category': 'Cardiac',
      'complexity': 'Intermediate',
    },
    {
      'name': 'Brain Structure',
      'thumbnail': 'assets/models/brain_thumb.png',
      'description':
          'Comprehensive brain model showing cortical regions and internal structures.',
      'category': 'Neurological',
      'complexity': 'Advanced',
    },
    {
      'name': 'Skeletal System',
      'thumbnail': 'assets/models/skeleton_thumb.png',
      'description': 'Full human skeleton with detailed joint structures.',
      'category': 'Musculoskeletal',
      'complexity': 'Beginner',
    },
    {
      'name': 'Digestive Tract',
      'thumbnail': 'assets/models/digestive_thumb.png',
      'description': 'Complete digestive system from oral cavity to rectum.',
      'category': 'Gastrointestinal',
      'complexity': 'Intermediate',
    },
  ];

  String _selectedCategory = 'All';
  bool _isModelLoaded = false;
  bool _isAnimating = false;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _scale = 1.0;

  final List<String> _categories = [
    'All',
    'Respiratory',
    'Cardiac',
    'Neurological',
    'Musculoskeletal',
    'Gastrointestinal'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    // Simulate model loading after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isModelLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredModels {
    if (_selectedCategory == 'All') {
      return _anatomyModels;
    }
    return _anatomyModels
        .where((model) => model['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Anatomical Viewer'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browser'),
            Tab(text: '3D Viewer'),
            Tab(text: 'Annotations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Model Browser Tab
          _buildBrowserTab(),

          // 3D Viewer Tab
          _buildViewerTab(),

          // Annotations Tab
          _buildAnnotationsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _scale = math.min(2.5, _scale + 0.1);
                    });
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _scale = math.max(0.5, _scale - 0.1);
                    });
                  },
                  child: const Icon(Icons.zoom_out),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'animation',
                  onPressed: () {
                    setState(() {
                      _isAnimating = !_isAnimating;
                    });
                    _showSnackBar(_isAnimating
                        ? 'Animation enabled'
                        : 'Animation disabled');
                  },
                  backgroundColor: _isAnimating ? Colors.green : null,
                  child: Icon(_isAnimating ? Icons.pause : Icons.play_arrow),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildBrowserTab() {
    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _filteredModels.isEmpty
              ? const Center(child: Text('No models found for this category'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredModels.length,
                  itemBuilder: (context, index) {
                    final model = _filteredModels[index];
                    return _buildModelCard(model);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () {
          _tabController.animateTo(1);
          setState(() {
            _isModelLoaded = false;
          });
          // Simulate model loading after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isModelLoaded = true;
              });
              _showSnackBar('${model['name']} loaded successfully');
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Use a fallback image from another asset if the model thumbnail doesn't exist
                  _buildModelThumbnail(model),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        model['complexity'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create model thumbnails with proper fallback
  Widget _buildModelThumbnail(Map<String, dynamic> model) {
    final Map<String, String> fallbackImages = {
      'Respiratory': 'assets/docteur.png',
      'Cardiac': 'assets/icon.png',
      'Neurological': 'assets/supporter.png',
      'Musculoskeletal': 'assets/docteur (1).png',
      'Gastrointestinal': 'assets/parler.png',
    };

    return Image.asset(
      model['thumbnail'],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Use category-specific fallback images from existing assets
        String fallbackAsset =
            fallbackImages[model['category']] ?? 'assets/icon.png';

        // Try loading the fallback image
        return Image.asset(
          fallbackAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If even the fallback fails, show a colored container with an icon
            return Container(
              color: _getCategoryColor(model['category']),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(model['category']),
                      size: 50,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper to get a category-specific color
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Respiratory':
        return Colors.blue;
      case 'Cardiac':
        return Colors.red;
      case 'Neurological':
        return Colors.purple;
      case 'Musculoskeletal':
        return Colors.orange;
      case 'Gastrointestinal':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  // Helper to get a category-specific icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Respiratory':
        return Icons.air;
      case 'Cardiac':
        return Icons.favorite;
      case 'Neurological':
        return Icons.psychology;
      case 'Musculoskeletal':
        return Icons.accessibility_new;
      case 'Gastrointestinal':
        return Icons.restaurant;
      default:
        return Icons.medical_services;
    }
  }

  Widget _build3DModel() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotationY += details.delta.dx * 0.01;
          _rotationX += details.delta.dy * 0.01;
        });
      },
      // Replace the onScaleUpdate method with a properly implemented version
      onScaleUpdate: (details) {
        setState(() {
          // Apply scale directly without using previousScale
          // Clamp between 0.5 and 3.0 to prevent extreme scaling
          _scale = math.max(0.5, math.min(3.0, _scale * details.scale));
        });
      },
      child: Container(
        color: Colors.grey[100],
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_rotationX)
              ..rotateY(_rotationY)
              ..scale(_scale),
            child: CustomPaint(
              painter: AnatomicalModelPainter(isAnimating: _isAnimating),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewerTab() {
    return _isModelLoaded
        ? Stack(
            children: [
              _build3DModel(),
              Positioned(
                bottom: 16,
                left: 16,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Drag to rotate • Pinch to zoom',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading 3D model...'),
              ],
            ),
          );
  }

  Widget _buildAnnotationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Model Annotations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildAnnotationItem(
          title: 'Trachea',
          description:
              'The trachea, commonly known as the windpipe, is a cartilaginous tube that connects the larynx to the bronchi of the lungs.',
        ),
        _buildAnnotationItem(
          title: 'Lungs',
          description:
              'The lungs are the primary organs of the respiratory system, responsible for taking in oxygen and expelling carbon dioxide.',
        ),
        _buildAnnotationItem(
          title: 'Diaphragm',
          description:
              'The diaphragm is a dome-shaped respiratory muscle that separates the thoracic cavity from the abdominal cavity.',
        ),
        _buildAnnotationItem(
          title: 'Bronchi',
          description:
              'The bronchi are the two large air passages that connect to the trachea and direct air into each lung.',
        ),
        _buildAnnotationItem(
          title: 'Alveoli',
          description:
              'Alveoli are tiny air sacs in the lungs where the exchange of oxygen and carbon dioxide takes place.',
        ),
      ],
    );
  }

  Widget _buildAnnotationItem(
      {required String title, required String description}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(description),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.highlight, size: 16),
              label: const Text('Highlight on Model'),
              onPressed: () {
                _tabController.animateTo(1);
                _showSnackBar('$title highlighted on model');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Using the Anatomical Viewer'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('• Browse 3D anatomical models in the Browser tab'),
              SizedBox(height: 8),
              Text('• Select a model to view it in 3D'),
              SizedBox(height: 8),
              Text('• Rotate the model by dragging'),
              SizedBox(height: 8),
              Text('• Zoom in/out using the buttons'),
              SizedBox(height: 8),
              Text('• View annotations to learn more about specific parts'),
              SizedBox(height: 8),
              Text('• Enable animation to see organ functions'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Viewer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Show Labels'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  Navigator.pop(context);
                  _showSnackBar('Feature not implemented yet');
                },
              ),
            ),
            ListTile(
              title: const Text('Show Grid'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  Navigator.pop(context);
                  _showSnackBar('Feature not implemented yet');
                },
              ),
            ),
            ListTile(
              title: const Text('High Quality Rendering'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  Navigator.pop(context);
                  _showSnackBar('Feature not implemented yet');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class AnatomicalModelPainter extends CustomPainter {
  final bool isAnimating;
  final double animationValue;

  AnatomicalModelPainter({
    required this.isAnimating,
  }) : animationValue = (DateTime.now().millisecondsSinceEpoch % 3000) / 3000;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;

    // Paint for the lung outlines
    final outlinePaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Paint for the lung fills
    final fillPaint = Paint()
      ..color = Colors.blue.shade100.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Paint for the breathing animation
    final breathingPaint = Paint()
      ..color = Colors.blue.shade200.withOpacity(isAnimating ? 0.7 : 0.5)
      ..style = PaintingStyle.fill;

    // Calculate breathing effect
    double breathingFactor = 1.0;
    if (isAnimating) {
      breathingFactor = 0.9 + 0.1 * math.sin(2 * math.pi * animationValue);
    }

    // Draw right lung
    final rightLungPath = Path()
      ..moveTo(center.dx - 20, center.dy - radius * 0.8)
      ..quadraticBezierTo(
          center.dx - radius * 0.8 * breathingFactor,
          center.dy - radius * 0.3,
          center.dx - radius * 0.6 * breathingFactor,
          center.dy + radius * 0.3)
      ..quadraticBezierTo(center.dx - radius * 0.3 * breathingFactor,
          center.dy + radius * 0.8, center.dx - 30, center.dy + radius * 0.7)
      ..lineTo(center.dx - 20, center.dy + radius * 0.6)
      ..lineTo(center.dx - 10, center.dy - radius * 0.4)
      ..close();

    canvas.drawPath(rightLungPath, breathingPaint);
    canvas.drawPath(rightLungPath, outlinePaint);

    // Draw left lung
    final leftLungPath = Path()
      ..moveTo(center.dx + 20, center.dy - radius * 0.8)
      ..quadraticBezierTo(
          center.dx + radius * 0.8 * breathingFactor,
          center.dy - radius * 0.3,
          center.dx + radius * 0.6 * breathingFactor,
          center.dy + radius * 0.3)
      ..quadraticBezierTo(center.dx + radius * 0.3 * breathingFactor,
          center.dy + radius * 0.8, center.dx + 30, center.dy + radius * 0.7)
      ..lineTo(center.dx + 20, center.dy + radius * 0.6)
      ..lineTo(center.dx + 10, center.dy - radius * 0.4)
      ..close();

    canvas.drawPath(leftLungPath, breathingPaint);
    canvas.drawPath(leftLungPath, outlinePaint);

    // Draw trachea
    final tracheaPaint = Paint()
      ..color = Colors.pink.shade200
      ..style = PaintingStyle.fill;

    final tracheaOutlinePaint = Paint()
      ..color = Colors.pink.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final tracheaPath = Path()
      ..moveTo(center.dx - 10, center.dy - radius * 0.8)
      ..lineTo(center.dx + 10, center.dy - radius * 0.8)
      ..lineTo(center.dx + 10, center.dy - radius * 0.1)
      ..lineTo(center.dx + 30, center.dy)
      ..lineTo(center.dx + 10, center.dy + radius * 0.1)
      ..lineTo(center.dx - 10, center.dy + radius * 0.1)
      ..lineTo(center.dx - 30, center.dy)
      ..lineTo(center.dx - 10, center.dy - radius * 0.1)
      ..close();

    canvas.drawPath(tracheaPath, tracheaPaint);
    canvas.drawPath(tracheaPath, tracheaOutlinePaint);

    // Draw rings on the trachea
    final ringPaint = Paint()
      ..color = Colors.pink.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double y = center.dy - radius * 0.7;
        y < center.dy - radius * 0.1;
        y += 10) {
      canvas.drawLine(
        Offset(center.dx - 10, y),
        Offset(center.dx + 10, y),
        ringPaint,
      );
    }

    // Draw diaphragm
    final diaphragmPaint = Paint()
      ..color = Colors.purple.shade300.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final diaphragmOutlinePaint = Paint()
      ..color = Colors.purple.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Calculate diaphragm animation
    double diaphragmHeight = center.dy + radius * 0.9;
    if (isAnimating) {
      diaphragmHeight = center.dy +
          radius * (0.9 - 0.1 * math.sin(2 * math.pi * animationValue));
    }

    final diaphragmPath = Path()
      ..moveTo(center.dx - radius * 0.8, diaphragmHeight)
      ..quadraticBezierTo(center.dx, diaphragmHeight - radius * 0.2,
          center.dx + radius * 0.8, diaphragmHeight);

    canvas.drawPath(diaphragmPath, diaphragmPaint);
    canvas.drawPath(diaphragmPath, diaphragmOutlinePaint);

    // Draw labels if needed
    if (isAnimating) {
      const textStyle = TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Respiration Animation',
          style: textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - radius - textPainter.height - 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnatomicalModelPainter oldDelegate) {
    return isAnimating || oldDelegate.isAnimating != isAnimating;
  }
}
