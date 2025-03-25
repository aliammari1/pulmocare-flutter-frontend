import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/utils/DioClient.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PatientAuthViewModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _token = '';
  String _userId = '';
  String _userEmail = '';
  String _userName = '';
  final Dio dio = DioHttpClient().dio; // Dio instance for API requests
  // Base URL for API requests
  final String _baseUrl = Config.apiBaseUrl;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get token => _token;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;

  // Initialize with stored values
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _userId = prefs.getString('userId') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _userName = prefs.getString('userName') ?? '';

    if (_token.isNotEmpty) {
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  // Patient signup
  Future<void> patientSignup(
      String name, String email, String password, String phoneNumber) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await dio.post(
        '$_baseUrl/patient/signup',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        // Auto login after signup
        await login(email, password, false);
      } else {
        final responseData = jsonDecode(response.data);
        _errorMessage = responseData['error'] ?? 'Signup failed';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login (works for both doctor and patient)
  Future<void> login(String email, String password,
      [bool isDoctor = true]) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Use the appropriate endpoint based on user type
      final endpoint = /*isDoctor ? '/doctor/login' :*/ '/patient/login';

      final response = await dio.post(
        '$_baseUrl$endpoint',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        _token = responseData['token'];
        _userId = responseData['id'];
        _userEmail = responseData['email'];
        _userName = responseData['name'];
        _isAuthenticated = true;

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token);
        prefs.setString('userId', _userId);
        prefs.setString('userEmail', _userEmail);
        prefs.setString('userName', _userName);
      } else {
        final responseData = jsonDecode(response.data);
        _errorMessage = responseData['error'] ?? 'Authentication failed';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with Face ID
  Future<void> loginWithFace() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await dio.post(
        '$_baseUrl/patient/login/face',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.data);
        _token = responseData['token'];
        _userId = responseData['id'];
        _userEmail = responseData['email'];
        _userName = responseData['name'];
        _isAuthenticated = true;

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token);
        prefs.setString('userId', _userId);
        prefs.setString('userEmail', _userEmail);
        prefs.setString('userName', _userName);
      } else {
        final responseData = jsonDecode(response.data);
        _errorMessage = responseData['error'] ?? 'Face authentication failed';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _token = '';
    _userId = '';
    _userEmail = '';
    _userName = '';
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userId');
    prefs.remove('userEmail');
    prefs.remove('userName');

    notifyListeners();
  }

  // Password reset request
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Choose the appropriate endpoint based on user type
      final endpoint = '/patient/forgot-password'; // Default to patient

      final response = await dio.post(
        '$_baseUrl$endpoint',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.data);
        _errorMessage = responseData['error'] ?? 'Failed to send reset code';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String email, String otp) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await dio.post(
        '$_baseUrl/patient/verify-otp',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.data);
        _errorMessage = responseData['error'] ?? 'Invalid OTP';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(
      String email, String otp, String newPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await dio.post(
        '$_baseUrl/patient/reset-password',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.data);
        _errorMessage = responseData['error'] ?? 'Failed to reset password';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
