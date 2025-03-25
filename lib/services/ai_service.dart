import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';

class AiService {
  final String _apiUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;
  // Headers for API requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-Request-ID': DateTime.now().microsecondsSinceEpoch.toString(),
    };
  }

  // Process text for corrections and suggestions
  Future<Map<String, dynamic>> processText(String text,
      {String context = ''}) async {
    try {
      final response = await dio.post(
        '$_apiUrl/ai/process-text',
        options: Options(headers: _getHeaders()),
        data: jsonEncode({'text': text, 'context': context, 'type': 'medical'}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to process text: ${response.data}');
      }
    } catch (e) {
      return {'correctedText': text, 'suggestions': [], 'error': e.toString()};
    }
  }

  // Get chatbot response to user input
  Future<Map<String, dynamic>> getChatbotResponse(
      String userInput, String reportContext) async {
    try {
      final response = await dio.post(
        '$_apiUrl/ai/chat',
        options: Options(headers: _getHeaders()),
        data: jsonEncode({
          'input': userInput,
          'context': reportContext,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to get chatbot response: ${response.data}');
      }
    } catch (e) {
      return {
        'response': 'Sorry, I encountered an error processing your request.',
        'error': e.toString()
      };
    }
  }

  // Analyze medical report content
  Future<Map<String, dynamic>> analyzeReport(String reportContent) async {
    try {
      final response = await dio.post(
        '$_apiUrl/ai/analyze-report',
        options: Options(headers: _getHeaders()),
        data: jsonEncode({
          'content': reportContent,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Failed to analyze report: ${response.data}');
      }
    } catch (e) {
      return {'analysis': {}, 'suggestions': [], 'error': e.toString()};
    }
  }
}
