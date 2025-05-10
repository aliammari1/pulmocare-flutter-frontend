import 'package:medapp/models/user.dart';

class Radiologist extends User {
  final String? licenseNumber;
  final String? hospital;
  final String? education;
  final String? experience;
  final String? signature;
  final bool isVerified;
  final Map<String, dynamic>? verificationDetails;

  Radiologist({
    super.id,
    super.name,
    super.email,
    super.phone,
    super.address,
    super.profilePicture,
    this.licenseNumber,
    this.hospital,
    this.education,
    this.experience,
    this.signature,
    this.isVerified = false,
    this.verificationDetails,
  }) : super(
          role: UserRole.radiologist,
        );

  factory Radiologist.fromJson(Map<String, dynamic> json) {
    return Radiologist(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profilePicture: json['profile_picture'],
      licenseNumber: json['licenseNumber'],
      hospital: json['hospital'],
      education: json['education'],
      experience: json['experience'],
      signature: json['signature'],
      isVerified: json['is_verified'] ?? false,
      verificationDetails: json['verificationDetails'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['licenseNumber'] = licenseNumber;
    data['hospital'] = hospital;
    data['education'] = education;
    data['experience'] = experience;
    data['signature'] = signature;
    data['is_verified'] = isVerified;
    data['verificationDetails'] = verificationDetails;
    return data;
  }
}
