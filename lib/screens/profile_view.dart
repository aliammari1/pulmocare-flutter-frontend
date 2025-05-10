import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_view_model.dart';
import '../theme/app_theme.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../widgets/verification_alert.dart';
import 'signature_view.dart';
import 'package:go_router/go_router.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/radiologist.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          // Get user based on role
          final user = authVM.currentUser;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final imageBytes = user.profilePicture != null
              ? base64Decode(user.profilePicture!)
              : null;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Modern Profile Header with animated gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withAlpha((0.8 * 255).toInt()),
                        AppTheme.accentColor,
                        AppTheme.primaryColor.withAlpha((0.9 * 255).toInt()),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Profile Image with animations
                      Hero(
                        tag: 'profile-image',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: AppTheme.disabledColor,
                              backgroundImage: imageBytes != null
                                  ? MemoryImage(imageBytes)
                                  : null,
                              child: imageBytes == null
                                  ? Icon(Icons.person,
                                      size: 65, color: AppTheme.primaryColor)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user.name!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Role-specific subtitle
                      _buildRoleSpecificSubtitle(authVM),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Verification Alert for professionals (Doctor, Radiologist)
                if (authVM.role == 'doctor' || authVM.role == 'radiologist')
                  VerificationAlert(isVerified: _isUserVerified(authVM)),

                // Information Cards with enhanced design
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildModernInfoCard(
                        Icons.email_outlined,
                        'Email Address',
                        user.email!,
                        AppTheme.primaryColor,
                      ),
                      _buildModernInfoCard(
                        Icons.phone_outlined,
                        'Phone Number',
                        user.phone ?? 'Not provided',
                        AppTheme.accentColor,
                      ),
                      _buildModernInfoCard(
                        Icons.location_on_outlined,
                        'Address',
                        user.address ?? 'Not provided',
                        AppTheme.primaryColor,
                      ),

                      // Role-specific information cards
                      ..._buildRoleSpecificInfoCards(authVM),

                      const SizedBox(height: 24),

                      // Signature button for professionals (Doctor, Radiologist)
                      if (authVM.role == 'doctor' ||
                          authVM.role == 'radiologist')
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _handleSignatureAction(context, authVM),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                                _hasSignature(authVM) ? Icons.draw : Icons.add,
                                color: Colors.black87),
                            label: Text(
                              _hasSignature(authVM)
                                  ? 'View Signature'
                                  : 'Add Signature',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      // Modern Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Change\nPassword',
                              Icons.lock_outline,
                              AppTheme.primaryColor,
                              () => _showChangePasswordDialog(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'Edit\nProfile',
                              Icons.edit_outlined,
                              AppTheme.accentColor,
                              () => _showEditProfileDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleSpecificSubtitle(AuthViewModel authVM) {
    switch (authVM.role) {
      case 'doctor':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            (authVM.currentDoctor as Doctor).specialty,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case 'radiologist':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Radiologist',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case 'patient':
        final patient = authVM.currentPatient as Patient?;
        final blood_type = patient?.blood_type;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            blood_type != null ? 'Blood Type: $blood_type' : 'Patient',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  List<Widget> _buildRoleSpecificInfoCards(AuthViewModel authVM) {
    final cards = <Widget>[];

    switch (authVM.role) {
      case 'doctor':
        final doctor = authVM.currentDoctor as Doctor;
        cards.add(_buildModernInfoCard(
          Icons.medical_services_outlined,
          'Specialty',
          doctor.specialty,
          Colors.teal,
        ));
        if (doctor.hospital != null && doctor.hospital!.isNotEmpty) {
          cards.add(_buildModernInfoCard(
            Icons.local_hospital_outlined,
            'Hospital',
            doctor.hospital!,
            Colors.indigo,
          ));
        }
        break;
      case 'radiologist':
        final radiologist = authVM.currentRadiologist as Radiologist?;
        if (radiologist?.hospital != null) {
          cards.add(_buildModernInfoCard(
            Icons.local_hospital_outlined,
            'Hospital',
            radiologist!.hospital!,
            Colors.indigo,
          ));
        }
        if (radiologist?.licenseNumber != null) {
          cards.add(_buildModernInfoCard(
            Icons.badge_outlined,
            'License Number',
            radiologist!.licenseNumber!,
            Colors.purple,
          ));
        }
        break;
      case 'patient':
        final patient = authVM.currentPatient as Patient?;
        if (patient?.date_of_birth != null) {
          cards.add(_buildModernInfoCard(
            Icons.cake_outlined,
            'Date of Birth',
            patient!.date_of_birth!,
            Colors.amber.shade700,
          ));
        }
        if (patient?.blood_type != null) {
          cards.add(_buildModernInfoCard(
            Icons.bloodtype_outlined,
            'Blood Type',
            patient!.blood_type!,
            Colors.red,
          ));
        }
        if (patient?.height != null || patient?.weight != null) {
          final heightWeight = [];
          if (patient?.height != null)
            heightWeight.add('Height: ${patient!.height}');
          if (patient?.weight != null)
            heightWeight.add('Weight: ${patient!.weight}');

          cards.add(_buildModernInfoCard(
            Icons.accessibility_new_outlined,
            'Physical',
            heightWeight.join(' | '),
            Colors.green,
          ));
        }
        break;
    }

    return cards;
  }

  bool _isUserVerified(AuthViewModel authVM) {
    if (authVM.role == 'doctor') {
      return (authVM.currentDoctor as Doctor?)?.isVerified ?? false;
    } else if (authVM.role == 'radiologist') {
      // The currentRadiologist is defined as User?, but we need to check isVerified
      // Since User doesn't have isVerified property, we'll return false for now
      // Or implement a proper verification check method for radiologists if needed
      return false;
    }
    return false;
  }

  bool _hasSignature(AuthViewModel authVM) {
    if (authVM.role == 'doctor') {
      return (authVM.currentDoctor as Doctor?)?.signature != null;
    } else if (authVM.role == 'radiologist') {
      // Since User doesn't have signature property, we need to modify this
      return false;
    }
    return false;
  }

  void _handleSignatureAction(BuildContext context, AuthViewModel authVM) {
    String? signature;

    if (authVM.role == 'doctor') {
      signature = (authVM.currentDoctor as Doctor?)?.signature;
    } else if (authVM.role == 'radiologist') {
      // Since User doesn't have signature property, signatures for radiologists
      // need to be handled differently. For now, we'll just use null.
      signature = null;
    }

    if (signature != null) {
      _showSignatureDialog(context, signature);
    } else {
      _showSignatureCreationDialog(context);
    }
  }

  void _showSignatureAction(BuildContext context, AuthViewModel authVM) {
    String? signature;

    if (authVM.role == 'doctor') {
      signature = (authVM.currentDoctor as Doctor?)?.signature;
    } else if (authVM.role == 'radiologist') {
      signature = (authVM.currentRadiologist as Radiologist?)?.signature;
    }

    if (signature != null) {
      _showSignatureDialog(context, signature);
    } else {
      _showSignatureCreationDialog(context);
    }
  }

  Widget _buildModernInfoCard(
      IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.1 * 255).toInt()),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFD8EFF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String errorText = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (value == currentPasswordController.text) {
                      return 'New password must be different from current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await context.read<AuthViewModel>().changePassword(
                          currentPasswordController.text.trim(),
                          newPasswordController.text.trim(),
                        );

                    final error = context.read<AuthViewModel>().errorMessage;
                    if (error.isEmpty) {
                      context.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() => errorText = error);
                    }
                  } catch (e) {
                    setState(() => errorText = 'Failed to change password: $e');
                  }
                }
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();
    final nameController =
        TextEditingController(text: authVM.currentDoctor?.name);
    final specialtyController =
        TextEditingController(text: authVM.currentDoctor?.specialty);
    final phoneController =
        TextEditingController(text: authVM.currentDoctor?.phone);
    final addressController =
        TextEditingController(text: authVM.currentDoctor?.address);
    XFile? selectedImage;
    String errorText = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: AppTheme.cardDecoration(),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: AppTheme.accentColor),
                      onPressed: () => context.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: AppTheme.inputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icons.person,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: specialtyController,
                        decoration: AppTheme.inputDecoration(
                          labelText: 'Specialty',
                          prefixIcon: Icons.medical_services,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: AppTheme.inputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icons.phone,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: AppTheme.inputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icons.location_on,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Select Profile Image'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => selectedImage = image);
                    }
                  },
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Selected: ${selectedImage!.name}',
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                if (errorText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.pop(ctx),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final base64Image = selectedImage != null
                                ? base64Encode(
                                    await selectedImage!.readAsBytes())
                                : null;
                            await authVM.updateDoctorProfile(
                              name: nameController.text.trim(),
                              specialty: specialtyController.text.trim(),
                              phone: phoneController.text.trim(),
                              address: addressController.text.trim(),
                              profileImage: base64Image,
                            );
                            if (authVM.errorMessage.isEmpty) {
                              context.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Profile updated')),
                              );
                            } else {
                              setState(() => errorText = authVM.errorMessage);
                            }
                          } catch (e) {
                            setState(() => errorText = 'Error: $e');
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add this method at the bottom of the class
  void _showSignatureDialog(BuildContext context, String signatureBase64) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Signature',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(signatureBase64),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.pop();
                      _showSignatureCreationDialog(
                          context); // Show new signature dialog
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Change'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this new method to show signature creation dialog
  void _showSignatureCreationDialog(BuildContext context) {
    final doctor = context.read<AuthViewModel>().currentDoctor;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SignatureView(existingSignature: doctor?.signature),
      ),
    );
  }
}
