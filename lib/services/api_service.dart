import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import '../models/report.dart';

class ApiService {
  final String baseUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;

  // Headers for API requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-Request-ID': DateTime.now().microsecondsSinceEpoch.toString(),
    };
  }

  // Reports Service Methods
  Future<List<Report>> getReports() async {
    final response = await dio.get(
      '$baseUrl/reports/all',
      options: Options(headers: _getHeaders()),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.data);
      return body.map((item) => Report.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load reports: ${response.data}');
    }
  }

  Future<Report> getReportById(String id) async {
    final response = await dio.get(
      '$baseUrl/reports/$id',
      options: Options(headers: _getHeaders()),
    );

    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to load report: ${response.data}');
    }
  }

  Future<Report> createReport(Map<String, dynamic> data) async {
    final response = await dio.post(
      '$baseUrl/reports/create',
      options: Options(headers: _getHeaders()),
      data: json.encode(data),
    );

    if (response.statusCode == 201) {
      return Report.fromJson(jsonDecode(response.data));
    } else {
      throw Exception('Failed to create report: ${response.data}');
    }
  }

  Future<Report> updateReport(String id, Map<String, dynamic> data) async {
    final response = await dio.put(
      '$baseUrl/reports/$id',
      options: Options(headers: _getHeaders()),
      data: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Report.fromJson(response.data);
    } else {
      throw Exception('Failed to update report: ${response.data}');
    }
  }

  Future<void> deleteReport(String id) async {
    final response = await dio.delete(
      '$baseUrl/reports/$id',
      options: Options(headers: _getHeaders()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete report: ${response.data}');
    }
  }

  // AI Integration Methods
  Future<Map<String, dynamic>> recognizeHandwriting(
      List<Map<String, dynamic>> strokeData) async {
    final response = await dio.post(
      '$baseUrl/ai/recognize-handwriting',
      options: Options(headers: _getHeaders()),
      data: jsonEncode({
        'strokes': strokeData,
        'context': 'medical',
      }),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to recognize handwriting: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> getMedicalTermSuggestions(
      String prefix, String specialty) async {
    final response = await dio.get(
      '$baseUrl/ai/medical-terms?prefix=$prefix&specialty=$specialty',
      options: Options(headers: _getHeaders()),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception(
          'Failed to get medical term suggestions: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> saveDraftReport(
      Map<String, dynamic> reportData) async {
    final response = await dio.post(
      '$baseUrl/reports/draft',
      options: Options(headers: _getHeaders()),
      data: jsonEncode(reportData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to save draft report: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> analyzeReportStructure(
      String reportContent) async {
    final response = await dio.post(
      '$baseUrl/ai/analyze-structure',
      options: Options(headers: _getHeaders()),
      data: jsonEncode({
        'content': reportContent,
      }),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to analyze report structure: ${response.data}');
    }
  }
}
