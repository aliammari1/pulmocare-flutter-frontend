import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'entry_view.dart';
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

  @override
  void initState() {
    super.initState();

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

    // Set up animations
    _gateAnimation = CurvedAnimation(
      parent: _gateController,
      curve: Curves.easeInOut,
    );

    _travelAnimation = CurvedAnimation(
      parent: _travelController,
      curve: Curves.easeInOutCubic,
    );

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
      if (mounted) {
        // Use WidgetsBinding to ensure all frames are rendered before navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const EntryView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
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

    _gateController.dispose();
    _travelController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050A30),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _gateController,
          _travelController,
          _textController,
          _fadeController
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity:
                Tween<double>(begin: 1.0, end: 0.0).animate(_fadeAnimation),
            child: Stack(
              children: [
                // Background stars
                Positioned.fill(
                  child: CustomPaint(
                    painter: StarFieldPainter(
                      progress: _travelAnimation.value,
                    ),
                  ),
                ),

                // Gate visualization
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer circular gate
                      Transform.scale(
                        scale: 1.0 + (_gateAnimation.value * 0.3),
                        child: Container(
                          width: size.width * 0.8,
                          height: size.width * 0.8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.7),
                              width: 10,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Middle ring
                      Transform.scale(
                        scale: 0.8 + (_gateAnimation.value * 0.2),
                        child: Container(
                          width: size.width * 0.6,
                          height: size.width * 0.6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.lightBlue.withOpacity(0.5),
                              width: 6,
                            ),
                          ),
                        ),
                      ),

                      // Inner ring
                      Transform.scale(
                        scale: 0.6 + (_gateAnimation.value * 0.1),
                        child: Container(
                          width: size.width * 0.4,
                          height: size.width * 0.4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                        ),
                      ),

                      // Center light
                      Container(
                        width: 20 + (100 * _travelAnimation.value),
                        height: 20 + (100 * _travelAnimation.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                              1.0 - (0.7 * _travelAnimation.value)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(
                                  0.8 - (0.5 * _travelAnimation.value)),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),

                      // Travel effect
                      Opacity(
                        opacity: _travelController.value,
                        child: CustomPaint(
                          size: Size(size.width, size.height),
                          painter: TravelTunnelPainter(
                            progress: _travelAnimation.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Welcome text
                Positioned(
                  bottom: size.height * 0.2,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _textAnimation.value,
                        child: Opacity(
                          opacity: _textAnimation.value,
                          child: Column(
                            children: [
                              // Welcome text
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    colors: [
                                      Color(0xFF4FC3F7),
                                      Colors.white,
                                      Color(0xFF4FC3F7)
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  'Welcome to the future',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // With PulmoCare
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF4FC3F7).withOpacity(0.2),
                                      const Color(0xFF0D47A1).withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'with PulmoCare',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
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
          );
        },
      ),
    );
  }
}

// Painter for the star field background
class StarFieldPainter extends CustomPainter {
  final double progress;
  final List<Star> _stars = [];

  StarFieldPainter({required this.progress}) {
    // Initialize stars with random positions
    final random = math.Random(42);
    for (int i = 0; i < 200; i++) {
      _stars.add(
        Star(
          x: random.nextDouble() * 2 - 1, // -1 to 1
          y: random.nextDouble() * 2 - 1, // -1 to 1
          z: random.nextDouble(),
          size: random.nextDouble() * 2 + 0.5,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final star in _stars) {
      // Calculate position with travel effect
      double depth = star.z + progress * 0.5;
      depth = depth % 1.0; // Loop back when depth exceeds 1

      // Calculate screen position
      final scale = 1.0 / depth;
      final screenX = centerX + star.x * scale * centerX;
      final screenY = centerY + star.y * scale * centerY;

      // Calculate star size and opacity based on depth
      final starSize = star.size * scale;
      final opacity = (1.0 - depth) * 0.8;

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw the star
      canvas.drawCircle(Offset(screenX, screenY), starSize, paint);

      // Add glow to brighter stars
      if (starSize > 2) {
        final glowPaint = Paint()
          ..color = Colors.blue.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(Offset(screenX, screenY), starSize * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Painter for the travel tunnel effect
class TravelTunnelPainter extends CustomPainter {
  final double progress;

  TravelTunnelPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.sqrt(centerX * centerX + centerY * centerY);

    // Draw concentric rings that appear to move toward the viewer
    for (int i = 0; i < 10; i++) {
      final ringProgress = (i / 10.0 + progress) % 1.0;
      final radius = maxRadius * ringProgress;

      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.3 * (1.0 - ringProgress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + (5 * (1.0 - ringProgress));

      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }

    // Draw light streaks for speed effect
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final startRadius = maxRadius * 0.2;
      final endRadius = maxRadius * (0.5 + random.nextDouble() * 0.5);

      final startX = centerX + math.cos(angle) * startRadius;
      final startY = centerY + math.sin(angle) * startRadius;
      final endX = centerX + math.cos(angle) * endRadius;
      final endY = centerY + math.sin(angle) * endRadius;

      final paint = Paint()
        ..color = Colors.white.withOpacity(0.3 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(TravelTunnelPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Helper class for star field
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
