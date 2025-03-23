import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medapp/config.dart';
import '../models/report.dart';

class ApiService {
  final String baseUrl = Config.apiBaseUrl;

  // Headers for API requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-Request-ID': DateTime.now().microsecondsSinceEpoch.toString(),
    };
  }

  // Reports Service Methods
  Future<List<Report>> getReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/all'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Report.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load reports: ${response.body}');
    }
  }

  Future<Report> getReportById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load report: ${response.body}');
    }
  }

  Future<Report> createReport(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/create'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return Report.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create report: ${response.body}');
    }
  }

  Future<Report> updateReport(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reports/$id'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update report: ${response.body}');
    }
  }

  Future<void> deleteReport(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reports/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete report: ${response.body}');
    }
  }

  // AI Integration Methods
  Future<Map<String, dynamic>> recognizeHandwriting(
      List<Map<String, dynamic>> strokeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/recognize-handwriting'),
      headers: _getHeaders(),
      body: jsonEncode({
        'strokes': strokeData,
        'context': 'medical',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to recognize handwriting: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getMedicalTermSuggestions(
      String prefix, String specialty) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/ai/medical-terms?prefix=$prefix&specialty=$specialty'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to get medical term suggestions: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> saveDraftReport(
      Map<String, dynamic> reportData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/draft'),
      headers: _getHeaders(),
      body: jsonEncode(reportData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save draft report: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> analyzeReportStructure(
      String reportContent) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/analyze-structure'),
      headers: _getHeaders(),
      body: jsonEncode({
        'content': reportContent,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to analyze report structure: ${response.body}');
    }
  }
}
