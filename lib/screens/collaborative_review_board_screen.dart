import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class CollaborativeReviewBoardScreen extends StatefulWidget {
  const CollaborativeReviewBoardScreen({super.key});

  @override
  State<CollaborativeReviewBoardScreen> createState() =>
      _CollaborativeReviewBoardScreenState();
}

class _CollaborativeReviewBoardScreenState
    extends State<CollaborativeReviewBoardScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _pendingCases = [];
  final List<Map<String, dynamic>> _activeSessions = [];
  final List<Map<String, dynamic>> _colleagues = [];
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Simulate loading data
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for demonstration
    final cases = List.generate(
      10,
      (index) => {
        'id': 'CASE-${1000 + index}',
        'patientName': _getRandomPatientName(),
        'patientAge': 30 + math.Random().nextInt(50),
        'studyType': _getRandomStudyType(),
        'priority': _getRandomPriority(),
        'submittedBy': _getRandomDoctorName(),
        'submissionDate':
            DateTime.now().subtract(Duration(days: math.Random().nextInt(7))),
        'description':
            'Complex case requiring collaborative review and interpretation.',
        'imageUrl': 'assets/images/sample_scan_${index % 5 + 1}.jpg',
        'status': index < 3 ? 'In Progress' : 'Pending',
      },
    );

    final sessions = [
      {
        'id': 'SESSION-1001',
        'title': 'Chest X-ray Interpretation - Challenging Cases',
        'host': 'Dr. Sarah Johnson',
        'participants': 5,
        'startTime': DateTime.now().add(const Duration(minutes: 30)),
        'duration': '60 minutes',
        'caseCount': 3,
        'status': 'Upcoming',
      },
      {
        'id': 'SESSION-1002',
        'title': 'Neuro MRI Weekly Review',
        'host': 'Dr. Michael Chen',
        'participants': 8,
        'startTime': DateTime.now().add(const Duration(hours: 2)),
        'duration': '90 minutes',
        'caseCount': 6,
        'status': 'Upcoming',
      },
      {
        'id': 'SESSION-1003',
        'title': 'Pediatric Radiology Consult',
        'host': 'Dr. Lisa Wong',
        'participants': 4,
        'inProgress': true,
        'startTime': DateTime.now().subtract(const Duration(minutes: 15)),
        'duration': '45 minutes',
        'caseCount': 2,
        'status': 'In Progress',
      },
    ];

    final colleagues = [
      {
        'id': 'RAD-1001',
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Neuroradiology',
        'hospital': 'University Medical Center',
        'imageUrl': 'assets/images/doctor1.jpg',
        'isOnline': true,
      },
      {
        'id': 'RAD-1002',
        'name': 'Dr. Michael Chen',
        'specialty': 'Musculoskeletal Radiology',
        'hospital': 'Central Hospital',
        'imageUrl': 'assets/images/doctor2.jpg',
        'isOnline': true,
      },
      {
        'id': 'RAD-1003',
        'name': 'Dr. Lisa Wong',
        'specialty': 'Pediatric Radiology',
        'hospital': 'Children\'s Hospital',
        'imageUrl': 'assets/images/doctor3.jpg',
        'isOnline': false,
      },
      {
        'id': 'RAD-1004',
        'name': 'Dr. Robert Miller',
        'specialty': 'Interventional Radiology',
        'hospital': 'Memorial Hospital',
        'imageUrl': 'assets/images/doctor4.jpg',
        'isOnline': true,
      },
      {
        'id': 'RAD-1005',
        'name': 'Dr. Emily Davis',
        'specialty': 'Thoracic Radiology',
        'hospital': 'University Medical Center',
        'imageUrl': 'assets/images/doctor5.jpg',
        'isOnline': false,
      },
    ];

    setState(() {
      _pendingCases.addAll(cases);
      _activeSessions.addAll(sessions);
      _colleagues.addAll(colleagues);
      _isLoading = false;
    });
  }

  String _getRandomPatientName() {
    final firstNames = [
      'James',
      'Mary',
      'John',
      'Patricia',
      'Robert',
      'Jennifer',
      'Michael',
      'Linda',
      'William',
      'Elizabeth'
    ];

    final lastNames = [
      'Smith',
      'Johnson',
      'Williams',
      'Jones',
      'Brown',
      'Davis',
      'Miller',
      'Wilson',
      'Moore',
      'Taylor'
    ];

    final firstName = firstNames[math.Random().nextInt(firstNames.length)];
    final lastName = lastNames[math.Random().nextInt(lastNames.length)];

    return '$firstName $lastName';
  }

  String _getRandomDoctorName() {
    final firstNames = [
      'Sarah',
      'Michael',
      'Lisa',
      'Robert',
      'Emily',
      'David',
      'Jennifer',
      'Thomas',
      'Maria',
      'Richard'
    ];

    final lastNames = [
      'Johnson',
      'Chen',
      'Wong',
      'Miller',
      'Davis',
      'Garcia',
      'Rodriguez',
      'Wilson',
      'Anderson',
      'Taylor'
    ];

    final firstName = firstNames[math.Random().nextInt(firstNames.length)];
    final lastName = lastNames[math.Random().nextInt(lastNames.length)];

    return 'Dr. $firstName $lastName';
  }

  String _getRandomStudyType() {
    final studyTypes = [
      'MRI Brain',
      'CT Chest',
      'X-ray Spine',
      'Ultrasound Abdomen',
      'PET Scan',
      'Mammogram',
      'CT Angiography',
      'MRI Knee'
    ];

    return studyTypes[math.Random().nextInt(studyTypes.length)];
  }

  String _getRandomPriority() {
    final priorities = ['High', 'Medium', 'Low'];
    final weights = [20, 50, 30]; // Percentage weights

    final random = math.Random().nextInt(100);
    int cumulativeWeight = 0;

    for (int i = 0; i < priorities.length; i++) {
      cumulativeWeight += weights[i];
      if (random < cumulativeWeight) {
        return priorities[i];
      }
    }

    return priorities.last;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _joinSession(Map<String, dynamic> session) {
    // In a real app, this would open the collaborative session
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join ${session['title']}?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Host: ${session['host']}'),
              const SizedBox(height: 8),
              Text('Participants: ${session['participants']}'),
              const SizedBox(height: 8),
              Text('Cases to review: ${session['caseCount']}'),
              const SizedBox(height: 16),
              Text(session['status'] == 'In Progress'
                  ? 'This session is already in progress. Join now?'
                  : 'This session will start in ${_getTimeUntilStart(session['startTime'])}. Join the waiting room?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joining ${session['title']}...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Join Now'),
          ),
        ],
      ),
    );
  }

  String _getTimeUntilStart(DateTime startTime) {
    final difference = startTime.difference(DateTime.now());
    if (difference.inHours > 0) {
      return '${difference.inHours} hours and ${difference.inMinutes % 60} minutes';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'less than a minute';
    }
  }

  void _reviewCase(Map<String, dynamic> caseData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Case ${caseData['id']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(caseData['priority'])
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 16,
                            color: _getPriorityColor(caseData['priority']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${caseData['priority']} Priority',
                            style: TextStyle(
                              color: _getPriorityColor(caseData['priority']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Patient: ${caseData['patientName']}, ${caseData['patientAge']} years',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Study: ${caseData['studyType']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Case Description:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(caseData['description']),
                const SizedBox(height: 16),
                Text(
                  'Submitted by: ${caseData['submittedBy']} on ${DateFormat('MMM dd, yyyy').format(caseData['submissionDate'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add your interpretation:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Enter your clinical findings and interpretation...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Interpretation submitted successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _inviteColleague(Map<String, dynamic> colleague) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite ${colleague['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Select a case or session to invite ${colleague['name']} to:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true, // Add this to prevent overflow
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  ..._activeSessions.map((session) => DropdownMenuItem(
                        value: 'session:${session['id']}',
                        child: Text(session['title']),
                      )),
                  ..._pendingCases.map((caseData) => DropdownMenuItem(
                        value: 'case:${caseData['id']}',
                        child: Text(
                            'Case ${caseData['id']} - ${caseData['studyType']}'),
                      )),
                ],
                onChanged: (value) {},
                hint: const Text('Select a case or session'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation sent to ${colleague['name']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborative Review Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create New Session'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Session Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Session created successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Create Session'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Sessions'),
            Tab(text: 'Pending Cases'),
            Tab(text: 'Colleagues'),
          ],
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Active Sessions Tab
                _buildActiveSessions(),

                // Pending Cases Tab
                _buildPendingCases(),

                // Colleagues Tab
                _buildColleagues(),
              ],
            ),
      floatingActionButton: _selectedTabIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // Add new case for review
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildActiveSessions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeSessions.length,
      itemBuilder: (context, index) {
        final session = _activeSessions[index];
        final bool isInProgress = session['status'] == 'In Progress';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isInProgress ? Colors.blue : Colors.transparent,
              width: isInProgress ? 2 : 0,
            ),
          ),
          child: InkWell(
            onTap: () => _joinSession(session),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // Limit to 2 lines
                          overflow: TextOverflow
                              .ellipsis, // Show ellipsis (...) if overflows
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isInProgress
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session['status'],
                          style: TextStyle(
                            color: isInProgress ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Host: ${session['host']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session['participants']} participants',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.folder,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session['caseCount']} cases',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isInProgress
                            ? 'Started ${_getTimeElapsed(session['startTime'])}'
                            : 'Starts ${DateFormat('h:mm a').format(session['startTime'])}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timelapse,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session['duration'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _joinSession(session),
                        icon: Icon(
                            isInProgress ? Icons.login : Icons.access_time),
                        label:
                            Text(isInProgress ? 'Join Now' : 'Join When Ready'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInProgress ? Colors.blue : null,
                          foregroundColor: isInProgress ? Colors.white : null,
                        ),
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

  String _getTimeElapsed(DateTime startTime) {
    final difference = DateTime.now().difference(startTime);
    if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildPendingCases() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search cases...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              // Filter cases by search term
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _pendingCases.length,
            itemBuilder: (context, index) {
              final caseData = _pendingCases[index];
              final bool isInProgress = caseData['status'] == 'In Progress';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _reviewCase(caseData),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Case ${caseData['id']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(caseData['priority'])
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag,
                                    size: 16,
                                    color:
                                        _getPriorityColor(caseData['priority']),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    caseData['priority'],
                                    style: TextStyle(
                                      color: _getPriorityColor(
                                          caseData['priority']),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Patient: ${caseData['patientName']}, ${caseData['patientAge']} years',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Study: ${caseData['studyType']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submitted by: ${caseData['submittedBy']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(caseData['submissionDate'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 4,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(right: 8, bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isInProgress
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                caseData['status'],
                                style: TextStyle(
                                  color: isInProgress
                                      ? Colors.blue
                                      : Colors.amber[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Details'),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(60, 36),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _reviewCase(caseData),
                              child: Text(isInProgress ? 'Continue' : 'Review'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(60, 36),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColleagues() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _colleagues.length,
      itemBuilder: (context, index) {
        final colleague = _colleagues[index];

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Leading avatar with online indicator
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    if (colleague['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                // Content (title and subtitle)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          colleague['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          colleague['specialty'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          colleague['hospital'],
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Chatting with ${colleague['name']}...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => _inviteColleague(colleague),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
