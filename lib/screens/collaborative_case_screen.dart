import 'package:flutter/material.dart';
import 'dart:async';

class CollaborativeCaseScreen extends StatefulWidget {
  final String caseId;

  const CollaborativeCaseScreen({super.key, required this.caseId});

  @override
  _CollaborativeCaseScreenState createState() =>
      _CollaborativeCaseScreenState();
}

class _CollaborativeCaseScreenState extends State<CollaborativeCaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  Map<String, dynamic>? _caseData;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCaseData();

    // Mock adding realtime comments
    Timer.periodic(const Duration(seconds: 25), (timer) {
      if (mounted) {
        _addMockComment();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCaseData() async {
    // In a real app, fetch from API using widget.caseId
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _caseData = {
          'id': widget.caseId,
          'title':
              'Challenging Case: Atypical Presentation of Pulmonary Nodules',
          'patientInfo': {
            'patientId': 'P-78245',
            'age': 57,
            'gender': 'Male',
            'clinicalHistory': 'Former smoker (30 pack-years), quit 5 years ago. '
                'Recent weight loss of 5kg over 3 months. Occasional night sweats. '
                'No hemoptysis. Family history of lung cancer (father).'
          },
          'referringPhysician': 'Dr. Sarah Johnson',
          'dateCreated': '2025-04-24',
          'status': 'Open',
          'priority': 'High',
          'images': [
            'assets/images/case1_image1.png',
            'assets/images/case1_image2.png',
            'assets/images/case1_image3.png'
          ],
          'initialFindings':
              'Multiple bilateral pulmonary nodules with irregular margins. '
                  'Largest nodule in right upper lobe measuring 2.3 cm. '
                  'No significant mediastinal or hilar adenopathy. '
                  'No pleural effusion.',
          'clinicalQuestion':
              'Evaluation for primary lung malignancy vs. metastatic disease. '
                  'Recommendation for biopsy approach.',
          'collaborators': [
            {
              'name': 'Dr. Michael Chen',
              'specialty': 'Thoracic Radiology',
              'hospital': 'University Medical Center'
            },
            {
              'name': 'Dr. Lisa Patel',
              'specialty': 'Pulmonology',
              'hospital': 'City General Hospital'
            },
            {
              'name': 'Dr. Robert Wilson',
              'specialty': 'Interventional Radiology',
              'hospital': 'University Medical Center'
            },
          ]
        };

        _comments = [
          {
            'id': '1',
            'author': 'Dr. Michael Chen',
            'timestamp': '10:23 AM',
            'text': 'The distribution pattern is concerning for metastatic disease rather than multiple primary lung cancers. '
                'I recommend PET-CT to evaluate for metabolic activity and potential primary site.',
            'specialty': 'Thoracic Radiology',
            'imageUrl': 'https://randomuser.me/api/portraits/men/35.jpg'
          },
          {
            'id': '2',
            'author': 'Dr. Lisa Patel',
            'timestamp': '10:45 AM',
            'text': 'I agree with Dr. Chen. Additionally, given the patient\'s smoking history, '
                'we should also consider lung cancer with intrapulmonary metastases. '
                'Recommending biopsy of the largest nodule via CT-guided approach.',
            'specialty': 'Pulmonology',
            'imageUrl': 'https://randomuser.me/api/portraits/women/65.jpg'
          },
        ];
      });
    }
  }

  void _addMockComment() {
    final mockComments = [
      {
        'id': '3',
        'author': 'Dr. Robert Wilson',
        'timestamp': 'Just now',
        'text': 'CT-guided biopsy is feasible for the 2.3cm RUL nodule. '
            'I recommend core needle biopsy rather than FNA given the differential considerations. '
            'We can schedule this for early next week if that works for the patient.',
        'specialty': 'Interventional Radiology',
        'imageUrl': 'https://randomuser.me/api/portraits/men/55.jpg'
      },
      {
        'id': '4',
        'author': 'Dr. Elaine Zhang',
        'timestamp': 'Just now',
        'text':
            'I would also recommend screening for common metastatic sources with abdominal and pelvic CT. '
                'The irregular margins are concerning.',
        'specialty': 'Oncology',
        'imageUrl': 'https://randomuser.me/api/portraits/women/22.jpg'
      }
    ];

    if (_comments.length < 4) {
      setState(() {
        _comments.add(mockComments[_comments.length - 2]);
      });

      // Scroll to bottom after adding comment
      Timer(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.add({
        'id': (_comments.length + 1).toString(),
        'author': 'Dr. You',
        'timestamp': 'Just now',
        'text': _commentController.text.trim(),
        'specialty': 'Radiology',
        'imageUrl': 'https://randomuser.me/api/portraits/men/78.jpg'
      });
      _commentController.clear();
    });

    // Scroll to bottom after adding comment
    Timer(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: Text(
          _isLoading ? 'Loading Case...' : 'Case: ${widget.caseId}',
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'DISCUSSION'),
            Tab(text: 'IMAGES'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDiscussionTab(),
                _buildImagesTab(),
              ],
            ),
      bottomNavigationBar:
          _tabController.index == 1 ? _buildCommentInput() : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCaseHeader(),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Patient Information',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Patient ID:', _caseData!['patientInfo']['patientId']),
                _buildInfoRow(
                    'Age:', '${_caseData!['patientInfo']['age']} years'),
                _buildInfoRow('Gender:', _caseData!['patientInfo']['gender']),
                const SizedBox(height: 8),
                const Text(
                  'Clinical History:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF050A30),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_caseData!['patientInfo']['clinicalHistory']),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Case Details',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Referring Physician:', _caseData!['referringPhysician']),
                _buildInfoRow('Date Created:', _caseData!['dateCreated']),
                _buildInfoRow('Status:', _caseData!['status']),
                _buildInfoRow('Priority:', _caseData!['priority']),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Initial Findings',
            content: Text(_caseData!['initialFindings']),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Clinical Question',
            content: Text(_caseData!['clinicalQuestion']),
          ),
          const SizedBox(height: 16),
          _buildCollaboratorsList(),
        ],
      ),
    );
  }

  Widget _buildDiscussionTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              final bool isCurrentUser = comment['author'] == 'Dr. You';

              return Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCurrentUser) ...[
                            CircleAvatar(
                              radius: 14,
                              backgroundImage:
                                  NetworkImage(comment['imageUrl']),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            comment['author'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment['timestamp'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 14,
                              backgroundImage:
                                  NetworkImage(comment['imageUrl']),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? const Color(0xFF2E8BC0).withOpacity(0.9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                            Text(
                              comment['text'],
                              style: TextStyle(
                                color: isCurrentUser
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment['specialty'],
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: isCurrentUser
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6, // Mock images
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://www.researchgate.net/publication/343949797/figure/fig2/AS:931234113949699@1599132942295/Typical-lung-cancer-CT-scan-images-of-benign-and-malignant-pulmonary-nodules-cropped-to.jpg',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      'Slice ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add your medical opinion...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF2E8BC0),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _submitComment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050A30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _caseData!['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _caseData!['status'] == 'Open'
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _caseData!['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _caseData!['priority'] == 'High'
                      ? Colors.red
                      : _caseData!['priority'] == 'Medium'
                          ? Colors.orange
                          : Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _caseData!['priority'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF050A30),
              ),
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF050A30),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsList() {
    return _buildInfoCard(
      title: 'Collaborators',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final collaborator in _caseData!['collaborators'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2E8BC0).withOpacity(0.2),
                child: Text(
                  collaborator['name'].toString().substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF2E8BC0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                collaborator['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${collaborator['specialty']} • ${collaborator['hospital']}',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.message_outlined,
                    color: Color(0xFF2E8BC0)),
                onPressed: () {
                  // Messaging functionality
                },
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Add collaborator
              },
              icon: const Icon(Icons.person_add),
              label: const Text('INVITE SPECIALIST'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E8BC0),
                side: const BorderSide(color: Color(0xFF2E8BC0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
