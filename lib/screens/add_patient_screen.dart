import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:medapp/config.dart';
import 'package:medapp/models/patient.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:medapp/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:medapp/services/auth_view_model.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic info controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Medical info controllers
  final _date_of_birthController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medical_historyController = TextEditingController();

  // Selected values
  String? _selectedblood_type;
  double _heightValue = 170;
  double _weightValue = 70;

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

  bool _isLoading = false;
  String? _errorMessage;

  final Dio dio = DioHttpClient().dio;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _date_of_birthController.dispose();
    _allergiesController.dispose();
    _medical_historyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _date_of_birthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Prepare patient data
      final Map<String, dynamic> patientData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'date_of_birth': _date_of_birthController.text,
        'blood_type': _selectedblood_type,
        'height': _heightValue.toStringAsFixed(0),
        'weight': _weightValue.toStringAsFixed(0),
        'allergies': _allergiesController.text.isEmpty
            ? []
            : _allergiesController.text
                .split(',')
                .where((e) => e.trim().isNotEmpty)
                .map((e) => e.trim())
                .toList(),
        'medical_history': _medical_historyController.text,
        'role': 'patient',
      };

      // Get the doctor's auth token
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final authToken = authViewModel.authToken;

      // API call to create patient
      final response = await dio.post(
        '${Config.apiBaseUrl}/patient/create',
        data: patientData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Patient ${_nameController.text} added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to create patient. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        if (e is DioException) {
          if (e.response?.data != null && e.response?.data['error'] != null) {
            _errorMessage = e.response?.data['error'];
          } else {
            _errorMessage = 'Network error. Please try again.';
          }
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add New Patient',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                      'Basic Information', Icons.person_outline),
                  const SizedBox(height: 20),

                  // Basic Information Fields
                  _buildInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter patient\'s full name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter patient\'s email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient\'s email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter patient\'s phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient\'s phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'Enter patient\'s home address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Medical Information Section
                  _buildSectionHeader(
                      'Medical Information', Icons.medical_services_outlined),
                  const SizedBox(height: 20),

                  // Date Picker for Birth Date
                  TextFormField(
                    controller: _date_of_birthController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'Select patient\'s date of birth',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a birth date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Blood Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedblood_type,
                    decoration: InputDecoration(
                      labelText: 'Blood Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.bloodtype_outlined),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    items: _blood_types
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedblood_type = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a blood type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Height Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Height: ${_heightValue.toInt()} cm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Slider(
                        value: _heightValue,
                        min: 50,
                        max: 220,
                        divisions: 170,
                        activeColor: AppTheme.primaryColor,
                        label: _heightValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _heightValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Weight Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight: ${_weightValue.toInt()} kg',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Slider(
                        value: _weightValue,
                        min: 20,
                        max: 150,
                        divisions: 130,
                        activeColor: AppTheme.primaryColor,
                        label: _weightValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _weightValue = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Allergies Field
                  _buildInputField(
                    controller: _allergiesController,
                    label: 'Allergies',
                    hint: 'Enter patient\'s allergies (comma separated)',
                    icon: Icons.warning_amber_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Medical History Field
                  _buildInputField(
                    controller: _medical_historyController,
                    label: 'Medical History',
                    hint: 'Enter any relevant medical history',
                    icon: Icons.history_edu_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Error message display
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.person_add),
                    label: const Text(
                      'Add Patient',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
