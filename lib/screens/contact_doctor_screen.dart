import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medapp/models/doctor.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/services/doctor_service.dart';

class ContactDoctorScreen extends StatefulWidget {
  const ContactDoctorScreen({super.key});

  @override
  _ContactDoctorScreenState createState() => _ContactDoctorScreenState();
}

class _ContactDoctorScreenState extends State<ContactDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  List<Doctor> _doctors = [];
  String? _selectedDoctorId;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  final DoctorService _doctorService = DoctorService();

  @override
  void initState() {
    super.initState();
    _loadDoctors();

    // Check if doctor info was passed as extra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        if (args.containsKey('doctorId')) {
          setState(() {
            _selectedDoctorId = args['doctorId'];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final doctors = await _doctorService.getDoctors();

      setState(() {
        _doctors = doctors.items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a doctor'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSending = true);

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _subjectController.clear();
        _messageController.clear();

        setState(() => _isSending = false);

        // Navigate back after success
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) context.pop();
        });
      } catch (e) {
        setState(() {
          _isSending = false;
          _error = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Doctor'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContactForm(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load doctors',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDoctors,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor selection
            const Text(
              'Select Doctor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDoctorDropdown(),
            const SizedBox(height: 24),

            // Subject field
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Message field
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.grey[600]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your message is encrypted and will only be visible to the selected doctor.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Send Message',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDoctorId,
          isExpanded: true,
          hint: const Text('Select a doctor'),
          items: _doctors.map((doctor) {
            return DropdownMenuItem<String>(
              value: doctor.id,
              child: Row(
                children: [
                  if (doctor.profilePicture != null) ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(doctor.profilePicture!),
                    ),
                    const SizedBox(width: 8),
                  ] else
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text(
                        (doctor.name != null && doctor.name!.isNotEmpty)
                            ? doctor.name![0].toUpperCase()
                            : "?",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          doctor.name ?? "Unknown",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doctor.specialty,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDoctorId = value;
            });
          },
        ),
      ),
    );
  }
}
