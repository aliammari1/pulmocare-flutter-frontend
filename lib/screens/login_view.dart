import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/user.dart';
import 'package:provider/provider.dart';
import '../services/auth_view_model.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class LoginView extends StatefulWidget {
  final UserRole role;

  const LoginView({super.key, required this.role});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _formAnimationController;

  // For parallax effect
  double _offsetX = 0;
  double _offsetY = 0;

  @override
  void initState() {
    super.initState();
    switch (widget.role) {
      case UserRole.doctor:
        _emailController.text = "ali.ammari@esprit.tn";
        break;
      case UserRole.radiologist:
        _emailController.text = "ali.ammari2@esprit.tn";
        break;
      case UserRole.patient:
        _emailController.text = "ali.ammari3@esprit.tn";
        break;
      default:
        _emailController.text = "";
        break;
    }
    _passwordController.text = "\$Admin2002";
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _formAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _showAlert(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF050A30).withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4FC3F7),
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF050A30),
      body: GestureDetector(
        onPanUpdate: (details) {
          // Update parallax effect
          setState(() {
            _offsetX += details.delta.dx * 0.01;
            _offsetY += details.delta.dy * 0.01;

            // Constrain offset values
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
              animation: _formAnimationController,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: _buildGlassButton(
                            onTap: () => context.pop(),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white.withOpacity(0.9),
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Logo with animations
                        AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            final scale = Tween<double>(begin: 0.0, end: 1.0)
                                .animate(CurvedAnimation(
                                  parent: _formAnimationController,
                                  curve: Interval(0.0, 0.5,
                                      curve: Curves.elasticOut),
                                ))
                                .value;

                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: _buildLogoSection(),
                        ),

                        const SizedBox(height: 40),

                        // Login form with glass morphism
                        AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            final slideAnimation = Tween<Offset>(
                              begin: Offset(0, 100),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _formAnimationController,
                              curve: Interval(0.3, 0.7,
                                  curve: Curves.easeOutQuint),
                            ));

                            final fadeAnimation = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(CurvedAnimation(
                              parent: _formAnimationController,
                              curve: Interval(0.3, 0.7, curve: Curves.easeOut),
                            ));

                            return FadeTransition(
                              opacity: fadeAnimation,
                              child: Transform.translate(
                                offset: slideAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: _buildGlassContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title
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
                                  child: Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // User type indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4FC3F7)
                                            .withOpacity(0.2),
                                        const Color(0xFF0D47A1)
                                            .withOpacity(0.2),
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
                                  child: Text(
                                    'Sign in as ${widget.role.name}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Email field
                                _buildTextField(
                                  controller: _emailController,
                                  validator: _validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  labelText: 'Email',
                                  prefixIcon: Icons.email,
                                ),

                                const SizedBox(height: 16),

                                // Password field
                                _buildTextField(
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  obscureText: _obscurePassword,
                                  labelText: 'Password',
                                  prefixIcon: Icons.lock,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white60,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push('/forgot-password'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF4FC3F7),
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFF4FC3F7)
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login button with cosmic design
                                _buildGlowingButton(
                                  text: 'LOGIN',
                                  isLoading: _isLoading,
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() => _isLoading = true);
                                            try {
                                              await context
                                                  .read<AuthViewModel>()
                                                  .login(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                    widget.role,
                                                  );

                                              final authVM =
                                                  context.read<AuthViewModel>();
                                              if (authVM.isAuthenticated) {
                                                // Check if returned role matches the selected role
                                                String selectedRole = widget
                                                    .role
                                                    .toString()
                                                    .split('.')
                                                    .last
                                                    .toLowerCase();
                                                if (authVM.role !=
                                                    selectedRole) {
                                                  setState(
                                                      () => _isLoading = false);
                                                  _showAlert(
                                                      'Error',
                                                      'Wrong Username or Password',
                                                      false);
                                                  await context
                                                      .read<AuthViewModel>()
                                                      .logout(context);
                                                  return;
                                                }

                                                _showAlert('Success',
                                                    'Login successful!', true);

                                                // Add debug prints to track navigation
                                                debugPrint(
                                                    'DEBUG: Authentication successful. User type: ${authVM.role}');

                                                // Redirect based on user type
                                                if (authVM.role == 'doctor') {
                                                  debugPrint(
                                                      'DEBUG: Navigating doctor to /doctor-dashboard');
                                                  context
                                                      .go('/doctor-dashboard');
                                                } else if (authVM.role ==
                                                    'radiologist') {
                                                  debugPrint(
                                                      'DEBUG: Navigating radiologist to /radiologist-dashboard');
                                                  context.go(
                                                      '/radiologist-dashboard');
                                                } else {
                                                  debugPrint(
                                                      'DEBUG: Navigating patient to /patient-dashboard');
                                                  context.go(
                                                      '/patient-dashboard'); // Patient dashboard
                                                }
                                              } else {
                                                _showAlert('Error',
                                                    authVM.errorMessage, false);
                                              }
                                            } catch (e) {
                                              _showAlert(
                                                  'Error', e.toString(), false);
                                            } finally {
                                              setState(
                                                  () => _isLoading = false);
                                            }
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Create account button
                        AnimatedBuilder(
                          animation: _formAnimationController,
                          builder: (context, child) {
                            final fadeAnimation = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(CurvedAnimation(
                              parent: _formAnimationController,
                              curve: Interval(0.7, 1.0, curve: Curves.easeOut),
                            ));

                            return FadeTransition(
                              opacity: fadeAnimation,
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: () =>
                                context.push('/register', extra: widget.role),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4FC3F7)
                                        .withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(color: Colors.white70),
                                  children: [
                                    TextSpan(
                                      text: 'Create Account',
                                      style: TextStyle(
                                        color: const Color(0xFF4FC3F7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Error Message
                        Consumer<AuthViewModel>(
                          builder: (context, authVM, child) {
                            return authVM.errorMessage.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      authVM.errorMessage,
                                      style: TextStyle(color: Colors.red[300]),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 10),

                        // Floating indicator
                        Container(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Glass morphism container
  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // Small glass button (for back button)
  Widget _buildGlassButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // Glowing cosmic button
  Widget _buildGlowingButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF304FFE),
                      const Color(0xFF4FC3F7),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Small glow effect
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Animated logo section
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
                  child: Icon(
                    widget.role == 'doctor'
                        ? Icons.medical_services
                        : widget.role == 'radiologist'
                            ? Icons.biotech
                            : Icons.person,
                    size: 70,
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
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  // Custom cosmic text field with animated glow effect
  Widget _buildTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Track field focus state internally
        final focusNode = FocusNode();
        bool isFocused = false;

        focusNode.addListener(() {
          setState(() => isFocused = focusNode.hasFocus);
        });

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? const Color(0xFF4FC3F7).withOpacity(0.3)
                    : const Color(0xFF304FFE).withOpacity(0.1),
                blurRadius: isFocused ? 15 : 6,
                spreadRadius: isFocused ? 2 : -1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background that subtly pulses when focused
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isFocused
                        ? [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.07),
                          ]
                        : [
                            Colors.white.withOpacity(0.09),
                            Colors.white.withOpacity(0.03),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFocused
                        ? const Color(0xFF4FC3F7).withOpacity(0.7)
                        : Colors.white.withOpacity(0.2),
                    width: isFocused ? 2 : 1,
                  ),
                ),
                child: isFocused
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4FC3F7).withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),

              // Glassmorphism effect
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.transparent,
                    ),
                    child: TextFormField(
                      controller: controller,
                      validator: validator,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFF4FC3F7),
                      cursorWidth: 1.5,
                      cursorRadius: const Radius.circular(3),
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        labelText: isFocused ? null : labelText,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: isFocused ? labelText : null,
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 15,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: const TextStyle(
                          color: Color(0xFFFF6E6E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 56,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: isFocused
                                    ? const Color(0xFF4FC3F7).withOpacity(0.4)
                                    : Colors.white.withOpacity(0.15),
                                width: isFocused ? 1.5 : 1,
                              ),
                            ),
                            gradient: LinearGradient(
                              colors: isFocused
                                  ? [
                                      const Color(0xFF304FFE).withOpacity(0.25),
                                      const Color(0xFF4FC3F7).withOpacity(0.15),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.05),
                                      Colors.white.withOpacity(0.01),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            prefixIcon,
                            color: isFocused
                                ? const Color(0xFF4FC3F7)
                                : Colors.white.withOpacity(0.8),
                            size: 22,
                          ),
                        ),
                        suffixIcon: suffixIcon,
                      ),
                    ),
                  ),
                ),
              ),

              // Cosmic particles when focused (subtle animation)
              if (isFocused)
                Positioned.fill(
                  child: IgnorePointer(
                    child: FocusParticles(color: const Color(0xFF4FC3F7)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Add a new widget for focus particles
class FocusParticles extends StatefulWidget {
  final Color color;

  const FocusParticles({super.key, required this.color});

  @override
  _FocusParticlesState createState() => _FocusParticlesState();
}

class _FocusParticlesState extends State<FocusParticles>
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: FieldParticlesPainter(
              animationValue: _controller.value,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class FieldParticlesPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  FieldParticlesPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    // Draw subtle particle effects for focused field
    for (int i = 0; i < 12; i++) {
      final xPos = random.nextDouble() * size.width;
      final yPos = random.nextDouble() * size.height;

      final xOffset = math.sin((animationValue * math.pi * 2) + i) * 3;
      final yOffset = math.cos((animationValue * math.pi * 2) + i) * 2;

      final x = xPos + xOffset;
      final y = yPos + yOffset;

      final radius = random.nextDouble() * 1.5 + 0.5;

      final opacity = (math.sin((animationValue * math.pi * 6) + i) + 1) / 3;

      final paint = Paint()
        ..color = i % 2 == 0
            ? color.withOpacity(opacity * 0.5)
            : Colors.white.withOpacity(opacity * 0.3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(FieldParticlesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}

// Custom painter for creating the animated gradient background
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
    final paint = Paint();

    // Create a deep space gradient background
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF050A30), // Deep space blue
        Color(0xFF000C40), // Navy blue
      ],
    ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Draw moving nebula clouds
    for (int i = 0; i < 3; i++) {
      double startX = size.width * 0.2 +
          (size.width * 0.6 * math.sin(value * math.pi * 2 + i)) +
          offsetX * 10;
      double startY = size.height * 0.2 +
          (size.height * 0.6 * math.cos(value * math.pi * 2 + i)) +
          offsetY * 10;

      final nebulaRadius = (size.width * 0.3) + (i * 20);

      final nebulaPaint = Paint()
        ..shader = RadialGradient(
          colors: i == 0
              ? [
                  const Color(0xFF304FFE).withOpacity(0.2),
                  const Color(0xFF304FFE).withOpacity(0.0),
                ]
              : i == 1
                  ? [
                      const Color(0xFF01579B).withOpacity(0.15),
                      const Color(0xFF01579B).withOpacity(0.0),
                    ]
                  : [
                      const Color(0xFF0277BD).withOpacity(0.1),
                      const Color(0xFF0277BD).withOpacity(0.0),
                    ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(startX, startY),
            radius: nebulaRadius,
          ),
        );

      canvas.drawCircle(
        Offset(startX, startY),
        nebulaRadius,
        nebulaPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GradientPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.offsetX != offsetX ||
      oldDelegate.offsetY != offsetY;
}

// Particles animator
class ParticlesPainter extends CustomPainter {
  final double value;
  final double offsetX;
  final double offsetY;

  ParticlesPainter({
    required this.value,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 80; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Create floating particles
      final x = baseX + math.sin(value * math.pi * 2 + i) * 5 + offsetX * 2;
      final y = baseY + math.cos(value * math.pi * 2 + i) * 5 + offsetY * 2;

      final radius = random.nextDouble() * 2.0 + 0.5;

      final paint = Paint()
        ..color = i % 3 == 0
            ? const Color(0xFF4FC3F7).withOpacity(0.8)
            : i % 3 == 1
                ? const Color(0xFF5C6BC0).withOpacity(0.6)
                : Colors.white.withOpacity(0.9);

      // Make some stars twinkle
      if (i % 7 == 0) {
        final twinkle = (math.sin(value * math.pi * 10 + i) + 1) / 2;
        paint.color = paint.color.withOpacity(0.3 + (twinkle * 0.6));
      }

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add star effect to some particles
      if (i % 11 == 0) {
        final starPaint = Paint()
          ..color = paint.color.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        // Draw simple star rays
        canvas.drawLine(
          Offset(x - radius * 2, y),
          Offset(x + radius * 2, y),
          starPaint,
        );
        canvas.drawLine(
          Offset(x, y - radius * 2),
          Offset(x, y + radius * 2),
          starPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.offsetX != offsetX ||
      oldDelegate.offsetY != offsetY;
}
