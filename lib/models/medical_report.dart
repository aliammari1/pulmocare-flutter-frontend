import 'package:hive/hive.dart';

class MedicalReport {
  final String id;

  final String patientName;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String diagnosis;

  @HiveField(4)
  final String symptoms;

  @HiveField(5)
  final String prescription;

  @HiveField(6)
  final List<String> attachments;

  @HiveField(7)
  final String doctorNotes;

  @HiveField(8)
  final bool isHandwritten;

  @HiveField(9)
  final bool isDictated;

  @HiveField(10)
  final String patientId;

  @HiveField(11)
  final Map<String, String> vitalSigns;

  @HiveField(12)
  final bool isUrgent;

  @HiveField(13)
  final String doctorId;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime? lastModified;

  @HiveField(16)
  final String status; // 'draft', 'pending', 'completed'

  MedicalReport({
    required this.id,
    required this.patientName,
    required this.date,
    required this.diagnosis,
    required this.symptoms,
    required this.prescription,
    this.attachments = const [],
    this.doctorNotes = '',
    this.isHandwritten = false,
    this.isDictated = false,
    required this.patientId,
    required this.vitalSigns,
    this.isUrgent = false,
    required this.doctorId,
    DateTime? createdAt,
    this.lastModified,
    this.status = 'draft',
  }) : createdAt = createdAt ?? DateTime.now();

  // Create a copy of the medical report with some fields updated
  MedicalReport copyWith({
    String? id,
    String? patientName,
    DateTime? date,
    String? diagnosis,
    String? symptoms,
    String? prescription,
    List<String>? attachments,
    String? doctorNotes,
    bool? isHandwritten,
    bool? isDictated,
    String? patientId,
    Map<String, String>? vitalSigns,
    bool? isUrgent,
    String? doctorId,
    DateTime? createdAt,
    DateTime? lastModified,
    String? status,
  }) {
    return MedicalReport(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      prescription: prescription ?? this.prescription,
      attachments: attachments ?? this.attachments,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      isHandwritten: isHandwritten ?? this.isHandwritten,
      isDictated: isDictated ?? this.isDictated,
      patientId: patientId ?? this.patientId,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      isUrgent: isUrgent ?? this.isUrgent,
      doctorId: doctorId ?? this.doctorId,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      status: status ?? this.status,
    );
  }
}
