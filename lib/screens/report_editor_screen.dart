import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:ui' as ui;
import '../services/ai_service.dart';
import 'package:go_router/go_router.dart';

class ReportEditorScreen extends StatefulWidget {
  final String initialContent;
  final String reportId;
  final String patientName;

  const ReportEditorScreen({
    super.key,
    this.initialContent = '',
    required this.reportId,
    required this.patientName,
  });

  @override
  State<ReportEditorScreen> createState() => _ReportEditorScreenState();
}

class _ReportEditorScreenState extends State<ReportEditorScreen>
    with SingleTickerProviderStateMixin {
  // Editor controllers and settings
  final TextEditingController _textController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Voice recognition variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastRecognizedWords = '';
  double _currentSoundLevel = 0.0;
  Timer? _silenceTimer;
  final List<double> _soundLevels = List.filled(30, 0.0);

  // Handwriting recognition variables
  bool _isHandwriting = false;
  List<Offset?> _handwritingPoints = [];

  // AI Assistant variables
  final AiService _aiService = AiService();
  String _assistantResponse = '';
  bool _isProcessing = false;
  List<String> _suggestions = [];
  Timer? _textProcessingDebounce;

  // UI Animation
  late AnimationController _animationController;
  bool _showChatbot = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialContent;
    _initializeSpeech();

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set up focus listener
    _editorFocusNode.addListener(_onFocusChange);

    // Set up text change listener
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _textProcessingDebounce?.cancel();
    _silenceTimer?.cancel();
    super.dispose();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      debugLogging: true,
    );

    if (!available && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Speech Recognition Unavailable'),
          content:
              const Text('Speech recognition is not available on this device.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechError(dynamic error) {
    setState(() {
      _isListening = false;
      _currentSoundLevel = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech error: ${error.errorMsg}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        await _speech.listen(
          onResult: _onSpeechResult,
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
            partialResults: true,
            cancelOnError: true,
          ),
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastRecognizedWords = result.recognizedWords;
      _currentSoundLevel = result.confidence;

      if (result.finalResult) {
        _insertTextAtCursor(result.recognizedWords);
        _silenceTimer?.cancel();
      } else {
        // Update sound levels visualization
        _updateSoundLevel(result.confidence);

        // Reset silence timer
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 2), () {
          if (_lastRecognizedWords.isNotEmpty) {
            _insertTextAtCursor(_lastRecognizedWords);
            _lastRecognizedWords = '';
          }
        });
      }
    });
  }

  void _updateSoundLevel(double level) {
    setState(() {
      _soundLevels.removeAt(0);
      _soundLevels
          .add((level * 100) + (DateTime.now().millisecondsSinceEpoch % 10));
    });
  }

  void _insertTextAtCursor(String text) {
    // Only add space if needed
    final currentText = _textController.text;
    final textSelection = _textController.selection;
    final cursorPosition = textSelection.start;

    if (cursorPosition < 0) return;

    String newText;
    if (cursorPosition > 0 &&
        cursorPosition < currentText.length &&
        !currentText[cursorPosition - 1].contains(RegExp(r'[\s\n]')) &&
        !text.startsWith(RegExp(r'[\s\n.,!?]'))) {
      newText = ' $text';
    } else {
      newText = text;
    }

    _textController.text = currentText.substring(0, cursorPosition) +
        newText +
        currentText.substring(cursorPosition);

    _textController.selection = TextSelection.collapsed(
      offset: cursorPosition + newText.length,
    );

    // Trigger AI processing after a short delay
    _processTextWithAI();
  }

  void _processTextWithAI() {
    _textProcessingDebounce?.cancel();
    _textProcessingDebounce =
        Timer(const Duration(milliseconds: 800), () async {
      if (_textController.text.isEmpty) return;

      setState(() {
        _isProcessing = true;
      });

      try {
        final result = await _aiService.processText(_textController.text);

        if (result.containsKey('suggestions') &&
            result['suggestions'] is List) {
          setState(() {
            _suggestions = List<String>.from(result['suggestions'] as List);
          });
        }

        if (result.containsKey('correctedText') &&
            result['correctedText'] != _textController.text) {
          // Highlight corrections but don't auto-replace text
          // Instead, add suggestions
        }
      } catch (e) {
        debugPrint('AI text processing error: $e');
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _onFocusChange() {
    if (!_editorFocusNode.hasFocus) {
      // When losing focus, process the entire text for a final review
      _processTextWithAI();
    }
  }

  void _onTextChanged() {
    // Handle real-time text changes
    if (!_isListening && !_isHandwriting) {
      _processTextWithAI();
    }
  }

  void _toggleHandwriting() {
    setState(() {
      _isHandwriting = !_isHandwriting;
      if (!_isHandwriting) {
        _recognizeHandwriting();
      }
    });
  }

  void _addHandwritingPoint(Offset? point) {
    setState(() {
      _handwritingPoints.add(point);
    });
  }

  void _recognizeHandwriting() async {
    if (_handwritingPoints.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // This would normally send the points to an AI service
    // For now, we'll simulate recognition with a delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulated text recognition (replace with actual API call)
    final recognizedText = "Handwritten text";

    _insertTextAtCursor(recognizedText);

    setState(() {
      _handwritingPoints = [];
      _isProcessing = false;
    });
  }

  void _toggleChatbot() {
    setState(() {
      _showChatbot = !_showChatbot;
    });

    if (_showChatbot) {
      _animationController.forward();
      _getAssistantAnalysis();
    } else {
      _animationController.reverse();
    }
  }

  void _getAssistantAnalysis() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _assistantResponse = 'Analyzing report...';
    });

    try {
      final analysis = await _aiService.analyzeReport(_textController.text);

      if (analysis.containsKey('analysis')) {
        setState(() {
          _assistantResponse =
              "Based on my analysis of the report for ${widget.patientName}:\n\n"
              "1. Key findings: ${analysis['analysis']['findings'] ?? 'None detected'}\n\n"
              "2. Possible additions: ${analysis['analysis']['suggestions'] ?? 'None needed'}\n\n"
              "3. Medical terms requiring clarification: ${analysis['analysis']['terms'] ?? 'None found'}\n\n"
              "Ask me anything about this report!";
        });
      } else {
        setState(() {
          _assistantResponse =
              "I've reviewed the report. What would you like to know?";
        });
      }
    } catch (e) {
      setState(() {
        _assistantResponse =
            "I had trouble analyzing this report. You can still ask me questions.";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _askAssistant(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _assistantResponse = "Thinking...";
    });

    try {
      final response =
          await _aiService.getChatbotResponse(question, _textController.text);

      setState(() {
        _assistantResponse =
            response['response'] ?? "I'm not sure how to answer that.";
      });
    } catch (e) {
      setState(() {
        _assistantResponse =
            "Sorry, I encountered an error processing your question.";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _applySuggestion(String suggestion) {
    // Apply the suggestion to the text
    _textController.text += " $suggestion";
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    // Remove this suggestion from the list
    setState(() {
      _suggestions.remove(suggestion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report: ${widget.patientName}'),
        actions: [
          IconButton(
            icon: Icon(
                _showChatbot ? Icons.chat_bubble : Icons.chat_bubble_outline),
            tooltip: 'AI Assistant',
            onPressed: _toggleChatbot,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Report',
            onPressed: () {
              // Save logic here
              context.pop(_textController.text);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Main editor column
          Expanded(
            flex: _showChatbot ? 2 : 3,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Text editor
                      if (!_isHandwriting)
                        Positioned.fill(
                          child: TextField(
                            controller: _textController,
                            focusNode: _editorFocusNode,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                              hintText:
                                  'Start typing or use voice/handwriting input...',
                            ),
                          ),
                        ),

                      // Handwriting canvas
                      if (_isHandwriting)
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: (details) {
                              _addHandwritingPoint(details.localPosition);
                            },
                            onPanUpdate: (details) {
                              _addHandwritingPoint(details.localPosition);
                            },
                            onPanEnd: (details) {
                              _addHandwritingPoint(null);
                            },
                            child: CustomPaint(
                              painter: HandwritingPainter(_handwritingPoints),
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Voice visualization overlay
                      if (_isListening)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _soundLevels
                                      .map((level) => Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            width: 3,
                                            height:
                                                (level / 5).clamp(3.0, 50.0),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(128 +
                                                      (level ~/ 2)
                                                          .clamp(0, 127)),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _lastRecognizedWords.isEmpty
                                      ? 'Listening...'
                                      : _lastRecognizedWords,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Processing indicator
                      if (_isProcessing)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Processing...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Suggestions area
                if (_suggestions.isNotEmpty)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: ActionChip(
                            label: Text(_suggestions[index]),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(25),
                            onPressed: () =>
                                _applySuggestion(_suggestions[index]),
                          ),
                        );
                      },
                    ),
                  ),

                // Input controls bar
                Container(
                  color: Colors.grey.shade100,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Voice input button
                      ElevatedButton.icon(
                        onPressed:
                            _isListening ? _stopListening : _startListening,
                        icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                        label: Text(_isListening ? 'Stop' : 'Voice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      // Handwriting toggle button
                      ElevatedButton.icon(
                        onPressed: _toggleHandwriting,
                        icon: Icon(_isHandwriting ? Icons.check : Icons.draw),
                        label: Text(_isHandwriting ? 'Done' : 'Write'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHandwriting
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),

                      // Clear handwriting button (only visible when handwriting)
                      if (_isHandwriting)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _handwritingPoints = [];
                            });
                          },
                          tooltip: 'Clear Handwriting',
                        ),

                      // Toggle AI assistant button
                      ElevatedButton.icon(
                        onPressed: _toggleChatbot,
                        icon: Icon(_showChatbot
                            ? Icons.chat_bubble
                            : Icons.chat_bubble_outline),
                        label: const Text('Assistant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chatbot panel - slides in and out
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _showChatbot ? MediaQuery.of(context).size.width * 0.3 : 0,
            child: _showChatbot ? _buildChatbotPanel() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotPanel() {
    final chatController = TextEditingController();

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.psychology_alt,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI Medical Assistant',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleChatbot,
                  tooltip: 'Close Assistant',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assistant response
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Thinking...'),
                            ],
                          )
                        : Text(_assistantResponse),
                  ),

                  const SizedBox(height: 16),

                  // Quick action buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickActionChip('Analyze symptoms'),
                      _buildQuickActionChip('Suggest diagnosis'),
                      _buildQuickActionChip('Treatment options'),
                      _buildQuickActionChip('Medical terminology'),
                      _buildQuickActionChip('Improve report structure'),
                      _buildQuickActionChip('Suggest follow-up'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // User input for chatbot
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: InputDecoration(
                      hintText: 'Ask about this report...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _askAssistant(value);
                        chatController.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (chatController.text.trim().isNotEmpty) {
                      _askAssistant(chatController.text);
                      chatController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _askAssistant(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle:
          TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

// Painter for handwriting input
class HandwritingPainter extends CustomPainter {
  final List<Offset?> points;

  HandwritingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null) {
        // Use ui.PointMode for drawing points
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) =>
      oldDelegate.points != points;
}
