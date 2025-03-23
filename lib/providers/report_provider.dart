import 'package:flutter/foundation.dart';
import '../models/medical_report.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService;
  List<MedicalReport> _reports = [];
  bool _isLoading = false;
  String? _error;
  Map<String, int> _statistics = {};

  ReportProvider(this._reportService) {
    _initializeReports();
  }

  List<MedicalReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get statistics => _statistics;

  Future<void> _initializeReports() async {
    _setLoading(true);
    try {
      _reports = await _reportService.getAllReports();
      _statistics = await _reportService.getReportStatistics();
      _error = null;
    } catch (e) {
      _error = 'Failed to load reports: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshReports() async {
    await _initializeReports();
  }

  Future<List<MedicalReport>> getFilteredReports({
    String? searchQuery,
    String? status,
    String? specialty,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUrgent,
  }) async {
    try {
      return await _reportService.getFilteredReports(
        searchQuery: searchQuery,
        status: status,
        specialty: specialty,
        startDate: startDate,
        endDate: endDate,
        isUrgent: isUrgent,
      );
    } catch (e) {
      _error = 'Failed to filter reports: $e';
      return [];
    }
  }

  Future<bool> saveReport(MedicalReport report) async {
    _setLoading(true);
    try {
      await _reportService.saveReport(report);
      await refreshReports();
      return true;
    } catch (e) {
      _error = 'Failed to save report: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReport(String id) async {
    _setLoading(true);
    try {
      await _reportService.deleteReport(id);
      await refreshReports();
      return true;
    } catch (e) {
      _error = 'Failed to delete report: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<MedicalReport?> getReport(String id) async {
    try {
      return await _reportService.getReport(id);
    } catch (e) {
      _error = 'Failed to get report: $e';
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
