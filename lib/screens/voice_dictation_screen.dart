import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:async';
import '../services/ai_service.dart';

class VoiceDictationScreen extends StatefulWidget {
  final String initialText;

  const VoiceDictationScreen({super.key, this.initialText = ''});

  @override
  State<VoiceDictationScreen> createState() => _VoiceDictationScreenState();
}

class _VoiceDictationScreenState extends State<VoiceDictationScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final AiService _aiService = AiService(); // Add AI service
  bool _isListening = false;
  String _dictatedText = '';
  final TextEditingController _textController = TextEditingController();

  // Language support
  List<LocaleName> _localeNames = [];
  String _currentLocaleId = '';

  // For animation and visual feedback
  late AnimationController _animationController;
  final List<double> _soundLevels = List.filled(30, 0.0);
  Timer? _levelTimer;
  double _currentSoundLevel = 0.0;
  String _status = 'Tap the microphone to start';

  // Medical terminology focus
  final List<String> _medicalSpecialties = [
    'General',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Dermatology',
    'Oncology',
    'Gastroenterology',
    'Endocrinology',
    'Psychiatry'
  ];
  String _selectedSpecialty = 'General';
  bool _useKeywords = false;
  bool _isEditing = false;
  bool _isInitialized = false;
  bool _hasSpeechPermission = false;

  // Medical terminology support
  final Map<String, List<String>> _medicalTerms = {
    'cardiology': [
      'tachycardia',
      'arrhythmia',
      'hypertension',
      'myocardial infarction'
    ],
    'neurology': ['seizure', 'migraine', 'neuropathy', 'encephalopathy'],
    'orthopedics': ['fracture', 'osteoarthritis', 'sprain', 'dislocation'],
    'pediatrics': ['otitis media', 'bronchiolitis', 'gastroenteritis'],
    'dermatology': ['dermatitis', 'psoriasis', 'eczema', 'melanoma'],
    'general': ['fever', 'pain', 'inflammation', 'infection']
  };

  // Section formatting
  bool _isSectionMode = false;
  String _currentSection = '';
  final List<String> _sectionKeywords = [
    'section',
    'subjective',
    'objective',
    'assessment',
    'plan',
    'history',
    'examination',
    'diagnosis',
    'prescription'
  ];

  // Voice commands
  final List<String> _commands = [
    'new line',
    'new section',
    'delete last',
    'clear all',
    'end section'
  ];

  // Add suggestions list
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText; // Use passed-in text
    _dictatedText = widget.initialText;
    _initializeSpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  void _initializeSpeechToText() async {
    try {
      _hasSpeechPermission = await _speechToText.hasPermission;

      await _speechToText
          .initialize(
        onError: (errorNotification) {
          setState(() {
            _status = 'Error: ${errorNotification.errorMsg}';
            _isListening = false;
          });
        },
        onStatus: (status) {
          setState(() {
            _status = status;
          });
        },
        debugLogging: true,
      )
          .then((available) {
        setState(() {
          _isInitialized = available;
          if (!available) {
            _status = 'Speech recognition not available on this device';
          } else {
            // If speech is available, get the list of languages
            _getAvailableLanguages();
          }
        });
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _status = 'Error initializing speech recognition: $e';
      });
    }
  }

  void _getAvailableLanguages() async {
    try {
      _localeNames = await _speechToText.locales();

      if (_localeNames.isNotEmpty) {
        // Default to system language if available, otherwise English
        final systemLocale = _localeNames.firstWhere(
          (locale) => locale.localeId
              .startsWith(Localizations.localeOf(context).languageCode),
          orElse: () => _localeNames.firstWhere(
            (locale) => locale.localeId.startsWith('en'),
            orElse: () => _localeNames.first,
          ),
        );

        setState(() {
          _currentLocaleId = systemLocale.localeId;
        });
      }
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      // Default to English or first available language
      if (_speechToText.lastStatus != 'notListening') {
        setState(() {
          _currentLocaleId = 'en_US';
        });
      }
    }
  }

  Future<void> _requestSpeechPermission() async {
    try {
      final hasPerm = await _speechToText.initialize(
        onStatus: (status) {
          setState(() {
            _status = status;
          });
        },
        onError: (errorNotification) {
          setState(() {
            _status = 'Error: ${errorNotification.errorMsg}';
          });
        },
      );

      setState(() {
        _hasSpeechPermission = hasPerm;
        _isInitialized = hasPerm;

        if (hasPerm) {
          _getAvailableLanguages();
          _status = 'Ready to start, tap the microphone';
        } else {
          _status =
              'Permission denied. Please grant microphone access in settings.';
        }
      });
    } catch (e) {
      setState(() {
        _hasSpeechPermission = false;
        _status = 'Error requesting permission: $e';
      });
    }
  }

  void _startListening() async {
    _startLevelTimer();

    if (!_isListening) {
      if (!_hasSpeechPermission) {
        await _requestSpeechPermission();
        if (!_hasSpeechPermission) return;
      }

      setState(() => _isListening = true);

      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenOptions: SpeechListenOptions(
            listenMode: ListenMode.confirmation,
            partialResults: true,
          ),
        );
      } catch (e) {
        setState(() {
          _isListening = false;
          _status = 'Error starting speech recognition: $e';
        });
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      if (result.finalResult) {
        String newText = result.recognizedWords;

        // Process voice commands
        if (_commands.contains(newText.toLowerCase())) {
          _processCommand(newText.toLowerCase());
          return;
        }

        // Check for section keywords
        if (_sectionKeywords.any((keyword) =>
            newText.toLowerCase().contains(keyword.toLowerCase()))) {
          _startNewSection(newText);
          return;
        }

        // Format and append text
        newText = _formatText(newText);

        if (_isEditing) {
          _dictatedText += " $newText";
        } else {
          _dictatedText = newText;
        }
        _textController.text = _dictatedText;
        _currentSoundLevel = result.confidence;

        // Process with AI for suggestions
        _processTextWithAI();
      } else {
        // Handle partial results
        _currentSoundLevel = result.confidence;
        _updateSoundLevels(result.confidence * 100);
      }
    });
  }

  // Add AI processing
  void _processTextWithAI() async {
    try {
      final result = await _aiService.processText(_dictatedText);

      if (result.containsKey('suggestions') && result['suggestions'] is List) {
        final suggestions = List<String>.from(result['suggestions'] as List);
        if (suggestions.isNotEmpty) {
          setState(() {
            // Add medical terminology suggestions
            final specialtyTerms =
                _medicalTerms[_selectedSpecialty.toLowerCase()] ??
                    _medicalTerms['general'] ??
                    [];

            // Combine AI suggestions with local terms
            _suggestions = [...suggestions, ...specialtyTerms.take(3)];
          });
        }
      }
    } catch (e) {
      debugPrint('AI processing error: $e');
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() {
        _isListening = false;
        _stopLevelTimer();
      });
    }
  }

  void _startLevelTimer() {
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Simulate sound level variation when listening
        if (_isListening) {
          _updateSoundLevels(_currentSoundLevel * 100 +
              (DateTime.now().millisecondsSinceEpoch % 30).toDouble());
        }
      });
    });
  }

  void _stopLevelTimer() {
    _levelTimer?.cancel();
    _levelTimer = null;
  }

  void _updateSoundLevels(double level) {
    _soundLevels.removeAt(0);
    _soundLevels.add(level);
  }

  String _formatText(String text) {
    // Capitalize first letter of sentences
    text = text.split('. ').map((sentence) {
      if (sentence.isEmpty) return sentence;
      return sentence[0].toUpperCase() + sentence.substring(1);
    }).join('. ');

    // Add proper spacing after punctuation
    text = text.replaceAll(RegExp(r'([.,!?])(?=\S)'), r'$1 ');

    // Format medical terms
    if (_useKeywords) {
      final selectedTerms = _medicalTerms[_selectedSpecialty.toLowerCase()] ??
          _medicalTerms['general'] ??
          [];

      for (var term in selectedTerms) {
        final regexp = RegExp(term, caseSensitive: false);
        if (text.toLowerCase().contains(term.toLowerCase())) {
          text = text.replaceAllMapped(regexp, (match) => term);
        }
      }
    }

    return text;
  }

  void _processCommand(String command) {
    switch (command) {
      case 'new line':
        _dictatedText += '\n';
        break;
      case 'new section':
        _isSectionMode = true;
        break;
      case 'delete last':
        final sentences = _dictatedText.split('.');
        if (sentences.length > 1) {
          sentences.removeLast();
          _dictatedText = '${sentences.join('.')}.';
        }
        break;
      case 'clear all':
        _dictatedText = '';
        break;
      case 'end section':
        _isSectionMode = false;
        _currentSection = '';
        break;
    }
    _textController.text = _dictatedText;
  }

  void _startNewSection(String text) {
    String sectionTitle = text.replaceAll('section', '').trim();
    _currentSection = sectionTitle.toUpperCase();
    _dictatedText += '\n\n$_currentSection:\n';
    _textController.text = _dictatedText;
    _isSectionMode = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Dictation'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Clear text',
            onPressed: () {
              setState(() {
                _dictatedText = '';
                _textController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Accept and return',
            onPressed: () {
              Navigator.pop(context, _textController.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSettingsCard(),
          _buildStatusIndicator(),
          Expanded(
            child: _buildDictationArea(),
          ),
          // Display AI suggestions
          if (_suggestions.isNotEmpty)
            Container(
              height: 50,
              color: Colors.grey.shade100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ActionChip(
                      label: Text(_suggestions[index]),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      onPressed: () {
                        setState(() {
                          // Apply suggestion
                          _dictatedText += " ${_suggestions[index]}";
                          _textController.text = _dictatedText;

                          // Remove used suggestion
                          _suggestions.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _isInitialized
            ? (_isListening ? _stopListening : _startListening)
            : _requestSpeechPermission,
        backgroundColor: _isListening
            ? Colors.red
            : (_isInitialized
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey),
        child: Icon(_isListening ? Icons.mic_off : Icons.mic, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _dictatedText = '';
                  _textController.clear();
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              icon: Icon(_isEditing ? Icons.edit : Icons.add),
              label: Text(_isEditing ? 'Edit Mode' : 'New Dictation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing
                    ? Colors.orange
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: const InputDecoration(
                      labelText: 'Medical Specialty',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items: _medicalSpecialties.map((String specialty) {
                      return DropdownMenuItem<String>(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecialty = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    const Text('Medical Terminology'),
                    Switch(
                      value: _useKeywords,
                      onChanged: (bool value) {
                        setState(() {
                          _useKeywords = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_localeNames.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _currentLocaleId.isEmpty
                    ? _localeNames.first.localeId
                    : _currentLocaleId,
                decoration: const InputDecoration(
                  labelText: 'Recognition Language',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                items: _localeNames.map((localeName) {
                  return DropdownMenuItem<String>(
                    value: localeName.localeId,
                    child: Text('${localeName.name} (${localeName.localeId})'),
                  );
                }).toList(),
                onChanged: (String? newLocale) {
                  if (newLocale != null) {
                    setState(() {
                      _currentLocaleId = newLocale;
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Text(
            _status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isListening
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: _isListening
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _soundLevels.asMap().entries.map((entry) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        width: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: (entry.value / 5).clamp(1.0, 20.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(77 + (entry.value * 0.77).toInt()),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text(!_isInitialized
                        ? 'Speech recognition not initialized'
                        : !_hasSpeechPermission
                            ? 'Need microphone permission'
                            : 'Tap the microphone to start dictation'),
                  ),
          ),
          if (_isSectionMode)
            Chip(
              label: Text('Section: $_currentSection'),
              backgroundColor:
                  Theme.of(context).colorScheme.secondary.withAlpha(50),
            ),
        ],
      ),
    );
  }

  Widget _buildDictationArea() {
    return Card(
      margin: const EdgeInsets.fromLTRB(
          12, 0, 12, 80), // Extra bottom margin for FAB
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isListening
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Dictation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (!_isInitialized)
                  TextButton.icon(
                    onPressed: _requestSpeechPermission,
                    icon: const Icon(Icons.mic_none),
                    label: const Text('Enable Voice'),
                  )
                else if (_isListening)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Recording',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                readOnly: _isListening,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Speak now...'
                      : (!_isInitialized || !_hasSpeechPermission)
                          ? 'Speech recognition is not available or needs permission'
                          : 'Your dictation will appear here',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _dictatedText = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _textController.dispose();
    _animationController.dispose();
    _levelTimer?.cancel();
    super.dispose();
  }
}
