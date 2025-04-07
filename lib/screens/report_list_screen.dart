import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_report.dart';
import 'create_report_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  // Mock data - in production this would come from a database or API
  late List<MedicalReport> _reports;
  late List<MedicalReport> _filteredReports;
  String _searchQuery = '';

  // Sorting options
  String _sortBy = 'date';
  bool _sortAscending = false;

  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Recent',
    'Urgent',
    'Pending',
    'Completed'
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMockReports();
    _filteredReports = List.from(_reports);
  }

  void _loadMockReports() {
    // Generate mock data for demonstration
    _reports = List.generate(
      15,
      (index) => MedicalReport(
        id: 'MR-${10000 + index}',
        patientId: 'P-${10000 + index}',
        doctorId: 'D-$index',
        vitalSigns: {
          'temperature': (36 + Random().nextDouble() * 2).toStringAsFixed(1),
          'blood_pressure':
              '${90 + Random().nextInt(20)}/${60 + Random().nextInt(10)}',
          'pulse': (65 + Random().nextInt(20)).toString(),
          'respiration': (12 + Random().nextInt(4)).toString(),
          'oxygen': (95 + Random().nextInt(3)).toString(),
        },
        patientName: _getMockPatientName(index),
        date: DateTime.now().subtract(Duration(days: index * 2)),
        diagnosis: _getMockDiagnosis(index),
        symptoms: 'Symptoms for patient $index',
        prescription: 'Prescription for patient $index',
        doctorNotes: 'Notes for patient $index',
        isHandwritten: index % 3 == 0,
        isDictated: index % 5 == 0,
      ),
    );
  }

  String _getMockPatientName(int index) {
    final names = [
      'John Smith',
      'Maria Garcia',
      'James Johnson',
      'Sarah Williams',
      'Robert Brown',
      'Jessica Jones',
      'Michael Davis',
      'Emily Wilson',
      'William Moore',
      'Emma Taylor',
      'David Anderson',
      'Olivia Martinez',
      'Joseph Thomas',
      'Sophia Jackson',
      'Charles White'
    ];
    return index < names.length ? names[index] : 'Patient $index';
  }

  String _getMockDiagnosis(int index) {
    final diagnoses = [
      'Hypertension',
      'Type 2 Diabetes',
      'Influenza',
      'Common Cold',
      'Migraine',
      'Asthma',
      'Bronchitis',
      'Gastritis',
      'Allergic Rhinitis',
      'Sinusitis',
      'Lower Back Pain',
      'Anemia',
      'Anxiety Disorder',
      'Urinary Tract Infection',
      'Dermatitis'
    ];
    return index < diagnoses.length ? diagnoses[index] : 'Diagnosis $index';
  }

  void _applySearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterReports();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterReports();
    });
  }

  void _applySorting(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = true;
      }
      _filterReports();
    });
  }

  void _filterReports() {
    setState(() {
      _filteredReports = _reports.where((report) {
        // First apply search query
        bool matchesSearch = _searchQuery.isEmpty ||
            report.patientName.toLowerCase().contains(_searchQuery) ||
            report.diagnosis.toLowerCase().contains(_searchQuery) ||
            report.id.toLowerCase().contains(_searchQuery);

        if (!matchesSearch) return false;

        // Then apply category filter
        switch (_selectedFilter) {
          case 'Recent':
            return report.date
                .isAfter(DateTime.now().subtract(const Duration(days: 7)));
          case 'Urgent':
            // In a real app, you would have an urgent flag
            return report.id.contains('0') || report.id.contains('5');
          case 'Pending':
            // In a real app, you would have a status field
            return report.id.endsWith('1') ||
                report.id.endsWith('3') ||
                report.id.endsWith('7');
          case 'Completed':
            return !report.id.endsWith('1') &&
                !report.id.endsWith('3') &&
                !report.id.endsWith('7');
          default:
            return true;
        }
      }).toList();

      // Apply sorting
      _filteredReports.sort((a, b) {
        int comparison;
        switch (_sortBy) {
          case 'patientName':
            comparison = a.patientName.compareTo(b.patientName);
            break;
          case 'id':
            comparison = a.id.compareTo(b.id);
            break;
          case 'diagnosis':
            comparison = a.diagnosis.compareTo(b.diagnosis);
            break;
          default: // date
            comparison = a.date.compareTo(b.date);
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _viewReportDetails(MedicalReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medical Report',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigate to edit screen with the report data
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () => _generatePDF(report),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    _buildInfoRow('ID', report.id),
                    _buildInfoRow('Patient', report.patientName),
                    _buildInfoRow(
                        'Date', DateFormat('MMM dd, yyyy').format(report.date)),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Diagnosis'),
                    _buildContentBox(report.diagnosis),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Symptoms'),
                    _buildContentBox(report.symptoms),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Prescription'),
                    _buildContentBox(report.prescription),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Doctor\'s Notes'),
                    _buildContentBox(report.doctorNotes),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (report.isHandwritten)
                          Chip(
                            label: const Text('Handwritten'),
                            avatar: const Icon(Icons.draw, size: 16),
                            backgroundColor: Colors.blue[100],
                          ),
                        const SizedBox(width: 8),
                        if (report.isDictated)
                          Chip(
                            label: const Text('Voice Dictated'),
                            avatar: const Icon(Icons.mic, size: 16),
                            backgroundColor: Colors.green[100],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _generatePDF(MedicalReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MEDICAL REPORT: ${report.id}',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Patient Information',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text('Name: ${report.patientName}'),
                        pw.Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(report.date)}'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('DIAGNOSIS',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(report.diagnosis),
              ),
              pw.SizedBox(height: 15),
              pw.Text('SYMPTOMS',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(report.symptoms),
              ),
              pw.SizedBox(height: 15),
              pw.Text('PRESCRIPTION',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(report.prescription),
              ),
              pw.SizedBox(height: 15),
              pw.Text('DOCTOR\'S NOTES',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(report.doctorNotes),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildContentBox(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _applySearch,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSortingOptions(),
          Expanded(
            child: _filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = _filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateReportScreen(),
            ),
          ).then((_) {
            // Refresh list after creating a new report
            // In a real app, this would fetch updated data
          });
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Create Report',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => _applyFilter(filter),
              backgroundColor: Colors.grey[200],
              selectedColor:
                  Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortingOptions() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Sort by:'),
          const SizedBox(width: 8),
          _buildSortButton('Date', 'date'),
          _buildSortButton('Patient', 'patientName'),
          _buildSortButton('ID', 'id'),
          const Spacer(),
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                _filterReports();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String sortKey) {
    final isSelected = _sortBy == sortKey;
    return TextButton(
      onPressed: () => _applySorting(sortKey),
      style: TextButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).toInt())
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  Widget _buildReportCard(MedicalReport report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewReportDetails(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt()),
                    radius: 24,
                    child: Text(
                      report.patientName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report.patientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              report.id,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(report.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diagnosis',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          report.diagnosis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (report.isHandwritten)
                        Tooltip(
                          message: 'Contains handwritten notes',
                          child: Icon(
                            Icons.draw,
                            size: 18,
                            color: Colors.blue[700],
                          ),
                        ),
                      if (report.isHandwritten && report.isDictated)
                        const SizedBox(width: 8),
                      if (report.isDictated)
                        Tooltip(
                          message: 'Contains voice dictation',
                          child: Icon(
                            Icons.mic,
                            size: 18,
                            color: Colors.green[700],
                          ),
                        ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
