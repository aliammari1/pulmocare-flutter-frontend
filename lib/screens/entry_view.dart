import 'package:flutter/material.dart';
import 'package:medapp/screens/login_screen.dart';
import 'package:medapp/screens/login_radio.dart';
import 'login_view.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/services.dart';

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
      backgroundColor: const Color(0xFF050A30),
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

            // Floating particles
            AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: ParticlesPainter(
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
                            const Text(
                              'Choose Access Type',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

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
                                    'Access patient diagnostics and manage treatments',
                                iconData: Icons.medical_services_outlined,
                                gradient: const [
                                  Color(0xFF3A7BD5),
                                  Color(0xFF00D2FF)
                                ],
                                userType: 'doctor',
                              ),
                            ),
                            const SizedBox(height: 20),

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
                                title: 'Radiologist Dashboard',
                                description:
                                    'Advanced X-ray analysis and reporting tools',
                                iconData: Icons.biotech_outlined,
                                gradient: const [
                                  Color(0xFF614385),
                                  Color(0xFF516395)
                                ],
                                userType: 'radiologist',
                              ),
                            ),
                            const SizedBox(height: 20),

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
                                    'View your medical reports and results',
                                iconData: Icons.person_outline,
                                gradient: const [
                                  Color(0xFF00B4DB),
                                  Color(0xFF0083B0)
                                ],
                                userType: 'patient',
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
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
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
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Touch & drag to explore',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
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

  // Animated 3D logo section
  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo with shimmering effect
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating outer ring
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 2 * math.pi),
                duration: const Duration(seconds: 20),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.5),
                          width: 2,
                        ),
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.blue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.7, 0.8, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Inner circle with icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      const Color(0xFFE0F7FA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/2059/2059316.png',
                    width: 70,
                    height: 70,
                    color: const Color(0xFF0D47A1),
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
        const SizedBox(height: 20),

        // App title with glowing effect
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF4FC3F7),
                Colors.white,
                Color(0xFF4FC3F7),
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: const Text(
            'PulmoCare',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Animated tagline container
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              'ADVANCED PULMONARY ANALYSIS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Interactive card for user access options
  Widget _buildAccessCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData iconData,
    required List<Color> gradient,
    required String userType,
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

        switch (userType) {
          case 'doctor':
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginView(userType: userType),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
            break;
          case 'radiologist':
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginRadioView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(0.0, 1.0);
                  var end = Offset.zero;
                  var curve = Curves.easeOutCubic;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
            break;
          case 'patient':
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
            break;
        }
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
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated particles in the background
                        Positioned.fill(
                          child: _buildCardParticles(gradient[0]),
                        ),
                        // Background decorative elements
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            iconData,
                            size: 100,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
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
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: gradient[0],
                                        size: 30,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 20),
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
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
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13,
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
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
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

  // Animated particles inside card
  Widget _buildCardParticles(Color baseColor) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: CardParticlesPainter(
            value: _backgroundAnimationController.value,
            baseColor: baseColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// Gradient painter for animated background
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
    // Using a different approach since Alignment doesn't have a translate method
    final beginX = -1.0 + math.sin(value * 2 * math.pi) * 0.2 + offsetX * 0.05;
    final beginY = -1.0 + math.cos(value * 2 * math.pi) * 0.2 + offsetY * 0.05;
    final endX = 1.0 - math.sin(value * 2 * math.pi) * 0.2 - offsetX * 0.05;
    final endY = 1.0 - math.cos(value * 2 * math.pi) * 0.2 - offsetY * 0.05;

    final gradient = LinearGradient(
      begin: Alignment(beginX, beginY),
      end: Alignment(endX, endY),
      colors: const [
        Color(0xFF050A30),
        Color(0xFF000428),
        Color(0xFF093575),
        Color(0xFF0F4C8F),
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

    // Add some light sources
    _drawLightSource(
      canvas,
      Offset(
        size.width *
            (0.2 + math.sin(value * 2 * math.pi) * 0.1 + offsetX * 0.02),
        size.height *
            (0.3 + math.cos(value * 2 * math.pi) * 0.1 + offsetY * 0.02),
      ),
      size.width * 0.3,
      const Color(0xFF4FC3F7).withOpacity(0.15),
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
      const Color(0xFF0D47A1).withOpacity(0.1),
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

// Particles painter for floating particles
class ParticlesPainter extends CustomPainter {
  final double value;
  final double offsetX;
  final double offsetY;
  final List<_Particle> _particles = [];

  ParticlesPainter({
    required this.value,
    required this.offsetX,
    required this.offsetY,
  }) {
    // Initialize particles with random positions and properties
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      _particles.add(
        _Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.01 + 0.005,
          opacity: random.nextDouble() * 0.4 + 0.1,
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

      // Draw the particle
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(wrappedX, wrappedY), particle.size, paint);

      // Add glow effect for larger particles
      if (particle.size > 2) {
        final glowPaint = Paint()
          ..color = Colors.blue.withOpacity(particle.opacity * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(
            Offset(wrappedX, wrappedY), particle.size * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.offsetX != offsetX ||
      oldDelegate.offsetY != offsetY;
}

// Card particle painter for animated particles inside access option cards
class CardParticlesPainter extends CustomPainter {
  final double value;
  final Color baseColor;
  final List<_CardParticle> _particles = [];

  CardParticlesPainter({
    required this.value,
    required this.baseColor,
  }) {
    // Initialize particles
    final random = math.Random(42);
    for (int i = 0; i < 15; i++) {
      _particles.add(
        _CardParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.02 + 0.01,
          angle: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in _particles) {
      // Update particle position based on animation value
      final xPos = (particle.x * size.width +
              math.sin(value * 2 * math.pi + particle.angle) * 20) %
          size.width;
      final yPos = (particle.y * size.height +
              math.cos(value * 2 * math.pi + particle.angle) * 20) %
          size.height;

      // Draw the particle
      final paint = Paint()
        ..color = baseColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(xPos, yPos), particle.size, paint);

      // Add glow effect
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(xPos, yPos), particle.size * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(CardParticlesPainter oldDelegate) =>
      value != oldDelegate.value || baseColor != oldDelegate.baseColor;
}

// Helper class for card particles
class _CardParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double angle;

  _CardParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

// Helper class for particles
class _Particle {
  double x; // 0 to 1, x position ratio
  double y; // 0 to 1, y position ratio
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
