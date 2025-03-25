import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import '../models/ordonnance.dart';

class OrdonnanceService {
  // Remplacer la référence à Constants.apiBaseUrl par une valeur directe
  final String baseUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;

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
      final response = await dio.post(
        '$baseUrl/api/ordonnances',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Accept',
          },
        ),
        data: ordonnance.toJson(),
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la création: ${response.data}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
