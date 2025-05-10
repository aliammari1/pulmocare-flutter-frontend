import 'package:flutter/material.dart';
import 'package:medapp/config.dart';
import 'package:medapp/models/user.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/medical_file.dart';
import '../providers/user_provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class AuthViewModel extends ChangeNotifier {
  User? currentUser;
  bool isAuthenticated = false;
  String errorMessage = '';
  String? authToken;
  String? refreshToken; // Added refresh token field

  // Add specific user type properties
  Doctor? currentDoctor;
  User? currentPatient;
  User? currentRadiologist;

  final Dio dio = DioHttpClient().dio;
  static const String baseUrl = Config.apiBaseUrl;

  // Role getter for navigation with robust fallback
  String get role {
    if (currentDoctor != null) return 'doctor';
    if (currentRadiologist != null) return 'radiologist';
    if (currentPatient != null) return 'patient';

    // Try to get the role from SharedPreferences as fallback
    _getSavedRole().then((savedRole) {
      if (savedRole != null && savedRole.isNotEmpty) {
        print('Retrieved role from SharedPreferences: $savedRole');
        return savedRole;
      }
    });

    return '';
  }

  // Constructor to initialize and check token
  AuthViewModel() {
    checkAuthToken();
  }

  // Check if a token exists in SharedPreferences and set auth state
  Future<void> checkAuthToken() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      authToken = token;

      // Also retrieve userId and role if available
      final userId = await getUserId();
      final userRole = await _getSavedRole();

      if (userId != null && userId.isNotEmpty) {
        print('Retrieved stored user ID: $userId');
      }

      if (userRole != null && userRole.isNotEmpty) {
        print('Retrieved stored user role: $userRole');
      }

      // Fetch user profile here
      try {
        await fetchProfile();

        // Verify if we have a valid role after fetching the profile
        if (role.isEmpty) {
          print(
              'Warning: User is authenticated but role is empty. Forcing re-login.');
          await logout(null); // Force logout if role is empty
          isAuthenticated = false;
        } else {
          isAuthenticated = true;
        }
      } catch (e) {
        print('Error fetching profile: $e');
        // Keep user logged in but mark for profile refresh
      }

      notifyListeners();
    }
  }

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Remove token from SharedPreferences
  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Save refresh token to SharedPreferences
  Future<void> saveRefreshToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', token);
  }

  // Get refresh token from SharedPreferences
  Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  // Remove refresh token from SharedPreferences
  Future<void> removeRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
  }

  // Save user role to SharedPreferences
  Future<void> saveUserRole(String userRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', userRole);
    print('Role saved to SharedPreferences: $userRole');
  }

  // Get user role from SharedPreferences
  Future<String?> _getSavedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    return role;
  }

  // Remove user role from SharedPreferences
  Future<void> removeUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
  }

  // Save user ID to SharedPreferences
  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Get user ID from SharedPreferences
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Remove user ID from SharedPreferences
  Future<void> removeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Synchronize user data with UserProvider
  void syncWithUserProvider(UserProvider userProvider) {
    userProvider.updateUserFromAuth(
      user: currentUser,
      doctor: currentDoctor,
      patient: currentPatient,
      radiologist: currentRadiologist,
    );
  }

  Future<void> login(String email, String password, UserRole role) async {
    try {
      print('Attempting login with: $email, role: $role'); // Debug log

      final response = await dio.post(
        '$baseUrl/auth/login',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          // Increase timeout for slow connections
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: json.encode({
          'email': email,
          'password': password,
          'role': _getRoleString(role),
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Updated to handle your JWT response format
        authToken = data['access_token'];
        refreshToken =
            data['refresh_token']; // Store refresh token from response

        if (authToken == null) {
          errorMessage = 'Invalid token received';
          isAuthenticated = false;
          notifyListeners();
          return;
        }

        // Save tokens to SharedPreferences
        await saveToken(authToken!);
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken!);
        }

        // Get user information from the token or response
        final String? userId = data['user_id'];
        final String? userEmail = data['email'];
        final String? userName = data['name'];

        // Save user ID to SharedPreferences
        if (userId != null && userId.isNotEmpty) {
          await saveUserId(userId);
        }

        // Clear all user objects first
        currentDoctor = null;
        currentPatient = null;
        currentRadiologist = null;

        // Create user based on role information
        final roleString =
            data['role'].toString().toLowerCase().split("-").first;

        // Save the role to SharedPreferences immediately
        await saveUserRole(roleString);
        print('Role from login: $roleString');

        switch (roleString) {
          case 'doctor':
            currentDoctor = Doctor(
              id: userId ?? '',
              name: userName ?? '',
              email: userEmail ?? '',
              specialty: data['specialty'] ?? '',
              phone: data['phone'] ?? '',
              address: data['address'] ?? '',
              profilePicture: data['profile_picture'],
              isVerified: data['is_verified'] ?? false,
              verificationDetails: data['verification_details'],
              signature: data['signature'],
              bio: data['bio'],
            );
            currentUser = currentDoctor;
            break;
          case 'patient':
            // Parse medical files if available
            List<MedicalFile> medicalFiles = [];
            if (data['medical_files'] != null) {
              try {
                medicalFiles = (data['medical_files'] as List)
                    .map((file) => MedicalFile.fromJson(file))
                    .toList();
              } catch (e) {
                print('Error parsing medical files: $e');
              }
            }

            // Create a Patient object with all available fields
            currentPatient = Patient(
              id: userId ?? '',
              name: userName ?? '',
              email: userEmail ?? '',
              phone: data['phone'] ?? '',
              address: data['address'] ?? '',
              profilePicture: data['profile_picture'],
              date_of_birth: data['date_of_birth'],
              blood_type: data['blood_type'],
              height: data['height']?.toString(),
              weight: data['weight']?.toString(),
              allergies: data['allergies'] != null
                  ? _parseAllergiesFromData(data['allergies'])
                  : null,
              medical_history: data['medical_history'] is List
                  ? List<String>.from(data['medical_history'])
                  : null,
              medical_files: medicalFiles,
            );
            currentUser = currentPatient;
            break;
          case 'radiologist':
            currentRadiologist = User(
              id: userId ?? '',
              name: userName ?? '',
              email: userEmail ?? '',
              phone: data['phone'] ?? '',
              address: data['address'] ?? '',
              profilePicture: data['profile_picture'],
            );
            currentUser = currentRadiologist;
            break;
          default:
            // Create a basic user if role is not recognized
            currentUser = User(
              id: userId ?? '',
              name: userName ?? '',
              email: userEmail ?? '',
              phone: data['phone'] ?? '',
              address: data['address'] ?? '',
              profilePicture: data['profile_picture'],
            );
            break;
        }

        isAuthenticated = true;
        errorMessage = '';

        // Fetch additional profile details if needed
        await fetchProfile();
      } else {
        errorMessage = 'Login failed: ${response.statusMessage}';
        isAuthenticated = false;
      }
    } on DioException catch (e) {
      print(
          'Login DioError: ${e.type} - ${e.message}'); // Better Dio error logging

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection and try again.';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      isAuthenticated = false;
    } catch (e) {
      print('Login error: $e'); // Debug log
      errorMessage = 'Network error: ${e.toString()}';
      isAuthenticated = false;
    }
    notifyListeners();
  }

  String _getRoleString(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return 'doctor';
      case UserRole.patient:
        return 'patient';
      case UserRole.radiologist:
        return 'radiologist';
      default:
        return 'patient';
    }
  }

  Future<void> signup(
    String name,
    String email,
    String password,
    String specialty,
    String phone,
    String address,
    UserRole role, {
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      // Create the base request data
      final Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'role': _getRoleString(role),
      };

      // Add role-specific fields
      if (role == UserRole.doctor) {
        requestData['specialty'] = specialty;

        // Add doctor-specific fields if available
        if (additionalFields != null) {
          requestData['licenseNumber'] = additionalFields['licenseNumber'];
          requestData['hospital'] = additionalFields['hospital'];
          requestData['education'] = additionalFields['education'];
          requestData['experience'] = additionalFields['experience'];
        }
      } else if (role == UserRole.radiologist) {
        // Add radiologist-specific fields if available
        if (additionalFields != null) {
          requestData['licenseNumber'] = additionalFields['licenseNumber'];
          requestData['hospital'] = additionalFields['hospital'];
          requestData['education'] = additionalFields['education'];
          requestData['experience'] = additionalFields['experience'];
        }
      } else if (role == UserRole.patient) {
        // Add patient-specific fields if available
        if (additionalFields != null) {
          requestData['date_of_birth'] = additionalFields['date_of_birth'];
          requestData['blood_type'] = additionalFields['blood_type'];
          requestData['height'] = additionalFields['height'];
          requestData['weight'] = additionalFields['weight'];

          // Ensure allergies is properly handled as a JSON-serializable list
          if (additionalFields.containsKey('allergies')) {
            var allergies = additionalFields['allergies'];
            if (allergies is String) {
              allergies = allergies
                  .split(',')
                  .where((e) => e.trim().isNotEmpty)
                  .map((e) => e.trim())
                  .toList();
            }
            requestData['allergies'] = allergies;
          } else {
            requestData['allergies'] = [];
          }

          // Ensure medical_history is sent as a list
          var medicalHistory = additionalFields['medical_history'];
          if (medicalHistory is String) {
            // Convert string to a list
            medicalHistory = [medicalHistory];
          }
          requestData['medical_history'] = medicalHistory;

          // Handle medical documents (convert from IDs to MedicalFile objects)
          if (additionalFields.containsKey('medicalDocuments')) {
            var fileIds = additionalFields['medicalDocuments'];
            if (fileIds != null && fileIds.isNotEmpty) {
              List<Map<String, dynamic>> medicalFiles = [];

              for (var fileId in fileIds) {
                // Create a medical file object for each file ID
                medicalFiles.add({
                  'id': fileId,
                  'fileName':
                      'Medical Document', // Default name that will be updated from server
                  'fileType':
                      'application/octet-stream', // Default type that will be updated from server
                  'fileUrl':
                      '$baseUrl/files/$fileId', // Assuming this is the URL pattern
                  'uploadedAt': DateTime.now().toIso8601String(),
                  'uploadedBy': email, // Using email as identifier for now
                  'description':
                      'Medical history document uploaded during signup'
                });
              }

              requestData['medical_files'] = medicalFiles;
            }
          }
        }
      }

      // Log the request data for debugging
      print(
          'Signup request data: $requestData'); // Log the full JSON for debugging
      final jsonData = json.encode(requestData);
      print('Signup JSON data: $jsonData');

      final response = await dio.post(
        '$baseUrl/auth/register',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          // Add reasonable timeouts
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: jsonData,
      );

      if (response.statusCode == 201) {
        // On successful signup, proceed to login
        await login(email, password, role);
      } else {
        // Handle non-successful status codes
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        errorMessage = data['error'] ??
            'Signup failed with status code: ${response.statusCode}';
        isAuthenticated = false;
      }
    } on DioException catch (e) {
      // Handle Dio specific errors with improved error messages
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timed out. Please try again.';
      } else if (e.type == DioExceptionType.badResponse) {
        // Try to extract error message from response
        final responseData = e.response?.data;
        if (responseData != null) {
          try {
            final data = responseData is String
                ? json.decode(responseData)
                : responseData;
            errorMessage = data['error'] ??
                'Signup failed with status code: ${e.response?.statusCode}';
          } catch (_) {
            errorMessage =
                'Signup failed with status code: ${e.response?.statusCode}';
          }
        } else {
          errorMessage =
              'Signup failed with status code: ${e.response?.statusCode}';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      isAuthenticated = false;
    } on TimeoutException catch (_) {
      errorMessage = 'Connection timed out. Please try again.';
      isAuthenticated = false;
    } on SocketException catch (_) {
      errorMessage = 'Network error. Please check your internet connection.';
      isAuthenticated = false;
    } catch (e) {
      errorMessage = 'Error during signup: ${e.toString()}';
      isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    errorMessage = '';
    try {
      final response = await dio.post(
        '$baseUrl/auth/forgot-password',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode({'email': email}),
      );
      if (response.statusCode != 200) {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
    }
    notifyListeners();
  }

  Future<bool> verifyOTP(String email, String otp) async {
    errorMessage = '';
    try {
      final response = await dio.post(
        '$baseUrl/auth/verify-otp',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Invalid OTP';
        return false;
      }
    } catch (e) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> resetPassword(
      String email, String otp, String newPassword) async {
    errorMessage = '';
    try {
      final response = await dio.post(
        '$baseUrl/auth/reset-password',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Failed to reset password';
        return false;
      }
    } catch (e) {
      errorMessage =
          'Connection failed. Please check your internet connection.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    // Get token if not already set
    authToken ??= await getToken();

    if (authToken == null) return;

    try {
      final response = await dio.get(
        '$baseUrl/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          // Increase timeout for profile fetch
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String role =
            data['role'].toString().toLowerCase().split("-").first;

        // Save the role to SharedPreferences
        if (role.isNotEmpty) {
          await saveUserRole(role);
          print('Role from profile: $role');
        } else {
          // Try to get the saved role as a fallback
          final savedRole = await _getSavedRole();
          if (savedRole != null && savedRole.isNotEmpty) {
            print('Using saved role: $savedRole');
          } else {
            print('No role found in profile or saved preferences');
          }
        }

        // Update user data based on type
        switch (role) {
          case 'doctor':
            currentDoctor = Doctor(
              id: data['id'] ?? currentDoctor?.id ?? '',
              name: data['name'] ?? currentDoctor?.name ?? '',
              email: data['email'] ?? currentDoctor?.email ?? '',
              specialty: data['specialty'] ?? currentDoctor?.specialty ?? '',
              phone: data['phone'] ?? currentDoctor?.phone ?? '',
              address: data['address'] ?? currentDoctor?.address ?? '',
              profilePicture:
                  data['profile_picture'] ?? currentDoctor?.profilePicture,
              isVerified:
                  data['is_verified'] ?? currentDoctor?.isVerified ?? false,
              verificationDetails: data['verification_details'] ??
                  currentDoctor?.verificationDetails,
              signature: data['signature'] ?? currentDoctor?.signature,
              bio: data['bio'] ?? currentDoctor?.bio,
            );
            currentUser = currentDoctor;
            break;
          case 'patient':
            // Parse medical files if available
            List<MedicalFile> medicalFiles = [];
            if (data['medical_files'] != null) {
              try {
                medicalFiles = (data['medical_files'] as List)
                    .map((file) => MedicalFile.fromJson(file))
                    .toList();
              } catch (e) {
                print('Error parsing medical files: $e');
              }
            }

            // Create a Patient object with all available fields
            currentPatient = Patient(
              id: data['id'] ?? currentPatient?.id ?? '',
              name: data['name'] ?? currentPatient?.name ?? '',
              email: data['email'] ?? currentPatient?.email ?? '',
              phone: data['phone'] ?? currentPatient?.phone ?? '',
              address: data['address'] ?? currentPatient?.address ?? '',
              profilePicture:
                  data['profile_picture'] ?? currentPatient?.profilePicture,
              date_of_birth: data['date_of_birth'],
              blood_type: data['blood_type'],
              height: data['height']?.toString(),
              weight: data['weight']?.toString(),
              allergies: data['allergies'] != null
                  ? _parseAllergiesFromData(data['allergies'])
                  : null,
              medical_history: data['medical_history'] is List
                  ? List<String>.from(data['medical_history'])
                  : null,
              medical_files: medicalFiles,
            );
            currentUser = currentPatient;
            break;
          case 'radiologist':
            currentRadiologist = User(
              id: data['id'] ?? currentRadiologist?.id ?? '',
              name: data['name'] ?? currentRadiologist?.name ?? '',
              email: data['email'] ?? currentRadiologist?.email ?? '',
              phone: data['phone'] ?? currentRadiologist?.phone ?? '',
              address: data['address'] ?? currentRadiologist?.address ?? '',
              profilePicture:
                  data['profile_picture'] ?? currentRadiologist?.profilePicture,
              role: UserRole.radiologist,
            );
            currentUser = currentRadiologist;
            break;
        }
        notifyListeners();
      }
    } on DioException catch (e) {
      // Handle Dio specific errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout while fetching profile. Please check your internet connection.';
      } else {
        errorMessage = 'Failed to fetch profile: ${e.message}';
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to fetch profile: $e';
      notifyListeners();
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/change-password',
        options: Options(headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        }),
        data: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Failed to change password';
      } else {
        errorMessage = '';
      }
    } catch (e) {
      errorMessage = 'Network error: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> updateDoctorProfile({
    required String name,
    required String specialty,
    required String phone,
    required String address,
    String? bio,
    String? profileImage,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/update-profile',
        options: Options(headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        }),
        data: json.encode({
          'name': name,
          'specialty': specialty,
          'phone': phone,
          'address': address,
          'profile_picture': profileImage,
          'bio': bio,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        currentDoctor = Doctor(
          id: currentDoctor?.id ?? '',
          name: name,
          email: currentDoctor?.email ?? '',
          specialty: specialty,
          phone: phone,
          address: address,
          profilePicture: profileImage ?? currentDoctor?.profilePicture,
          isVerified: currentDoctor?.isVerified ?? false,
          verificationDetails: currentDoctor?.verificationDetails,
          signature: currentDoctor?.signature,
          bio: bio ?? currentDoctor?.bio,
        );
        currentUser = currentDoctor;
        errorMessage = '';
      } else {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Failed to update profile';
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
    }
    notifyListeners();
  }

  Future<void> logout(BuildContext? context) async {
    // Get tokens if not already set
    authToken ??= await getToken();
    refreshToken ??= await getRefreshToken();

    if (authToken == null) return;

    // Clear local data regardless of server response
    Future<void> clearLocalData() async {
      await removeToken();
      await removeRefreshToken();
      await removeUserId();
      await removeUserRole();

      authToken = null;
      refreshToken = null;
      currentDoctor = null;
      currentPatient = null;
      currentRadiologist = null;
      currentUser = null;
      isAuthenticated = false;

      // Clear UserProvider data if context is available
      if (context != null) {
        try {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.clearUserData();
        } catch (e) {
          print('Error clearing UserProvider data: $e');
        }
      }

      notifyListeners();
    }

    try {
      // Include refresh token in the logout request body only if it's not null
      Map<String, dynamic> requestData = {};
      if (refreshToken != null) {
        requestData['refresh_token'] = refreshToken;
      }

      await dio.post(
        '$baseUrl/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          // Use shorter timeout for logout to prevent UI hanging
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
        data: json.encode(requestData),
      );

      await clearLocalData();
      errorMessage = '';
    } catch (e) {
      print('Logout error: $e'); // Debug log
      // Still clear local data even if the server request fails
      await clearLocalData();
      errorMessage = 'Network error during logout: ${e.toString()}';
    }
  }

  Future<void> verifyDoctor(String base64Image) async {
    try {
      final response = await dio.post(
        '$baseUrl/verify-doctor',
        options: Options(headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        }),
        data: json.encode({
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        if (currentDoctor != null) {
          currentDoctor = Doctor(
            id: currentDoctor!.id,
            name: currentDoctor!.name,
            email: currentDoctor!.email,
            specialty: currentDoctor!.specialty,
            phone: currentDoctor!.phone,
            address: currentDoctor!.address,
            profilePicture: currentDoctor!.profilePicture,
            isVerified: true,
          );
          currentUser = currentDoctor;
        }
        errorMessage = '';
      } else {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Verification failed';
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
    }
    notifyListeners();
  }

  Future<void> updateSignature(String signatureBase64) async {
    try {
      final response = await dio.post(
        '$baseUrl/update-signature',
        options: Options(headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        }),
        data: json.encode({
          'signature': signatureBase64,
        }),
      );

      if (response.statusCode == 200) {
        if (currentDoctor != null) {
          currentDoctor = Doctor(
            id: currentDoctor!.id,
            name: currentDoctor!.name,
            email: currentDoctor!.email,
            specialty: currentDoctor!.specialty,
            phone: currentDoctor!.phone,
            address: currentDoctor!.address,
            profilePicture: currentDoctor!.profilePicture,
            isVerified: currentDoctor!.isVerified,
            verificationDetails: currentDoctor!.verificationDetails,
            signature: signatureBase64,
          );
        }
        errorMessage = '';
      } else {
        final data = json.decode(response.data);
        errorMessage = data['error'] ?? 'Failed to update signature';
      }
    } catch (e) {
      errorMessage = 'Network error: $e';
    }
    notifyListeners();
  }

  // Helper method to parse allergies from different formats
  List<String>? _parseAllergiesFromData(dynamic allergiesData) {
    if (allergiesData == null) {
      return null;
    } else if (allergiesData is String) {
      // Handle string format (comma-separated values)
      if (allergiesData.isEmpty) return [];
      return allergiesData
          .split(',')
          .where((item) => item.trim().isNotEmpty)
          .map((item) => item.trim())
          .toList();
    } else if (allergiesData is List) {
      // Handle list format
      return allergiesData
          .map<String>((item) {
            if (item is String) {
              return item;
            } else if (item is Map) {
              // Handle map format with 'name' field
              return item['name']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }
}
