enum RadiologyType { xray, ultrasound, mri, ct, petScan, mammogram, other }

enum RadiologyStatus {
  requested,
  scheduled,
  completed,
  reported,
  cancelled,
}

enum RadiologyUrgency {
  routine,
  urgent,
  emergency,
}

class RadiologyExamination {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final RadiologyType type;
  final String bodyPart;
  final RadiologyStatus status;
  final DateTime requestedDate;
  final DateTime? scheduledDate;
  final DateTime? completionDate;
  final String? reason;
  final String? notes;
  final String? urgencyLevel; // 'routine', 'urgent', 'emergency'

  RadiologyExamination({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.type,
    required this.bodyPart,
    required this.status,
    required this.requestedDate,
    this.scheduledDate,
    this.completionDate,
    this.reason,
    this.notes,
    this.urgencyLevel,
  });

  factory RadiologyExamination.fromJson(Map<String, dynamic> json) {
    return RadiologyExamination(
      id: json['id'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      type: _parseRadiologyType(json['type']),
      bodyPart: json['bodyPart'],
      status: _parseRadiologyStatus(json['status']),
      requestedDate: DateTime.parse(json['requestedDate']),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      reason: json['reason'],
      notes: json['notes'],
      urgencyLevel: json['urgencyLevel'],
    );
  }

  static RadiologyType _parseRadiologyType(String type) {
    switch (type.toLowerCase()) {
      case 'xray':
        return RadiologyType.xray;
      case 'ultrasound':
        return RadiologyType.ultrasound;
      case 'mri':
        return RadiologyType.mri;
      case 'ct':
        return RadiologyType.ct;
      case 'petscan':
        return RadiologyType.petScan;
      case 'mammogram':
        return RadiologyType.mammogram;
      default:
        return RadiologyType.other;
    }
  }

  static RadiologyStatus _parseRadiologyStatus(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return RadiologyStatus.requested;
      case 'scheduled':
        return RadiologyStatus.scheduled;
      case 'completed':
        return RadiologyStatus.completed;
      case 'reported':
        return RadiologyStatus.reported;
      case 'cancelled':
        return RadiologyStatus.cancelled;
      default:
        return RadiologyStatus.requested;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'type': type.toString().split('.').last,
      'bodyPart': bodyPart,
      'status': status.toString().split('.').last,
      'requestedDate': requestedDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'reason': reason,
      'notes': notes,
      'urgencyLevel': urgencyLevel,
    };
  }
}

class RadiologyReport {
  final String id;
  final String? examinationId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String radiologistId;
  final String radiologistName;
  final DateTime date;
  final String type;
  final String bodyPart;
  final DateTime? reportDate;
  final String findings;
  final String impression;
  final String recommendedActions;
  final RadiologyUrgency urgency;
  final RadiologyStatus status;
  final List<String>? imageUrls;
  final String? recommendation;

  RadiologyReport({
    required this.id,
    this.examinationId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.radiologistId,
    required this.radiologistName,
    required this.date,
    required this.type,
    required this.bodyPart,
    this.reportDate,
    required this.findings,
    required this.impression,
    required this.recommendedActions,
    required this.urgency,
    required this.status,
    this.imageUrls,
    this.recommendation,
  });

  factory RadiologyReport.fromJson(Map<String, dynamic> json) {
    return RadiologyReport(
      id: json['id'],
      examinationId: json['examinationId'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      radiologistId: json['radiologistId'],
      radiologistName: json['radiologistName'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      bodyPart: json['bodyPart'],
      reportDate: json['reportDate'] != null
          ? DateTime.parse(json['reportDate'])
          : null,
      findings: json['findings'],
      impression: json['impression'],
      recommendedActions: json['recommendedActions'] ?? '',
      urgency: _parseRadiologyUrgency(json['urgency']),
      status: _parseRadiologyStatus(json['status']),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      recommendation: json['recommendation'],
    );
  }

  static RadiologyUrgency _parseRadiologyUrgency(String? urgency) {
    if (urgency == null) return RadiologyUrgency.routine;

    switch (urgency.toLowerCase()) {
      case 'urgent':
        return RadiologyUrgency.urgent;
      case 'emergency':
        return RadiologyUrgency.emergency;
      default:
        return RadiologyUrgency.routine;
    }
  }

  static RadiologyStatus _parseRadiologyStatus(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return RadiologyStatus.requested;
      case 'scheduled':
        return RadiologyStatus.scheduled;
      case 'completed':
        return RadiologyStatus.completed;
      case 'reported':
        return RadiologyStatus.reported;
      case 'cancelled':
        return RadiologyStatus.cancelled;
      default:
        return RadiologyStatus.requested;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examinationId': examinationId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'radiologistId': radiologistId,
      'radiologistName': radiologistName,
      'date': date.toIso8601String(),
      'type': type,
      'bodyPart': bodyPart,
      'reportDate': reportDate?.toIso8601String(),
      'findings': findings,
      'impression': impression,
      'recommendedActions': recommendedActions,
      'urgency': urgency.toString().split('.').last,
      'status': status.toString().split('.').last,
      'imageUrls': imageUrls,
      'recommendation': recommendation,
    };
  }
}
