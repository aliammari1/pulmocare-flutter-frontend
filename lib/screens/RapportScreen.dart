import 'package:flutter/material.dart';
import 'package:medapp/models/radiologist.dart';
import 'package:medapp/services/rapport_service.dart';
import 'package:medapp/theme/app_theme.dart';
import 'package:medapp/services/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:medapp/services/auth_view_model.dart';
import 'package:provider/provider.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({super.key});

  @override
  _RapportScreenState createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  final RapportService _rapportService = RapportService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isDarkMode = false;
  bool _isAutoSaveEnabled = true;
  Timer? _autoSaveTimer;
  bool _showTemplateGallery = false;

  // Radiologist user information
  Radiologist? _currentRadiologist;

  // Animation controllers
  late AnimationController _animationController;

  // Valeurs par défaut pour les listes déroulantes
  String _selectedExamType = 'Scanner';
  String _selectedReportType = 'Standard';

  // Liste des types d'examens disponibles avec leurs icônes
  final List<Map<String, dynamic>> _examTypes = [
    {'name': 'Scanner', 'icon': Icons.crop_free},
    {'name': 'IRM', 'icon': Icons.panorama_horizontal},
    {'name': 'Radiographie', 'icon': Icons.filter_center_focus},
    {'name': 'Échographie', 'icon': Icons.waves},
    {'name': 'EEG', 'icon': Icons.polyline},
    {'name': 'ECG', 'icon': Icons.monitor_heart},
  ];

  // Modèles de rapports enrichis
  final Map<String, Map<String, dynamic>> _reportTemplates = {
    'Standard': {
      'content': '''
INDICATION :
[À compléter]

TECHNIQUE :
Examen réalisé selon le protocole standard

RÉSULTATS :
[À compléter]

CONCLUSION :
[À compléter]
''',
      'icon': Icons.article,
      'color': Color(0xFF4A6572),
      'description': 'Rapport médical standard pour tous types d\'examens'
    },
    'Urgence': {
      'content': '''
MOTIF D'URGENCE :
[À compléter]

CONSTATATIONS :
[À compléter]

CONCLUSION URGENTE :
[À compléter]
''',
      'icon': Icons.alarm,
      'color': Color(0xFFE53935),
      'description': 'Pour les cas nécessitant une intervention rapide'
    },
    'Suivi': {
      'content': '''
HISTORIQUE DU PATIENT :
[À compléter]

EVOLUTION DEPUIS DERNIER EXAMEN :
[À compléter]

TRAITEMENT ACTUEL :
[À compléter]

NOUVELLES OBSERVATIONS :
[À compléter]

RECOMMANDATIONS :
[À compléter]
''',
      'icon': Icons.history,
      'color': Color(0xFF43A047),
      'description': 'Pour les examens de suivi d\'un traitement'
    },
    'Pédiatrique': {
      'content': '''
AGE DE L'ENFANT :
[À compléter]

CROISSANCE :
[À compléter]

OBSERVATIONS SPÉCIFIQUES :
[À compléter]

ADAPTATION POSOLOGIQUE :
[À compléter]

RECOMMANDATIONS AUX PARENTS :
[À compléter]
''',
      'icon': Icons.child_care,
      'color': Color(0xFF1E88E5),
      'description': 'Adapté aux examens pour patients pédiatriques'
    },
  };

  // Drafts historique
  List<Map<String, dynamic>> _draftHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    // Initialiser le contenu avec le modèle Standard par défaut
    _contentController.text =
        _reportTemplates[_selectedReportType]?['content'] ?? '';
    _initializeSpeech();
    _loadSettings();
    _setupAutoSave();
    _loadDraftHistory();
    _loadCurrentRadiologist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _autoSaveTimer?.cancel();
    _patientNameController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isAutoSaveEnabled = prefs.getBool('autoSave') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('autoSave', _isAutoSaveEnabled);
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isAutoSaveEnabled && _contentController.text.isNotEmpty) {
        _saveDraft();
      }
    });
  }

  Future<void> _saveDraft() async {
    if (_patientNameController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      final draft = {
        'patientName': _patientNameController.text,
        'examType': _selectedExamType,
        'reportType': _selectedReportType,
        'content': _contentController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final prefs = await SharedPreferences.getInstance();
      List<String> drafts = prefs.getStringList('draftHistory') ?? [];

      if (drafts.length >= 10) {
        drafts.removeLast();
      }

      drafts.insert(0, draft.toString());
      await prefs.setStringList('draftHistory', drafts);

      _loadDraftHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Brouillon sauvegardé automatiquement"),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadDraftHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> drafts = prefs.getStringList('draftHistory') ?? [];

    setState(() {
      _draftHistory = drafts.map((draft) {
        // Parsing simpliste du string (une solution de production utiliserait JSON)
        final Map<String, dynamic> draftMap = {};
        draft
            .replaceAll('{', '')
            .replaceAll('}', '')
            .split(',')
            .forEach((item) {
          final parts = item.split(':');
          if (parts.length == 2) {
            draftMap[parts[0].trim()] = parts[1].trim();
          }
        });
        return draftMap;
      }).toList();
    });
  }

  void _loadDraft(Map<String, dynamic> draft) {
    setState(() {
      _patientNameController.text = draft['patientName'] ?? '';
      _selectedExamType = draft['examType'] ?? 'Scanner';
      _selectedReportType = draft['reportType'] ?? 'Standard';
      _contentController.text = draft['content'] ?? '';
      _tabController.animateTo(0);
    });
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      // Speech recognition service is initialized
    } else {
      // Speech recognition service is not available
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              // Append to current text
              _contentController.text += ' ${result.recognizedWords}';
            });
          },
          localeId: 'fr_FR', // Set to French
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _submitRapport() async {
    if (_formKey.currentState!.validate()) {
      _animationController.forward();
      try {
        await _rapportService.ajouterRapport(
          patientName: _patientNameController.text,
          examType: _selectedExamType,
          reportType: _selectedReportType,
          content: _contentController.text,
        );

        // Ajoutez une notification
        context.read<NotificationProvider>().addRapportNotification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Rapport ajouté avec succès !"),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _patientNameController.clear();
        setState(() {
          _selectedExamType = 'Scanner';
          _selectedReportType = 'Standard';
          _contentController.text =
              _reportTemplates['Standard']?['content'] ?? '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text("Erreur lors de l'ajout du rapport"),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      await Future.delayed(Duration(milliseconds: 1500));
      _animationController.reset();
    }
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required IconData icon,
    bool expanded = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _isDarkMode ? Color(0xFF2C3E50) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isDarkMode
              ? Colors.grey.shade800
              : AppTheme.accentColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? AppTheme.accentColor.withOpacity(0.3)
                : AppTheme.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: _isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(String key) {
    final template = _reportTemplates[key]!;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReportType = key;
          _contentController.text = template['content'];
          _showTemplateGallery = false;
        });
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isDarkMode ? Color(0xFF1E2A38) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: template['color'],
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: template['color'].withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: template['color'].withOpacity(_isDarkMode ? 0.4 : 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(template['icon'], color: template['color']),
                  SizedBox(width: 8),
                  Expanded(
                    // Added Expanded to prevent overflow
                    child: Text(
                      key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                        overflow: TextOverflow
                            .ellipsis, // Added to handle longer text
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                template['description'],
                style: TextStyle(
                  fontSize: 12,
                  color:
                      _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.3)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Text(
                      template['content'],
                      style: TextStyle(
                        fontSize: 11,
                        color: _isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade800,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: AppTheme.primaryColor,
              colorScheme: ColorScheme.dark(
                primary: AppTheme.primaryColor,
                secondary: AppTheme.accentColor,
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: AppTheme.primaryColor,
              colorScheme: ColorScheme.light(
                primary: AppTheme.primaryColor,
                secondary: AppTheme.accentColor,
              ),
            ),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Color(0xFF121212) : Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
              _isDarkMode ? Color(0xFF212121) : AppTheme.primaryColor,
          title: Text(
            "Création de Rapport Médical",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                  _saveSettings();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isDarkMode
                        ? "Mode sombre activé"
                        : "Mode clair activé"),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: _isDarkMode ? "Mode clair" : "Mode sombre",
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveDraft,
              tooltip: "Sauvegarder brouillon",
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'templates') {
                  setState(() {
                    _showTemplateGallery = true;
                  });
                } else if (value == 'autoSave') {
                  setState(() {
                    _isAutoSaveEnabled = !_isAutoSaveEnabled;
                    _saveSettings();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isAutoSaveEnabled
                          ? "Sauvegarde automatique activée"
                          : "Sauvegarde automatique désactivée"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'templates',
                  child: Row(
                    children: [
                      Icon(Icons.view_carousel_rounded,
                          color: _isDarkMode
                              ? Colors.white
                              : AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text('Galerie de modèles'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'autoSave',
                  child: Row(
                    children: [
                      Icon(
                          _isAutoSaveEnabled
                              ? Icons.pause_circle_outline
                              : Icons.save_outlined,
                          color: _isDarkMode
                              ? Colors.white
                              : AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(_isAutoSaveEnabled
                          ? 'Désactiver auto-save'
                          : 'Activer auto-save'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.accentColor,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.edit_document), text: "Rapport"),
              Tab(icon: Icon(Icons.view_carousel_rounded), text: "Modèles"),
              Tab(icon: Icon(Icons.history), text: "Brouillons"),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: RAPPORT
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildSectionCard(
                            title: 'Informations du patient',
                            icon: Icons.person,
                            expanded: true,
                            content: Column(
                              children: [
                                TextFormField(
                                  controller: _patientNameController,
                                  decoration: InputDecoration(
                                    labelText: "Nom du patient",
                                    hintText:
                                        "Entrez le nom complet du patient",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _isDarkMode
                                            ? Colors.grey.shade700
                                            : AppTheme.accentColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: _isDarkMode
                                          ? AppTheme.accentColor
                                          : AppTheme.primaryColor,
                                    ),
                                    filled: true,
                                    fillColor: _isDarkMode
                                        ? Color(0xFF1E1E1E)
                                        : Colors.white,
                                    labelStyle: TextStyle(
                                      color: _isDarkMode
                                          ? Colors.grey.shade400
                                          : null,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? "Ce champ est obligatoire"
                                      : null,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText:
                                              "Date de naissance (optionnel)",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: _isDarkMode
                                                  ? Colors.grey.shade700
                                                  : AppTheme.accentColor,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.calendar_today,
                                            color: _isDarkMode
                                                ? AppTheme.accentColor
                                                : AppTheme.primaryColor,
                                          ),
                                          filled: true,
                                          fillColor: _isDarkMode
                                              ? Color(0xFF1E1E1E)
                                              : Colors.white,
                                          labelStyle: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey.shade400
                                                : null,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: "N° Dossier (optionnel)",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: _isDarkMode
                                                  ? Colors.grey.shade700
                                                  : AppTheme.accentColor,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.folder,
                                            color: _isDarkMode
                                                ? AppTheme.accentColor
                                                : AppTheme.primaryColor,
                                          ),
                                          filled: true,
                                          fillColor: _isDarkMode
                                              ? Color(0xFF1E1E1E)
                                              : Colors.white,
                                          labelStyle: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey.shade400
                                                : null,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildSectionCard(
                            title: 'Type d\'Examen',
                            icon: Icons.medical_services,
                            content: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _examTypes.length,
                              itemBuilder: (context, index) {
                                final examType = _examTypes[index];
                                final isSelected =
                                    _selectedExamType == examType['name'];

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedExamType = examType['name'];
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected
                                          ? (_isDarkMode
                                              ? AppTheme.primaryColor
                                                  .withOpacity(0.3)
                                              : AppTheme.primaryColor
                                                  .withOpacity(0.1))
                                          : (_isDarkMode
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade100),
                                      border: Border.all(
                                        width: 2,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          examType['icon'],
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : (_isDarkMode
                                                  ? Colors.grey
                                                  : Colors.grey.shade600),
                                          size: 24,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          examType['name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? (_isDarkMode
                                                    ? AppTheme.accentColor
                                                    : AppTheme.primaryColor)
                                                : (_isDarkMode
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade800),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildSectionCard(
                            title: 'Contenu du Rapport',
                            icon: Icons.edit_document,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedReportType,
                                        decoration: InputDecoration(
                                          labelText: "Type de Rapport",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: _isDarkMode
                                                  ? Colors.grey.shade700
                                                  : AppTheme.accentColor,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            _reportTemplates[
                                                        _selectedReportType]
                                                    ?['icon'] ??
                                                Icons.description,
                                            color: _isDarkMode
                                                ? AppTheme.accentColor
                                                : AppTheme.primaryColor,
                                          ),
                                          filled: true,
                                          fillColor: _isDarkMode
                                              ? Color(0xFF1E1E1E)
                                              : Colors.white,
                                          labelStyle: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey.shade400
                                                : null,
                                          ),
                                        ),
                                        isExpanded: true,
                                        items: _reportTemplates.keys
                                            .map((String type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedReportType = newValue;
                                              _contentController.text =
                                                  _reportTemplates[newValue]
                                                          ?['content'] ??
                                                      '';
                                            });
                                          }
                                        },
                                        dropdownColor: _isDarkMode
                                            ? Color(0xFF2C2C2C)
                                            : Colors.white,
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.view_carousel_outlined,
                                        color: _isDarkMode
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showTemplateGallery = true;
                                        });
                                      },
                                      tooltip: "Voir la galerie de modèles",
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _isDarkMode
                                              ? Color(0xFF1E1E1E)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _isDarkMode
                                                  ? Colors.black
                                                      .withOpacity(0.2)
                                                  : Colors.grey
                                                      .withOpacity(0.1),
                                              blurRadius: 8,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: _isDarkMode
                                                ? Colors.grey.shade800
                                                : AppTheme.accentColor
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _contentController,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(16),
                                            alignLabelWithHint: true,
                                            hintText: "Contenu du rapport...",
                                            hintStyle: TextStyle(
                                              color: _isDarkMode
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade400,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          cursorColor: AppTheme.primaryColor,
                                          maxLines: 15,
                                          validator: (value) => value!.isEmpty
                                              ? "Ce champ est obligatoire"
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isListening
                                            ? Icons.mic
                                            : Icons.mic_none,
                                        color: _isListening
                                            ? AppTheme.primaryColor
                                            : (_isDarkMode
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade700),
                                      ),
                                      onPressed: _listen,
                                      iconSize: 28,
                                      tooltip: "Dicter votre rapport",
                                    ),
                                    if (_isListening)
                                      Text(
                                        "Écoute en cours...",
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(
                                        Icons.content_copy,
                                        color: _isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: _contentController.text));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Contenu copié dans le presse-papier"),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      tooltip: "Copier le contenu",
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: _isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                                "Réinitialiser le rapport?"),
                                            content: Text(
                                                "Voulez-vous vraiment effacer le contenu actuel et recharger le modèle?"),
                                            actions: [
                                              TextButton(
                                                child: Text("Annuler"),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: Text("Réinitialiser"),
                                                onPressed: () {
                                                  setState(() {
                                                    _contentController
                                                        .text = _reportTemplates[
                                                                _selectedReportType]
                                                            ?['content'] ??
                                                        '';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      tooltip: "Réinitialiser le contenu",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitRapport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDarkMode
                                  ? Colors.tealAccent.shade700
                                  : AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: Size(double.infinity, 54),
                              elevation: 3,
                              shadowColor: _isDarkMode
                                  ? Colors.black.withAlpha((0.5 * 255).toInt())
                                  : AppTheme.primaryColor
                                      .withAlpha((0.5 * 255).toInt()),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle),
                                SizedBox(width: 8),
                                Text(
                                  "Valider le rapport",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // TAB 2: MODELES
                GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _reportTemplates.length,
                  itemBuilder: (context, index) {
                    String key = _reportTemplates.keys.elementAt(index);
                    return _buildTemplateCard(key);
                  },
                ),
                // TAB 3: BROUILLONS
                _draftHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: _isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Pas encore de brouillons sauvegardés",
                              style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Vos brouillons apparaîtront ici",
                              style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _draftHistory.length,
                        itemBuilder: (context, index) {
                          final draft = _draftHistory[index];
                          final patientName =
                              draft['patientName'] ?? 'Sans nom';
                          final timestamp =
                              draft['timestamp'] ?? 'Date inconnue';

                          // Safe date parsing with fallback
                          DateTime parsedDate;
                          try {
                            parsedDate = DateTime.parse(timestamp);
                          } catch (e) {
                            parsedDate = DateTime
                                .now(); // Fallback to current date if parsing fails
                          }

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            color:
                                _isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isDarkMode
                                      ? AppTheme.accentColor.withOpacity(0.2)
                                      : AppTheme.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.description,
                                  color: _isDarkMode
                                      ? AppTheme.accentColor
                                      : AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                patientName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    "Type: ${draft['examType'] ?? 'Inconnu'} • ${draft['reportType'] ?? 'Standard'}",
                                    style: TextStyle(
                                      color: _isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Sauvegardé le ${parsedDate.day}/${parsedDate.month} à ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isDarkMode
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.restore,
                                  color: _isDarkMode
                                      ? AppTheme.accentColor
                                      : AppTheme.primaryColor,
                                ),
                                onPressed: () => _loadDraft(draft),
                                tooltip: "Restaurer ce brouillon",
                              ),
                              onTap: () => _loadDraft(draft),
                            ),
                          );
                        },
                      ),
              ],
            ),

            // Template gallery dialog
            if (_showTemplateGallery)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Text(
                                "Galerie de Modèles",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _showTemplateGallery = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _reportTemplates.length,
                            itemBuilder: (context, index) {
                              String key =
                                  _reportTemplates.keys.elementAt(index);
                              return _buildTemplateCard(key);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Success animation
            if (_animationController.isAnimating)
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                    controller: _animationController,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Load current radiologist from AuthViewModel
  Future<void> _loadCurrentRadiologist() async {
    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Check if user is radiologist
      if (authViewModel.role == 'radiologist') {
        setState(() {
          _currentRadiologist =
              authViewModel.currentRadiologist as Radiologist?;
        });

        // If we have the radiologist info, pre-populate signature if available
        if (_currentRadiologist != null &&
            _currentRadiologist!.signature != null) {
          // Potentially use the signature in reports
          print(
              "Radiologist signature available: ${_currentRadiologist!.signature != null}");
        }
      } else {
        print("Current user is not a radiologist");
      }
    } catch (e) {
      print("Error loading radiologist data: $e");
    }
  }
}
