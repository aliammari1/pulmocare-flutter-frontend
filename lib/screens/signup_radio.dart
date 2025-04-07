import 'package:flutter/material.dart';
import 'package:medapp/screens/map_selection_dialog.dart';
import 'package:provider/provider.dart';
import '../services/auth_radio_view_model.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/location_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import '../widgets/visit_card_scan_dialog.dart';

class SignupRadioView extends StatefulWidget {
  const SignupRadioView({super.key});

  @override
  _SignupRadioViewState createState() => _SignupRadioViewState();
}

class _SignupRadioViewState extends State<SignupRadioView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _initialCountryCode;
  bool _isCountryCodeLoading = true;
  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions
    _loadCountryCode();
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
        _phoneController.text = result['phone_number'] ?? '';
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
    if (value == null || value.isEmpty) {
      return 'Specialty is required';
    }
    return null;
  }

  // ignore: unused_element
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
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
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AuthRadioViewModel(),
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF81C9F3),
                      Color(0xFF35C5CF),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Please fill in the details below',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: _showVisitCardScanDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF35C5CF),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.document_scanner,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Scan Visit Card',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                validator: _validateName,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person,
                                      color: Color(0xFF81C9F3)),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                validator: _validateEmail,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email,
                                      color: Color(0xFF81C9F3)),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                validator: _validatePassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock,
                                      color: Color(0xFF81C9F3)),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _specialtyController,
                                validator: _validateSpecialty,
                                decoration: InputDecoration(
                                  labelText: 'Specialty',
                                  prefixIcon: Icon(Icons.medical_services,
                                      color: Color(0xFF81C9F3)),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildPhoneField(),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                validator: _validateAddress,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  prefixIcon: Icon(Icons.location_on,
                                      color: Color(0xFF81C9F3)),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.map),
                                    onPressed: () async {
                                      final selectedAddress =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return MapSelectionDialog(
                                              initialAddress:
                                                  _addressController.text);
                                        },
                                      );
                                      if (selectedAddress != null) {
                                        setState(() => _addressController.text =
                                            selectedAddress);
                                      }
                                    },
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);
                                          try {
                                            await context
                                                .read<AuthRadioViewModel>()
                                                .signup(
                                                  _nameController.text,
                                                  _emailController.text,
                                                  _passwordController.text,
                                                  _specialtyController.text,
                                                  _phoneController.text,
                                                  _addressController.text,
                                                );
                                            if (context
                                                .read<AuthRadioViewModel>()
                                                .isAuthenticated) {
                                              _showAlert(
                                                  'Success',
                                                  'Account created successfully!',
                                                  true);
                                              Navigator.pushReplacementNamed(
                                                  context, '/homeRadio');
                                            }
                                          } catch (e) {
                                            _showAlert(
                                                'Error', e.toString(), false);
                                          } finally {
                                            setState(() => _isLoading = false);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF35C5CF),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Sign Up',
                                        style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                        // Error Message
                        Consumer<AuthRadioViewModel>(
                          builder: (context, authVM, child) {
                            return authVM.errorMessage.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha((0.1 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      authVM.errorMessage,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildPhoneField() {
    if (_isCountryCodeLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
      ),
      initialCountryCode: _initialCountryCode ?? 'US', // Fallback to US
      onChanged: (phone) {
        _phoneController.text = phone.completeNumber;
      },
    );
  }
}
