import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
// Add this import
import '../models/medicament.dart';
import '../models/ordonnance.dart';
import 'api_service_ordonnance.dart';
import 'dart:io';

class OrdonnanceViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Ordonnance? _ordonnance;
  bool _isLoading = false;
  String? _errorMessage;
  List<Medicament>? _searchResults;
  List<Map<String, dynamic>>? _medecinOrdonnances;

  List<Medicament>? get searchResults => _searchResults;
  Ordonnance? get ordonnance => _ordonnance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>>? get medecinOrdonnances => _medecinOrdonnances;

  Future<List<Medicament>> fetchMedicaments(String query) async {
    if (query.isEmpty) return [];

    try {
      _setLoading(true);
      final results = await _apiService.searchMedicaments(query);
      _searchResults = results;
      _clearError();
      return results;
    } catch (e) {
      _setError('Erreur de recherche: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOrdonnance(Ordonnance ordonnance) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.createOrdonnance(ordonnance);
      _ordonnance = ordonnance;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentOrdonnance(Ordonnance ordonnance) {
    _ordonnance = ordonnance;
    notifyListeners();
  }

  Future<bool> sendOrdonnanceToPatient(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_ordonnance == null) {
        throw Exception('Aucune ordonnance à envoyer');
      }

      // Validation de l'email
      if (!email.contains('@') || !email.contains('.')) {
        throw Exception('Adresse email non valide');
      }

      final pdfBytes = await _ordonnance!.generatePdf();
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/ordonnance_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await File(path).writeAsBytes(pdfBytes);

      final emailSender = Email(
        body: 'Veuillez trouver ci-joint votre ordonnance.',
        subject: 'Votre Ordonnance Médicale',
        recipients: [email],
        attachmentPaths: [path],
        isHTML: false,
      );

      await FlutterEmailSender.send(emailSender);

      // Nettoyage du fichier temporaire
      await File(path).delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur d\'envoi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Uint8List?> downloadOrdonnancePdf() async {
    try {
      if (_ordonnance == null) {
        _errorMessage = 'Aucune ordonnance disponible';
        notifyListeners();
        return null;
      }

      _isLoading = true;
      notifyListeners();

      final pdfBytes = await _ordonnance!.generatePdf();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return pdfBytes;
    } catch (e) {
      _errorMessage = 'Erreur lors de la génération du PDF: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<dynamic>> loadDoctorOrdonnances(String medecinId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ordonnances = await _apiService.getDoctorOrdonnances(medecinId);
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
      return ordonnances;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des ordonnances: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Stream<List<dynamic>> getDoctorOrdonnancesStream(String medecinId) async* {
    if (medecinId.isEmpty) {
      yield [];
      return;
    }

    try {
      final ordonnances = await _apiService.getDoctorOrdonnances(medecinId);
      yield ordonnances;
    } catch (e) {
      print('Erreur lors du chargement des ordonnances: $e');
      yield [];
    }
  }

  Future<Uint8List?> generatePdfFromData(dynamic ordonnanceData) async {
    try {
      // Parse date correctly handling both string and map formats
      DateTime date;
      if (ordonnanceData['date'] is Map) {
        // Handle MongoDB date format
        date = DateTime.parse(ordonnanceData['date']['\$date']);
      } else {
        // Handle string date format
        date = DateTime.parse(ordonnanceData['date']);
      }

      final ordonnance = Ordonnance(
        id: ordonnanceData['_id'],
        patientId: ordonnanceData['patient_id'].toString(),
        medecinId: ordonnanceData['medecin_id'].toString(),
        clinique: ordonnanceData['clinique']?.toString() ?? '',
        specialite: ordonnanceData['specialite']?.toString() ?? '',
        date: date,
        medicaments: (ordonnanceData['medicaments'] as List)
            .map((m) => Medicament.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
      return await ordonnance.generatePdf();
    } catch (e) {
      _errorMessage = 'Erreur lors de la génération du PDF: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMedecinOrdonnances(String? medecinId,
      {int retryCount = 1}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (medecinId == null || medecinId.isEmpty) {
        throw Exception('ID médecin manquant');
      }

      _medecinOrdonnances = await _apiService.getMedecinOrdonnances(medecinId);
      _errorMessage = null;
    } catch (e) {
      print("Error in viewmodel: $e");
      if (retryCount > 0) {
        await Future.delayed(const Duration(seconds: 1));
        return loadMedecinOrdonnances(medecinId, retryCount: retryCount - 1);
      }
      _errorMessage = 'Erreur: $e';
      _medecinOrdonnances = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveCurrentOrdonnancePdf() async {
    if (_ordonnance == null || _ordonnance?.id == null) return null;

    try {
      final pdfBytes = await _ordonnance!.generatePdf();
      return await _apiService.saveOrdonnancePdf(_ordonnance!.id!, pdfBytes);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Uint8List?> viewOrdonnancePdf(String ordonnanceId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final pdfBytes = await _apiService.getOrdonnancePdf(ordonnanceId);
      if (pdfBytes == null) throw Exception('Impossible de récupérer le PDF');

      _isLoading = false;
      notifyListeners();
      return pdfBytes;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du PDF: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Uint8List?> previewExistingOrdonnance(String ordonnanceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Récupérer d'abord les données de l'ordonnance
      final ordonnanceData =
          await _apiService.getMedecinOrdonnance(ordonnanceId);
      if (ordonnanceData == null) {
        throw Exception('Ordonnance non trouvée');
      }

      // Générer le PDF à partir des données
      final pdfBytes = await generatePdfFromData(ordonnanceData);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return pdfBytes;
    } catch (e) {
      _errorMessage = 'Erreur lors de la prévisualisation: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSingleOrdonnance(String ordonnanceId) async {
    try {
      final ordonnanceData =
          await _apiService.getSingleOrdonnance(ordonnanceId);
      if (ordonnanceData == null) {
        throw Exception('Ordonnance introuvable');
      }
      return ordonnanceData;
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération de l\'ordonnance: $e';
      notifyListeners();
      return null;
    }
  }

  void clearResults() {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> sendOrdonnancePdfToEmail(
    String email,
    Uint8List pdfBytes,
    String patientId,
  ) async {
    try {
      if (!isValidEmail(email)) {
        throw Exception('Adresse email invalide');
      }

      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/ordonnance_${patientId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await File(path).writeAsBytes(pdfBytes);

      final emailSender = Email(
        body: '''
Bonjour,

Veuillez trouver ci-joint votre ordonnance médicale.

Cordialement,
Votre médecin
''',
        subject: 'Ordonnance Médicale - Patient $patientId',
        recipients: [email],
        attachmentPaths: [path],
        isHTML: false,
      );

      await FlutterEmailSender.send(emailSender);

      // Nettoyage du fichier temporaire
      await File(path).delete();

      return true;
    } catch (e) {
      _errorMessage = 'Erreur d\'envoi: $e';
      notifyListeners();
      return false;
    }
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  Future<Map<String, String>> getPatientEmail(String patientId) async {
    try {
      final result = await _apiService.getPatientEmail(patientId);
      return result;
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération de l\'email: $e';
      notifyListeners();
      return {};
    }
  }

  Future<bool> handleOrdonnanceCreation(Ordonnance ordonnance) async {
    try {
      await addOrdonnance(ordonnance);

      if (ordonnance.id != null) {
        final pdfBytes = await ordonnance.generatePdf();
        await _apiService.saveOrdonnancePdf(ordonnance.id!, pdfBytes);
      }

      return true;
    } catch (e) {
      print('Error in handleOrdonnanceCreation: $e');
      return false;
    }
  }

  Future<bool> createOrdonnance(Ordonnance ordonnance) async {
    try {
      _setLoading(true);
      _clearError();

      // Validation des données
      if (ordonnance.patientId.isEmpty || ordonnance.medecinId.isEmpty) {
        throw Exception('ID patient et médecin requis');
      }

      if (ordonnance.medicaments.isEmpty) {
        throw Exception('Au moins un médicament est requis');
      }

      final response = await _apiService.createOrdonnance(ordonnance);

      // Mettre à jour l'ID de l'ordonnance avec celui retourné par le serveur
      if (response['id'] != null) {
        ordonnance.id = response['id'];
        _ordonnance = ordonnance;
      }

      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      print('\n=== ERREUR DANS LE VIEWMODEL ===');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      print('Stack trace:\n$stackTrace');

      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<String?> savePdf(String ordonnanceId, Uint8List pdfBytes) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (ordonnanceId.isEmpty) {
        throw Exception('ID de l\'ordonnance non défini');
      }

      final filename =
          await _apiService.saveOrdonnancePdf(ordonnanceId, pdfBytes);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return filename;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors de la sauvegarde du PDF: $e';
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
