import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';

class VisitCardScanDialog extends StatefulWidget {
  const VisitCardScanDialog({super.key});

  @override
  _VisitCardScanDialogState createState() => _VisitCardScanDialogState();
}

class _VisitCardScanDialogState extends State<VisitCardScanDialog> {
  File? _image;
  bool _isLoading = false;
  String _errorMessage = '';
  final _picker = ImagePicker();
  final String _apiUrl = Config.apiBaseUrl;
  final Dio dio = DioHttpClient().dio;
  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _errorMessage = '';
        });
        _processImage();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to pick image');
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    try {
      String base64Image = base64Encode(_image!.readAsBytesSync());
      var response = await dio.post(
        '$_apiUrl/scan-visit-card',
        options: Options(headers: {"Content-Type": "application/json"}),
        data: json.encode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        Navigator.pop(context, data); // Return the extracted data
      } else {
        setState(() => _errorMessage = 'Failed to process image');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan Visit Card',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF35C5CF),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _getImage(ImageSource.camera),
                ),
                _buildOptionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _getImage(ImageSource.gallery),
                ),
              ],
            ),
            if (_isLoading) ...[
              SizedBox(height: 20),
              CircularProgressIndicator(color: Color(0xFF35C5CF)),
            ],
            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF35C5CF).withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF35C5CF), size: 32),
            SizedBox(height: 8),
            Text(label, style: TextStyle(color: Color(0xFF35C5CF))),
          ],
        ),
      ),
    );
  }
}
