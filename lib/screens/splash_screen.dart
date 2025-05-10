import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers for different animation elements
  late AnimationController _gateController;
  late AnimationController _travelController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  // Define animations
  late Animation<double> _gateAnimation;
  late Animation<double> _travelAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _fadeAnimation;

  // Navigation flag to prevent multiple navigations
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style to ensure clean fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Initialize animation controllers
    _gateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _travelController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Set up animations with appropriate bounds
    _gateAnimation = CurvedAnimation(
      parent: _gateController,
      curve: Curves.easeInOut,
    );

    _travelAnimation = CurvedAnimation(
      parent: _travelController,
      curve: Curves.easeInOutCubic,
    );

    // Adjust the text animation to prevent out of bounds values
    _textController.addListener(() {
      // Keep the controller value within bounds
      if (_textController.value < 0) _textController.value = 0;
      if (_textController.value > 1) _textController.value = 1;
    });

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Add navigation listener to fadeController
    _fadeController.addStatusListener(_handleAnimationStatusChange);

    // Start the animation sequence
    _startAnimationSequence();
  }

  // Handle animation status changes
  void _handleAnimationStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Make sure we have a valid context before navigating
      if (mounted && !_isNavigating) {
        _isNavigating = true;

        // Use WidgetsBinding to ensure all frames are rendered before navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Restore system UI after splash screen
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

          // Wrap in try-catch to handle any navigation errors
          try {
            context.go('/entryView');
          } catch (e) {
            debugPrint('Navigation error: $e');
            // Fallback navigation if the context is still valid
            if (mounted) {
              context.pushReplacementNamed('/entryView');
            }
          }
        });
      }
    }
  }

  void _startAnimationSequence() async {
    // Open the gates
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _gateController.forward();

    // Travel through the gate
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _travelController.forward();

    // Show the welcome text
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) _textController.forward();

    // Fade out everything to show the entry view
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) _fadeController.forward();
  }

  @override
  void dispose() {
    // Remove listener before disposing
    _fadeController.removeStatusListener(_handleAnimationStatusChange);

    // Dispose the animation controllers
    _gateController.dispose();
    _travelController.dispose();
    _textController.dispose();
    _fadeController.dispose();

    // Ensure system UI is restored if not already
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Medical theme colors
    const primaryColor = Color(0xFF0B4F6C);
    const secondaryColor = Color(0xFF01BAEF);
    const accentColor = Color(0xFF40BCD8);
    const backgroundColor = Color(0xFFEBF2FA);

    return WillPopScope(
      // Prevent back button during splash
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        // Prevent any gestures from interfering with the splash
        body: AbsorbPointer(
          absorbing: true,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _gateController,
              _travelController,
              _textController,
              _fadeController
            ]),
            builder: (context, child) {
              // Ensure the fade transition opacity is valid
              final fadeOpacity = _fadeAnimation.value.clamp(0.0, 1.0);

              return FadeTransition(
                opacity: AlwaysStoppedAnimation(1.0 - fadeOpacity),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MedicalPatternPainter(
                          progress: _travelAnimation.value,
                        ),
                      ),
                    ),

                    // Pulse animation
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Heart rate line
                          Positioned(
                            top: size.height * 0.45,
                            left: 0,
                            right: 0,
                            child: CustomPaint(
                              size: Size(size.width, 60),
                              painter: HeartbeatPainter(
                                progress: _travelAnimation.value,
                                color: primaryColor,
                              ),
                            ),
                          ),

                          // Medical cross symbol
                          Transform.scale(
                            scale: 0.8 + (_gateAnimation.value * 0.2),
                            child: Container(
                              width: size.width * 0.4,
                              height: size.width * 0.4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withOpacity(0.05),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.7),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: primaryColor,
                                  size: size.width * 0.2,
                                ),
                              ),
                            ),
                          ),

                          // Pulse rings
                          ...List.generate(3, (index) {
                            final delay = index * 0.3;
                            // Ensure animation value is valid and positive
                            final animationValue =
                                _travelAnimation.value > delay
                                    ? ((_travelAnimation.value - delay) % 1.0)
                                    : 0.0;
                            final isVisible = _travelAnimation.value > delay;

                            // Ensure opacity is between 0.0 and 1.0
                            final opacity = isVisible
                                ? (1.0 - animationValue).clamp(0.0, 1.0)
                                : 0.0;

                            return Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: 0.8 + (animationValue * 0.5),
                                child: Container(
                                  width: size.width * 0.4,
                                  height: size.width * 0.4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accentColor.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Company logo and tagline
                    Positioned(
                      bottom: size.height * 0.2,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          // Ensure the text animation scale and opacity are within bounds
                          final textScale =
                              _textAnimation.value.clamp(0.0, 1.0);
                          final textOpacity =
                              _textAnimation.value.clamp(0.0, 1.0);

                          return Transform.scale(
                            scale: textScale,
                            child: Opacity(
                              opacity: textOpacity,
                              child: Column(
                                children: [
                                  // Logo text
                                  Text(
                                    'PulmoCare',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      letterSpacing: 1.0,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  // Tagline
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Advanced Respiratory Care',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: secondaryColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // Trust indicators
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFF0B4F6C),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Trusted by medical professionals',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: primaryColor.withOpacity(0.7),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
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
              );
            },
          ),
        ),
      ),
    );
  }
}

