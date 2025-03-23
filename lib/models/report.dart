class Report {
  final String id;
  final String patientId;
  final String doctorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? additionalData;

  Report({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.additionalData,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'additional_data': additionalData,
    };
  }
}
