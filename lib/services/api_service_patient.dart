import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use the correct localhost URL for your platform
  static const String baseUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/login',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
        data: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.data);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      return data;
    } catch (e) {
      throw Exception('Connection failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/register',
        options: Options(headers: {"Content-Type": "application/json"}),
        data: jsonEncode(userData),
      );

      return jsonDecode(response.data);
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await dio.get(
        '$baseUrl/profile',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );

      return jsonDecode(response.data);
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
}
