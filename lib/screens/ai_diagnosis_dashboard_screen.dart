import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AIDiagnosisDashboardScreen extends StatefulWidget {
  const AIDiagnosisDashboardScreen({super.key});

  @override
  State<AIDiagnosisDashboardScreen> createState() =>
      _AIDiagnosisDashboardScreenState();
}

class _AIDiagnosisDashboardScreenState
    extends State<AIDiagnosisDashboardScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final List<String> _symptoms = [];
  final List<Map<String, dynamic>> _suggestedDiagnoses = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _addSymptom(String symptom) {
    if (symptom.isNotEmpty) {
      setState(() {
        _symptoms.add(symptom);
      });
      _symptomsController.clear();
    }
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
      // Reset diagnoses when symptoms change
      _suggestedDiagnoses.clear();
    });
  }

  Future<void> _generateDiagnoses() async {
    if (_symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one symptom')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock data - in a real app, this would come from an AI service
    final List<Map<String, dynamic>> mockDiagnoses = [
      {
        'condition': 'Upper Respiratory Infection',
        'probability': 0.87,
        'description':
            'A viral infection affecting the upper respiratory tract, including the nose, throat, and airways.',
        'nextSteps': [
          'Rest and hydration',
          'Over-the-counter decongestants',
          'Monitor for fever'
        ]
      },
      {
        'condition': 'Seasonal Allergies',
        'probability': 0.65,
        'description':
            'An immune system response to environmental allergens such as pollen, dust, or pet dander.',
        'nextSteps': [
          'Antihistamines',
          'Avoid known allergens',
          'Consider allergy testing'
        ]
      },
      {
        'condition': 'Migraine',
        'probability': 0.42,
        'description':
            'A neurological condition that can cause severe headaches, often with visual disturbances and nausea.',
        'nextSteps': [
          'Rest in a dark, quiet room',
          'Over-the-counter pain relievers',
          'Track triggers for prevention'
        ]
      },
    ];

    setState(() {
      _suggestedDiagnoses.clear();
      _suggestedDiagnoses.addAll(mockDiagnoses);
      _isLoading = false;
    });
  }

  Widget _buildDecisionTree() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive Decision Tree',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Explore possible diagnoses by answering additional questions:',
          ),
          const SizedBox(height: 16),

          // Decision tree questions would be dynamically generated in a real app
          _buildDecisionQuestion(
              'Does the patient have fever?', ['Yes', 'No', 'Unknown']),
          _buildDecisionQuestion(
              'Is there chest pain?', ['Yes', 'No', 'Unknown']),
          _buildDecisionQuestion(
              'Duration of symptoms?', ['< 24 hours', '1-3 days', '> 3 days']),

          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // This would refine the diagnoses based on answers
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Decision tree refined results (to be implemented)')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Refine Diagnosis'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionQuestion(String question, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected:
                    false, // In a real app, this would track the selection
                onSelected: (selected) {
                  // Would store the selection in state
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diagnosis Assistant'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                const Text(
                  'Enter patient symptoms to get AI-assisted diagnosis suggestions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Symptoms input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _symptomsController,
                        decoration: InputDecoration(
                          labelText: 'Add symptom',
                          hintText: 'e.g. headache, fever, cough',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: _addSymptom,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: AppTheme.primaryColor,
                      iconSize: 32,
                      onPressed: () => _addSymptom(_symptomsController.text),
                    ),
                  ],
                ),

                // Symptoms list
                if (_symptoms.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Current Symptoms:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: List<Widget>.generate(
                      _symptoms.length,
                      (index) => Chip(
                        label: Text(_symptoms[index]),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeSymptom(index),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateDiagnoses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Generate Diagnosis Suggestions'),
                    ),
                  ),
                ],

                // Decision Tree (for complex cases)
                if (_suggestedDiagnoses.isNotEmpty) _buildDecisionTree(),

                // Results section
                if (_suggestedDiagnoses.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Suggested Diagnoses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Based on the provided symptoms, these conditions should be considered:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Replace Expanded with a SizedBox with fixed height
                  SizedBox(
                    height: 400, // Give an appropriate height for the list
                    child: ListView.builder(
                      shrinkWrap:
                          true, // Makes the ListView take only the space it needs
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                      itemCount: _suggestedDiagnoses.length,
                      itemBuilder: (context, index) {
                        final diagnosis = _suggestedDiagnoses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ...existing code for card content...
                          child: ExpansionTile(
                            title: Text(
                              diagnosis['condition'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: LinearProgressIndicator(
                              value: diagnosis['probability'],
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                diagnosis['probability'] > 0.7
                                    ? Colors.red
                                    : diagnosis['probability'] > 0.5
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                            trailing: Text(
                              '${(diagnosis['probability'] * 100).toInt()}%',
                              style: TextStyle(
                                color: diagnosis['probability'] > 0.7
                                    ? Colors.red
                                    : diagnosis['probability'] > 0.5
                                        ? Colors.orange
                                        : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              // ...existing code for expansion tile children...
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      diagnosis['description'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Recommended Next Steps:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...List<Widget>.generate(
                                      diagnosis['nextSteps'].length,
                                      (i) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.arrow_right,
                                              size: 16,
                                              color: AppTheme.secondaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                  diagnosis['nextSteps'][i]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // This would save to patient record
                                          },
                                          icon: const Icon(Icons.save),
                                          label: const Text(
                                              'Save to Patient Record'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // This would navigate to prescription screen
                                          },
                                          icon: const Icon(
                                              Icons.medical_services),
                                          label:
                                              const Text('Create Prescription'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
