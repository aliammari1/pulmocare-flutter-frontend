import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class SignaturePad extends StatefulWidget {
  final Function(Uint8List) onSigned;

  const SignaturePad({
    super.key,
    required this.onSigned,
  });

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;
  Color _currentColor = Colors.blue;
  double _currentWidth = 3.0;
  bool _isEditing = false;

  void clear() {
    setState(() {
      _strokes = [];
      _currentStroke = null;
    });
  }

  Future<void> save() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = _currentColor
      ..strokeWidth = _currentWidth
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(300, 150);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      widget.onSigned(pngBytes.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.2 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre d'outils
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.black),
                _buildColorButton(Colors.red),
                const SizedBox(width: 8),
                _buildWidthSlider(),
              ],
            ),
          ),

          // Zone de signature
          Container(
            width: 300,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _isEditing = true;
                      _currentStroke = [details.localPosition];
                      _strokes.add(_currentStroke!);
                    });
                  },
                  onPanUpdate: (details) {
                    if (_isEditing) {
                      setState(() {
                        _currentStroke?.add(details.localPosition);
                      });
                    }
                  },
                  onPanEnd: (details) {
                    _isEditing = false;
                    _currentStroke = null;
                    save(); // Sauvegarder automatiquement
                  },
                  child: CustomPaint(
                    painter: SignaturePainter(
                        _strokes, _currentColor, _currentWidth),
                    size: const Size(300, 150),
                  ),
                ),
                if (_strokes.isEmpty)
                  Center(
                    child: Text(
                      'Signez ici',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.clear,
                  label: 'Effacer',
                  onPressed: clear,
                  color: Colors.red.shade400,
                ),
                _buildActionButton(
                  icon: Icons.undo,
                  label: 'Annuler',
                  onPressed: _strokes.isEmpty ? null : _undoLastStroke,
                  color: Colors.orange,
                ),
                _buildActionButton(
                  icon: Icons.check,
                  label: 'Valider',
                  onPressed: _strokes.isEmpty ? null : save,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _currentColor = color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.3 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidthSlider() {
    return SizedBox(
      width: 100,
      child: Slider(
        value: _currentWidth,
        min: 1.0,
        max: 10.0,
        divisions: 9,
        onChanged: (value) => setState(() => _currentWidth = value),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }

  void _undoLastStroke() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
        save();
      }
    });
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double width;

  SignaturePainter(this.strokes, this.color, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
