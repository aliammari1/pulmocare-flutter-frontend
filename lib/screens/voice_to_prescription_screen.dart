import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class VoiceToPrescriptionScreen extends StatefulWidget {
  const VoiceToPrescriptionScreen({super.key});

  @override
  State<VoiceToPrescriptionScreen> createState() =>
      _VoiceToPrescriptionScreenState();
}

class _VoiceToPrescriptionScreenState extends State<VoiceToPrescriptionScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcribedText = '';
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();

  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _interactions = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _prescriptionController.dispose();
    _patientNameController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  // Initialize the speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Speech recognition not available on this device')),
      );
    }
  }

  // Start listening for speech
  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
        },
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  // Stop listening for speech
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Add transcribed text to prescription
  void _addToPrescription() {
    if (_transcribedText.isEmpty) return;

    // Add a new line if the prescription isn't empty
    if (_prescriptionController.text.isNotEmpty) {
      _prescriptionController.text += '\n';
    }

    _prescriptionController.text += _transcribedText;
    setState(() => _transcribedText = '');
  }

  // Check for interactions in the prescription
  void _checkInteractions() async {
    if (_prescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prescription first')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock extraction of medications from prescription text
    final List<Map<String, dynamic>> extractedMeds = [
      {
        'name': 'Lisinopril',
        'dosage': '10mg',
        'frequency': 'once daily',
        'category': 'ACE Inhibitor',
        'purpose': 'Blood pressure control',
      },
      {
        'name': 'Simvastatin',
        'dosage': '20mg',
        'frequency': 'once daily at bedtime',
        'category': 'Statin',
        'purpose': 'Cholesterol management',
      },
      {
        'name': 'Ibuprofen',
        'dosage': '400mg',
        'frequency': 'as needed for pain',
        'category': 'NSAID',
        'purpose': 'Pain relief',
      },
    ];

    // Mock medication interactions
    final List<Map<String, dynamic>> mockInteractions = [
      {
        'severity': 'Moderate',
        'description':
            'Ibuprofen may decrease the antihypertensive effect of Lisinopril',
        'recommendation':
            'Monitor blood pressure closely. Consider acetaminophen as an alternative analgesic.',
        'medications': ['Lisinopril', 'Ibuprofen'],
      },
    ];

    setState(() {
      _medications = extractedMeds;
      _interactions = mockInteractions;
      _isAnalyzing = false;
    });
  }

  // Format the prescription into standard medical format
  void _formatPrescription() {
    if (_prescriptionController.text.isEmpty) return;

    // Simple formatting for demonstration
    final String formattedText =
        _formatPrescriptionText(_prescriptionController.text);

    setState(() {
      _prescriptionController.text = formattedText;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prescription formatted')),
    );
  }

  String _formatPrescriptionText(String text) {
    // This is a simplified example of prescription formatting
    // In a real app, this would use NLP to structure the prescription

    // Split by lines
    List<String> lines = text.split('\n');
    List<String> formattedLines = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      // Skip empty lines
      if (line.isEmpty) continue;

      // Add numbering for each medication
      formattedLines.add('${i + 1}. $line');
    }

    // Add signature line at the end
    formattedLines.add('\nSig: _____________________________');
    formattedLines.add('Date: ${DateTime.now().toString().substring(0, 10)}');

    return formattedLines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice to Prescription'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient information section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _patientNameController,
                              decoration: const InputDecoration(
                                labelText: 'Patient Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _patientIdController,
                              decoration: const InputDecoration(
                                labelText: 'Patient ID',
                                prefixIcon: Icon(Icons.badge),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // This would open a patient search dialog in a real app
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Patient search functionality would appear here')));
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Search Patient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Voice dictation section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voice Dictation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _transcribedText.isEmpty
                                    ? 'Tap the microphone and speak...'
                                    : _transcribedText,
                                style: TextStyle(
                                  color: _transcribedText.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.black,
                                ),
                              ),
                            ),
                            if (_transcribedText.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                color: AppTheme.primaryColor,
                                onPressed: _addToPrescription,
                                tooltip: 'Add to prescription',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                _isListening ? _stopListening : _startListening,
                            icon: Icon(_isListening ? Icons.stop : Icons.mic),
                            label:
                                Text(_isListening ? 'Stop' : 'Start Recording'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening
                                  ? Colors.red
                                  : AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                          if (_transcribedText.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _transcribedText = '');
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Prescription textarea
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prescription',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_paste),
                            tooltip: 'Template',
                            onPressed: () {
                              // This would show prescription templates in a real app
                              setState(() {
                                _prescriptionController.text +=
                                    '\n• Medication: \n• Dosage: \n• Frequency: \n• Duration: \n• Special instructions: ';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _prescriptionController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText:
                              'Enter prescription details here or use voice dictation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _formatPrescription,
                              icon: const Icon(Icons.format_align_left),
                              label: const Text('Format Prescription'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _checkInteractions,
                              icon: _isAnalyzing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.security),
                              label: Text(_isAnalyzing
                                  ? 'Checking...'
                                  : 'Check Interactions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Only show this section if medications have been extracted
              if (_medications.isNotEmpty) ...[
                const SizedBox(height: 20),

                // Extracted medications
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extracted Medications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_medications.length, (index) {
                          final med = _medications[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                med['name'][0],
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            title: Text(med['name']),
                            subtitle:
                                Text('${med['dosage']} - ${med['frequency']}'),
                            trailing: Text(
                              med['category'],
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],

              // Only show this section if interactions have been found
              if (_interactions.isNotEmpty) ...[
                const SizedBox(height: 20),

                // Medication interactions
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Potential Interactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_interactions.length, (index) {
                          final interaction = _interactions[index];
                          Color severityColor;

                          switch (interaction['severity']) {
                            case 'Minor':
                              severityColor = Colors.yellow[700]!;
                              break;
                            case 'Moderate':
                              severityColor = Colors.orange;
                              break;
                            case 'Major':
                              severityColor = Colors.red;
                              break;
                            default:
                              severityColor = Colors.grey;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: severityColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: severityColor
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          '${interaction['severity']} Severity',
                                          style: TextStyle(
                                            color: severityColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Between: ${interaction['medications'].join(' & ')}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    interaction['description'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Recommendation:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    interaction['recommendation'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Save and send buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // This would save as draft in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Prescription saved as draft')));
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // This would create and send the prescription in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Prescription created and saved')));
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Create Prescription'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
