import 'package:flutter/material.dart';
import 'package:medapp/widgets/chat_dialog.dart';
import 'gemini_service.dart';

class ChatViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = false;
  String _error = '';
  final List<ChatMessage> _messages = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  List<ChatMessage> get messages => _messages;

  Future<void> sendMessage(String message, {String? imagePath}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      final userMessage = ChatMessage(
        id: DateTime.now().toString(),
        content: message,
        isBot: false,
        timestamp: DateTime.now(),
        imageUrl: null,
      );
      _messages.add(userMessage);
      notifyListeners();

      // Get AI response
      String aiResponse;
      try {
        aiResponse = await _geminiService.getMedicalResponse(message);
      } catch (e) {
        aiResponse =
            "I apologize, but I'm having trouble generating a response right now. Please try again in a moment.";
        _error = e.toString();
      }

      // Add AI message
      final aiMessage = ChatMessage(
        id: DateTime.now().toString(),
        content: aiResponse,
        isBot: true,
        timestamp: DateTime.now(),
        imageUrl: null,
      );
      _messages.add(aiMessage);
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
