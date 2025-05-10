import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _labResults = [];
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyFlagged = false;
  final ScrollController _scrollController = ScrollController();

  // Test categories for filtering
  final List<String> _categories = [
    'All',
    'Blood Tests',
    'Urinalysis',
    'Imaging',
    'Respiratory',
    'Cardiac',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadLabResults();
  }

  Future<void> _loadLabResults() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Mock data for lab results
    final mockResults = [
      {
        'id': '1',
        'name': 'Complete Blood Count (CBC)',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'category': 'Blood Tests',
        'status': 'Completed',
        'requestedBy': 'Dr. Sarah Johnson',
        'facility': 'Downtown Medical Lab',
        'isFlagged': true,
        'resultsUrl': 'https://example.com/results/cbc12345',
        'values': [
          {
            'name': 'White Blood Cell Count (WBC)',
            'value': '12.5',
            'unit': 'K/µL',
            'range': '4.5-11.0',
            'status': 'High',
          },
          {
            'name': 'Red Blood Cell Count (RBC)',
            'value': '4.8',
            'unit': 'M/µL',
            'range': '4.5-5.9',
            'status': 'Normal',
          },
          {
            'name': 'Hemoglobin (Hgb)',
            'value': '14.2',
            'unit': 'g/dL',
            'range': '13.5-17.5',
            'status': 'Normal',
          },
          {
            'name': 'Hematocrit (Hct)',
            'value': '42',
            'unit': '%',
            'range': '41-50',
            'status': 'Normal',
          },
          {
            'name': 'Platelet Count',
            'value': '350',
            'unit': 'K/µL',
            'range': '150-450',
            'status': 'Normal',
          },
        ]
      },
      {
        'id': '2',
        'name': 'Comprehensive Metabolic Panel (CMP)',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'category': 'Blood Tests',
        'status': 'Completed',
        'requestedBy': 'Dr. Sarah Johnson',
        'facility': 'Downtown Medical Lab',
        'isFlagged': false,
        'resultsUrl': 'https://example.com/results/cmp12345',
        'values': [
          {
            'name': 'Sodium',
            'value': '140',
            'unit': 'mmol/L',
            'range': '135-145',
            'status': 'Normal',
          },
          {
            'name': 'Potassium',
            'value': '4.0',
            'unit': 'mmol/L',
            'range': '3.5-5.0',
            'status': 'Normal',
          },
          {
            'name': 'Chloride',
            'value': '102',
            'unit': 'mmol/L',
            'range': '98-107',
            'status': 'Normal',
          },
          {
            'name': 'CO2 (Carbon Dioxide)',
            'value': '23',
            'unit': 'mmol/L',
            'range': '23-29',
            'status': 'Normal',
          },
          {
            'name': 'BUN (Blood Urea Nitrogen)',
            'value': '15',
            'unit': 'mg/dL',
            'range': '7-20',
            'status': 'Normal',
          },
          {
            'name': 'Creatinine',
            'value': '0.9',
            'unit': 'mg/dL',
            'range': '0.6-1.2',
            'status': 'Normal',
          },
          {
            'name': 'Glucose',
            'value': '95',
            'unit': 'mg/dL',
            'range': '70-99',
            'status': 'Normal',
          },
          {
            'name': 'Calcium',
            'value': '9.5',
            'unit': 'mg/dL',
            'range': '8.5-10.2',
            'status': 'Normal',
          },
        ]
      },
      {
        'id': '3',
        'name': 'Pulmonary Function Test',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'category': 'Respiratory',
        'status': 'Completed',
        'requestedBy': 'Dr. Robert Chen',
        'facility': 'Respiratory Care Center',
        'isFlagged': true,
        'resultsUrl': 'https://example.com/results/pft12345',
        'values': [
          {
            'name': 'FEV1',
            'value': '65',
            'unit': '% predicted',
            'range': '≥80',
            'status': 'Low',
          },
          {
            'name': 'FVC',
            'value': '70',
            'unit': '% predicted',
            'range': '≥80',
            'status': 'Low',
          },
          {
            'name': 'FEV1/FVC',
            'value': '0.68',
            'unit': 'ratio',
            'range': '≥0.7',
            'status': 'Low',
          },
          {
            'name': 'DLCO (Diffusing Capacity)',
            'value': '75',
            'unit': '% predicted',
            'range': '≥80',
            'status': 'Low',
          },
        ]
      },
      {
        'id': '4',
        'name': 'Urinalysis',
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'category': 'Urinalysis',
        'status': 'Completed',
        'requestedBy': 'Dr. Emily Rodriguez',
        'facility': 'Downtown Medical Lab',
        'isFlagged': false,
        'resultsUrl': 'https://example.com/results/ua12345',
        'values': [
          {
            'name': 'Color',
            'value': 'Yellow',
            'unit': '',
            'range': 'Yellow',
            'status': 'Normal',
          },
          {
            'name': 'Clarity',
            'value': 'Clear',
            'unit': '',
            'range': 'Clear',
            'status': 'Normal',
          },
          {
            'name': 'pH',
            'value': '6.0',
            'unit': '',
            'range': '5.0-8.0',
            'status': 'Normal',
          },
          {
            'name': 'Specific Gravity',
            'value': '1.020',
            'unit': '',
            'range': '1.005-1.030',
            'status': 'Normal',
          },
          {
            'name': 'Glucose',
            'value': 'Negative',
            'unit': '',
            'range': 'Negative',
            'status': 'Normal',
          },
          {
            'name': 'Protein',
            'value': 'Negative',
            'unit': '',
            'range': 'Negative',
            'status': 'Normal',
          },
        ]
      },
      {
        'id': '5',
        'name': 'Chest X-Ray',
        'date': DateTime.now().subtract(const Duration(days: 45)),
        'category': 'Imaging',
        'status': 'Completed',
        'requestedBy': 'Dr. Sarah Johnson',
        'facility': 'Central Radiology',
        'isFlagged': false,
        'resultsUrl': 'https://example.com/results/cxr12345',
        'values': [
          {
            'name': 'Impression',
            'value':
                'No acute cardiopulmonary process. Stable appearance of hyperinflated lungs consistent with known COPD.',
            'unit': '',
            'range': '',
            'status': 'N/A',
          },
        ]
      },
      {
        'id': '6',
        'name': 'Arterial Blood Gas (ABG)',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'category': 'Respiratory',
        'status': 'Completed',
        'requestedBy': 'Dr. Robert Chen',
        'facility': 'Pulmonology Lab',
        'isFlagged': true,
        'resultsUrl': 'https://example.com/results/abg12345',
        'values': [
          {
            'name': 'pH',
            'value': '7.36',
            'unit': '',
            'range': '7.35-7.45',
            'status': 'Normal',
          },
          {
            'name': 'PaCO2',
            'value': '48',
            'unit': 'mmHg',
            'range': '35-45',
            'status': 'High',
          },
          {
            'name': 'PaO2',
            'value': '74',
            'unit': 'mmHg',
            'range': '80-100',
            'status': 'Low',
          },
          {
            'name': 'HCO3',
            'value': '26',
            'unit': 'mEq/L',
            'range': '22-26',
            'status': 'Normal',
          },
          {
            'name': 'SaO2',
            'value': '92',
            'unit': '%',
            'range': '≥95',
            'status': 'Low',
          },
        ]
      },
      {
        'id': '7',
        'name': 'Lipid Panel',
        'date': DateTime.now().subtract(const Duration(days: 90)),
        'category': 'Blood Tests',
        'status': 'Completed',
        'requestedBy': 'Dr. Emily Rodriguez',
        'facility': 'Downtown Medical Lab',
        'isFlagged': true,
        'resultsUrl': 'https://example.com/results/lipid12345',
        'values': [
          {
            'name': 'Total Cholesterol',
            'value': '220',
            'unit': 'mg/dL',
            'range': '<200',
            'status': 'High',
          },
          {
            'name': 'LDL Cholesterol',
            'value': '140',
            'unit': 'mg/dL',
            'range': '<100',
            'status': 'High',
          },
          {
            'name': 'HDL Cholesterol',
            'value': '45',
            'unit': 'mg/dL',
            'range': '≥60',
            'status': 'Low',
          },
          {
            'name': 'Triglycerides',
            'value': '180',
            'unit': 'mg/dL',
            'range': '<150',
            'status': 'High',
          },
        ]
      },
    ];

    setState(() {
      _labResults = mockResults;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredResults {
    return _labResults.where((result) {
      // Apply category filter
      if (_selectedFilter != 'All' && result['category'] != _selectedFilter) {
        return false;
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        final resultName = result['name'].toString().toLowerCase();
        final requestedBy = result['requestedBy'].toString().toLowerCase();
        if (!resultName.contains(searchTerm) &&
            !requestedBy.contains(searchTerm)) {
          return false;
        }
      }

      // Apply flagged filter
      if (_showOnlyFlagged && !result['isFlagged']) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lab Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _downloadAllResults();
            },
            tooltip: 'Download All Results',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilters(),
                const Divider(height: 1),
                Expanded(
                  child: _filteredResults.isEmpty
                      ? _buildNoResultsMessage()
                      : _buildResultsList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showRequestTestDialog();
        },
        label: const Text('Request Test'),
        icon: const Icon(Icons.add),
        tooltip: 'Request a new lab test',
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search lab tests...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Filter by:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedFilter == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = category;
                            });
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Show flagged results only'),
              const Spacer(),
              Switch(
                value: _showOnlyFlagged,
                onChanged: (value) {
                  setState(() {
                    _showOnlyFlagged = value;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Showing ${_filteredResults.length} of ${_labResults.length} results',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No lab results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: result['isFlagged']
            ? BorderSide(color: Colors.red.shade300, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          _showResultDetails(result);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(result['category'])
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result['category'],
                      style: TextStyle(
                        color: _getCategoryColor(result['category']),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (result['isFlagged'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.red[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Flagged',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, yyyy').format(result['date']),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      result['requestedBy'],
                      style: TextStyle(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    onPressed: () {
                      _showResultDetails(result);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    onPressed: () {
                      _downloadResult(result);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 800,
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('MMM d, yyyy').format(result['date'])} • ${result['category']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      if (result['isFlagged'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.flag, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Flagged',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection('Test Information', [
                          {
                            'label': 'Requested By',
                            'value': result['requestedBy'],
                            'icon': Icons.person,
                          },
                          {
                            'label': 'Facility',
                            'value': result['facility'],
                            'icon': Icons.business,
                          },
                          {
                            'label': 'Date',
                            'value': DateFormat('MMMM d, yyyy')
                                .format(result['date']),
                            'icon': Icons.calendar_today,
                          },
                          {
                            'label': 'Status',
                            'value': result['status'],
                            'icon': Icons.check_circle,
                          },
                        ]),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildResultsTable(result['values']),
                        const SizedBox(height: 24),
                        if (result['category'] == 'Imaging') ...[
                          const Text(
                            'Images',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildImagePlaceholder(),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share with Doctor'),
                        onPressed: () {
                          context.pop();
                          _shareResults(result);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download PDF'),
                        onPressed: () {
                          context.pop();
                          _downloadResult(result);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          item['value'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsTable(List<dynamic> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey[300]!),
              ),
              columns: const [
                DataColumn(label: Text('Test')),
                DataColumn(label: Text('Result')),
                DataColumn(label: Text('Units')),
                DataColumn(label: Text('Reference Range')),
                DataColumn(label: Text('Status')),
              ],
              rows: values.map((value) {
                return DataRow(cells: [
                  DataCell(Text(value['name'])),
                  DataCell(Text(
                    value['value'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(value['status']),
                    ),
                  )),
                  DataCell(Text(value['unit'] ?? '')),
                  DataCell(Text(value['range'] ?? '')),
                  DataCell(_buildStatusCell(value['status'])),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCell(String status) {
    if (status == 'Normal' || status == 'N/A') {
      return Row(
        children: [
          Icon(
            status == 'Normal'
                ? Icons.check_circle
                : Icons.remove_circle_outline,
            color: status == 'Normal' ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: status == 'Normal' ? Colors.green : Colors.grey,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            status == 'High' ? Icons.arrow_upward : Icons.arrow_downward,
            color: status == 'High' ? Colors.red : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: status == 'High' ? Colors.red : Colors.orange,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'X-Ray Image',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image viewer coming soon!')),
                );
              },
              child: const Text('View Full Size'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Lab Results'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Understanding Your Results',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '• Normal: Values within the expected range for healthy individuals.',
                ),
                Text(
                  '• High: Values above the reference range. May require attention.',
                ),
                Text(
                  '• Low: Values below the reference range. May require attention.',
                ),
                SizedBox(height: 16),
                Text(
                  'Flagged Results',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Tests marked as "Flagged" have values that may need medical attention. Please consult with your healthcare provider about any concerns.',
                ),
                SizedBox(height: 16),
                Text(
                  'Contact your doctor if you have questions about your lab results or if you need assistance interpreting them.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showRequestTestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request a Lab Test'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Contact your doctor to request a new lab test.'),
                SizedBox(height: 16),
                Text(
                  'Note: Most lab tests require a doctor\'s order. You can use the "Contact Doctor" feature to request needed tests.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                context.pushNamed('/contact-doctor');
              },
              child: const Text('Contact Doctor'),
            ),
          ],
        );
      },
    );
  }

  void _downloadResult(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${result['name']} results...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadAllResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading all lab results as a ZIP file...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareResults(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${result['name']} results...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Blood Tests':
        return Colors.red;
      case 'Urinalysis':
        return Colors.amber;
      case 'Imaging':
        return Colors.blue;
      case 'Respiratory':
        return Colors.teal;
      case 'Cardiac':
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.orange[700]!;
      case 'Normal':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }
}
