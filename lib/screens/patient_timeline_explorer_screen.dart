import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../theme/app_theme.dart';

class PatientTimelineExplorerScreen extends StatefulWidget {
  final String? patientId;

  const PatientTimelineExplorerScreen({
    super.key,
    this.patientId,
  });

  @override
  State<PatientTimelineExplorerScreen> createState() =>
      _PatientTimelineExplorerScreenState();
}

class _PatientTimelineExplorerScreenState
    extends State<PatientTimelineExplorerScreen> {
  // Timeline zoom level - from 0.5 (zoomed out) to 2.0 (zoomed in)
  double _zoomLevel = 1.0;
  String _selectedPeriod = 'All Time';
  String _selectedCategory = 'All Events';

  // Mock data
  final List<Map<String, dynamic>> _timelineEvents = [
    {
      'date': DateTime.now().subtract(const Duration(days: 370)),
      'title': 'Initial Consultation',
      'description': 'First visit for persistent cough and fatigue',
      'category': 'Visit',
      'doctor': 'Dr. Emma Johnson',
      'location': 'Main Hospital Clinic',
      'notes':
          'Patient presented with symptoms of persistent cough, fatigue, and mild chest pain. Ordered chest X-ray and blood tests.',
      'attachments': ['Initial Consultation Report', 'Doctor Notes'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 365)),
      'title': 'Chest X-Ray',
      'description': 'Radiological examination of lungs',
      'category': 'Radiology',
      'doctor': 'Dr. Michael Chen',
      'location': 'Imaging Department',
      'notes':
          'Chest X-ray showed mild infiltrates in the lower right lobe, suspicious for early pneumonia.',
      'attachments': ['X-Ray Image', 'Radiology Report'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 358)),
      'title': 'Diagnosis: Pneumonia',
      'description': 'Confirmed community-acquired pneumonia',
      'category': 'Diagnosis',
      'doctor': 'Dr. Emma Johnson',
      'location': 'Main Hospital Clinic',
      'notes':
          'Based on radiological findings and symptoms, diagnosed with community-acquired pneumonia. Prescribed amoxicillin 500mg three times daily for 10 days.',
      'attachments': ['Diagnosis Report'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 345)),
      'title': 'Follow-up Visit',
      'description': 'Assessment of treatment efficacy',
      'category': 'Visit',
      'doctor': 'Dr. Emma Johnson',
      'location': 'Main Hospital Clinic',
      'notes':
          'Patient showing good response to antibiotic therapy. Symptoms mostly resolved. Recommended completing full course of antibiotics.',
      'attachments': ['Follow-up Report'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 180)),
      'title': 'Annual Physical',
      'description': 'Comprehensive health check',
      'category': 'Visit',
      'doctor': 'Dr. Emma Johnson',
      'location': 'Main Hospital Clinic',
      'notes':
          'General health good. Blood pressure slightly elevated (138/88). Recommended diet modifications and increased physical activity.',
      'attachments': ['Physical Exam Report', 'Lab Results'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 90)),
      'title': 'Medication Adjustment',
      'description': 'Hypertension medication prescribed',
      'category': 'Prescription',
      'doctor': 'Dr. Emma Johnson',
      'location': 'Telemedicine Consultation',
      'notes':
          'Based on home blood pressure monitoring, prescribed lisinopril 10mg daily for hypertension management.',
      'attachments': ['Prescription Details', 'Blood Pressure Log'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'title': 'Blood Tests',
      'description': 'Complete blood count and metabolic panel',
      'category': 'Laboratory',
      'doctor': 'Dr. Robert Smith',
      'location': 'Medical Laboratory',
      'notes':
          'All values within normal range except slightly elevated cholesterol (215 mg/dL).',
      'attachments': ['Lab Results PDF'],
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'title': 'Telemedicine Follow-up',
      'description': 'Review of recent test results',
      'category': 'Visit',
      'doctor': 'Dr. Emma Johnson',
      'location': 'Telemedicine Consultation',
      'notes':
          'Discussed cholesterol management through diet. Blood pressure improved on medication (125/80). Continue current regimen and recheck in 3 months.',
      'attachments': ['Consultation Summary', 'Dietary Guidelines'],
    },
  ];

  // Filtered list of events based on selected period and category
  List<Map<String, dynamic>> get _filteredEvents {
    return _timelineEvents.where((event) {
      // Filter by time period
      if (_selectedPeriod == 'Last Month') {
        if (event['date']
            .isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
          return false;
        }
      } else if (_selectedPeriod == 'Last 3 Months') {
        if (event['date']
            .isBefore(DateTime.now().subtract(const Duration(days: 90)))) {
          return false;
        }
      } else if (_selectedPeriod == 'Last 6 Months') {
        if (event['date']
            .isBefore(DateTime.now().subtract(const Duration(days: 180)))) {
          return false;
        }
      } else if (_selectedPeriod == 'Last Year') {
        if (event['date']
            .isBefore(DateTime.now().subtract(const Duration(days: 365)))) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != 'All Events' &&
          event['category'] != _selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get unique categories for filter dropdown
  List<String> get _categories {
    final Set<String> categories = {'All Events'};
    for (final event in _timelineEvents) {
      categories.add(event['category'] as String);
    }
    return categories.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Timeline Explorer'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Patient info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('assets/avatar-des-utilisateurs.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sarah Johnson', // This would be dynamic in a real app
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'DOB: 05/12/1985 • ID: ${widget.patientId ?? '012345'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Chip(
                  label: const Text('Active Patient'),
                  avatar: const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Filters and controls
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Time period and category filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: InputDecoration(
                          labelText: 'Time Period',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          'All Time',
                          'Last Month',
                          'Last 3 Months',
                          'Last 6 Months',
                          'Last Year',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedPeriod = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Event Type',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: _categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Zoom control
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.zoom_out),
                    Expanded(
                      child: Slider(
                        value: _zoomLevel,
                        min: 0.5,
                        max: 2.0,
                        divisions: 6,
                        label: 'Zoom: ${_zoomLevel.toStringAsFixed(1)}x',
                        onChanged: (value) {
                          setState(() {
                            _zoomLevel = value;
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.zoom_in),
                  ],
                ),
              ],
            ),
          ),

          // Timeline
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timeline_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No events found for this time period',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      final bool isFirst = index == 0;
                      final bool isLast = index == _filteredEvents.length - 1;

                      return SizedBox(
                        height: 140 *
                            _zoomLevel, // Apply zoom level to adjust space
                        child: TimelineTile(
                          isFirst: isFirst,
                          isLast: isLast,
                          alignment: TimelineAlign.manual,
                          lineXY: 0.15,
                          indicatorStyle: IndicatorStyle(
                            width: 20,
                            height: 20,
                            indicator: _buildIndicator(event['category']),
                            drawGap: true,
                          ),
                          beforeLineStyle: LineStyle(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            thickness: 2,
                          ),
                          afterLineStyle: LineStyle(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            thickness: 2,
                          ),
                          endChild: _buildEventCard(event),
                          startChild: Center(
                            child: Text(
                              _formatDate(event['date']),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    12 * _zoomLevel, // Apply zoom to text size
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // This would navigate to an add event screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add new event functionality coming soon')),
          );
        },
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildIndicator(String category) {
    IconData icon;
    Color color;

    switch (category) {
      case 'Visit':
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'Radiology':
        icon = Icons.image;
        color = Colors.purple;
        break;
      case 'Laboratory':
        icon = Icons.science;
        color = Colors.amber;
        break;
      case 'Diagnosis':
        icon = Icons.find_in_page;
        color = Colors.red;
        break;
      case 'Prescription':
        icon = Icons.medication;
        color = Colors.green;
        break;
      default:
        icon = Icons.event_note;
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * _zoomLevel, // Apply zoom to text size
                    ),
                  ),
                  Chip(
                    label: Text(
                      event['category'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10 * _zoomLevel, // Apply zoom to text size
                      ),
                    ),
                    backgroundColor: _getCategoryColor(event['category']),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                event['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12 * _zoomLevel, // Apply zoom to text size
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 12 * _zoomLevel,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['doctor'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11 * _zoomLevel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on,
                    size: 12 * _zoomLevel,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event['location'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11 * _zoomLevel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Visit':
        return Colors.blue;
      case 'Radiology':
        return Colors.purple;
      case 'Laboratory':
        return Colors.amber;
      case 'Diagnosis':
        return Colors.red;
      case 'Prescription':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _getCategoryColor(event['category']).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(event['category']),
                    color: _getCategoryColor(event['category']),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(event['date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    event['category'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getCategoryColor(event['category']),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(
                Icons.description, 'Description', event['description']),
            _buildDetailRow(Icons.person, 'Doctor', event['doctor']),
            _buildDetailRow(Icons.location_on, 'Location', event['location']),
            _buildDetailRow(Icons.note, 'Notes', event['notes']),
            const SizedBox(height: 16),
            const Text(
              'Attachments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              event['attachments'].length,
              (index) => ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(event['attachments'][index]),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // Download functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Downloading ${event['attachments'][index]}...')),
                    );
                  },
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit functionality
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Share functionality
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width -
                    70, // Adjust width to avoid overflow
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Visit':
        return Icons.medical_services;
      case 'Radiology':
        return Icons.image;
      case 'Laboratory':
        return Icons.science;
      case 'Diagnosis':
        return Icons.find_in_page;
      case 'Prescription':
        return Icons.medication;
      default:
        return Icons.event_note;
    }
  }
}
