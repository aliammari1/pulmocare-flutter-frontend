import 'package:flutter/material.dart';
import 'package:medapp/models/user.dart';
import 'package:medapp/models/doctor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  Doctor? _currentDoctor;
  User? _currentPatient;
  User? _currentRadiologist;

  User? get currentUser => _currentUser;
  Doctor? get currentDoctor => _currentDoctor;
  User? get currentPatient => _currentPatient;
  User? get currentRadiologist => _currentRadiologist;
  String? get name => _currentUser?.name;
  String? get email => _currentUser?.email;
  String? get phone => _currentUser?.phone;
  String? get address => _currentUser?.address;
  String? get profilePicture => _currentUser?.profilePicture;
  UserRole? get userRole => _currentUser?.role;

  // Used to determine if user is a doctor, radiologist, or patient
  bool get isDoctor => _currentDoctor != null;
  bool get isRadiologist => _currentRadiologist != null;
  bool get isPatient => _currentPatient != null;

  // Initialize user data from stored preferences
  Future<void> initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData == null) return;

    try {
      final Map<String, dynamic> userJson = json.decode(userData);
      final role = userJson['role']?.toString().toLowerCase();

      switch (role) {
        case 'doctor':
          _currentDoctor = Doctor(
            id: userJson['id'] ?? '',
            name: userJson['name'] ?? '',
            email: userJson['email'] ?? '',
            specialty: userJson['specialty'] ?? '',
            phone: userJson['phone'] ?? '',
            address: userJson['address'] ?? '',
            profilePicture: userJson['profile_picture'],
            isVerified: userJson['is_verified'] ?? false,
            verificationDetails: userJson['verification_details'],
            signature: userJson['signature'],
            bio: userJson['bio'],
          );
          _currentUser = _currentDoctor;
          break;
        case 'radiologist':
          _currentRadiologist = User(
            id: userJson['id'] ?? '',
            name: userJson['name'] ?? '',
            email: userJson['email'] ?? '',
            phone: userJson['phone'] ?? '',
            address: userJson['address'] ?? '',
            profilePicture: userJson['profile_picture'],
            role: UserRole.radiologist,
          );
          _currentUser = _currentRadiologist;
          break;
        case 'patient':
          _currentPatient = User(
            id: userJson['id'] ?? '',
            name: userJson['name'] ?? '',
            email: userJson['email'] ?? '',
            phone: userJson['phone'] ?? '',
            address: userJson['address'] ?? '',
            profilePicture: userJson['profile_picture'],
            role: UserRole.patient,
          );
          _currentUser = _currentPatient;
          break;
      }
      notifyListeners();
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }

  // Update user data from the auth model
  void updateUserFromAuth({
    User? user,
    Doctor? doctor,
    User? patient,
    User? radiologist,
  }) {
    _currentUser = user;
    _currentDoctor = doctor;
    _currentPatient = patient;
    _currentRadiologist = radiologist;

    // Save to shared preferences for persistence
    _saveUserData();
    notifyListeners();
  }

  // Clear all user data (used during logout)
  void clearUserData() {
    _currentUser = null;
    _currentDoctor = null;
    _currentPatient = null;
    _currentRadiologist = null;

    _removeUserData();
    notifyListeners();
  }

  // Update user's profile data
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profilePicture,
    String? specialty,
    String? bio,
    bool? isVerified,
  }) async {
    if (_currentDoctor != null) {
      _currentDoctor = Doctor(
        id: _currentDoctor!.id,
        name: name ?? _currentDoctor!.name,
        email: email ?? _currentDoctor!.email,
        phone: phone ?? _currentDoctor!.phone,
        address: address ?? _currentDoctor!.address,
        profilePicture: profilePicture ?? _currentDoctor!.profilePicture,
        specialty: specialty ?? _currentDoctor!.specialty,
        isVerified: isVerified ?? _currentDoctor!.isVerified,
        bio: bio ?? _currentDoctor!.bio,
        signature: _currentDoctor!.signature,
        verificationDetails: _currentDoctor!.verificationDetails,
      );
      _currentUser = _currentDoctor;
    } else if (_currentPatient != null) {
      _currentPatient = User(
        id: _currentPatient!.id,
        name: name ?? _currentPatient!.name,
        email: email ?? _currentPatient!.email,
        phone: phone ?? _currentPatient!.phone,
        address: address ?? _currentPatient!.address,
        profilePicture: profilePicture ?? _currentPatient!.profilePicture,
        role: UserRole.patient,
      );
      _currentUser = _currentPatient;
    } else if (_currentRadiologist != null) {
      _currentRadiologist = User(
        id: _currentRadiologist!.id,
        name: name ?? _currentRadiologist!.name,
        email: email ?? _currentRadiologist!.email,
        phone: phone ?? _currentRadiologist!.phone,
        address: address ?? _currentRadiologist!.address,
        profilePicture: profilePicture ?? _currentRadiologist!.profilePicture,
        role: UserRole.radiologist,
      );
      _currentUser = _currentRadiologist;
    }

    _saveUserData();
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    if (_currentUser == null) return;

    final Map<String, dynamic> userData = {
      'id': _currentUser!.id,
      'name': _currentUser!.name,
      'email': _currentUser!.email,
      'phone': _currentUser!.phone,
      'address': _currentUser!.address,
      'profile_picture': _currentUser!.profilePicture,
      'role': _currentUser!.role.toString().split('.').last,
    };

    // Add doctor-specific fields if it's a doctor
    if (_currentDoctor != null) {
      userData['specialty'] = _currentDoctor!.specialty;
      userData['is_verified'] = _currentDoctor!.isVerified;
      userData['signature'] = _currentDoctor!.signature;
      userData['bio'] = _currentDoctor!.bio;
      userData['verification_details'] = _currentDoctor!.verificationDetails;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  // Remove user data from SharedPreferences
  Future<void> _removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}
