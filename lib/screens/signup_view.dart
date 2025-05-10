import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/user.dart';
import 'package:medapp/screens/map_selection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_view_model.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/location_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/visit_card_scan_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:math';
import "package:medapp/widgets/medical_ui_components.dart";
import '../services/file_service.dart';
import 'package:faker/faker.dart' hide Color;

class FluidBackground extends StatefulWidget {
  final Color color;

  const FluidBackground({Key? key, required this.color}) : super(key: key);

  @override
  _FluidBackgroundState createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
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
        return CustomPaint(
          painter: FluidPainter(
            color: widget.color,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class FluidPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  FluidPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    // Create flowing abstract medical-like fluid patterns
    final path = Path();

    // Start from bottom left
    path.moveTo(0, height);

    // First curve
    path.quadraticBezierTo(
        width * 0.25 + sin(animationValue * pi * 2) * width * 0.1,
        height * 0.8 + cos(animationValue * pi * 2) * height * 0.05,
        width * 0.5,
        height * 0.85 + sin(animationValue * pi) * height * 0.05);

    // Second curve
    path.quadraticBezierTo(
        width * 0.75 - sin(animationValue * pi * 2) * width * 0.1,
        height * 0.9 + cos(animationValue * pi * 2 + pi / 3) * height * 0.05,
        width,
        height * 0.8);

    // Complete the path
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);

    // Second flowing pattern
    final path2 = Path();
    path2.moveTo(0, height * 0.7);

    // Create wave effect
    path2.quadraticBezierTo(
        width * 0.3 + cos(animationValue * pi * 2 + pi / 4) * width * 0.1,
        height * 0.65 + sin(animationValue * pi * 2) * height * 0.04,
        width * 0.6,
        height * 0.75 + cos(animationValue * pi) * height * 0.04);

    path2.quadraticBezierTo(
        width * 0.8 - sin(animationValue * pi * 2) * width * 0.1,
        height * 0.8 + sin(animationValue * pi * 2 + pi / 2) * height * 0.05,
        width,
        height * 0.7);

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    final paint2 = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Animated gradient button
class AnimatedGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final List<List<Color>> gradients;

  const AnimatedGradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.gradients,
  }) : super(key: key);

  @override
  _AnimatedGradientButtonState createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
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
        // Animate between gradients
        final int index =
            (_controller.value * widget.gradients.length).floor() %
                widget.gradients.length;
        final List<Color> currentGradient = widget.gradients[index];

        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: currentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: currentGradient.first.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}

// Custom loading indicator
class LoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const LoadingIndicator({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 2,
      ),
    );
  }
}

class SignupView extends StatefulWidget {
  final UserRole role;

  const SignupView({super.key, required this.role});

  @override
  _SignupViewState createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  // Patient-specific controllers
  final _date_of_birthController = TextEditingController();
  final _blood_typeController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medical_historyController = TextEditingController();

  bool _isLoading = false;
  String? _initialCountryCode;
  bool _isCountryCodeLoading = true;
  final _locationService = LocationService();

  // Blood type options
  final List<String> _blood_types = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  String? _selectedblood_type;

  // Track the current step for multi-step form
  int _currentStep = 0;

  // Page controller for horizontal page navigation
  late PageController _pageController;

  // Define the steps based on role
  late List<String> _steps;
  // File picker variables
  List<File> _selectedmedical_historyFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Add FileService instance
  final FileService _fileService = FileService();

  // Add a list to store file IDs returned from the server
  List<String> _uploadedFileIds = [];

  // Create a faker instance
  final faker = Faker();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadCountryCode();
    _pageController = PageController(initialPage: 0);

