import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:go_router/go_router.dart';

class TreatmentTimelineScreen extends StatefulWidget {
  final String patientId;

  const TreatmentTimelineScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<TreatmentTimelineScreen> createState() =>
      _TreatmentTimelineScreenState();
}

class _TreatmentTimelineScreenState extends State<TreatmentTimelineScreen> {
  final _searchController = TextEditingController();
  String _filterCategory = 'All';
  bool _showOnlyImportant = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _timelineEvents = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  void _loadPatientData() async {
    // Simulating data loading from API
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for the treatment timeline
    final mockEvents = [
      {
        'id': '1',
        'title': 'Initial Diagnosis',
        'description':
            'Diagnosed with moderate chronic obstructive pulmonary disease (COPD)',
        'date': DateTime.now().subtract(const Duration(days: 180)),
        'category': 'Diagnosis',
        'isImportant': true,
        'doctor': 'Dr. Sarah Johnson',
        'location': 'Pulmonology Department',
        'attachments': 2,
        'notes':
            'Patient presented with persistent cough, shortness of breath, and fatigue.',
        'recommendations':
            'Prescribed bronchodilators and recommended lifestyle changes.',
      },
      {
        'id': '2',
        'title': 'Medication Started',
        'description': 'Started on Advair Diskus 250/50 twice daily',
        'date': DateTime.now().subtract(const Duration(days: 175)),
        'category': 'Medication',
        'isImportant': true,
        'doctor': 'Dr. Sarah Johnson',
        'location': 'Outpatient Clinic',
        'attachments': 1,
        'notes': 'Patient educated on proper inhaler technique.',
        'recommendations': 'Follow up in 4 weeks to assess efficacy.',
      },
      {
        'id': '3',
        'title': 'Pulmonary Function Test',
        'description': 'FEV1 65% of predicted, FVC 80% of predicted',
        'date': DateTime.now().subtract(const Duration(days: 160)),
        'category': 'Test',
        'isImportant': false,
        'doctor': 'Dr. Michael Rodriguez',
        'location': 'Respiratory Lab',
        'attachments': 3,
        'notes':
            'Results confirm moderate airflow obstruction consistent with COPD.',
        'recommendations': 'Continue current treatment plan.',
      },
      {
        'id': '4',
        'title': 'Follow-up Appointment',
        'description': 'Patient reports improvement in symptoms',
        'date': DateTime.now().subtract(const Duration(days: 145)),
        'category': 'Visit',
        'isImportant': false,
        'doctor': 'Dr. Sarah Johnson',
        'location': 'Outpatient Clinic',
        'attachments': 0,
        'notes': 'Patient reports improved breathing and exercise capacity.',
        'recommendations':
            'Continue medication, add pulmonary rehabilitation program.',
      },
      {
        'id': '5',
        'title': 'COPD Exacerbation',
        'description':
            'Admitted for acute exacerbation requiring oxygen therapy',
        'date': DateTime.now().subtract(const Duration(days: 120)),
        'category': 'Hospitalization',
        'isImportant': true,
        'doctor': 'Dr. Robert Chen',
        'location': 'Emergency Department',
        'attachments': 5,
        'notes':
            'Admitted with severe shortness of breath, wheezing, and respiratory distress.',
        'recommendations':
            'IV steroids, antibiotics, and intensified bronchodilator therapy.',
      },
      {
        'id': '6',
        'title': 'Chest X-Ray',
        'description': 'Showed hyperinflation and flattened diaphragms',
        'date': DateTime.now().subtract(const Duration(days: 119)),
        'category': 'Imaging',
        'isImportant': false,
        'doctor': 'Dr. Emily Wilson',
        'location': 'Radiology Department',
        'attachments': 2,
        'notes': 'Findings consistent with COPD, no evidence of pneumonia.',
        'recommendations': 'Follow up imaging in 6 months.',
      },
      {
        'id': '7',
        'title': 'Hospital Discharge',
        'description': 'Discharged after 6 days with improved symptoms',
        'date': DateTime.now().subtract(const Duration(days: 114)),
        'category': 'Hospitalization',
        'isImportant': true,
        'doctor': 'Dr. Robert Chen',
        'location': 'Pulmonary Ward',
        'attachments': 4,
        'notes':
            'Symptoms improved substantially. Patient able to ambulate without oxygen.',
        'recommendations':
            'Resume home medications with addition of oral steroids taper.',
      },
      {
        'id': '8',
        'title': 'Started Pulmonary Rehabilitation',
        'description': '12-week program focusing on exercise and education',
        'date': DateTime.now().subtract(const Duration(days: 100)),
        'category': 'Therapy',
        'isImportant': false,
        'doctor': 'Dr. Lisa Park',
        'location': 'Rehabilitation Center',
        'attachments': 1,
        'notes': 'Initial assessment showed moderate exercise limitation.',
        'recommendations': 'Attend sessions twice weekly for 12 weeks.',
      },
      {
        'id': '9',
        'title': 'Medication Adjustment',
        'description': 'Added Spiriva Respimat 2.5mcg daily',
        'date': DateTime.now().subtract(const Duration(days: 90)),
        'category': 'Medication',
        'isImportant': true,
        'doctor': 'Dr. Sarah Johnson',
        'location': 'Outpatient Clinic',
        'attachments': 1,
        'notes':
            'Added long-acting anticholinergic to improve symptom control.',
        'recommendations': 'Continue all other medications unchanged.',
      },
      {
        'id': '10',
        'title': 'Follow-up PFTs',
        'description': 'FEV1 improved to 70% of predicted',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'category': 'Test',
        'isImportant': false,
        'doctor': 'Dr. Michael Rodriguez',
        'location': 'Respiratory Lab',
        'attachments': 3,
        'notes': 'Shows modest improvement in pulmonary function.',
        'recommendations': 'Continue current treatment regimen.',
      },
      {
        'id': '11',
        'title': 'Annual Influenza Vaccination',
        'description': 'Administered quadrivalent flu vaccine',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'category': 'Vaccination',
        'isImportant': false,
        'doctor': 'Dr. Nicole Brady',
        'location': 'Primary Care Clinic',
        'attachments': 0,
        'notes': 'No adverse reactions reported.',
        'recommendations': 'Continue annual influenza vaccination.',
      },
      {
        'id': '12',
        'title': 'Recent Evaluation',
        'description': 'Comprehensive assessment of COPD management',
        'date': DateTime.now().subtract(const Duration(days: 14)),
        'category': 'Visit',
        'isImportant': true,
        'doctor': 'Dr. Sarah Johnson',
        'location': 'Outpatient Clinic',
        'attachments': 2,
        'notes': 'Patient reports good symptom control with current regimen.',
        'recommendations':
            'Continue current medications, complete pulmonary rehabilitation.',
      },
    ];

    setState(() {
      _timelineEvents = mockEvents;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredEvents {
    return _timelineEvents.where((event) {
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        if (!event['title'].toLowerCase().contains(searchTerm) &&
            !event['description'].toLowerCase().contains(searchTerm)) {
          return false;
        }
      }

      // Apply category filter
      if (_filterCategory != 'All' && event['category'] != _filterCategory) {
        return false;
      }

      // Apply importance filter
      if (_showOnlyImportant && !event['isImportant']) {
        return false;
      }

      return true;
    }).toList();
  }

  List<String> get _availableCategories {
    final categories =
        _timelineEvents.map((e) => e['category'] as String).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Treatment Timeline',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              _printTimeline();
            },
            tooltip: 'Print Timeline',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareTimeline();
            },
            tooltip: 'Share Timeline',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildPatientHeader(),
                  _buildFilters(),
                  Expanded(
                    child: _filteredEvents.isEmpty
                        ? _buildNoEventsMessage()
                        : _buildTimeline(),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog();
        },
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPatientHeader() {
    final patientInfo = {
      'name': 'John Smith',
      'id': widget.patientId == 'all' ? 'P10023' : widget.patientId,
      'age': 62,
      'gender': 'Male',
      'primaryDiagnosis': 'COPD, Stage 2',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientInfo['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${patientInfo['id']} | Age: ${patientInfo['age']} | ${patientInfo['gender']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        patientInfo['primaryDiagnosis'] as String,
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Full History'),
                onPressed: () {
                  context.pushNamed(
                    '/patient-history/${patientInfo['id']}',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search timeline...',
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
          LayoutBuilder(builder: (context, constraints) {
            // Check if we should stack the filters vertically when width is limited
            final isNarrow = constraints.maxWidth < 600;

            return isNarrow
                ? Column(
                    children: [
                      _buildCategoryFilter(),
                      const SizedBox(height: 12),
                      _buildImportantEventsFilter(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildCategoryFilter()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildImportantEventsFilter()),
                    ],
                  );
          }),
          const SizedBox(height: 8),
          Text(
            'Showing ${_filteredEvents.length} of ${_timelineEvents.length} events',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _filterCategory,
          items: _availableCategories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _filterCategory = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildImportantEventsFilter() {
    return InkWell(
      onTap: () {
        setState(() {
          _showOnlyImportant = !_showOnlyImportant;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: _showOnlyImportant
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _showOnlyImportant ? Icons.star : Icons.star_outline,
              color: _showOnlyImportant
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Important Events',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Switch(
              value: _showOnlyImportant,
              onChanged: (value) {
                setState(() {
                  _showOnlyImportant = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoEventsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No events found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final filteredEvents = _filteredEvents;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final isFirst = index == 0;
        final isLast = index == filteredEvents.length - 1;

        return TimelineTile(
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: _getCategoryColor(event['category']),
            iconStyle: IconStyle(
              color: Colors.white,
              iconData: _getCategoryIcon(event['category']),
              fontSize: 16,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: Colors.grey[300]!,
          ),
          endChild: _buildEventCard(event),
          startChild: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              DateFormat('MMM d, yyyy').format(event['date']),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          alignment: TimelineAlign.manual,
          lineXY: 0.2,
        );
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(left: 16, bottom: 16, top: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: event['isImportant']
            ? BorderSide(color: _getCategoryColor(event['category']), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          _showEventDetails(event);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event['category'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event['category'] as String,
                        style: TextStyle(
                          color: _getCategoryColor(event['category']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (event['isImportant'])
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                event['description'] as String,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event['doctor'] as String,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if ((event['attachments'] as int) > 0) ...[
                    const Icon(Icons.attach_file, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${event['attachments']} attachments',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: screenWidth > 600 ? 500 : screenWidth * 0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(event['category'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event['category'] as String,
                            style: TextStyle(
                              color: _getCategoryColor(event['category']),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (event['isImportant'])
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Important',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Divider(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDetailRow(Icons.calendar_today, 'Date',
                              DateFormat.yMMMd().format(event['date'])),
                          _buildDetailRow(Icons.description, 'Description',
                              event['description']),
                          _buildDetailRow(
                              Icons.person, 'Doctor', event['doctor']),
                          _buildDetailRow(
                              Icons.location_on, 'Location', event['location']),
                          const Divider(),
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event['notes'] as String,
                            softWrap: true,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Recommendations',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event['recommendations'] as String,
                            softWrap: true,
                          ),
                          if ((event['attachments'] as int) > 0) ...[
                            const Divider(),
                            _buildDetailRow(Icons.attach_file, 'Attachments',
                                '${event['attachments']} document(s)'),
                            TextButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('View Attachments'),
                              onPressed: () {
                                // Show attachments
                                context.pop();
                                _viewAttachments(event);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {
                          context.pop();
                          _showEditEventDialog(event);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Event'),
          content: const Text(
              'This function will allow adding a new event to the treatment timeline.'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feature coming soon!'),
                  ),
                );
              },
              child: const Text('Add Event'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    // This would be implemented to edit events
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing event: ${event['title']}'),
      ),
    );
  }

  void _viewAttachments(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Viewing ${event['attachments']} attachments for: ${event['title']}'),
      ),
    );
  }

  void _printTimeline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing timeline...'),
      ),
    );
  }

  void _shareTimeline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing timeline...'),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Diagnosis':
        return Colors.purple;
      case 'Medication':
        return Colors.blue;
      case 'Test':
        return Colors.teal;
      case 'Visit':
        return Colors.green;
      case 'Hospitalization':
        return Colors.red;
      case 'Imaging':
        return Colors.orange;
      case 'Therapy':
        return Colors.indigo;
      case 'Vaccination':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Diagnosis':
        return Icons.medical_information;
      case 'Medication':
        return Icons.medication;
      case 'Test':
        return Icons.science;
      case 'Visit':
        return Icons.event_note;
      case 'Hospitalization':
        return Icons.local_hospital;
      case 'Imaging':
        return Icons.image;
      case 'Therapy':
        return Icons.healing;
      case 'Vaccination':
        return Icons.vaccines;
      default:
        return Icons.event;
    }
  }
}
