import 'package:medapp/models/user.dart';

class Doctor extends User {
  final String specialty;
  final bool isVerified;
  final Map<String, dynamic>? verificationDetails;
  final String? signature;
  final String? bio; // Added bio field
  final String? licenseNumber; // Added license number field
  final String? hospital; // Added hospital/clinic field
  final String? education; // Added education field
  final String? experience; // Added experience field

  Doctor({
    super.id,
    super.name,
    super.email,
    super.phone,
    super.address,
    super.profilePicture,
    required this.specialty,
    this.isVerified = false, // Default to false
    this.verificationDetails,
    this.signature,
    this.bio, // Added bio parameter
    this.licenseNumber, // Added license number parameter
    this.hospital, // Added hospital parameter
    this.education, // Added education parameter
    this.experience, // Added experience parameter
  }) : super(
          role: UserRole.doctor,
        );

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profilePicture: json['profile_picture'],
      specialty: json['specialty'],
      isVerified: json['is_verified'] ?? false,
      verificationDetails: json['verificationDetails'],
      signature: json['signature'],
      bio: json['bio'],
      licenseNumber: json['licenseNumber'],
      hospital: json['hospital'],
      education: json['education'],
      experience: json['experience'],
    );
  }
}
