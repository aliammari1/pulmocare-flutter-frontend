import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_viewmodel.dart';
import '../theme/app_theme.dart';
import '../utils/medical_prompts.dart';
import 'package:go_router/go_router.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isBot;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isBot,
    required this.timestamp,
    this.imageUrl,
  });
}

class ChatDialog extends StatefulWidget {
  const ChatDialog({super.key});

  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isBot ? 8 : 50,
          right: message.isBot ? 50 : 8,
          top: 8,
          bottom: 8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isBot ? Colors.white : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  height: 150,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: message.isBot ? Colors.black87 : Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isBot ? Colors.grey : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Consumer<ChatViewModel>(
        builder: (context, chatVM, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatVM.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(chatVM.messages[index]);
                  },
                ),
              ),
              if (chatVM.isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI is thinking...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: MedicalPrompts.getRandomSuggestion(),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(16),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    context.read<ChatViewModel>().sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Medical AI Assistant',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
