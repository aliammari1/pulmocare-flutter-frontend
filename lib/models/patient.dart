import 'package:medapp/models/user.dart';
import 'package:medapp/models/medical_file.dart';

class Patient extends User {
  final String? date_of_birth;
  final String? blood_type;
  final String? height;
  final String? weight;
  final List<String>? allergies;
  final List<String>? medical_history;
  final List<MedicalFile> medical_files;

  Patient({
    super.id,
    super.name,
    super.email,
    super.phone,
    super.address,
    super.profilePicture,
    this.date_of_birth,
    this.blood_type,
    this.height,
    this.weight,
    this.allergies,
    this.medical_history,
    List<MedicalFile>? medical_files,
  })  : this.medical_files = medical_files ?? [],
        super(
          role: UserRole.patient,
        );

  factory Patient.fromJson(Map<String, dynamic> json) {
    List<MedicalFile> files = [];
    if (json['medical_files'] != null) {
      files = (json['medical_files'] as List)
          .map((file) => MedicalFile.fromJson(file))
          .toList();
    }

    return Patient(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profilePicture: json['profile_picture'],
      date_of_birth: json['date_of_birth'],
      blood_type: json['blood_type'],
      height: json['height'],
      weight: json['weight'],
      allergies: _parseAllergies(json['allergies']),
      medical_history: json['medical_history'],
      medical_files: files,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['date_of_birth'] = date_of_birth;
    data['blood_type'] = blood_type;
    data['height'] = height;
    data['weight'] = weight;
    data['allergies'] = allergies != null ? allergies!.join(', ') : null;
    data['medical_history'] = medical_history;
    data['medical_files'] = medical_files.toList();
    return data;
  }

  // Helper method to parse allergies from different formats
  static List<String>? _parseAllergies(dynamic allergiesData) {
    if (allergiesData == null) {
      return null;
    } else if (allergiesData is String) {
      // Handle string format (comma-separated values)
      if (allergiesData.isEmpty) return [];
      return allergiesData
          .split(',')
          .where((item) => item.trim().isNotEmpty)
          .map((item) => item.trim())
          .toList();
    } else if (allergiesData is List) {
      // Handle list format
      return allergiesData
          .map<String>((item) {
            if (item is String) {
              return item;
            } else if (item is Map) {
              // Handle map format with 'name' field
              return item['name']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }
}
