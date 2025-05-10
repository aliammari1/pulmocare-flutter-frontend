import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/auth_view_model.dart';
import '../theme/app_theme.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize data from the user model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctor =
          Provider.of<AuthViewModel>(context, listen: false).currentDoctor;
      if (doctor != null) {
        _nameController.text = doctor.name ?? '';
        _emailController.text = doctor.email ?? '';
        _phoneController.text = doctor.phone ?? '';
        _specialtyController.text = doctor.specialty ?? '';
        _addressController.text = doctor.address ?? '';
        _profileImage =
            doctor.profilePicture != null ? File(doctor.profilePicture!) : null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Convert image to base64 if selected
      String? profileImageBase64;
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        profileImageBase64 = base64Encode(bytes);
      }

      // Update profile
      await authViewModel.updateDoctorProfile(
        name: _nameController.text,
        specialty: _specialtyController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
        profileImage: profileImageBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Doctor Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => context.go("/doctor-dashboard"),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: "Edit Profile",
            )
          else
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: "Cancel Editing",
            ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          final doctor = authViewModel.currentDoctor;

          if (doctor == null) {
            return const Center(child: Text("No doctor profile found"));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header with Image
                    _buildProfileHeader(doctor),

                    const SizedBox(height: 24),

                    // Profile Information
                    _buildProfileInformation(doctor),

                    // Save Button (when editing)
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Save Profile",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic doctor) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _getProfileImage(doctor),
                  child: _profileImage == null && doctor.profilePicture == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _isEditing
              ? TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                )
              : Text(
                  "Dr. ${doctor.name ?? 'Doctor'}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 4),
          if (!_isEditing)
            Text(
              doctor.specialty ?? "Specialty",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 16),
          if (!_isEditing && doctor.bio != null && doctor.bio!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                doctor.bio ?? "",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage(dynamic doctor) {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (doctor.profilePicture != null) {
      try {
        return MemoryImage(base64Decode(doctor.profilePicture!));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Widget _buildProfileInformation(dynamic doctor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),

            // Specialty
            if (_isEditing) ...[
              TextFormField(
                controller: _specialtyController,
                decoration: InputDecoration(
                  labelText: "Specialty",
                  prefixIcon: Icon(Icons.medical_services,
                      color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your specialty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ] else
              _buildInfoRow("Specialty", doctor.specialty ?? "Not specified",
                  Icons.medical_services),

            // Email
            if (_isEditing) ...[
              TextFormField(
                controller: _emailController,
                enabled: false, // Email shouldn't be editable
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else
              _buildInfoRow("Email Address", doctor.email ?? "Not specified",
                  Icons.email),

            // Phone
            if (_isEditing) ...[
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ] else
              _buildInfoRow(
                  "Phone Number", doctor.phone ?? "Not specified", Icons.phone),

            // Address
            if (_isEditing) ...[
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon:
                      Icon(Icons.location_on, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ] else
              _buildInfoRow("Address", doctor.address ?? "Not specified",
                  Icons.location_on),

            // Bio
            if (_isEditing) ...[
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: "Bio",
                  prefixIcon: Icon(Icons.info, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                validator: (value) => null, // Bio is optional
              ),
            ] else if (doctor.bio != null && doctor.bio!.isNotEmpty)
              _buildInfoRow("Bio", doctor.bio ?? "Not specified", Icons.info),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
