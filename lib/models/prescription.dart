
enum PrescriptionStatus {
  pending,
  active,
  completed,
  cancelled
}

extension PrescriptionStatusExtension on PrescriptionStatus {
  String get name {
    return toString().split('.').last;
  }
  
  static PrescriptionStatus fromString(String status) {
    return PrescriptionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PrescriptionStatus.pending,
    );
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final List<PrescriptionItem> medications;
  final DateTime date;
  final PrescriptionStatus status;
  final String? notes;

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.medications,
    required this.date,
    required this.status,
    this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      medications: (json['medications'] as List?)
              ?.map((item) => PrescriptionItem.fromJson(item))
              .toList() ??
          [],
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: PrescriptionStatusExtension.fromString(json['status'] ?? 'pending'),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'medications': medications.map((item) => item.toJson()).toList(),
      'date': date.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }
  
  bool get isActive => status == PrescriptionStatus.active;
}

class PrescriptionItem {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}
