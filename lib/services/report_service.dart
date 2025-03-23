import 'package:hive/hive.dart';
import '../models/medical_report.dart';

class ReportService {
  static const String _boxName = 'medical_reports';

  Future<Box<MedicalReport>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<MedicalReport>(_boxName);
    }
    return Hive.box<MedicalReport>(_boxName);
  }

  Future<List<MedicalReport>> getAllReports() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<List<MedicalReport>> getFilteredReports({
    String? searchQuery,
    String? status,
    String? specialty,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUrgent,
  }) async {
    final box = await _getBox();
    return box.values.where((report) {
      bool matches = true;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        matches = matches &&
            (report.patientName
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                report.diagnosis
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                report.symptoms
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                report.id.toLowerCase().contains(searchQuery.toLowerCase()));
      }

      if (status != null && status != 'All') {
        matches = matches && report.status == status.toLowerCase();
      }

      if (specialty != null && specialty != 'All') {
        // Implement specialty matching logic
      }

      if (startDate != null) {
        matches = matches && report.date.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && report.date.isBefore(endDate);
      }

      if (isUrgent != null) {
        matches = matches && report.isUrgent == isUrgent;
      }

      return matches;
    }).toList();
  }

  Future<String> saveReport(MedicalReport report) async {
    final box = await _getBox();
    await box.put(report.id, report);
    return report.id;
  }

  Future<void> deleteReport(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<MedicalReport?> getReport(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<List<MedicalReport>> getRecentReports({int limit = 5}) async {
    final box = await _getBox();
    final reports = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return reports.take(limit).toList();
  }

  Future<Map<String, int>> getReportStatistics() async {
    final box = await _getBox();
    final reports = box.values.toList();

    return {
      'total': reports.length,
      'pending': reports.where((r) => r.status == 'pending').length,
      'completed': reports.where((r) => r.status == 'completed').length,
      'urgent': reports.where((r) => r.isUrgent).length,
    };
  }

  Stream<List<MedicalReport>> watchReports() async* {
    final box = await _getBox();
    yield* box.watch().map((_) => box.values.toList());
  }
}
