import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:medapp/models/user.dart';
import '../theme/app_theme.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key});

  @override
  State<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<EntryView> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _logoAnimationController;

  // For parallax effect
  double _offsetX = 0;
  double _offsetY = 0;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _buttonAnimationController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: GestureDetector(
        onPanUpdate: (details) {
          // Update parallax effect based on gesture
          setState(() {
            _offsetX += details.delta.dx * 0.01;
            _offsetY += details.delta.dy * 0.01;

            // Constrain the offset values
            _offsetX = _offsetX.clamp(-10.0, 10.0);
            _offsetY = _offsetY.clamp(-10.0, 10.0);
          });
        },
        child: Stack(
          children: [
            // Animated gradient background
            AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                final value = _backgroundAnimationController.value;
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: GradientPainter(
                    value: value,
                    offsetX: _offsetX,
                    offsetY: _offsetY,
                  ),
                );
              },
            ),

            // Medical pattern grid
            CustomPaint(
              size: Size(size.width, size.height),
              painter: MedicalGridPainter(),
            ),

            // Floating particles with medical symbols
            AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: MedicalParticlesPainter(
                    value: _backgroundAnimationController.value,
                    offsetX: _offsetX,
                    offsetY: _offsetY,
                  ),
                );
              },
            ),

            // Main content with parallax effect
            AnimatedBuilder(
              animation: Listenable.merge(
                  [_logoAnimationController, _buttonAnimationController]),
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(_offsetY * 0.01)
                    ..rotateY(-_offsetX * 0.01),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Logo with animated reveal
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: _buildLogoSection(),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Access options with staggered animation
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Text(
                              'Select Access Type',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingLarge),

                            // Doctor Button with animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildAccessCard(
                                context,
                                title: 'Doctor Portal',
                                description:
                                    'Access patient analytics and treatment plans',
                                iconData: MedicalThemeElements.doctor,
                                gradient: const [
                                  AppTheme.primaryColor,
                                  Color(0xFF156584),
                                ],
                                role: UserRole.doctor,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),

                            // Radiologist Button with animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildAccessCard(
                                context,
                                title: 'Radiologist Access',
                                description:
                                    'Advanced imaging analysis and reporting',
                                iconData: Icons.biotech_outlined,
                                gradient: const [
                                  Color(0xFF156584),
                                  AppTheme.secondaryColor,
                                ],
                                role: UserRole.radiologist,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),

                            // Patient Button with animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildAccessCard(
                                context,
                                title: 'Patient Access',
                                description:
                                    'View your medical records and results',
                                iconData: MedicalThemeElements.patient,
                                gradient: const [
                                  AppTheme.secondaryColor,
                                  AppTheme.accentColor,
                                ],
                                role: UserRole.patient,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating action indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 1),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: AppTheme.spacingMedium),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMedium,
                              vertical: AppTheme.spacingSmall),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusCircular),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white.withOpacity(0.7),
                                size: AppTheme.iconSizeSmall,
                              ),
                              const SizedBox(width: AppTheme.spacingSmall),
                              Text(
                                'Swipe to explore',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: AppTheme.fontSizeXSmall,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
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
            ),
          ],
        ),
      ),
    );
  }

  // Animated medical logo section
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo with pulse effect
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring animation
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 2 * math.pi),
                duration: const Duration(seconds: 20),
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.3;
                      final animationValue =
                          (_backgroundAnimationController.value - delay) % 1.0;
                      final isVisible =
                          _backgroundAnimationController.value > delay;

                      return Opacity(
                        opacity: isVisible ? (1.0 - animationValue) * 0.3 : 0,
                        child: Transform.scale(
                          scale: 0.7 + (animationValue * 0.3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.accentColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              // Medical cross emblem
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: AppTheme.elevationMedium,
                ),
                child: Center(
                  child: Icon(
                    Icons.local_hospital,
                    color: AppTheme.primaryColor,
                    size: 50,
                  ),
                ),
              ),

              // Animated shimmer effect
              AnimatedBuilder(
                animation: _backgroundAnimationController,
                builder: (context, child) {
                  return Positioned(
                    left:
                        -70 + (140 * _backgroundAnimationController.value * 2),
                    top: 0,
                    bottom: 0,
                    width: 70,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // App title with glowing effect
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                AppTheme.secondaryColor,
                Colors.white,
                AppTheme.secondaryColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Text(
            'PulmoCare',
            style: TextStyle(
              fontSize: AppTheme.fontSizeDisplay,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),

        // Tagline container
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppTheme.borderRadiusCircular),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              'ADVANCED RESPIRATORY CARE',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTheme.fontSizeXSmall,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Professional medical access card
  Widget _buildAccessCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required List<Color> gradient,
    required UserRole role,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        _buttonAnimationController.forward();
        // Add subtle haptic feedback on tap down
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _buttonAnimationController.reverse(),
      onTapCancel: () => _buttonAnimationController.reverse(),
      onTap: () {
        // Stronger haptic feedback on actual tap
        HapticFeedback.mediumImpact();

        // Add small delay to allow animation to complete
        Future.delayed(const Duration(milliseconds: 100), () {
          switch (role) {
            case UserRole.doctor:
              // Using GoRouter navigation
              context.push('/login', extra: UserRole.doctor);
              break;
            case UserRole.radiologist:
              context.push('/login', extra: UserRole.radiologist);
              break;
            case UserRole.patient:
              context.push('/login', extra: UserRole.patient);
              break;
            default:
              break;
          }
        });
      },
      child: AnimatedBuilder(
        animation: _buttonAnimationController,
        builder: (context, child) {
          // Enhanced 3D button press effect with subtle rotation
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateX(_buttonAnimationController.value * 0.03)
              ..rotateY(_buttonAnimationController.value * -0.02)
              ..scale(1.0 - (_buttonAnimationController.value * 0.03)),
            alignment: Alignment.center,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppTheme.elevationMedium,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Subtle medical patterns in background
                        Positioned.fill(
                          child: _buildCardPattern(gradient[0]),
                        ),

                        // Background decorative elements
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            iconData,
                            size: 100,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Row(
                            children: [
                              // Icon in circle with subtle animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(seconds: 1),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: AppTheme.elevationLow,
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: gradient[0],
                                        size: 25,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(width: AppTheme.spacingMedium),

                              // Text content with staggered animation
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration:
                                          const Duration(milliseconds: 800),
                                      curve: Curves.easeOutQuad,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(20 * (1 - value), 0),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: AppTheme.fontSizeLarge,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: AppTheme.spacingXSmall),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration:
                                          const Duration(milliseconds: 800),
                                      curve: Curves.easeOutQuad,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(20 * (1 - value), 0),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        description,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: AppTheme.fontSizeSmall,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow indicator with small animation
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(10 * (1 - value), 0),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: AppTheme.iconSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Subtle medical patterns inside card
  Widget _buildCardPattern(Color baseColor) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: MedicalCardPatternPainter(
            value: _backgroundAnimationController.value,
            baseColor: baseColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Medical-themed gradient painter for animated background
class GradientPainter extends CustomPainter {
  final double value;
  final double offsetX;
  final double offsetY;

  GradientPainter({
    required this.value,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create moving gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Create shifting gradient colors with modified alignment
    final beginX = -1.0 + math.sin(value * 2 * math.pi) * 0.2 + offsetX * 0.05;
    final beginY = -1.0 + math.cos(value * 2 * math.pi) * 0.2 + offsetY * 0.05;
    final endX = 1.0 - math.sin(value * 2 * math.pi) * 0.2 - offsetX * 0.05;
    final endY = 1.0 - math.cos(value * 2 * math.pi) * 0.2 - offsetY * 0.05;

    final gradient = LinearGradient(
      begin: Alignment(beginX, beginY),
      end: Alignment(endX, endY),
      colors: const [
        AppTheme.primaryColor,
        Color(0xFF062F3F),
        Color(0xFF093575),
        AppTheme.secondaryColor,
      ],
      stops: [
        0.1 + (math.sin(value * math.pi) * 0.05),
        0.4 + (math.cos(value * math.pi) * 0.05),
        0.6 + (math.sin(value * math.pi) * 0.05),
        0.9 + (math.cos(value * math.pi) * 0.05),
      ],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add subtle light sources to create depth
    _drawLightSource(
      canvas,
      Offset(
        size.width *
            (0.2 + math.sin(value * 2 * math.pi) * 0.1 + offsetX * 0.02),
        size.height *
            (0.3 + math.cos(value * 2 * math.pi) * 0.1 + offsetY * 0.02),
      ),
      size.width * 0.3,
      AppTheme.secondaryColor.withOpacity(0.15),
    );

    _drawLightSource(
      canvas,
      Offset(
        size.width *
            (0.8 + math.cos(value * 2 * math.pi) * 0.1 - offsetX * 0.02),
        size.height *
            (0.7 + math.sin(value * 2 * math.pi) * 0.1 - offsetY * 0.02),
      ),
      size.width * 0.4,
      AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  void _drawLightSource(
      Canvas canvas, Offset center, double radius, Color color) {
    final gradient = RadialGradient(
      colors: [
        color,
        color.withOpacity(0),
      ],
      stops: const [0.1, 1.0],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(GradientPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.offsetX != offsetX ||
      oldDelegate.offsetY != offsetY;
}

// Medical grid painter for background pattern
class MedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 20;

    // Draw subtle grid
    final gridPaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i <= size.width / cellSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= size.height / cellSize; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(MedicalGridPainter oldDelegate) => false;
}

// Medical particles painter
class MedicalParticlesPainter extends CustomPainter {
  final double value;
  final double offsetX;
  final double offsetY;
  final List<_MedicalParticle> _particles = [];

  MedicalParticlesPainter({
    required this.value,
    required this.offsetX,
    required this.offsetY,
  }) {
    // Initialize particles with random positions and properties
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      _particles.add(
        _MedicalParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2.5 + 1,
          speed: random.nextDouble() * 0.01 + 0.005,
          opacity: random.nextDouble() * 0.4 + 0.1,
          type: random.nextInt(2), // 0 = cross, 1 = circle
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      // Calculate position with animation and parallax effect
      final x = (particle.x * size.width +
              math.sin(value * 2 * math.pi + particle.y * 10) * 20) +
          (offsetX * particle.size * 3);
      final y = (particle.y * size.height +
              math.cos(value * 2 * math.pi + particle.x * 10) * 20) +
          (offsetY * particle.size * 3);

      // Wrap around the screen if particles go off-screen
      final wrappedX = x % size.width;
      final wrappedY = y % size.height;

      // Draw the particle based on type
      // Ensure opacity is within valid range (0.0 to 1.0)
      final calculatedOpacity =
          particle.opacity * (0.6 + math.sin(value * math.pi * 2) * 0.4);
      final safeOpacity = calculatedOpacity.clamp(0.0, 1.0);

      if (particle.type == 0) {
        // Draw medical cross
        final paint = Paint()
          ..color = AppTheme.secondaryColor.withOpacity(safeOpacity)
          ..style = PaintingStyle.fill;

        final crossSize = particle.size * 2.5;
        final crossThickness = crossSize / 3;

        // Horizontal line
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(wrappedX, wrappedY),
            width: crossSize,
            height: crossThickness,
          ),
          paint,
        );

        // Vertical line
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(wrappedX, wrappedY),
            width: crossThickness,
            height: crossSize,
          ),
          paint,
        );

        // Add glow effect for larger particles
        if (particle.size > 1.5) {
          final safeGlowOpacity = (safeOpacity * 0.3).clamp(0.0, 1.0);
          final glowPaint = Paint()
            ..color = AppTheme.secondaryColor.withOpacity(safeGlowOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(wrappedX, wrappedY),
              width: crossSize * 1.5,
              height: crossThickness * 1.5,
            ),
            glowPaint,
          );
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(wrappedX, wrappedY),
              width: crossThickness * 1.5,
              height: crossSize * 1.5,
            ),
            glowPaint,
          );
        }
      } else {
        // Draw circle (pill or medical symbol)
        final paint = Paint()
          ..color = AppTheme.accentColor.withOpacity(safeOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawCircle(
          Offset(wrappedX, wrappedY),
          particle.size * 2,
          paint,
        );

        // Add glow for larger particles
        if (particle.size > 1.5) {
          final safeGlowOpacity = (safeOpacity * 0.3).clamp(0.0, 1.0);
          final glowPaint = Paint()
            ..color = AppTheme.accentColor.withOpacity(safeGlowOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

          canvas.drawCircle(
            Offset(wrappedX, wrappedY),
            particle.size * 3,
            glowPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(MedicalParticlesPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.offsetX != offsetX ||
      oldDelegate.offsetY != offsetY;
}

// Card pattern painter for animated medical patterns inside access option cards
class MedicalCardPatternPainter extends CustomPainter {
  final double value;
  final Color baseColor;
  final List<_CardPattern> _patterns = [];

  MedicalCardPatternPainter({
    required this.value,
    required this.baseColor,
  }) {
    // Initialize patterns
    final random = math.Random(42);
    for (int i = 0; i < 5; i++) {
      _patterns.add(
        _CardPattern(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 6 + 3,
          type: random.nextInt(2), // 0 = cross, 1 = circle
          angle: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final pattern in _patterns) {
      // Update pattern position based on animation value
      final xPos = (pattern.x * size.width +
              math.sin(value * 2 * math.pi + pattern.angle) * 3) %
          size.width;
      final yPos = (pattern.y * size.height +
              math.cos(value * 2 * math.pi + pattern.angle) * 3) %
          size.height;

      // Draw pattern based on type
      final patternPaint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill;

      if (pattern.type == 0) {
        // Cross symbol
        final crossSize = pattern.size;
        final thickness = crossSize / 3;

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(xPos, yPos),
            width: crossSize,
            height: thickness,
          ),
          patternPaint,
        );

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(xPos, yPos),
            width: thickness,
            height: crossSize,
          ),
          patternPaint,
        );
      } else {
        // Circle symbol
        canvas.drawCircle(
          Offset(xPos, yPos),
          pattern.size / 2,
          patternPaint,
        );

        // Draw medical heartbeat line inside
        if (pattern.size > 7) {
          final path = Path();
          final lineSize = pattern.size * 0.6;
          final lineHeight = pattern.size * 0.2;

          path.moveTo(xPos - lineSize / 2, yPos);
          path.lineTo(xPos - lineSize / 4, yPos);
          path.lineTo(xPos - lineSize / 6, yPos - lineHeight);
          path.lineTo(xPos, yPos + lineHeight);
          path.lineTo(xPos + lineSize / 6, yPos - lineHeight);
          path.lineTo(xPos + lineSize / 4, yPos);
          path.lineTo(xPos + lineSize / 2, yPos);

          canvas.drawPath(
              path,
              Paint()
                ..color = Colors.white.withOpacity(0.1)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0);
        }
      }
    }
  }

  @override
  bool shouldRepaint(MedicalCardPatternPainter oldDelegate) =>
      value != oldDelegate.value || baseColor != oldDelegate.baseColor;
}

// Helper class for medical particles
class _MedicalParticle {
  double x; // 0 to 1, x position ratio
  double y; // 0 to 1, y position ratio
  final double size;
  final double speed;
  final double opacity;
  final int type; // 0 = cross, 1 = circle

  _MedicalParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.type,
  });
}

// Helper class for card patterns
class _CardPattern {
  final double x;
  final double y;
  final double size;
  final int type;
  final double angle;

  _CardPattern({
    required this.x,
    required this.y,
    required this.size,
    required this.type,
    required this.angle,
  });
}
