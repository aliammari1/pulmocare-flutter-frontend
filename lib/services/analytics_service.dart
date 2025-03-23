import '../models/medical_report.dart';

class AnalyticsService {
  Map<String, int> getReportStatusDistribution(List<MedicalReport> reports) {
    final distribution = <String, int>{
      'draft': 0,
      'pending': 0,
      'completed': 0,
    };

    for (final report in reports) {
      distribution[report.status] = (distribution[report.status] ?? 0) + 1;
    }

    return distribution;
  }

  Map<String, int> getDiagnosisFrequency(List<MedicalReport> reports) {
    final frequency = <String, int>{};

    for (final report in reports) {
      frequency[report.diagnosis] = (frequency[report.diagnosis] ?? 0) + 1;
    }

    return Map.fromEntries(
      frequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(10),
    );
  }

  Map<DateTime, int> getReportsTrend(
    List<MedicalReport> reports, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final trend = <DateTime, int>{};
    final currentDate = startDate;

    while (currentDate.isBefore(endDate)) {
      trend[currentDate] = reports
          .where((report) =>
              report.date.year == currentDate.year &&
              report.date.month == currentDate.month &&
              report.date.day == currentDate.day)
          .length;

      currentDate.add(const Duration(days: 1));
    }

    return trend;
  }

  double getAverageReportsPerDay(List<MedicalReport> reports) {
    if (reports.isEmpty) return 0;

    final dates = reports.map((r) => r.date).toSet();
    return reports.length / dates.length;
  }

  Map<String, double> getVitalSignsAverages(List<MedicalReport> reports) {
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final report in reports) {
      for (final entry in report.vitalSigns.entries) {
        final value = double.tryParse(entry.value);
        if (value != null) {
          totals[entry.key] = (totals[entry.key] ?? 0) + value;
          counts[entry.key] = (counts[entry.key] ?? 0) + 1;
        }
      }
    }

    return {for (final key in totals.keys) key: totals[key]! / counts[key]!};
  }

  List<MedicalReport> getUrgentReportsTrend(List<MedicalReport> reports) {
    return reports.where((report) => report.isUrgent).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, dynamic> generateMonthlyReport(
    List<MedicalReport> reports,
    DateTime month,
  ) {
    final monthlyReports = reports.where((report) =>
        report.date.year == month.year && report.date.month == month.month);

    return {
      'total_reports': monthlyReports.length,
      'urgent_reports': monthlyReports.where((r) => r.isUrgent).length,
      'completed_reports':
          monthlyReports.where((r) => r.status == 'completed').length,
      'average_reports_per_day': monthlyReports.length / 30,
      'diagnosis_distribution': getDiagnosisFrequency(monthlyReports.toList()),
      'vital_signs_averages': getVitalSignsAverages(monthlyReports.toList()),
    };
  }

  List<Map<String, dynamic>> getPatientHistory(
    List<MedicalReport> reports,
    String patientId,
  ) {
    final patientReports = reports
        .where((report) => report.patientId == patientId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return patientReports.map((report) {
      final vitalSigns = report.vitalSigns;
      return {
        'date': report.date,
        'diagnosis': report.diagnosis,
        'vital_signs': vitalSigns,
        'is_urgent': report.isUrgent,
        'status': report.status,
      };
    }).toList();
  }
}
