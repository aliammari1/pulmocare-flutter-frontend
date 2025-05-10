import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:medapp/services/file_service.dart';
import 'package:medapp/models/medical_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  final List<String> _categories = [
    'All Documents',
    'Medical Records',
    'Lab Reports',
    'Prescriptions',
    'Insurance',
    'Consent Forms',
    'Imaging'
  ];

  String _selectedCategory = 'All Documents';
  bool _isGridView = true;
  bool _isLoading = true;
  String? _userId;

  // File service and real document data
  final FileService _fileService = FileService();
  late List<MedicalFile> _documents;
  late List<MedicalFile> _filteredDocuments;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _documentNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isMedicallyImportant = false;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _getUserIdAndLoadDocuments();
  }

  Future<void> _getUserIdAndLoadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      setState(() {
        _isLoading = false;
        _documents = [];
        _filteredDocuments = [];
      });
      return;
    }
    await _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get real documents from the FileService
      final files = await _fileService.getPatientMedicalFiles(_userId!);

      setState(() {
        _documents = files;
        _filterDocuments(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _documents = [];
        _filteredDocuments = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load documents: ${e.toString()}')),
      );
    }
  }

  void _filterDocuments(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_selectedCategory == 'All Documents') {
          _filteredDocuments = List.from(_documents);
        } else {
          _filteredDocuments = _documents
              .where((doc) => doc.metadata?['category'] == _selectedCategory)
              .toList();
        }
      } else {
        _filteredDocuments = _documents
            .where((doc) =>
                doc.objectName.toLowerCase().contains(query.toLowerCase()) &&
                (_selectedCategory == 'All Documents' ||
                    doc.metadata?['category'] == _selectedCategory))
            .toList();
      }
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterDocuments(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Vault'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildCategoryFilter(),
                Expanded(
                  child: _filteredDocuments.isEmpty
                      ? _buildEmptyState()
                      : _isGridView
                          ? _buildGridView()
                          : _buildListView(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUploadDialog();
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterDocuments('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: _filterDocuments,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _selectCategory(category),
              backgroundColor: Colors.grey.shade200,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildListView() {
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredDocuments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final document = _filteredDocuments[index];
          return _buildDocumentListItem(document);
        },
      ),
    );
  }

  Widget _buildDocumentCard(MedicalFile document) {
    final Color cardColor = document.metadata?['isMedicallyImportant'] == true
        ? Colors.blue.shade50
        : Colors.white;

    IconData fileIcon;
    if (document.objectName.toLowerCase().endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
    } else if (document.objectName.toLowerCase().endsWith('.jpg') ||
        document.objectName.toLowerCase().endsWith('.jpeg') ||
        document.objectName.toLowerCase().endsWith('.png')) {
      fileIcon = Icons.image;
    } else if (document.objectName.toLowerCase().endsWith('.doc') ||
        document.objectName.toLowerCase().endsWith('.docx')) {
      fileIcon = Icons.text_snippet;
    } else {
      fileIcon = Icons.insert_drive_file;
    }

    return InkWell(
      onTap: () => _showDocumentDetails(document),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      fileIcon,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (document.metadata?['isShared'] == true)
                    Tooltip(
                      message:
                          'Shared with ${document.metadata?['sharedWith'] ?? "others"}',
                      child: const Icon(
                        Icons.people,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.basename(document.objectName),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${document.metadata?['category'] ?? 'Uncategorized'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy')
                          .format(DateTime.parse(document.lastModified)),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatSize(document.size),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentListItem(MedicalFile document) {
    final Color listItemColor =
        document.metadata?['isMedicallyImportant'] == true
            ? Colors.blue.shade50
            : Colors.white;

    IconData fileIcon;
    if (document.objectName.toLowerCase().endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
    } else if (document.objectName.toLowerCase().endsWith('.jpg') ||
        document.objectName.toLowerCase().endsWith('.jpeg') ||
        document.objectName.toLowerCase().endsWith('.png')) {
      fileIcon = Icons.image;
    } else if (document.objectName.toLowerCase().endsWith('.doc') ||
        document.objectName.toLowerCase().endsWith('.docx')) {
      fileIcon = Icons.text_snippet;
    } else {
      fileIcon = Icons.insert_drive_file;
    }

    return Card(
      elevation: 1,
      color: listItemColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            fileIcon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          path.basename(document.objectName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                'Category: ${document.metadata?['category'] ?? 'Uncategorized'}'),
            Text(
              '${DateFormat('MMM dd, yyyy').format(DateTime.parse(document.lastModified))} • ${_formatSize(document.size)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (document.metadata?['isShared'] == true)
              Tooltip(
                message:
                    'Shared with ${document.metadata?['sharedWith'] ?? "others"}',
                child: const Icon(
                  Icons.people,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showOptionsMenu(document);
              },
            ),
          ],
        ),
        onTap: () => _showDocumentDetails(document),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Sort Documents',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date (Newest First)'),
                onTap: () {
                  setState(() {
                    _filteredDocuments.sort(
                        (a, b) => b.lastModified.compareTo(a.lastModified));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date (Oldest First)'),
                onTap: () {
                  setState(() {
                    _filteredDocuments.sort(
                        (a, b) => a.lastModified.compareTo(b.lastModified));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (A-Z)'),
                onTap: () {
                  setState(() {
                    _filteredDocuments
                        .sort((a, b) => a.objectName.compareTo(b.objectName));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name (Z-A)'),
                onTap: () {
                  setState(() {
                    _filteredDocuments
                        .sort((a, b) => b.objectName.compareTo(a.objectName));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDocumentDetails(MedicalFile document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      path.basename(document.objectName),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.folder, 'Category',
                  document.metadata?['category'] ?? 'Uncategorized'),
              _buildDetailRow(
                  Icons.calendar_today,
                  'Upload Date',
                  DateFormat('MMMM dd, yyyy')
                      .format(DateTime.parse(document.lastModified))),
              _buildDetailRow(
                  Icons.storage, 'Size', _formatSize(document.size)),
              if (document.metadata?['isShared'] == true)
                _buildDetailRow(Icons.people, 'Shared With',
                    document.metadata?['sharedWith'] ?? 'Others'),
              _buildDetailRow(
                Icons.security,
                'Medical Importance',
                document.metadata?['isMedicallyImportant'] == true
                    ? 'High'
                    : 'Standard',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    Icons.download,
                    'Download',
                    onTap: () {
                      Navigator.pop(context);
                      _downloadDocument(document);
                    },
                  ),
                  _buildActionButton(
                    Icons.share,
                    'Share',
                    onTap: () {
                      Navigator.pop(context);
                      _showShareDialog(document);
                    },
                  ),
                  _buildActionButton(
                    Icons.ios_share,
                    'Export',
                    onTap: () {
                      Navigator.pop(context);
                      _shareExternally(document);
                    },
                  ),
                  _buildActionButton(
                    Icons.edit,
                    'Edit',
                    onTap: () {
                      Navigator.pop(context);
                      _showEditDialog(document);
                    },
                  ),
                  _buildActionButton(
                    Icons.delete_outline,
                    'Delete',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(document);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label,
      {bool isDestructive = false, VoidCallback? onTap}) {
    final Color textColor = isDestructive ? Colors.red : Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(MedicalFile document) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showDocumentDetails(document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadDocument(document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _showShareDialog(document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(document);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUploadDialog() {
    _documentNameController.clear();
    _categoryController.clear();
    _isMedicallyImportant = false;
    _selectedFile = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _documentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Document Name',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.folder),
                    ),
                    items: _categories
                        .where((cat) => cat != 'All Documents')
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    value: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _categoryController.text = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          _selectedFile = File(result.files.single.path!);
                          if (_documentNameController.text.isEmpty) {
                            _documentNameController.text =
                                path.basename(result.files.single.path!);
                          }
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedFile != null
                              ? path.basename(_selectedFile!.path)
                              : 'Click to select file',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Mark as medically important'),
                      const Spacer(),
                      Switch(
                        value: _isMedicallyImportant,
                        onChanged: (value) {
                          setState(() {
                            _isMedicallyImportant = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedFile == null ||
                  _documentNameController.text.isEmpty ||
                  _categoryController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Please provide a file, name, and category')),
                );
                return;
              }

              Navigator.pop(context);
              _uploadDocument();
            },
            child: const Text('UPLOAD'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null || _userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final metadata = {
        'category': _categoryController.text,
        'isMedicallyImportant': _isMedicallyImportant,
        'isShared': false,
      };

      await _fileService.uploadFile(
        _selectedFile!,
        _documentNameController.text,
        bucket: "patientdocuments",
        folder: _userId!,
        metadata: metadata,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );

      // Reload documents list
      await _loadDocuments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.toString()}')),
      );
    }
  }

  void _showEditDialog(MedicalFile document) {
    final originalName = path.basename(document.objectName);
    _documentNameController.text = originalName;
    _categoryController.text = document.metadata?['category'] ?? '';
    _isMedicallyImportant = document.metadata?['isMedicallyImportant'] == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Document'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _documentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Document Name',
                      prefixIcon: Icon(Icons.edit),
                    ),
                    readOnly: true, // Name should be read-only for now
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.folder),
                    ),
                    items: _categories
                        .where((cat) => cat != 'All Documents')
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    value: _categoryController.text.isNotEmpty
                        ? _categoryController.text
                        : null,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _categoryController.text = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Mark as medically important'),
                      const Spacer(),
                      Switch(
                        value: _isMedicallyImportant,
                        onChanged: (value) {
                          setState(() {
                            _isMedicallyImportant = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDocument(document);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDocument(MedicalFile document) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the existing metadata
      final Map<String, dynamic> metadata = document.metadata ?? {};
      metadata['category'] = _categoryController.text;
      metadata['isMedicallyImportant'] = _isMedicallyImportant;

      // Call API to update metadata
      await _fileService.updateFileMetadata(
        'medicalimages',
        document.objectName,
        metadata,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document updated successfully')),
      );

      // Reload documents list
      await _loadDocuments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    }
  }

  void _confirmDelete(MedicalFile document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document?'),
        content: const Text(
            'Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteDocument(document);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(MedicalFile document) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _fileService.deleteFile('medicalimages', document.objectName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );

      // Reload documents list
      await _loadDocuments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${e.toString()}')),
      );
    }
  }

  void _showShareDialog(MedicalFile document) {
    final TextEditingController shareWithController = TextEditingController(
      text: document.metadata?['sharedWith'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: shareWithController,
              decoration: const InputDecoration(
                labelText: 'Share with',
                hintText: 'Enter name or email',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareDocument(document, shareWithController.text);
            },
            child: const Text('SHARE'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareDocument(MedicalFile document, String shareWith) async {
    if (shareWith.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipient')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update the existing metadata
      final Map<String, dynamic> metadata = document.metadata ?? {};
      metadata['isShared'] = true;
      metadata['sharedWith'] = shareWith;

      // Call API to update metadata
      await _fileService.updateFileMetadata(
        'medicalimages',
        document.objectName,
        metadata,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document shared with $shareWith')),
      );

      // Reload documents list
      await _loadDocuments();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sharing failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _downloadDocument(MedicalFile document) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Show a progress indicator
      final snackBar = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(width: 16),
              Text('Downloading file...'),
            ],
          ),
          duration:
              Duration(minutes: 5), // Long duration, will be dismissed manually
        ),
      );

      // Download the file
      final filePath = await _fileService.downloadFile(document);

      // Dismiss the progress indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success message with appropriate actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File downloaded successfully'),
          action: SnackBarAction(
            label: document.contentType.startsWith('image/') ? 'VIEW' : 'OPEN',
            onPressed: () async {
              if (document.contentType.startsWith('image/')) {
                // For images, open file directly as they might be saved to gallery
                await OpenFile.open(filePath);
              } else {
                // For other files, try to open with system handler
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Could not open file: ${result.message}')),
                    );
                  }
                }
              }
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add a method to share files externally
  Future<void> _shareExternally(MedicalFile document) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First download the file to have a local copy
      final filePath = await _fileService.downloadFile(document);

      // Share the file using share_plus
      await share_plus.Share.shareFiles(
        [filePath],
        text: 'Sharing ${path.basename(document.objectName)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _documentNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
