import 'medical_file.dart';

enum AppointmentStatus { pending, accepted, rejected, completed, cancelled }

enum AppointmentType { initial, followUp, emergency, consultation }

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime scheduledTime;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? reason;
  final String? notes;
  final Duration? duration;
  final bool isVirtual;
  final List<MedicalFile> medical_files;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.scheduledTime,
    required this.status,
    required this.type,
    required this.isVirtual,
    this.reason,
    this.notes,
    this.duration,
    this.medical_files = const [],
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    List<MedicalFile> files = [];
    if (json['medical_files'] != null) {
      files = (json['medical_files'] as List)
          .map((fileJson) => MedicalFile.fromJson(fileJson))
          .toList();
    }

    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      status: _parseStatus(json['status']),
      type: _parseType(json['type']),
      isVirtual: json['isVirtual'] ?? false,
      reason: json['reason'],
      notes: json['notes'],
      duration:
          json['duration'] != null ? Duration(minutes: json['duration']) : null,
      medical_files: files,
    );
  }

  static AppointmentStatus _parseStatus(String status) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AppointmentStatus.pending,
    );
  }

  static AppointmentType _parseType(String type) {
    return AppointmentType.values.firstWhere(
      (e) => e.name == type || e.name == _normalizeTypeName(type),
      orElse: () => AppointmentType.consultation,
    );
  }

  static String _normalizeTypeName(String type) {
    // Convert hyphenated or space-separated types to camelCase
    if (type == 'follow-up' || type == 'follow up') {
      return 'followUp';
    }
    return type;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'isVirtual': isVirtual,
      'reason': reason,
      'notes': notes,
      'duration': duration?.inMinutes,
      'medical_files': medical_files.toList(),
    };
  }

  bool get isPending => status == AppointmentStatus.pending;
  bool get isAccepted => status == AppointmentStatus.accepted;
  bool get isRejected => status == AppointmentStatus.rejected;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  bool get isInitial => type == AppointmentType.initial;
  bool get isFollowUp => type == AppointmentType.followUp;
  bool get isEmergency => type == AppointmentType.emergency;
  bool get isConsultation => type == AppointmentType.consultation;

  bool get hasmedical_files => medical_files.isNotEmpty;

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? scheduledTime,
    AppointmentStatus? status,
    AppointmentType? type,
    String? reason,
    String? notes,
    Duration? duration,
    bool? isVirtual,
    List<MedicalFile>? medical_files,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      isVirtual: isVirtual ?? this.isVirtual,
      medical_files: medical_files ?? this.medical_files,
    );
  }

  Appointment addMedicalFile(MedicalFile file) {
    return copyWith(
      medical_files: [...medical_files, file],
    );
  }

  Appointment removeMedicalFile(String fileId) {
    return copyWith(
      medical_files: medical_files.where((file) => file.objectName != fileId).toList(),
    );
  }
}

class AppointmentCreate {
  final String patientId;
  final String doctorId;
  final DateTime scheduledTime;
  final AppointmentType type;
  final String? reason;
  final Duration? duration;
  final bool isVirtual;
  final List<String>? medicalFileIds;

  AppointmentCreate({
    required this.patientId,
    required this.doctorId,
    required this.scheduledTime,
    required this.type,
    required this.isVirtual,
    this.reason,
    this.duration,
    this.medicalFileIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'type': type.name,
      'isVirtual': isVirtual,
      'reason': reason,
      'duration': duration?.inMinutes,
      'medicalFileIds': medicalFileIds,
    };
  }
}

class PaginatedAppointmentResponse {
  final List<Appointment> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginatedAppointmentResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginatedAppointmentResponse.fromJson(Map<String, dynamic> json) {
    List<Appointment> appointments = [];
    if (json['items'] != null) {
      appointments = (json['items'] as List)
          .map((item) => Appointment.fromJson(item))
          .toList();
    }

    return PaginatedAppointmentResponse(
      items: appointments,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }

  bool get hasNextPage => page < pages;
  bool get hasPreviousPage => page > 1;
  int get nextPage => hasNextPage ? page + 1 : page;
  int get previousPage => hasPreviousPage ? page - 1 : page;
  bool get isEmpty => items.isEmpty;
}
