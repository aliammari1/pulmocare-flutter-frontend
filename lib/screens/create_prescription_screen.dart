import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/prescription.dart';
import '../services/doctor_service.dart';
import '../theme/app_theme.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  const CreatePrescriptionScreen({super.key});

  @override
  State<CreatePrescriptionScreen> createState() =>
      _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DoctorService _doctorService = DoctorService();

  // Form controllers
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Medications list
  final List<Map<String, String>> _medications = [];

  // Controllers for adding new medication
  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _medDosageController = TextEditingController();
  final TextEditingController _medFrequencyController = TextEditingController();
  final TextEditingController _medDurationController = TextEditingController();
  final TextEditingController _medInstructionsController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _addMedication() {
    if (_medNameController.text.isEmpty || _medDosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and dosage are required')),
      );
      return;
    }

    setState(() {
      _medications.add({
        'name': _medNameController.text,
        'dosage': _medDosageController.text,
        'frequency': _medFrequencyController.text,
        'duration': _medDurationController.text,
        'instructions': _medInstructionsController.text,
      });

      // Clear controllers
      _medNameController.clear();
      _medDosageController.clear();
      _medFrequencyController.clear();
      _medDurationController.clear();
      _medInstructionsController.clear();
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _savePrescription() async {
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one medication')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create prescription items
      final medications = _medications
          .map((med) => PrescriptionItem(
                name: med['name']!,
                dosage: med['dosage']!,
                frequency: med['frequency'] ?? '',
                duration: med['duration'] ?? '',
                instructions: med['instructions'],
              ))
          .toList();

      // Create prescription
      final prescription = Prescription(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Will be replaced by the server
        patientId: _patientIdController.text,
        patientName: _patientNameController.text,
        doctorId:
            'd123', // In a real app, this would be the logged-in doctor's ID
        doctorName:
            'Dr. Smith', // In a real app, this would be the logged-in doctor's name
        medications: medications,
        date: DateTime.now(),
        status: PrescriptionStatus.active,
        notes: _notesController.text,
      );

      // Save prescription (this would call an API in a real app)
      // For now, we'll just simulate success
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription created successfully')),
        );

        // Navigate back to prescriptions list
        context.go('/prescriptions');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Prescription',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Information Section
                      _buildSectionTitle('Patient Information'),
                      _buildTextFormField(
                        controller: _patientIdController,
                        labelText: 'Patient ID',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _patientNameController,
                        labelText: 'Patient Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patient name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Medications Section
                      _buildSectionTitle('Medications'),
                      if (_medications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No medications added yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _medications.length,
                          itemBuilder: (context, index) {
                            final medication = _medications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          medication['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _removeMedication(index),
                                        ),
                                      ],
                                    ),
                                    Text('Dosage: ${medication['dosage']}'),
                                    if (medication['frequency']!.isNotEmpty)
                                      Text(
                                          'Frequency: ${medication['frequency']}'),
                                    if (medication['duration']!.isNotEmpty)
                                      Text(
                                          'Duration: ${medication['duration']}'),
                                    if (medication['instructions']!.isNotEmpty)
                                      Text(
                                          'Instructions: ${medication['instructions']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Add New Medication
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Medication',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _medNameController,
                                labelText: 'Medication Name *',
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _medDosageController,
                                labelText: 'Dosage *',
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _medFrequencyController,
                                labelText: 'Frequency (e.g., Every 8 hours)',
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _medDurationController,
                                labelText: 'Duration (e.g., 7 days)',
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _medInstructionsController,
                                labelText: 'Instructions',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Medication'),
                                  onPressed: _addMedication,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Notes Section
                      _buildSectionTitle('Notes'),
                      _buildTextField(
                        controller: _notesController,
                        labelText: 'Additional Notes',
                        maxLines: 4,
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _savePrescription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Prescription',
                            style: TextStyle(
                              fontSize: 16,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
