import 'package:http/http.dart' as http;
import 'package:medapp/config.dart';
import '../models/ordonnance.dart';

class OrdonnanceService {
  // Remplacer la référence à Constants.apiBaseUrl par une valeur directe
  final String baseUrl = Config.apiBaseUrl;

  Future<bool> validateOrdonnance(Ordonnance ordonnance) async {
    if (ordonnance.patientId.isEmpty || ordonnance.medecinId.isEmpty) {
      return false;
    }
    if (ordonnance.medicaments.isEmpty) {
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> createOrdonnance(Ordonnance ordonnance) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ordonnances'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Accept',
        },
        body: ordonnance.toJson().toString(),
      );

      if (response.statusCode == 201) {
        return response.body as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la création: ${response.body}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
