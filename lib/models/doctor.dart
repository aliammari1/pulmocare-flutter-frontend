class Doctor {
  final String id;
  final String name;
  final String email;
  final String specialty;
  final String phoneNumber;
  final String address;
  final String? profileImage;
  final bool isVerified; // Changed from bool? to bool
  final Map<String, dynamic>? verificationDetails; // Add verification details
  final String? signature; // Add this field

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.phoneNumber,
    required this.address,
    this.profileImage,
    this.isVerified = false, // Default to false
    this.verificationDetails,
    this.signature, // Add this field
  });
}
