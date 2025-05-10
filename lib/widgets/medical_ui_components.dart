import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

// Modern medical-themed background painter with subtle healthcare patterns
class MedicalBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  MedicalBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Create a clean base gradient background
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    final Paint backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          primaryColor.withOpacity(0.03),
          primaryColor.withOpacity(0.06),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // Draw subtle healthcare cross pattern
    final crossPaint = Paint()
      ..color = primaryColor.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    for (double x = -20; x < width; x += 100) {
      for (double y = -20; y < height; y += 100) {
        // Small medical cross
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 40, y + 45, 20, 10),
            Radius.circular(2),
          ),
          crossPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 45, y + 40, 10, 20),
            Radius.circular(2),
          ),
          crossPaint,
        );
      }
    }

    // Draw elegant curved medical pulse lines
    final pulsePaint = Paint()
      ..color = secondaryColor.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Top pulse line
    final pulsePath1 = Path();
    pulsePath1.moveTo(0, height * 0.15);

    for (int i = 0; i < 6; i++) {
      double segmentWidth = width / 6;
      double startX = i * segmentWidth;

      pulsePath1.lineTo(startX + segmentWidth * 0.2, height * 0.15);
      pulsePath1.quadraticBezierTo(startX + segmentWidth * 0.3, height * 0.12,
          startX + segmentWidth * 0.35, height * 0.15);
      pulsePath1.quadraticBezierTo(startX + segmentWidth * 0.4, height * 0.18,
          startX + segmentWidth * 0.5, height * 0.15);
      pulsePath1.lineTo(startX + segmentWidth, height * 0.15);
    }

    // Bottom pulse line
    final pulsePath2 = Path();
    pulsePath2.moveTo(0, height * 0.85);

    for (int i = 0; i < 6; i++) {
      double segmentWidth = width / 6;
      double startX = i * segmentWidth;

      pulsePath2.lineTo(startX + segmentWidth * 0.2, height * 0.85);
      pulsePath2.quadraticBezierTo(startX + segmentWidth * 0.3, height * 0.82,
          startX + segmentWidth * 0.35, height * 0.85);
      pulsePath2.quadraticBezierTo(startX + segmentWidth * 0.4, height * 0.88,
          startX + segmentWidth * 0.5, height * 0.85);
      pulsePath2.lineTo(startX + segmentWidth, height * 0.85);
    }

    canvas.drawPath(pulsePath1, pulsePaint);
    canvas.drawPath(pulsePath2, pulsePaint);

    // Draw a few hexagon molecular structures (medical chemistry reference)
    final hexagonPaint = Paint()
      ..color = primaryColor.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    void drawHexagon(double centerX, double centerY, double radius) {
      final hexPath = Path();
      for (int i = 0; i < 6; i++) {
        double angle = (60 * i - 30) * math.pi / 180;
        double x = centerX + radius * math.cos(angle);
        double y = centerY + radius * math.sin(angle);

        if (i == 0) {
          hexPath.moveTo(x, y);
        } else {
          hexPath.lineTo(x, y);
        }
      }
      hexPath.close();
      canvas.drawPath(hexPath, hexagonPaint);
    }

    // Draw a few hexagons in the corners
    drawHexagon(width * 0.1, height * 0.1, 30);
    drawHexagon(width * 0.1, height * 0.3, 20);
    drawHexagon(width * 0.15, height * 0.2, 25);

    drawHexagon(width * 0.9, height * 0.8, 30);
    drawHexagon(width * 0.85, height * 0.75, 20);
    drawHexagon(width * 0.95, height * 0.7, 25);

    // Draw small DNA helix in top right
    final dnaPaint = Paint()
      ..color = primaryColor.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dnaPath = Path();
    double dnaStartX = width * 0.85;
    double dnaEndX = width;
    double dnaStartY = height * 0.05;
    double dnaHeight = height * 0.25;

    for (double t = 0; t < dnaHeight; t += 5) {
      double x = dnaStartX + (dnaEndX - dnaStartX) * math.sin(t / 15);
      if (t == 0) {
        dnaPath.moveTo(x, dnaStartY + t);
      } else {
        dnaPath.lineTo(x, dnaStartY + t);
      }
    }

    canvas.drawPath(dnaPath, dnaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pulsing avatar specifically for the medical app
class PulsingAvatar extends StatefulWidget {
  final double radius;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const PulsingAvatar({
    Key? key,
    required this.radius,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  _PulsingAvatarState createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing background
            Container(
              width: widget.radius * 2 + 15 * _pulseAnimation.value,
              height: widget.radius * 2 + 15 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.primaryColor
                    .withOpacity(0.3 * (1 - _pulseAnimation.value)),
              ),
            ),
            // Icon container
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor,
                    widget.secondaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.radius,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Shimmer text effect for headers
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerText({
    Key? key,
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);

  @override
  _ShimmerTextState createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              widget.baseColor,
              widget.highlightColor,
              widget.baseColor,
            ],
            stops: [
              0.0,
              _controller.value,
              1.0,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.clamp,
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}

// Glassmorphic container for modern UI
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blur;
  final double border;
  final LinearGradient linearGradient;
  final LinearGradient borderGradient;
  final Alignment? alignment;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    required this.width,
    this.height,
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    required this.linearGradient,
    required this.borderGradient,
    this.border = 1.0,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: linearGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: border,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Custom animated progress orb for form steps
class AnimatedProgressOrb extends StatelessWidget {
  final bool isActive;
  final bool isCurrent;
  final int stepNumber;
  final Color primaryColor;

  const AnimatedProgressOrb({
    Key? key,
    required this.isActive,
    required this.isCurrent,
    required this.stepNumber,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [primaryColor.withOpacity(0.8), primaryColor]
              : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.5)],
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? primaryColor.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: isActive ? 10 : 4,
            spreadRadius: isActive ? 1 : 0,
          ),
        ],
        border: isCurrent ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: Center(
        child: isCurrent
            ? _buildPulsingNumber(stepNumber)
            : Text(
                stepNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildPulsingNumber(int number) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

// Upload progress indicator with animated waves
class WaveProgressIndicator extends StatefulWidget {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const WaveProgressIndicator({
    Key? key,
    required this.progress,
    required this.color,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _WaveProgressIndicatorState createState() => _WaveProgressIndicatorState();
}

class _WaveProgressIndicatorState extends State<WaveProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final progressWidth = width * widget.progress;

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(progressWidth, 12),
                    painter: _WavePainter(
                      color: widget.color,
                      animationValue: _controller.value,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _WavePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start at the bottom left
    path.moveTo(0, size.height);

    // Draw wave pattern
    final waveHeight = size.height * 0.2;
    final waveWidth = size.width * 0.1;
    final offsetX = size.width * animationValue;

    for (double i = 0; i <= size.width + waveWidth; i += waveWidth) {
      final x = i;
      final y = size.height -
          waveHeight * math.sin((i - offsetX) / waveWidth * math.pi);
      path.lineTo(x, y);
    }

    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Document card for file preview with animated hover effect
class DocumentCard extends StatefulWidget {
  final String fileName;
  final String fileSize;
  final IconData fileIcon;
  final Color iconColor;
  final VoidCallback onDelete;

  const DocumentCard({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.fileIcon,
    required this.iconColor,
    required this.onDelete,
  }) : super(key: key);

  @override
  _DocumentCardState createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? widget.iconColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isHovering ? 8 : 5,
              spreadRadius: _isHovering ? 1 : 0,
              offset: _isHovering ? const Offset(0, 3) : const Offset(0, 2),
            ),
          ],
          border: _isHovering
              ? Border.all(color: widget.iconColor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.fileIcon,
                color: widget.iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.fileSize,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
