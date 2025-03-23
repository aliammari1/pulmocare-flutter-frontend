import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Replace with your actual API key from Google AI Studio
  static const String apiKey = 'AIzaSyAWgoAVpU5XEnnIX3owlfHyg4-YhO1Tffg';
  late final GenerativeModel model;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  final String medicalContext = '''
    You are an AI medical assistant helping doctors. Your responses should:
    - Be professional and medical-oriented
    - Include relevant medical terminology when appropriate
    - Reference medical guidelines when possible
    - Suggest evidence-based practices
    - Maintain patient confidentiality
    - Remind that final decisions rest with the healthcare provider
    ''';

  Future<String> getMedicalResponse(String prompt) async {
    try {
      final content = [
        Content.text('$medicalContext\n\nQuestion: $prompt'),
      ];

      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      return responseText;
    } catch (e) {
      print('Gemini API Error: $e'); // Add logging for debugging
      throw Exception('Failed to get AI response: $e');
    }
  }
}
