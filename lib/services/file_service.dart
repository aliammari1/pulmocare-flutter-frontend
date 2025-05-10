import 'dart:io';
import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/models/medical_file.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/foundation.dart';

class FileService {
  final String baseUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;

  // Upload a file with metadata
  Future<String> uploadFile(File file, String fileName,
      {String bucket = 'medicalimages',
      String? folder, // folder is patientId
      Map<String, dynamic>? metadata}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    // Add authorization token to headers
    dio.options.headers['Authorization'] = 'Bearer $token';

    // Process metadata to match MinIO's expected format
    // The backend will add the x-amz-meta- prefix to each key
    final formattedMetadata = <String, dynamic>{};
    if (metadata != null) {
      metadata.forEach((key, value) {
        // Convert all values to strings as MinIO expects string metadata
        formattedMetadata[key] = value.toString();
      });
    }

    // Create form data for the upload
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'bucket': bucket,
      if (folder != null) 'folder': folder,
      // Send metadata items individually to match backend expectations
      if (formattedMetadata.isNotEmpty) 'metadata': formattedMetadata,
    });

    try {
      // Post with progress tracking
      final response = await dio.post(
        '$baseUrl/files/upload',
        data: formData,
        onSendProgress: (int sent, int total) {
          print('${(sent / total * 100).toStringAsFixed(0)}% uploaded');
        },
      );

      // Check if upload was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['object_name']; // The backend returns object_name
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<List<MedicalFile>> listFiles({
    required String bucket,
    String? patientId,
    int limit = 100,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    try {
      String url = '$baseUrl/files/$bucket';
      Map<String, dynamic> queryParams = {'limit': limit};

      if (patientId != null) {
        queryParams['prefix'] = patientId;
      }

      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['files'];
        return data.map((file) => MedicalFile.fromJson(file)).toList();
      } else {
        throw Exception('Failed to retrieve files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching files: $e');
    }
  }

  // Get details of a single medical file
  Future<MedicalFile> getFileDetails(String bucket, String objectName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    try {
      final response = await dio.get(
        '$baseUrl/files/$bucket/$objectName',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return MedicalFile.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to retrieve file details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching file details: $e');
    }
  }

  // Delete a file
  Future<bool> deleteFile(String bucket, String objectName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    try {
      final response = await dio.delete(
        '$baseUrl/files/$bucket/$objectName',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  // Update metadata for a file
  Future<bool> updateFileMetadata(
      String bucket, String objectName, Map<String, dynamic> metadata) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    // Format metadata for MinIO compatibility
    final formattedMetadata = <String, String>{};
    metadata.forEach((key, value) {
      // Convert all values to strings as MinIO expects string metadata
      formattedMetadata[key] = value.toString();
    });

    try {
      final response = await dio.put(
        '$baseUrl/files/$bucket/$objectName/metadata',
        data: formattedMetadata,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating file metadata: $e');
    }
  }

  // Fetch medical files for a patient (convenience method)
  Future<List<MedicalFile>> getPatientMedicalFiles(String patientId) async {
    return listFiles(
      bucket: 'patientdocuments',
      patientId: patientId,
    );
  }

  // Download a file
  Future<String> downloadFile(MedicalFile file) async {
    try {
      // Create a temporary file path
      final appDir = await getTemporaryDirectory();
      final filePath = '${appDir.path}/${file.filename ?? 'downloaded_file'}';

      // Start the download
      await dio.download(
        file.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
                '${(received / total * 100).toStringAsFixed(0)}% downloaded');
          }
        },
      );

      // If the file is an image or video, save it to the gallery
      if (file.contentType.startsWith('image/')) {
        // Request storage permission
        if (await Permission.storage.request().isGranted) {
          final bytes = await File(filePath).readAsBytes();
          final extension = file.filename?.split('.').last ?? 'jpg';

          // Save image to gallery using image_gallery_saver
          await ImageGallerySaver.saveImage(
            bytes,
            quality: 100,
            name: '${DateTime.now().millisecondsSinceEpoch}.$extension',
          );

          debugPrint('Image saved to gallery');
        }
      } else if (file.contentType.startsWith('video/')) {
        // For videos, we'll leave the file in the temporary directory
        // and allow the user to open it directly
        debugPrint('Video downloaded to: $filePath');
      }

      // For documents or other types, just return the path
      return filePath;
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  // Convenience method to get the pre-signed download URL for a file
  Future<String> getDownloadUrl(String bucket, String objectName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    try {
      final response = await dio.get(
        '$baseUrl/files/$bucket/$objectName/url',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['download_url'];
      } else {
        throw Exception('Failed to get download URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting download URL: $e');
    }
  }
}
