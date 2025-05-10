import 'package:flutter/material.dart';

class ClinicalDecisionSupportScreen extends StatefulWidget {
  const ClinicalDecisionSupportScreen({super.key});

  @override
  _ClinicalDecisionSupportScreenState createState() =>
      _ClinicalDecisionSupportScreenState();
}

class _ClinicalDecisionSupportScreenState
    extends State<ClinicalDecisionSupportScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  String _selectedDiagnosisCategory = 'Cardiac';
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];

  final List<String> _diagnosisCategories = [
    'Cardiac',
    'Respiratory',
    'Neurological',
    'Gastrointestinal',
    'Musculoskeletal',
    'Dermatological',
    'Endocrine',
    'Infectious Disease',
    'Psychiatric',
    'Other'
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _generateSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock data based on the selected category
    // In a real app, this would come from an API
    setState(() {
      _isLoading = false;

      if (_selectedDiagnosisCategory == 'Cardiac') {
        _suggestions = [
          {
            'title': 'Myocardial Infarction',
            'probability': 0.87,
            'keyIndicators': [
              'Chest pain',
              'Elevated troponin levels',
              'ST-segment elevation'
            ],
            'suggestedTests': ['ECG', 'Cardiac enzymes', 'Coronary angiogram'],
            'recommendedTreatments': [
              'Aspirin',
              'Anticoagulation therapy',
              'Consider PCI'
            ]
          },
          {
            'title': 'Congestive Heart Failure',
            'probability': 0.64,
            'keyIndicators': ['Dyspnea', 'Edema', 'Fatigue'],
            'suggestedTests': ['BNP levels', 'Chest X-ray', 'Echocardiogram'],
            'recommendedTreatments': [
              'ACE inhibitors',
              'Beta blockers',
              'Diuretics'
            ]
          }
        ];
      } else if (_selectedDiagnosisCategory == 'Respiratory') {
        _suggestions = [
          {
            'title': 'Community-Acquired Pneumonia',
            'probability': 0.78,
            'keyIndicators': [
              'Cough with sputum',
              'Fever',
              'Crackles on auscultation'
            ],
            'suggestedTests': [
              'Chest X-ray',
              'Blood cultures',
              'Sputum culture'
            ],
            'recommendedTreatments': [
              'Antibiotics',
              'Oxygen therapy if needed',
              'Bronchodilators'
            ]
          },
          {
            'title': 'Chronic Obstructive Pulmonary Disease Exacerbation',
            'probability': 0.59,
            'keyIndicators': [
              'Increased dyspnea',
              'Increased sputum volume',
              'Sputum purulence'
            ],
            'suggestedTests': [
              'Spirometry',
              'Arterial blood gas',
              'Chest X-ray'
            ],
            'recommendedTreatments': [
              'Bronchodilators',
              'Corticosteroids',
              'Antibiotics if indicated'
            ]
          }
        ];
      } else {
        // Default suggestions for other categories
        _suggestions = [
          {
            'title': 'Further evaluation needed',
            'probability': 0.50,
            'keyIndicators': ['Symptoms require additional assessment'],
            'suggestedTests': [
              'Complete blood count',
              'Basic metabolic panel',
              'Relevant imaging'
            ],
            'recommendedTreatments': [
              'Symptomatic treatment',
              'Follow up in 2-3 days',
              'Specialist referral if no improvement'
            ]
          }
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: const Text(
          'Clinical Decision Support',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clinical Decision Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF050A30),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Patient Symptoms:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF050A30),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _symptomsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Enter patient symptoms and clinical findings...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Category:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF050A30),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDiagnosisCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDiagnosisCategory = newValue!;
                          });
                        },
                        items: _diagnosisCategories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _generateSuggestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8BC0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Generate Recommendations',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Results section
              if (_suggestions.isNotEmpty) ...[
                const Text(
                  'AI-Generated Diagnostic Suggestions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF050A30),
                  ),
                ),
                const SizedBox(height: 16),
                ..._suggestions
                    .map((suggestion) => _buildSuggestionCard(suggestion)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (suggestion['probability'] as double) > 0.7
              ? Colors.orangeAccent
              : Colors.transparent,
          width: (suggestion['probability'] as double) > 0.7 ? 1.5 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    suggestion['title'],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF050A30),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getProbabilityColor(
                        suggestion['probability'] as double),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${(suggestion['probability'] * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Key Indicators:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletList(suggestion['keyIndicators'] as List),
            const SizedBox(height: 16),
            const Text(
              'Suggested Tests:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletList(suggestion['suggestedTests'] as List),
            const SizedBox(height: 16),
            const Text(
              'Recommended Treatments:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletList(suggestion['recommendedTreatments'] as List),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Here you would implement saving this to patient's record
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to patient record')),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add to Record'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E8BC0),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Here you would implement sharing this with a colleague
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share feature coming soon')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8BC0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletList(List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(item)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Color _getProbabilityColor(double probability) {
    if (probability > 0.8) {
      return Colors.redAccent;
    } else if (probability > 0.6) {
      return Colors.orangeAccent;
    } else {
      return Colors.blueAccent;
    }
  }
}
