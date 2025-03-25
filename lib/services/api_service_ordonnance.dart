import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../models/medicament.dart';
import '../models/ordonnance.dart';

class ApiService {
  static const String openFdaBaseUrl = 'https://api.fda.gov/drug';
  // Mise à jour de la clé API FDA
  static const String apiKey = '4DpshbRmBvQ4k0hg27yZT2zEEFvYVHbqa8WHlhan';
  static const String _apiUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;
  Future<List<Medicament>> searchMedicaments(String query) async {
    try {
      print("Searching medications with query: $query");

      // Construire la requête avec un OU logique pour le nom et le dosage
      final searchQuery =
          'openfda.brand_name:"$query" OR openfda.strength:"$query"';

      final response = await dio.get(
        '$openFdaBaseUrl/label.json'
        '?api_key=$apiKey'
        '&search=$searchQuery'
        '&limit=20',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        if (data['results'] != null) {
          final results = data['results'] as List;
          return results.map((item) {
            final openfda = item['openfda'] ?? {};

            // Extract more detailed information
            final brandName = (openfda['brand_name'] as List?)?.first ?? '';
            final genericName = (openfda['generic_name'] as List?)?.first ?? '';
            final dosageForm = (openfda['dosage_form'] as List?)?.first ?? '';
            final strength = (openfda['strength'] as List?)?.first ?? '';
            final manufacturer =
                (openfda['manufacturer_name'] as List?)?.first ?? '';

            // Get detailed dosage instructions with fallback
            String dosageInstructions = '';
            if (item['dosage_and_administration'] != null) {
              dosageInstructions = (item['dosage_and_administration'] as List)
                  .map((instruction) => instruction.toString())
                  .where((instruction) => instruction.isNotEmpty)
                  .join('\n');
            } else if (item['dosage_forms_and_strengths'] != null) {
              dosageInstructions = (item['dosage_forms_and_strengths'] as List)
                  .map((instruction) => instruction.toString())
                  .where((instruction) => instruction.isNotEmpty)
                  .join('\n');
            }

            // Get route of administration
            final route = (openfda['route'] as List?)?.first ?? '';

            // Combine dosage form and strength if available
            final dosage = [dosageForm, strength]
                .where((element) => element.isNotEmpty)
                .join(' ');

            return Medicament(
              name: brandName,
              usage: genericName,
              dosage: dosage,
              posologie: _formatPosologie(dosageInstructions),
              laboratoire: manufacturer,
              route: route,
              warning: _extractWarnings(item['warnings'] ?? []),
            );
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
        }
      }
    } catch (e) {
      print('Erreur recherche OpenFDA: $e');
    }
    return [];
  }

  String _formatPosologie(String instructions) {
    if (instructions.isEmpty) return '';

    // Clean up and format the instructions
    return instructions
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n• ');
  }

  String _extractWarnings(List<dynamic> warnings) {
    return warnings
        .map((w) => w.toString())
        .where((w) => w.isNotEmpty)
        .join('\n• ');
  }

  Future<bool> validateOrdonnance(Ordonnance ordonnance) async {
    if (ordonnance.patientId.isEmpty || ordonnance.medecinId.isEmpty) {
      throw Exception('ID patient et ID médecin sont requis');
    }
    if (ordonnance.medicaments.isEmpty) {
      throw Exception('Au moins un médicament est requis');
    }
    return true;
  }

  Future<Map<String, dynamic>> createOrdonnance(Ordonnance ordonnance) async {
    try {
      print('\n=== ENVOI DE LA REQUÊTE ===');
      final url = '$_apiUrl/ordonnances';
      final body = jsonEncode(ordonnance.toJson());

      print('URL: $url');
      print('Body: $body');

      final response = await dio
          .post(
            url,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
            data: body,
          )
          .timeout(const Duration(seconds: 30));

      print('\n=== RÉPONSE DU SERVEUR ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.data}');

      if (response.statusCode == 201) {
        return json.decode(response.data);
      }

      throw Exception('Erreur HTTP ${response.statusCode}: ${response.data}');
    } catch (e) {
      print('\n=== ERREUR DE CRÉATION ===');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      rethrow;
    }
  }

  Future<List<Ordonnance>> getDoctorOrdonnances(String medecinId) async {
    final response = await dio.get(
      '$_apiUrl/ordonnances/doctor/$medecinId',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.data);
      return data.map((json) => Ordonnance.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des ordonnances');
  }

  Future<String> savePdf(
      String medecinId, String ordonnanceId, Uint8List pdfBytes) async {
    try {
      FormData formData = FormData.fromMap({
        'pdf': MultipartFile.fromBytes(
          pdfBytes,
          filename: 'ordonnance.pdf',
          contentType: MediaType('application', 'pdf'),
        ),
        'medecin_id': medecinId,
        'ordonnance_id': ordonnanceId,
      });

      final response = await dio.post(
        '$_apiUrl/pdfs/save',
        data: formData,
      );

      if (response.statusCode == 201) {
        return response.data['filename'];
      }
      throw Exception(response.data['error']);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du PDF: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMedecinPdfs(String medecinId) async {
    final response = await dio.get('$_apiUrl/pdfs/medecin/$medecinId');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    throw Exception('Erreur lors de la récupération des PDFs');
  }

  Future<Uint8List> downloadPdf(String filename) async {
    final response = await dio.get(
      '$_apiUrl/pdfs/download/$filename',
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      return Uint8List.fromList(response.data);
    }
    throw Exception('Erreur lors du téléchargement du PDF');
  }

  Future<List<Map<String, dynamic>>> getMedecinOrdonnances(
      String medecinId) async {
    try {
      print("Fetching ordonnances for medecin: $medecinId");
      final response = await dio.get(
        '$_apiUrl/ordonnances/medecin/$medecinId/ordonnances',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in API service: $e");
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<String> saveOrdonnancePdf(
      String ordonnanceId, Uint8List pdfBytes) async {
    try {
      FormData formData = FormData.fromMap({
        'pdf': MultipartFile.fromBytes(
          pdfBytes,
          filename: 'ordonnance.pdf',
          contentType: MediaType('application', 'pdf'),
        ),
      });

      final response = await dio.post(
        '$_apiUrl/ordonnances/$ordonnanceId/pdf',
        data: formData,
      );

      if (response.statusCode == 201) {
        return response.data['filename'];
      }
      throw Exception(response.data['error']);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du PDF: $e');
    }
  }

  Future<Uint8List?> getOrdonnancePdf(String ordonnanceId) async {
    try {
      final response = await dio.get(
        '$_apiUrl/ordonnances/$ordonnanceId/pdf',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      print("Failed to get PDF: ${response.statusCode}");
      return null;
    } catch (e) {
      print("Error getting PDF: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMedecinOrdonnance(
      String ordonnanceId) async {
    try {
      print("Fetching ordonnance: $ordonnanceId");
      final response = await dio.get('$_apiUrl/ordonnances/$ordonnanceId');

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error getting ordonnance: $e');
      return null;
    }
  }

  Future<Uint8List?> generatePdfFromData(
      Map<String, dynamic> ordonnance) async {
    try {
      final response = await dio.post(
        '$_apiUrl/generate-pdf',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
        data: ordonnance,
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSingleOrdonnance(String ordonnanceId) async {
    try {
      print("Fetching ordonnance: $ordonnanceId");
      final response = await dio.get('$_apiUrl/ordonnances/$ordonnanceId');

      if (response.statusCode == 200) {
        return response.data;
      }
      print(
          'Failed to get ordonnance: ${response.statusCode} - ${response.data}');
      return null;
    } catch (e) {
      print('Error getting ordonnance: $e');
      return null;
    }
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  Future<Map<String, String>> getPatientEmail(String patientId) async {
    try {
      final response = await dio.get('$_apiUrl/patients/$patientId/email');

      if (response.statusCode == 200) {
        return Map<String, String>.from(response.data);
      }
      return {};
    } catch (e) {
      print('Error getting patient email: $e');
      return {};
    }
  }

  Future<bool> sendOrdonnancePdf(
      String emailAddress, Uint8List pdfBytes, String patientId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ordonnance_$patientId.pdf');
      await file.writeAsBytes(pdfBytes);

      final email = Email(
        body: 'Veuillez trouver ci-joint votre ordonnance médicale.',
        subject: 'Votre ordonnance médicale',
        recipients: [emailAddress],
        attachmentPaths: [file.path],
      );

      await FlutterEmailSender.send(email);
      await file.delete();
      return true;
    } catch (e) {
      print('Error sending PDF: $e');
      return false;
    }
  }
}
