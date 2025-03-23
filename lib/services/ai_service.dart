import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medapp/config.dart';

class AiService {
  final String _apiUrl = Config.apiBaseUrl;

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
      final response = await http.post(
        Uri.parse('$_apiUrl/ai/process-text'),
        headers: _getHeaders(),
        body: jsonEncode({'text': text, 'context': context, 'type': 'medical'}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to process text: ${response.body}');
      }
    } catch (e) {
      return {'correctedText': text, 'suggestions': [], 'error': e.toString()};
    }
  }

  // Get chatbot response to user input
  Future<Map<String, dynamic>> getChatbotResponse(
      String userInput, String reportContext) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/ai/chat'),
        headers: _getHeaders(),
        body: jsonEncode({
          'input': userInput,
          'context': reportContext,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get chatbot response: ${response.body}');
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
      final response = await http.post(
        Uri.parse('$_apiUrl/ai/analyze-report'),
        headers: _getHeaders(),
        body: jsonEncode({
          'content': reportContent,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze report: ${response.body}');
      }
    } catch (e) {
      return {'analysis': {}, 'suggestions': [], 'error': e.toString()};
    }
  }
}
