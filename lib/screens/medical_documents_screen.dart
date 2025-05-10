import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MedicalDocumentsScreen extends StatefulWidget {
  const MedicalDocumentsScreen({super.key});

  @override
  _MedicalDocumentsScreenState createState() => _MedicalDocumentsScreenState();
}

class _MedicalDocumentsScreenState extends State<MedicalDocumentsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Lab Results',
    'Imaging',
    'Prescriptions',
    'Referrals',
    'Discharge',
    'Insurance',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDocuments);
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    final documents = [
      {
        'id': 'doc001',
        'name': 'Complete Blood Count (CBC)',
        'category': 'Lab Results',
        'date': '2025-04-15',
        'provider': 'Central Laboratory',
        'fileType': 'PDF',
        'fileSize': '1.2 MB',
        'isStarred': true,
        'thumbnailUrl': 'https://example.com/thumbnail1.jpg',
        'notes': 'Routine annual checkup'
      },
      {
        'id': 'doc002',
        'name': 'Chest X-Ray',
        'category': 'Imaging',
        'date': '2025-03-20',
        'provider': 'City General Hospital',
        'fileType': 'DICOM',
        'fileSize': '8.5 MB',
        'isStarred': false,
        'thumbnailUrl': 'https://example.com/thumbnail2.jpg',
        'notes': 'Follow-up for respiratory symptoms'
      },
      {
        'id': 'doc003',
        'name': 'Lipid Panel',
        'category': 'Lab Results',
        'date': '2025-04-10',
        'provider': 'Central Laboratory',
        'fileType': 'PDF',
        'fileSize': '0.8 MB',
        'isStarred': true,
        'thumbnailUrl': 'https://example.com/thumbnail3.jpg',
        'notes': 'Monitoring cholesterol levels'
      },
      {
        'id': 'doc004',
        'name': 'Prescription - Lisinopril',
        'category': 'Prescriptions',
        'date': '2025-04-02',
        'provider': 'Dr. Sarah Johnson',
        'fileType': 'PDF',
        'fileSize': '0.5 MB',
        'isStarred': false,
        'thumbnailUrl': 'https://example.com/thumbnail4.jpg',
        'notes': 'Hypertension medication, 10mg daily'
      },
      {
        'id': 'doc005',
        'name': 'MRI - Left Knee',
        'category': 'Imaging',
        'date': '2025-02-15',
        'provider': 'Advanced Imaging Center',
        'fileType': 'DICOM',
        'fileSize': '12.4 MB',
        'isStarred': true,
        'thumbnailUrl': 'https://example.com/thumbnail5.jpg',
        'notes': 'Evaluation for meniscus tear'
      },
      {
        'id': 'doc006',
        'name': 'Cardiology Referral',
        'category': 'Referrals',
        'date': '2025-03-25',
        'provider': 'Dr. Michael Chen',
        'fileType': 'PDF',
        'fileSize': '0.4 MB',
        'isStarred': false,
        'thumbnailUrl': 'https://example.com/thumbnail6.jpg',
        'notes': 'For evaluation of heart murmur'
      },
      {
        'id': 'doc007',
        'name': 'Hospital Discharge Summary',
        'category': 'Discharge',
        'date': '2024-12-05',
        'provider': 'City General Hospital',
        'fileType': 'PDF',
        'fileSize': '2.1 MB',
        'isStarred': false,
        'thumbnailUrl': 'https://example.com/thumbnail7.jpg',
        'notes': 'Following appendectomy procedure'
      },
      {
        'id': 'doc008',
        'name': 'Insurance Claim Form',
        'category': 'Insurance',
        'date': '2025-01-10',
        'provider': 'Health Plus Insurance',
        'fileType': 'PDF',
        'fileSize': '0.9 MB',
        'isStarred': false,
        'thumbnailUrl': 'https://example.com/thumbnail8.jpg',
        'notes': 'Claim for hospital stay'
      },
    ];

    setState(() {
      _isLoading = false;
      _documents = documents;
      _filteredDocuments = documents;
    });
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredDocuments = _documents.where((doc) {
          return doc['name'].toString().toLowerCase().contains(query) ||
              doc['provider'].toString().toLowerCase().contains(query) ||
              doc['notes'].toString().toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredDocuments = _documents.where((doc) {
          return doc['category'] == _selectedCategory &&
              (doc['name'].toString().toLowerCase().contains(query) ||
                  doc['provider'].toString().toLowerCase().contains(query) ||
                  doc['notes'].toString().toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterDocuments();
  }

  void _toggleStar(String docId) {
    setState(() {
      final docIndex = _documents.indexWhere((doc) => doc['id'] == docId);
      if (docIndex != -1) {
        _documents[docIndex]['isStarred'] = !_documents[docIndex]['isStarred'];
        // Update filtered list as well
        final filteredIndex =
            _filteredDocuments.indexWhere((doc) => doc['id'] == docId);
        if (filteredIndex != -1) {
          _filteredDocuments[filteredIndex]['isStarred'] =
              _documents[docIndex]['isStarred'];
        }
      }
    });
  }

  void _showDocumentDetails(Map<String, dynamic> document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFF050A30),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        document['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),

              // Document preview area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Document viewer placeholder
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          color: const Color(0xFFF0F0F0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (document['fileType'] == 'PDF')
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 100,
                                    color: Colors.red.shade300,
                                  )
                                else if (document['fileType'] == 'DICOM')
                                  Image.network(
                                    'https://www.researchgate.net/publication/343949797/figure/fig2/AS:931234113949699@1599132942295/Typical-lung-cancer-CT-scan-images-of-benign-and-malignant-pulmonary-nodules-cropped-to.jpg',
                                    height: 200,
                                    fit: BoxFit.contain,
                                  )
                                else
                                  const Icon(
                                    Icons.insert_drive_file,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  'Preview of ${document['name']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E8BC0),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Opening document viewer...')),
                                    );
                                  },
                                  icon: const Icon(Icons.fullscreen),
                                  label: const Text('View Full Document'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Document details
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Document Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Category', document['category']),
                            _buildDetailRow('Date', document['date']),
                            _buildDetailRow('Provider', document['provider']),
                            _buildDetailRow('File Type', document['fileType']),
                            _buildDetailRow('File Size', document['fileSize']),
                            const SizedBox(height: 24),
                            const Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                document['notes'] ?? 'No notes available.',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.share,
                                  label: 'Share',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Sharing document...')),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.download,
                                  label: 'Download',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Downloading document...')),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: Icons.print,
                                  label: 'Print',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Sending to printer...')),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  icon: document['isStarred']
                                      ? Icons.star
                                      : Icons.star_border,
                                  label: document['isStarred']
                                      ? 'Starred'
                                      : 'Star',
                                  onPressed: () {
                                    _toggleStar(document['id']);
                                    context.pop();
                                  },
                                  color: document['isStarred']
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color ?? const Color(0xFF2E8BC0),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? const Color(0xFF2E8BC0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A30),
        title: const Text(
          'Medical Documents',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show menu options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),

                // Category filter
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _selectCategory(category),
                          backgroundColor: Colors.white,
                          selectedColor:
                              const Color(0xFF2E8BC0).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2E8BC0)
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Documents list
                Expanded(
                  child: _filteredDocuments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.folder_open,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedCategory == 'All'
                                    ? 'No documents found'
                                    : 'No $_selectedCategory documents found',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try another search or category',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredDocuments.length,
                          itemBuilder: (context, index) {
                            final document = _filteredDocuments[index];

                            return Card(
                              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                onTap: () => _showDocumentDetails(document),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Document type icon/thumbnail
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: _getDocumentTypeIcon(
                                              document['fileType']),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Document details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              document['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${document['provider']} • ${document['date']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getCategoryColor(
                                                        document['category']),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    document['category'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  document['fileType'],
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  document['fileSize'],
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Favorite button
                                      IconButton(
                                        icon: Icon(
                                          document['isStarred']
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: document['isStarred']
                                              ? Colors.amber
                                              : Colors.grey,
                                        ),
                                        onPressed: () =>
                                            _toggleStar(document['id']),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload feature coming soon')),
          );
        },
        backgroundColor: const Color(0xFF2E8BC0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _getDocumentTypeIcon(String fileType) {
    switch (fileType) {
      case 'PDF':
        return Icon(Icons.picture_as_pdf, size: 32, color: Colors.red.shade400);
      case 'DICOM':
        return const Icon(Icons.image, size: 32, color: Colors.blue);
      case 'JPG':
      case 'PNG':
        return const Icon(Icons.image, size: 32, color: Colors.green);
      default:
        return const Icon(Icons.insert_drive_file,
            size: 32, color: Colors.grey);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Lab Results':
        return Colors.purple;
      case 'Imaging':
        return Colors.blue;
      case 'Prescriptions':
        return Colors.green;
      case 'Referrals':
        return Colors.orange;
      case 'Discharge':
        return Colors.red;
      case 'Insurance':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
