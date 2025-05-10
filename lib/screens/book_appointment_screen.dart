import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medapp/models/doctor.dart';
import 'package:medapp/services/doctor_service.dart';
import 'package:medapp/models/appointment.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/services/appointment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medapp/services/file_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DoctorService _doctorService = DoctorService();
  final AppointmentService _appointmentService = AppointmentService();
  final FileService _fileService = FileService();

  List<Doctor> _doctors = [];
  String? _selectedDoctorId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isVirtual = false;
  String _appointmentType = 'initial_consultation';
  List<PlatformFile> _selectedFiles = [];
  List<String> _uploadedFileIds = [];
  bool _isUploading = false;

  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
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

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Method to pick files
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to remove a file from selection
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  // Method to upload files
  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      for (var file in _selectedFiles) {
        if (file.path != null) {
          final fileId = await _fileService.uploadFile(
            File(file.path!),
            file.name,
          );
          _uploadedFileIds.add(fileId);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading files: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitAppointment() async {
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

      try {
        setState(() => _isSubmitting = true);

        // Upload files if any are selected
        if (_selectedFiles.isNotEmpty) {
          await _uploadFiles();
        }

        // Create a DateTime that combines the selected date and time
        final appointmentDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Get the current patient's ID from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
        final patientId = userData['user_id'];

        // Convert string appointment type to enum
        final appointmentTypeEnum = _getAppointmentTypeEnum(_appointmentType);

        // Create appointment data
        final appointmentData = AppointmentCreate(
          doctorId: _selectedDoctorId!,
          scheduledTime: appointmentDateTime,
          type: appointmentTypeEnum,
          isVirtual: _isVirtual,
          patientId: patientId,
          reason: _reasonController.text,
          duration: const Duration(minutes: 30),
          medicalFileIds: _uploadedFileIds.isNotEmpty ? _uploadedFileIds : null,
        );

        // Send appointment data to backend
        await _appointmentService.bookAppointment(appointmentData);

        setState(() => _isSubmitting = false);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/patient-appointments');
      } catch (e) {
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to convert string to AppointmentType enum
  AppointmentType _getAppointmentTypeEnum(String typeString) {
    switch (typeString) {
      case 'initial_consultation':
        return AppointmentType.initial;
      case 'follow_up':
        return AppointmentType.followUp;
      case 'emergency':
        return AppointmentType.emergency;
      case 'specialist_consultation':
        return AppointmentType.consultation;
      default:
        return AppointmentType.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load doctors',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDoctors,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
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
                          Container(
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
                                            backgroundImage: NetworkImage(
                                                doctor.profilePicture!),
                                          ),
                                          const SizedBox(width: 8),
                                        ] else
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: AppTheme
                                                .primaryColor
                                                .withOpacity(0.2),
                                            child: Text(
                                              "?",
                                              style: TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                doctor.name ?? 'Unknown',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
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
                          ),
                          const SizedBox(height: 24),

                          // Date and time selection
                          const Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: AppTheme.primaryColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('MMM d, yyyy')
                                              .format(_selectedDate),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectTime,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            color: AppTheme.primaryColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedTime.format(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Appointment type
                          const Text(
                            'Appointment Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _appointmentType,
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'initial_consultation',
                                    child: Text('Initial Consultation'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'follow_up',
                                    child: Text('Follow Up'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'emergency',
                                    child: Text('Emergency'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'specialist_consultation',
                                    child: Text('Specialist Consultation'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _appointmentType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Virtual appointment toggle
                          Row(
                            children: [
                              Checkbox(
                                activeColor: AppTheme.primaryColor,
                                value: _isVirtual,
                                onChanged: (value) {
                                  setState(() {
                                    _isVirtual = value!;
                                  });
                                },
                              ),
                              const Text('Virtual Appointment'),
                              const Spacer(),
                              Icon(
                                Icons.videocam,
                                color: _isVirtual
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Reason for visit
                          TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Reason for Visit',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a reason for your visit';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Additional notes
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Additional Notes (Optional)',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // File upload section
                          const Text(
                            'Upload Medical Documents (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isUploading ? null : _pickFiles,
                                  icon: const Icon(Icons.attach_file),
                                  label: Text(_isUploading
                                      ? 'Uploading...'
                                      : 'Select Files'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                  ),
                                ),
                                if (_selectedFiles.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Selected Files:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _selectedFiles.length,
                                    itemBuilder: (context, index) {
                                      final file = _selectedFiles[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          file.name,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          '${(file.size / 1024).toStringAsFixed(2)} KB',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => _removeFile(index),
                                          color: Colors.red,
                                          iconSize: 20,
                                        ),
                                        leading: Icon(
                                          _getFileIcon(file.extension ?? ''),
                                          color: AppTheme.primaryColor,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmitting ? null : _submitAppointment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Book Appointment',
                                      style: TextStyle(fontSize: 16),
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

  // Helper method to determine file icon based on extension
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
