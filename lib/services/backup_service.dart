import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/medical_report.dart';

class BackupService {
  static const String backupFileName = 'medical_reports_backup.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$backupFileName');
  }

  Future<void> backupReports(List<MedicalReport> reports) async {
    try {
      final file = await _localFile;
      final data = reports.map((report) => _reportToJson(report)).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      throw Exception('Failed to backup reports: $e');
    }
  }

  Future<List<MedicalReport>> restoreReports() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final data = jsonDecode(contents) as List;
      return data.map((json) => _reportFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to restore reports: $e');
    }
  }

  Future<void> exportReports(List<MedicalReport> reports) async {
    try {
      final file = await _localFile;
      final data = reports.map((report) => _reportToJson(report)).toList();
      await file.writeAsString(jsonEncode(data));

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Medical Reports Backup',
        subject: 'MediScribe Reports Export',
      );
    } catch (e) {
      throw Exception('Failed to export reports: $e');
    }
  }

  Future<List<MedicalReport>> importReports(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as List;
      return data.map((json) => _reportFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to import reports: $e');
    }
  }

  Map<String, dynamic> _reportToJson(MedicalReport report) {
    return {
      'id': report.id,
      'patientName': report.patientName,
      'patientId': report.patientId,
      'date': report.date.toIso8601String(),
      'diagnosis': report.diagnosis,
      'symptoms': report.symptoms,
      'prescription': report.prescription,
      'doctorNotes': report.doctorNotes,
      'isHandwritten': report.isHandwritten,
      'isDictated': report.isDictated,
      'isUrgent': report.isUrgent,
      'doctorId': report.doctorId,
      'vitalSigns': report.vitalSigns,
      'status': report.status,
      'createdAt': report.createdAt.toIso8601String(),
      'lastModified': report.lastModified?.toIso8601String(),
      'attachments': report.attachments,
    };
  }

  MedicalReport _reportFromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json['id'],
      patientName: json['patientName'],
      patientId: json['patientId'],
      date: DateTime.parse(json['date']),
      diagnosis: json['diagnosis'],
      symptoms: json['symptoms'],
      prescription: json['prescription'],
      doctorNotes: json['doctorNotes'],
      isHandwritten: json['isHandwritten'],
      isDictated: json['isDictated'],
      isUrgent: json['isUrgent'],
      doctorId: json['doctorId'],
      vitalSigns: Map<String, String>.from(json['vitalSigns']),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
      attachments: List<String>.from(json['attachments']),
    );
  }
}