// Painter for the medical background pattern
class MedicalPatternPainter extends CustomPainter {
  final double progress;
  final List<Offset> _gridPoints = [];

  MedicalPatternPainter({required this.progress}) {
    // Create a grid of points
    final density = 20;
    for (int i = 0; i < density; i++) {
      for (int j = 0; j < density; j++) {
        _gridPoints.add(Offset(i / (density - 1), j / (density - 1)));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 20;
    final primaryColor = const Color(0xFF0B4F6C);
    final secondaryColor = const Color(0xFF01BAEF);

    // Draw subtle grid
    final gridPaint = Paint()
      ..color = primaryColor.withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < size.width / cellSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
    }

    for (int i = 0; i < size.height / cellSize; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
    }

    // Draw medical symbols
    final symbolSize = cellSize * 0.8;
    final symbolPaint = Paint()
      ..color = secondaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final symbolStroke = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 2; i < size.width / cellSize; i += 4) {
      for (int j = 2; j < size.height / cellSize; j += 4) {
        final centerX = i * cellSize;
        final centerY = j * cellSize;

        // Alternate between different medical symbols
        if ((i + j) % 2 == 0) {
          // Cross symbol
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: symbolSize,
              height: symbolSize / 3,
            ),
            symbolPaint,
          );
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: symbolSize / 3,
              height: symbolSize,
            ),
            symbolPaint,
          );
        } else {
          // Circle symbol (pill or stethoscope)
          canvas.drawCircle(
            Offset(centerX, centerY),
            symbolSize / 2,
            symbolPaint,
          );
          canvas.drawCircle(
            Offset(centerX, centerY),
            symbolSize / 2,
            symbolStroke,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(MedicalPatternPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Painter for the heartbeat line
class HeartbeatPainter extends CustomPainter {
  final double progress;
  final Color color;

  HeartbeatPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Starting point
    path.moveTo(0, height / 2);

    // Clamp the progress value to ensure it's within bounds
    final safeProgress = progress.clamp(0.0, 1.0);

    // Calculate where in the heartbeat we are based on progress
    final fullCycleWidth =
        width * 0.25; // One heartbeat takes up 1/4 of the width
    final offset = (safeProgress * width * 2) % width; // Scroll the heartbeat

    // Draw multiple heartbeat cycles
    for (var cycleStart = -fullCycleWidth;
        cycleStart < width + fullCycleWidth;
        cycleStart += fullCycleWidth) {
      final adjustedStart = cycleStart - offset;

      // First flat segment
      path.lineTo(adjustedStart + fullCycleWidth * 0.1, height / 2);

      // P wave (small bump)
      path.quadraticBezierTo(adjustedStart + fullCycleWidth * 0.15,
          height * 0.4, adjustedStart + fullCycleWidth * 0.2, height / 2);

      // Flat segment after P wave
      path.lineTo(adjustedStart + fullCycleWidth * 0.3, height / 2);

      // QRS complex (the main spike)
      path.lineTo(adjustedStart + fullCycleWidth * 0.35, height * 0.3); // Q
      path.lineTo(adjustedStart + fullCycleWidth * 0.4, height * 0.1); // R
      path.lineTo(adjustedStart + fullCycleWidth * 0.45, height * 0.3); // S

      // T wave (small bump after the spike)
      path.lineTo(adjustedStart + fullCycleWidth * 0.55, height / 2);
      path.quadraticBezierTo(adjustedStart + fullCycleWidth * 0.65,
          height * 0.6, adjustedStart + fullCycleWidth * 0.75, height / 2);

      // End with flat line
      path.lineTo(adjustedStart + fullCycleWidth, height / 2);
    }

    // Draw the path
    canvas.drawPath(path, paint);

    // Add a glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(HeartbeatPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

// Helper class for star field is no longer needed and has been replaced
class Star {
  final double x; // -1 to 1
  final double y; // -1 to 1
  double z; // 0 to 1, depth
  final double size;

  Star({
    required this.x,
    required this.y,
    required this.z,
    required this.size,
  });
}
