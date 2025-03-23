import 'package:flutter/material.dart';
import 'package:medapp/models/medical_report.dart';
import 'package:medapp/screens/report_list_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'handwriting_screen.dart';
import 'voice_dictation_screen.dart';
import '../services/report_service.dart';
import 'package:uuid/uuid.dart';
import 'report_editor_screen.dart'; // Import the new report editor

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Patient info
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _patientIdController = TextEditingController();

  // Medical data
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // Vital signs
  final _temperatureController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _respirationController = TextEditingController();
  final _oxygenController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isUrgent = false;
  bool _isShowingVitalSigns = true;

  late ReportService _reportService;
  bool _isSaving = false;
  String _generatedId = '';
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generatedId = 'MR-${_uuid.v4().substring(0, 8).toUpperCase()}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to get service from provider, fallback to service locator if needed
    try {
      _reportService = Provider.of<ReportService>(context, listen: false);
    } catch (e) {
      print('Service Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Add medical logo image if available
    // final medicalLogo = await rootBundle.load('assets/images/medical_logo.png');
    // final logoImage = pw.MemoryImage(medicalLogo.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('MEDICAL REPORT',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
                      _isUrgent
                          ? pw.Text('URGENT',
                              style: pw.TextStyle(
                                  color: PdfColors.red,
                                  fontWeight: pw.FontWeight.bold))
                          : pw.Container(),
                    ],
                  ),
                  // Uncomment when logo is available
                  // pw.SizedBox(height: 60, width: 60, child: pw.Image(logoImage)),
                ],
              ),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 15),
              pw.Text('PATIENT INFORMATION',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  color: PdfColors.grey200,
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Name: ${_patientNameController.text}'),
                          pw.Text('ID: ${_patientIdController.text}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Age: ${_ageController.text}'),
                          pw.Text('Gender: ${_genderController.text}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text('VITAL SIGNS',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  color: PdfColors.grey200,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                        child: pw.Text(
                            'Temperature: ${_temperatureController.text} °C')),
                    pw.Expanded(
                        child: pw.Text(
                            'BP: ${_bloodPressureController.text} mmHg')),
                    pw.Expanded(
                        child: pw.Text('Pulse: ${_pulseController.text} bpm')),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text('DIAGNOSIS',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(_diagnosisController.text),
              ),
              pw.SizedBox(height: 15),
              pw.Text('SYMPTOMS',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(_symptomsController.text),
              ),
              pw.SizedBox(height: 15),
              pw.Text('PRESCRIPTION',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(_prescriptionController.text),
              ),
              pw.SizedBox(height: 15),
              pw.Text('DOCTOR\'S NOTES',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(_notesController.text),
              ),
              pw.Spacer(),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Doctor\'s Signature'),
                    pw.SizedBox(height: 20),
                    pw.Container(width: 100, height: 1, color: PdfColors.black),
                  ],
                ),
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

  Future<void> _saveReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        final report = MedicalReport(
          id: _generatedId,
          patientName: _patientNameController.text,
          patientId: _patientIdController.text,
          date: _selectedDate,
          diagnosis: _diagnosisController.text,
          symptoms: _symptomsController.text,
          prescription: _prescriptionController.text,
          doctorNotes: _notesController.text,
          isUrgent: _isUrgent,
          doctorId: 'DR-001',
          vitalSigns: {
            'temperature': _temperatureController.text,
            'blood_pressure': _bloodPressureController.text,
            'pulse': _pulseController.text,
            'respiration': _respirationController.text,
            'oxygen': _oxygenController.text,
          },
          status: 'draft',
        );

        await _reportService.saveReport(report);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report saved successfully'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to report details
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportListScreen(),
                    ),
                  );
                },
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  // New method to open the integrated report editor
  Future<void> _openReportEditor(String sectionName) async {
    // Determine initial content based on which section we're editing
    String initialContent = '';
    switch (sectionName) {
      case 'symptoms':
        initialContent = _symptomsController.text;
        break;
      case 'diagnosis':
        initialContent = _diagnosisController.text;
        break;
      case 'prescription':
        initialContent = _prescriptionController.text;
        break;
      case 'notes':
        initialContent = _notesController.text;
        break;
    }

    // Navigate to the report editor
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportEditorScreen(
          initialContent: initialContent,
          reportId: _generatedId,
          patientName: _patientNameController.text.isNotEmpty
              ? _patientNameController.text
              : 'New Patient',
        ),
      ),
    );

    // Update the appropriate field with the result
    if (result != null) {
      setState(() {
        switch (sectionName) {
          case 'symptoms':
            _symptomsController.text = result;
            break;
          case 'diagnosis':
            _diagnosisController.text = result;
            break;
          case 'prescription':
            _prescriptionController.text = result;
            break;
          case 'notes':
            _notesController.text = result;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges()) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text(
                  'You have unsaved changes. Are you sure you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Medical Report'),
          centerTitle: true,
          elevation: 3,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePDF,
              tooltip: 'Generate PDF Report',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(
                icon: Icon(Icons.person),
                text: 'Patient',
              ),
              Tab(
                icon: Icon(Icons.medical_services),
                text: 'Diagnosis',
              ),
              Tab(
                icon: Icon(Icons.note_alt),
                text: 'Notes',
              ),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Patient Info Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Patient Information'),
                    const SizedBox(height: 8),
                    _buildPatientInfoSection(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSectionHeader('Vital Signs'),
                        ),
                        IconButton(
                          icon: Icon(_isShowingVitalSigns
                              ? Icons.expand_less
                              : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _isShowingVitalSigns = !_isShowingVitalSigns;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isShowingVitalSigns) _buildVitalSignsSection(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Urgent Case'),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isUrgent,
                          onChanged: (value) {
                            setState(() {
                              _isUrgent = value;
                            });
                          },
                          activeColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Diagnosis Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputSection(
                      'Symptoms',
                      _symptomsController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputSection(
                      'Diagnosis',
                      _diagnosisController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputSection(
                      'Prescription',
                      _prescriptionController,
                      hintText: 'Enter medications, dosages, and instructions',
                    ),
                  ],
                ),
              ),

              // Notes Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputSection(
                      'Doctor\'s Notes',
                      _notesController,
                      maxLines: 8,
                      hintText:
                          'Enter additional notes, observations, or follow-up instructions',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HandwritingScreen(),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _notesController.text += result;
                                });
                              }
                            },
                            icon: const Icon(Icons.draw),
                            label: const Text('Add Handwriting'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8BC0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VoiceDictationScreen(),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _notesController.text += result;
                                });
                              }
                            },
                            icon: const Icon(Icons.mic),
                            label: const Text('Add Voice Note'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A5F7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        persistentFooterButtons: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveReport,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasUnsavedChanges() {
    return _patientNameController.text.isNotEmpty ||
        _diagnosisController.text.isNotEmpty ||
        _symptomsController.text.isNotEmpty ||
        _prescriptionController.text.isNotEmpty ||
        _notesController.text.isNotEmpty;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _patientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter patient name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _patientIdController,
                    decoration: const InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _genderController,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.event),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                child: Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Temperature (°C)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.thermostat),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(
                      labelText: 'Blood Pressure (mmHg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pulseController,
                    decoration: const InputDecoration(
                      labelText: 'Pulse Rate (bpm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_heart),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _respirationController,
                    decoration: const InputDecoration(
                      labelText: 'Respiration Rate',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.air),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _oxygenController,
              decoration: const InputDecoration(
                labelText: 'Oxygen Saturation (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    TextEditingController controller, {
    int maxLines = 4,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hintText ?? 'Enter $label',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (label != 'Doctor\'s Notes' &&
                        (value?.isEmpty ?? true)) {
                      return 'Please enter $label';
                    }
                    return null;
                  },
                ),
              ),
              // Add an advanced editor button
              Positioned(
                right: 8,
                bottom: 8,
                child: ElevatedButton.icon(
                  onPressed: () => _openReportEditor(label
                      .toLowerCase()
                      .replaceAll('\'s', '')
                      .replaceAll(' ', '_')),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Advanced Editor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _patientIdController.dispose();
    _diagnosisController.dispose();
    _symptomsController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _pulseController.dispose();
    _respirationController.dispose();
    _oxygenController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
