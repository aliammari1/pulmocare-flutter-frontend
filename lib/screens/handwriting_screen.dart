import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  // Track drawing points
  final List<List<DrawingPoint>> _strokes = [];
  final List<List<DrawingPoint>> _redoStack = [];
  List<DrawingPoint>? _currentStroke;
  String _noteText = '';
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _canvasKey = GlobalKey();
  bool _isEditingText = false;
  bool _needsClearConfirmation = false;

  // Drawing options
  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 3.0;
  bool _isDrawingLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handwriting Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Toggle Text Mode',
            onPressed: _toggleTextMode,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save and Return',
            onPressed: (_noteText.isNotEmpty || _strokes.isNotEmpty)
                ? () => _saveAndReturn(context)
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDrawingOptions(),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  if (_isEditingText)
                    _buildTextInput()
                  else
                    RepaintBoundary(
                      key: _canvasKey,
                      child: _buildDrawingCanvas(),
                    ),
                  if (_needsClearConfirmation) _buildClearConfirmationDialog(),
                  if (_isDrawingLoading) _buildLoadingOverlay(),
                ],
              ),
            ),
          ),
          _buildNotePreview(),
        ],
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _strokes.isNotEmpty ? _undoStroke : null,
              tooltip: 'Undo',
              color: Theme.of(context).colorScheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: _redoStack.isNotEmpty ? _redoStroke : null,
              tooltip: 'Redo',
              color: Theme.of(context).colorScheme.primary,
            ),
            const VerticalDivider(width: 20),
            IconButton(
              icon: Icon(
                Icons.cleaning_services,
                color: (_strokes.isNotEmpty || _noteText.isNotEmpty)
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: (_strokes.isNotEmpty || _noteText.isNotEmpty)
                  ? () => setState(() => _needsClearConfirmation = true)
                  : null,
              tooltip: 'Clear',
            ),
            const VerticalDivider(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveAndReturn(context),
                icon: const Icon(Icons.save_alt),
                label: const Text('Save Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleTextMode() {
    setState(() {
      _isEditingText = !_isEditingText;
      if (_isEditingText) {
        _textController.text = _noteText;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _noteText = '';
      _textController.text = '';
      _needsClearConfirmation = false;
    });
  }

  void _undoStroke() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _redoStack.add(_strokes.removeLast());
      });
    }
  }

  void _redoStroke() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _strokes.add(_redoStack.removeLast());
      });
    }
  }

  Future<void> _saveAndReturn(BuildContext context) async {
    // If in text mode, save text first
    if (_isEditingText) {
      setState(() {
        _noteText = _textController.text;
        _isEditingText = false;
      });
    }

    // If there are strokes, convert drawing to an image description
    String result = _noteText;
    if (_strokes.isNotEmpty) {
      setState(() => _isDrawingLoading = true);

      try {
        // Get the image from the canvas
        final RenderRepaintBoundary boundary = _canvasKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (result.isEmpty) {
          result = "[Handwritten note - Image captured]";
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving drawing: $e')),
        );
      } finally {
        setState(() => _isDrawingLoading = false);
      }
    }

    if (result.isNotEmpty) {
      context.pop(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
    }
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Type your notes here...',
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildDrawingCanvas() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _redoStack.clear(); // Clear redo stack when drawing starts
          _currentStroke = [];
          final RenderBox box = context.findRenderObject() as RenderBox;
          final point = box.globalToLocal(details.globalPosition);
          _currentStroke!.add(DrawingPoint(
            point,
            Paint()
              ..color = _currentColor
              ..strokeWidth = _currentStrokeWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..style = PaintingStyle.stroke,
          ));
          _strokes.add(_currentStroke!);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final point = box.globalToLocal(details.globalPosition);
          _currentStroke!.add(DrawingPoint(
            point,
            Paint()
              ..color = _currentColor
              ..strokeWidth = _currentStrokeWidth
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..style = PaintingStyle.stroke,
          ));
        });
      },
      onPanEnd: (_) {
        setState(() {
          _currentStroke = null;
        });
      },
      child: CustomPaint(
        painter: HandwritingPainter(_strokes),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildNotePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: 120), // Set maximum height
      child: SingleChildScrollView(
        // Add scrolling capability
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Note Text:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (!_isEditingText && _noteText.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _toggleTextMode,
                    tooltip: 'Edit Text',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Text(
                _noteText.isEmpty
                    ? 'Add text using the text editor button or draw on the canvas'
                    : _noteText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withAlpha(76),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing your handwriting...'),
                Text('This may take a moment'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text(
            'Pen Color:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          _buildColorOption(Colors.black),
          _buildColorOption(Colors.blue),
          _buildColorOption(Colors.red),
          _buildColorOption(Colors.green),
          const SizedBox(width: 16),
          Text(
            'Width:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Slider(
              value: _currentStrokeWidth,
              min: 1.0,
              max: 8.0,
              divisions: 7,
              label: _currentStrokeWidth.round().toString(),
              onChanged: (value) {
                setState(() {
                  _currentStrokeWidth = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            width: _currentColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildClearConfirmationDialog() {
    return Container(
      color: Colors.black.withAlpha(128),
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Clear Everything?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                  'This will clear all your handwriting and text. This action cannot be undone.'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _needsClearConfirmation = false;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Clear All'),
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

class DrawingPoint {
  final Offset point;
  final Paint paint;

  DrawingPoint(this.point, this.paint);
}

class HandwritingPainter extends CustomPainter {
  final List<List<DrawingPoint>> strokes;

  HandwritingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(
          stroke[i].point,
          stroke[i + 1].point,
          stroke[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) => true;
}