    // Set steps based on user role
    if (widget.role == UserRole.patient) {
      _steps = ['Personal Info', 'Medical Info', 'Contact'];
    } else if (widget.role == UserRole.doctor) {
      _steps = [
        'Personal Info',
        'Medical Credentials',
        'Professional Info',
        'Contact'
      ];
    } else {
      _steps = ['Personal Info', 'Professional Info', 'Contact'];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _hospitalController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    // Dispose patient-specific controllers
    _date_of_birthController.dispose();
    _blood_typeController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medical_historyController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Request location permission
    var locationStatus = await Permission.location.status;
    if (locationStatus.isDenied) {
      await Permission.location.request();
    }

    // Request camera permission
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }
  }

  Future<void> _loadCountryCode() async {
    try {
      setState(() => _isCountryCodeLoading = true);
      final countryCode = await _locationService.getCurrentCountryCode();

      setState(() {
        _initialCountryCode = countryCode;
        _isCountryCodeLoading = false;
      });
      print('Detected Country Code: $_initialCountryCode');
    } catch (e) {
      print('Error detecting country code: $e');
      setState(() => _isCountryCodeLoading = false);
    }
  }

  Future<void> _showVisitCardScanDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => VisitCardScanDialog(),
    );

    if (result != null) {
      setState(() {
        _nameController.text = result['name'] ?? '';
        _specialtyController.text = result['specialty'] ?? '';
        _emailController.text = result['email'] ?? '';
        _phoneController.text = result['phone'] ?? '';
        _addressController.text = result['address'] ?? '';
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? _validateSpecialty(String? value) {
    if (widget.role == UserRole.doctor && (value == null || value.isEmpty)) {
      return 'Specialty is required for doctors';
    }
    return null;
  }

  String? _validateLicenseNumber(String? value) {
    if ((widget.role == UserRole.doctor ||
            widget.role == UserRole.radiologist) &&
        (value == null || value.isEmpty)) {
      return 'License number is required';
    }
    return null;
  }

  String? _validateHospital(String? value) {
    if ((widget.role == UserRole.doctor ||
            widget.role == UserRole.radiologist) &&
        (value == null || value.isEmpty)) {
      return 'Hospital/Clinic information is required';
    }
    return null;
  }
  // Phone validation is handled by IntlPhoneField widget

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (widget.role == UserRole.patient && (value == null || value.isEmpty)) {
      return 'Height is required';
    }
    if (value != null && value.isNotEmpty) {
      try {
        double.parse(value);
      } catch (e) {
        return 'Please enter a valid number';
      }
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (widget.role == UserRole.patient && (value == null || value.isEmpty)) {
      return 'Weight is required';
    }
    if (value != null && value.isNotEmpty) {
      try {
        double.parse(value);
      } catch (e) {
        return 'Please enter a valid number';
      }
    }
    return null;
  }

  String? _validatedate_of_birth(String? value) {
    if (widget.role == UserRole.patient && (value == null || value.isEmpty)) {
      return 'Birth date is required';
    }
    return null;
  }

  // Date picker for patient birth date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date_of_birthController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showAlert(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Next step logic
  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Previous step logic
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get role-specific colors with the new medical color palette
    final primaryColor = _getRolePrimaryColor();
    final secondaryColor = _getRoleSecondaryColor();
    final IconData roleIcon = _getRoleIcon();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Modern subtle medical background
          Positioned.fill(
            child: CustomPaint(
              painter: MedicalBackgroundPainter(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Clean, modern header with role icon
                  _buildModernHeader(
                      context, roleIcon, primaryColor, secondaryColor),

                  // Form progress indicator
                  _buildModernProgressIndicator(),

                  // Page view for form steps
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      children: _buildPageSteps(),
                    ),
                  ),

                  // Modern navigation buttons
                  _buildModernNavigationButtons(primaryColor, secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern, clean header with subtle medical branding
  Widget _buildModernHeader(BuildContext context, IconData roleIcon,
      Color primaryColor, Color secondaryColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // Back button with subtle design
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, size: 18),
              color: primaryColor,
              onPressed: () => context.pop(),
            ),
          ),
          SizedBox(width: 16),

          // Title section with clean typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRoleTitle(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3247),
                    fontFamily: 'Poppins',
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _getRoleSubtitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7691),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Clean role icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(roleIcon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // Modern, clean progress indicator
  Widget _buildModernProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Step ${_currentStep + 1} of ${_steps.length}: ${_steps[_currentStep]}',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF546E7A),
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          // Progress bar with animated indicator
          Stack(
            children: [
              // Background track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Progress indicator
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 8,
                width: MediaQuery.of(context).size.width *
                    ((_currentStep + 1) / _steps.length) *
                    0.87,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRolePrimaryColor(),
                      _getRoleSecondaryColor(),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: _getRolePrimaryColor().withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Step indicators
          Container(
            padding: EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: EdgeInsets.only(right: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentStep
                              ? _getRolePrimaryColor()
                              : Colors.grey.shade200,
                          border: index == _currentStep
                              ? Border.all(
                                  color:
                                      _getRolePrimaryColor().withOpacity(0.3),
                                  width: 3,
                                )
                              : null,
                          boxShadow: index <= _currentStep
                              ? [
                                  BoxShadow(
                                    color:
                                        _getRolePrimaryColor().withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: index < _currentStep
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: index <= _currentStep
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    );
  }

  // Modern, elegant navigation buttons
  Widget _buildModernNavigationButtons(
      Color primaryColor, Color secondaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -3),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _prevStep,
              icon: Icon(Icons.arrow_back_rounded, size: 18),
              label: Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF546E7A),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          else
            SizedBox(width: 90),

          // Demo data button
          IconButton(
            onPressed: _fillWithDemoData,
            icon: Icon(Icons.auto_fix_high, color: primaryColor),
            tooltip: 'Fill with demo data',
          ),

          // Next/Submit button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_currentStep < _steps.length - 1) {
                      _nextStep();
                    } else {
                      _submitForm();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getRolePrimaryColor(),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: _getRolePrimaryColor().withOpacity(0.4),
            ),
            child: _isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Please wait...'),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentStep < _steps.length - 1
                            ? 'Continue'
                            : 'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        _currentStep < _steps.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Build the different page steps based on role
  List<Widget> _buildPageSteps() {
    if (widget.role == UserRole.patient) {
      return [
        _buildPatientPersonalInfoStep(),
        _buildPatientMedicalInfoStep(),
        _buildContactInfoStep(),
      ];
    } else if (widget.role == UserRole.doctor) {
      return [
        _buildPersonalInfoStep(),
        _buildDoctorCredentialsStep(),
        _buildDoctorProfessionalInfoStep(),
        _buildContactInfoStep(),
      ];
    } else {
      // Radiologist
      return [
        _buildPersonalInfoStep(),
        _buildRadiologistProfessionalInfoStep(),
        _buildContactInfoStep(),
      ];
    }
  }

  // First step for all roles: Personal information
  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information', Icons.person_outline),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _nameController,
            label:
                widget.role == UserRole.patient ? 'Full Name' : 'Dr. Full Name',
            hintText: 'Enter your full name',
            icon: Icons.person,
            validator: _validateName,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Create a strong password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: _validatePassword,
            helperText: '8+ characters with letters, numbers & symbols',
          ),
        ],
      ),
    );
  }

  // Patient-specific personal info step
  Widget _buildPatientPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information', Icons.person_outline),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _nameController,
            label: 'Full Name',
            hintText: 'Enter your full name',
            icon: Icons.person,
            validator: _validateName,
          ),
          const SizedBox(height: 20),
          _buildDatePickerField(
            controller: _date_of_birthController,
            label: 'Date of Birth',
            hintText: 'Select your date of birth',
            validator: _validatedate_of_birth,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'Enter your email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Create a strong password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: _validatePassword,
            helperText: '8+ characters with letters, numbers & symbols',
          ),
        ],
      ),
    );
  }

  // Patient-specific medical info step
  Widget _buildPatientMedicalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Medical Information', Icons.medical_information),
          const SizedBox(height: 24),

          // Enhanced blood type selector with animated container
          _buildblood_typeSelector(),

          const SizedBox(height: 20),

          // Enhanced physical measurements with interactive sliders
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _getRolePrimaryColor().withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasurementSlider(
                        label: 'Height (cm)',
                        controller: _heightController,
                        validator: _validateHeight,
                        icon: Icons.height,
                        min: 100,
                        max: 220,
                        defaultValue: 170,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMeasurementSlider(
                        label: 'Weight (kg)',
                        controller: _weightController,
                        validator: _validateWeight,
                        icon: Icons.fitness_center,
                        min: 30,
                        max: 150,
                        defaultValue: 70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Enhanced allergies input with tags
          _buildEnhancedInputField(
            controller: _allergiesController,
            label: 'Allergies',
            hintText: 'List any allergies (if none, type "None")',
            icon: Icons.warning_amber_rounded,
            maxLines: 2,
            chipBuilder: (text) {
              if (text.isEmpty) return const SizedBox.shrink();

              final allergies =
                  text.split(',').where((e) => e.trim().isNotEmpty).toList();
              if (allergies.isEmpty) return const SizedBox.shrink();

              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: allergies
                    .map((allergy) => Chip(
                          label: Text(allergy.trim()),
                          backgroundColor:
                              _getRolePrimaryColor().withOpacity(0.1),
                          labelStyle: TextStyle(color: _getRolePrimaryColor()),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            final newList =
                                allergies.where((e) => e != allergy).join(', ');
                            _allergiesController.text = newList;
                            setState(() {});
                          },
                        ))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // Advanced Medical Document Upload Section
          _buildMedicalDocumentsUploadSection(),
        ],
      ),
    );
  }

  // Doctor credentials step
  Widget _buildDoctorCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Medical Credentials', Icons.badge),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _specialtyController,
            label: 'Medical Specialty',
            hintText: 'e.g., Cardiology, Neurology',
            icon: Icons.medical_services,
            validator: _validateSpecialty,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _licenseNumberController,
            label: 'Medical License Number',
            hintText: 'Enter your license number',
            icon: Icons.card_membership,
            validator: _validateLicenseNumber,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _educationController,
            label: 'Medical Education',
            hintText: 'e.g., MD from Johns Hopkins University',
            icon: Icons.school,
          ),
          const SizedBox(height: 20),
          _buildScanCardButton(),
        ],
      ),
    );
  }

  // Doctor professional info step
  Widget _buildDoctorProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Professional Details', Icons.business_center),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _hospitalController,
            label: 'Primary Hospital/Clinic',
            hintText: 'Where do you primarily practice?',
            icon: Icons.local_hospital,
            validator: _validateHospital,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _experienceController,
            label: 'Years of Experience',
            hintText: 'How many years have you practiced?',
            icon: Icons.timeline,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // Radiologist professional info step
  Widget _buildRadiologistProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Radiologist Qualifications', Icons.biotech),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _licenseNumberController,
            label: 'Radiologist License Number',
            hintText: 'Enter your license number',
            icon: Icons.card_membership,
            validator: _validateLicenseNumber,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _hospitalController,
            label: 'Radiology Center/Hospital',
            hintText: 'Where do you practice radiology?',
            icon: Icons.business,
            validator: _validateHospital,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _educationController,
            label: 'Radiology Education',
            hintText: 'e.g., Board Certified in Diagnostic Radiology',
            icon: Icons.school,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _experienceController,
            label: 'Experience in Radiology (years)',
            hintText: 'Years of experience in radiology',
            icon: Icons.timeline,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildScanCardButton(),
        ],
      ),
    );
  }

  // Contact information step (shared by all roles)
  Widget _buildContactInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Contact Information', Icons.contact_phone),
          const SizedBox(height: 24),

          _buildPhoneFieldWidget(),
          const SizedBox(height: 20),

          _buildAddressField(),
          const SizedBox(height: 16),

          // Summary section with animated opacity
          AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 500),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getRolePrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: _getRolePrimaryColor().withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to create your account!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getRolePrimaryColor(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click "Create Account" below to join as a ${_getRoleString()}.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets for form building
  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _getRolePrimaryColor().withOpacity(0.2),
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getRolePrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _getRolePrimaryColor(), size: 22),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label outside the field for cleaner look
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _getRolePrimaryColor()),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _getRolePrimaryColor(), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            // Add depth with subtle inner shadow
            isDense: true,
          ),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          cursorColor: _getRolePrimaryColor(),
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?)? validator,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_month,
                  size: 18, color: _getRolePrimaryColor()),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.text.isEmpty
                    ? Colors.grey.shade300
                    : _getRolePrimaryColor(),
                width: controller.text.isEmpty ? 1.5 : 2,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: _getRolePrimaryColor(),
                  size: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? hintText : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: _getRolePrimaryColor(),
                ),
              ],
            ),
          ),
        ),
        if (controller.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Please select a date',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
  // Dropdown field functionality is now handled by custom UI components

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      validator: _validateAddress,
      decoration: InputDecoration(
        labelText: widget.role == UserRole.patient
            ? 'Home Address'
            : widget.role == UserRole.doctor
                ? 'Practice Address'
                : 'Office Address',
        hintText: widget.role == UserRole.patient
            ? 'Your residential address'
            : 'Your professional address',
        prefixIcon: Icon(Icons.location_on, color: _getRolePrimaryColor()),
        suffixIcon: IconButton(
          icon: Icon(Icons.map, color: _getRolePrimaryColor()),
          tooltip: 'Select on map',
          onPressed: _openMapSelection,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getRolePrimaryColor(), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      maxLines: 2,
    );
  }

  Widget _buildPhoneFieldWidget() {
    if (_isCountryCodeLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getRolePrimaryColor(), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      initialCountryCode: _initialCountryCode ?? 'US',
      onChanged: (phone) {
        _phoneController.text = phone.completeNumber;
      },
      dropdownIcon: Icon(
        Icons.arrow_drop_down,
        color: _getRolePrimaryColor(),
      ),
      flagsButtonMargin: EdgeInsets.only(left: 8),
    );
  }

  Widget _buildScanCardButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showVisitCardScanDialog,
        icon: Icon(Icons.document_scanner),
        label: Text('Scan Your Business Card'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getRolePrimaryColor().withOpacity(0.9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // Helper methods
  Future<void> _openMapSelection() async {
    final selectedAddress = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return MapSelectionDialog(initialAddress: _addressController.text);
      },
    );
    if (selectedAddress != null) {
      setState(() => _addressController.text = selectedAddress);
    }
  }

  // Modified method to pick and upload files
  Future<void> _pickMultiplemedical_historyFiles() async {
    try {
      setState(() => _isUploading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // Create a list to hold the actual File objects
        List<File> files = [];
        List<String> fileIds = [];

        // Process each file path to create proper File objects
        for (var platformFile in result.files) {
          if (platformFile.path != null) {
            files.add(File(platformFile.path!));
          }
        }

        // Upload each file and track progress
        final totalFiles = files.length;
        int uploadedCount = 0;
        for (var file in files) {
          debugPrint("${file.path}");
        }
        for (var file in files) {
          try {
            final fileName = file.path.split('/').last;
            // Upload the file
            final prefs = await SharedPreferences.getInstance();
            final patientId = prefs.getString("userId");

            final fileId = await _fileService.uploadFile(file, fileName,
                bucket: "patientdocuments", folder: "$patientId");
            fileIds.add(fileId);
            // Update progress
            uploadedCount++;
            if (!mounted) return;
            setState(() {
              _uploadProgress = uploadedCount / totalFiles;
            });
          } catch (e) {
            print('Error uploading file: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Error uploading file: ${file.path.split('/').last}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        if (files.isNotEmpty) {
          setState(() {
            _selectedmedical_historyFiles.addAll(files);
            _uploadedFileIds.addAll(fileIds);

            // Add filenames to medical history text as reference
            String fileNames = result.files.map((file) => file.name).join(', ');
            if (_medical_historyController.text.isEmpty) {
              _medical_historyController.text =
                  'Attached documents: $fileNames';
            } else if (!_medical_historyController.text
                .contains('Attached documents:')) {
              _medical_historyController.text +=
                  '\n\nAttached documents: $fileNames';
            } else {
              // Update existing documents list
              final regex = RegExp(r'Attached documents:.*');
              final match = regex.firstMatch(_medical_historyController.text);
              if (match != null) {
                final existingText =
                    _medical_historyController.text.substring(0, match.start);
                _medical_historyController.text = existingText +
                    'Attached documents: ' +
                    (_selectedmedical_historyFiles
                        .map((file) => file.path.split('/').last)
                        .join(', '));
              }
            }
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${fileIds.length} of ${files.length} files uploaded successfully'),
              backgroundColor: _getRolePrimaryColor(),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }

      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
      _showErrorDialog('File Selection Error', 'Could not select files: $e');
    }
  }

  // Method to remove a file from the selected files list
  void _removeFile(File file) {
    final index = _selectedmedical_historyFiles.indexOf(file);
    setState(() {
      _selectedmedical_historyFiles.remove(file);

      // Also remove the corresponding fileId if it exists
      if (index >= 0 && index < _uploadedFileIds.length) {
        _uploadedFileIds.removeAt(index);
      }

      // Update the medical history text
      if (_selectedmedical_historyFiles.isEmpty) {
        _medical_historyController.text = _medical_historyController.text
            .replaceAll(RegExp(r'Attached documents:.*'), '')
            .trim();
      }
    });
  }

  // Enhanced input field with chips/tag support
  Widget _buildEnhancedInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    Widget Function(String)? chipBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chipBuilder != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: chipBuilder(controller.text),
          ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: Icon(icon, color: _getRolePrimaryColor()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _getRolePrimaryColor(), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          maxLines: maxLines,
          onChanged: (value) {
            // Update the UI when text changes to refresh chips
            if (chipBuilder != null) {
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  // Measurement slider with visual indicators
  Widget _buildMeasurementSlider({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required IconData icon,
    required double min,
    required double max,
    required double defaultValue,
  }) {
    // Set initial value if the controller is empty
    if (controller.text.isEmpty) {
      controller.text = defaultValue.toString();
    }

    double value = double.tryParse(controller.text) ?? defaultValue;
    if (value < min) value = min;
    if (value > max) value = max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _getRolePrimaryColor(), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getRolePrimaryColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                label: value.toInt().toString(),
                activeColor: _getRolePrimaryColor(),
                onChanged: (newValue) {
                  setState(() {
                    controller.text = newValue.toInt().toString();
                  });
                },
              ),
            ),
            Container(
              width: 50,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  controller.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRolePrimaryColor(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  // Modified to include file IDs in form submission
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        // Create a map of additional fields based on role (without file IDs)
        Map<String, dynamic> additionalFields = {};

        if (widget.role == UserRole.doctor) {
          additionalFields = {
            'specialty': _specialtyController.text,
            'licenseNumber': _licenseNumberController.text,
            'hospital': _hospitalController.text,
            'education': _educationController.text,
            'experience': _experienceController.text,
          };
        } else if (widget.role == UserRole.radiologist) {
          additionalFields = {
            'licenseNumber': _licenseNumberController.text,
            'hospital': _hospitalController.text,
            'education': _educationController.text,
            'experience': _experienceController.text,
          };
        } else if (widget.role == UserRole.patient) {
          additionalFields = {
            'date_of_birth': _date_of_birthController.text,
            'blood_type': _blood_typeController.text,
            'height': _heightController.text,
            'weight': _weightController.text,
            'allergies': _allergiesController.text.isEmpty
                ? []
                : _allergiesController.text
                    .split(',')
                    .where((e) => e.trim().isNotEmpty)
                    .map((e) => e.trim())
                    .toList(),
            'medical_history': [_medical_historyController.text],
            // Do NOT include 'medicalDocuments' here
          };
        }
        Map<String, dynamic> processedFields = additionalFields;
        await context.read<AuthViewModel>().signup(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
              _specialtyController.text,
              _phoneController.text,
              _addressController.text,
              widget.role,
              additionalFields: processedFields,
            );

        if (context.read<AuthViewModel>().isAuthenticated) {
          // After successful signup/login, upload files if any
          if (_selectedmedical_historyFiles.isNotEmpty) {
            setState(() {
              _isUploading = true;
              _uploadProgress = 0;
            });
            List<String> fileIds = [];
            int uploadedCount = 0;
            final totalFiles = _selectedmedical_historyFiles.length;
            for (var file in _selectedmedical_historyFiles) {
              try {
                final fileName = file.path.split('/').last;
                final prefs = await SharedPreferences.getInstance();
                final patientId = prefs.getString("userId");

                final fileId = await _fileService.uploadFile(file, fileName,
                    bucket: "patientdocuments", folder: "$patientId");
                fileIds.add(fileId);
              } catch (e) {
                print('Error uploading file: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error uploading file: ${file.path.split('/').last}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              uploadedCount++;
              setState(() {
                _uploadProgress = uploadedCount / totalFiles;
              });
            }
            setState(() {
              _isUploading = false;
              _uploadProgress = 0;
              _uploadedFileIds = fileIds;
            });
            if (fileIds.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${fileIds.length} medical file(s) uploaded successfully!'),
                  backgroundColor: _getRolePrimaryColor(),
                ),
              );
            }
          }
          // Route based on user role
          switch (widget.role) {
            case UserRole.doctor:
              context.go('/doctor-dashboard');
              break;
            case UserRole.radiologist:
              context.go('/radiologist-dashboard');
              break;
            case UserRole.patient:
              context.go('/patient-dashboard');
              break;
            default:
              context.go('/dashboard');
          }
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showAlert(
            'Error',
            context.read<AuthViewModel>().errorMessage,
            false,
          );
        }
      } catch (e) {
        _showAlert('Error', 'Failed to create account: $e', false);
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      // If validation fails, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
            style: TextButton.styleFrom(
              foregroundColor: _getRolePrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for role-specific styling
  Color _getRolePrimaryColor() {
    switch (widget.role) {
      case UserRole.doctor:
        return Color(0xFF2C6BED); // Blue shade for doctors
      case UserRole.radiologist:
        return Color(0xFF7B2AD6); // Purple shade for radiologists
      case UserRole.patient:
        return Color(0xFF35A8CF); // Teal shade for patients
      default:
        return Color(0xFF35C5CF); // Default color
    }
  }

  Color _getRoleSecondaryColor() {
    switch (widget.role) {
      case UserRole.doctor:
        return Color(0xFF2794DA); // Lighter blue for doctors
      case UserRole.radiologist:
        return Color(0xFF9F5EE2); // Lighter purple for radiologists
      case UserRole.patient:
        return Color(0xFF4DCFE1); // Lighter teal for patients
      default:
        return Color(0xFF81C9F3); // Default secondary color
    }
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.radiologist:
        return Icons.biotech;
      case UserRole.patient:
        return Icons.person;
      default:
        return Icons.person_add;
    }
  }

  String _getRoleTitle() {
    switch (widget.role) {
      case UserRole.doctor:
        return "Doctor Registration";
      case UserRole.radiologist:
        return "Radiologist Registration";
      case UserRole.patient:
        return "Patient Registration";
      default:
        return "Create Account";
    }
  }

  String _getRoleString() {
    switch (widget.role) {
      case UserRole.doctor:
        return "Doctor";
      case UserRole.radiologist:
        return "Radiologist";
      case UserRole.patient:
        return "Patient";
      default:
        return "User";
    }
  }

  String _getRoleSubtitle() {
    switch (widget.role) {
      case UserRole.doctor:
        return 'Join our healthcare provider network';
      case UserRole.radiologist:
        return 'Connect with patients and medical professionals';
      case UserRole.patient:
        return 'Access quality healthcare services';
      default:
        return 'Please fill in the details below';
    }
  }
  // Not using account type label directly anymore

  // Enhanced blood type selector
  Widget _buildblood_typeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.bloodtype, size: 20, color: _getRolePrimaryColor()),
              SizedBox(width: 8),
              Text(
                "Blood Type",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedblood_type == null
                  ? Colors.grey.shade300
                  : _getRolePrimaryColor(),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _getRolePrimaryColor().withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _blood_types
                    .map((type) => _buildblood_typeChip(type))
                    .toList(),
              ),
              if (_selectedblood_type == null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.red.shade400),
                      SizedBox(width: 6),
                      Text(
                        "Please select your blood type",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade400,
                        ),
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

  // Individual blood type chip with medical-themed design
  Widget _buildblood_typeChip(String type) {
    final isSelected = _selectedblood_type == type;
    final isNegative = type.endsWith('-');

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedblood_type = type;
          _blood_typeController.text = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? (isNegative ? Colors.blue.shade50 : Colors.red.shade50)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isNegative ? Colors.blue : Colors.red)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isNegative ? Colors.blue : Colors.red)
                        .withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 18,
                color: isSelected
                    ? (isNegative ? Colors.blue.shade700 : Colors.red.shade700)
                    : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            Icon(
              Icons.water_drop,
              size: 16,
              color: isSelected
                  ? (isNegative ? Colors.blue.shade700 : Colors.red.shade700)
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Modern medical document upload with preview
  Widget _buildMedicalDocumentsUploadSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRolePrimaryColor().withOpacity(0.05),
            _getRoleSecondaryColor().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRolePrimaryColor().withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section with icon - modified to handle overflow
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getRolePrimaryColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_information,
                  color: _getRolePrimaryColor(),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              // Wrap column with Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Medical Documents",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Upload your medical history documents",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      // Add overflow handling for text
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Text input for manual entry
          TextFormField(
            controller: _medical_historyController,
            decoration: InputDecoration(
              hintText: 'Enter your medical history details',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _getRolePrimaryColor().withOpacity(0.3),
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            style: TextStyle(fontSize: 16),
            maxLines: 4,
          ),

          SizedBox(height: 20),

          // Upload button area
          _buildFileUploadArea(),

          // File preview section
          if (_selectedmedical_historyFiles.isNotEmpty)
            _buildDocumentPreviewList(),
        ],
      ),
    );
  }
  // Modern upload area with drag & drop visual

  Widget _buildFileUploadArea() {
    return InkWell(
      onTap: _pickMultiplemedical_historyFiles,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getRolePrimaryColor().withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 42,
              color: _getRolePrimaryColor(),
            ),
            SizedBox(height: 12),
            Text(
              "Drag & drop medical files",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "or click to browse",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Supported formats: PDF, DOC, DOCX, JPG, PNG, DICOM",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            if (_isUploading) ...[
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_getRolePrimaryColor()),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: 8),
              Text(
                "Uploading... ${(_uploadProgress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  color: _getRolePrimaryColor(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Document preview list with thumbnails
  Widget _buildDocumentPreviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          "Uploaded Documents (${_selectedmedical_historyFiles.length})",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        ...List.generate(_selectedmedical_historyFiles.length, (index) {
          final file = _selectedmedical_historyFiles[index];
          final fileName = file.path.split('/').last;
          final extension = fileName.split('.').last.toLowerCase();

          // Choose icon based on file type
          IconData fileIcon = Icons.insert_drive_file;
          Color iconColor = Colors.blueGrey;

          if (extension == 'pdf') {
            fileIcon = Icons.picture_as_pdf;
            iconColor = Colors.red.shade700;
          } else if (extension == 'doc' || extension == 'docx') {
            fileIcon = Icons.article;
            iconColor = Colors.blue.shade700;
          } else if (extension == 'jpg' ||
              extension == 'jpeg' ||
              extension == 'png') {
            fileIcon = Icons.image;
            iconColor = Colors.green.shade700;
          } else if (extension == 'dicom' || extension == 'dcm') {
            fileIcon = Icons.biotech;
            iconColor = _getRolePrimaryColor();
          }

          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    fileIcon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getReadableFileSize(file),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _removeFile(file),
                  tooltip: "Remove file",
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Helper method to get readable file size
  String _getReadableFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  // Method to fill form with demo data based on role
  void _fillWithDemoData() {
    setState(() {
      // Common fields for all roles
      _nameController.text = faker.person.name();
      _emailController.text = faker.internet.email().toLowerCase();
      _passwordController.text = 'Password123!';
      _phoneController.text =
          '+1${faker.randomGenerator.numbers(10, 10).join('')}';
      _addressController.text =
          '${faker.address.streetAddress()}, ${faker.address.city()}, ${faker.address.zipCode()}';

      // Role-specific fields
      switch (widget.role) {
        case UserRole.doctor:
          _populateDoctorFields();
          break;
        case UserRole.radiologist:
          _populateRadiologistFields();
          break;
        case UserRole.patient:
          _populatePatientFields();
          break;
        default:
          break;
      }
    });

    // Show success message with proper role-specific color
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo data generated successfully!'),
        backgroundColor: _getRolePrimaryColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Auto-advance to the next step if we're on the first step
    if (_currentStep == 0) {
      Future.delayed(Duration(milliseconds: 800), () {
        _nextStep();
      });
    }
  }

  // Helper method to populate doctor-specific fields with fake data
  void _populateDoctorFields() {
    // List of common medical specialties
    final specialties = [
      'Cardiology',
      'Dermatology',
      'Neurology',
      'Pediatrics',
      'Orthopedics',
      'Psychiatry',
      'Oncology',
      'Gynecology',
      'Urology',
      'Endocrinology',
      'Gastroenterology'
    ];

    // List of medical schools
    final medicalSchools = [
      'Harvard Medical School',
      'Johns Hopkins School of Medicine',
      'Mayo Clinic Alix School of Medicine',
      'Stanford University School of Medicine',
      'Yale School of Medicine',
      'University of Pennsylvania School of Medicine',
      'Columbia University Vagelos College of Physicians and Surgeons',
      'University of California, San Francisco School of Medicine'
    ];

    // List of hospitals
    final hospitals = [
      'Mayo Clinic',
      'Cleveland Clinic',
      'Johns Hopkins Hospital',
      'Massachusetts General Hospital',
      'UCLA Medical Center',
      'New York-Presbyterian Hospital',
      'UCSF Medical Center',
      'Northwestern Memorial Hospital',
      'University of Michigan Hospitals'
    ];

    _specialtyController.text =
        specialties[faker.randomGenerator.integer(specialties.length)];
    _licenseNumberController.text =
        'MD${faker.randomGenerator.fromPattern(['######'])}';
    _educationController.text =
        'MD from ${medicalSchools[faker.randomGenerator.integer(medicalSchools.length)]}';
    _hospitalController.text =
        hospitals[faker.randomGenerator.integer(hospitals.length)];
    _experienceController.text =
        (faker.randomGenerator.integer(18) + 3).toString();
  }

  // Helper method to populate radiologist-specific fields with fake data
  void _populateRadiologistFields() {
    // List of radiology centers
    final radiologyCenters = [
      'Advanced Radiology Center',
      'Metropolitan Diagnostic Imaging',
      'University Radiology Associates',
      'Central Imaging Partners',
      'Regional MRI & CT Center',
      'Premier Medical Imaging',
      'Valley Radiology Services',
      'Comprehensive Diagnostic Radiology'
    ];

    // List of radiology certifications
    final radiologyCertifications = [
      'Board Certified in Diagnostic Radiology',
      'Fellowship in Interventional Radiology',
      'Fellowship in Neuroradiology',
      'Certification in Magnetic Resonance Imaging',
      'Certification in Computed Tomography',
      'Fellowship in Musculoskeletal Radiology',
      'Certification in Ultrasound Imaging',
      'Fellowship in Body Imaging'
    ];
    _licenseNumberController.text =
        'RAD-${faker.randomGenerator.fromPattern(['######'])}';
    _hospitalController.text = radiologyCenters[
        faker.randomGenerator.integer(radiologyCenters.length)];
    _educationController.text = radiologyCertifications[
        faker.randomGenerator.integer(radiologyCertifications.length)];
    _experienceController.text =
        faker.randomGenerator.integer(25, min: 2).toString();
  }

  // Helper method to populate patient-specific fields with fake data
  void _populatePatientFields() {
    // Generate random date in the past 50 years
    final randomYear =
        DateTime.now().year - (faker.randomGenerator.integer(33) + 18);
    final randomMonth = (faker.randomGenerator.integer(12) + 1);
    final randomDay = (faker.randomGenerator.integer(28) + 1);
    _date_of_birthController.text = '$randomDay/$randomMonth/$randomYear';

    // Select random blood type
    final randomblood_typeIndex =
        faker.randomGenerator.integer(_blood_types.length);
    _selectedblood_type = _blood_types[randomblood_typeIndex];
    _blood_typeController.text =
        _selectedblood_type!; // Random height between 150 and 200 cm
    final randomHeight = (faker.randomGenerator.integer(51) + 150).toString();
    _heightController.text = randomHeight;

    // Random weight between 50 and 100 kg
    final randomWeight = (faker.randomGenerator.integer(51) + 50).toString();
    _weightController.text = randomWeight;

    // Random allergies (or none)
    final possibleAllergies = [
      'Penicillin',
      'Peanuts',
      'Shellfish',
      'Dust',
      'Pollen',
      'Dairy',
      'Eggs',
      'Latex',
      'Insect stings'
    ];

    if (faker.randomGenerator.boolean()) {
      final allergyCount = faker.randomGenerator.integer(3, min: 1);
      final selectedAllergies = <String>{};

      for (int i = 0; i < allergyCount; i++) {
        selectedAllergies.add(possibleAllergies[
            faker.randomGenerator.integer(possibleAllergies.length)]);
      }

      _allergiesController.text = selectedAllergies.join(', ');
    } else {
      _allergiesController.text = 'None';
    } // Random medical history
    final possibleConditions = [
      'Asthma - Diagnosed ${faker.randomGenerator.integer(10, min: 1)} years ago',
      'Hypertension - Under medication',
      'Type 2 Diabetes - Diet controlled',
      'Migraine - Occasional episodes',
      'Appendectomy - ${faker.randomGenerator.integer(20, min: 1)} years ago',
      'Seasonal allergies - Spring and Fall',
      'Knee surgery - ${faker.randomGenerator.integer(10, min: 1)} years ago'
    ];

    if (faker.randomGenerator.boolean()) {
      final conditionCount = faker.randomGenerator.integer(3, min: 1);
      final selectedConditions = <String>{};

      for (int i = 0; i < conditionCount; i++) {
        selectedConditions.add(possibleConditions[
            faker.randomGenerator.integer(possibleConditions.length)]);
      }

      if (selectedConditions.isEmpty) {
        _medical_historyController.text = 'No significant medical history';
      } else {
        _medical_historyController.text = selectedConditions.join('\n\n');
      }
    } else {
      _medical_historyController.text = 'No significant medical history';
    }
  }
}
