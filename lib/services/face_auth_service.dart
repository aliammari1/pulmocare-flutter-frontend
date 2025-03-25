import 'dart:io';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:logging/logging.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:http_parser/http_parser.dart';

class FaceAuthService {
  final _logger = Logger('FaceAuthService');
  final String baseUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;

  Future<bool> verifyFace(String email, XFile imageFile) async {
    try {
      final file = File(imageFile.path);

      // Create form data for multipart request
      FormData formData = FormData.fromMap({
        'email': email,
        'image': await MultipartFile.fromFile(
          file.path,
          filename: 'face_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await dio.post(
        '$baseUrl/patient/verify-face',
        data: formData,
      );

      final result = response.data;
      return result['match'] ?? false;
    } catch (e) {
      _logger.warning('Face verification error: $e');
      return false;
    }
  }

  Future<String?> registerFace(String email, XFile imageFile) async {
    try {
      final file = File(imageFile.path);

      // Create form data for multipart request
      FormData formData = FormData.fromMap({
        'email': email,
        'image': await MultipartFile.fromFile(
          file.path,
          filename: 'face_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await dio.post(
        '$baseUrl/patient/register-face',
        data: formData,
      );

      final result = response.data;
      return result['message'];
    } catch (e) {
      _logger.warning('Face registration error: $e');
      return null;
    }
  }
}
