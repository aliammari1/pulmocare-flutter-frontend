// filepath: c:\Users\aliammari\OneDrive - ESPRIT\Desktop\integration\med\medapp_frontend\lib\services\doctor_service.dart
import 'package:flutter/material.dart';
import 'package:medapp/config.dart';
import 'package:medapp/models/doctor.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:medapp/models/appointment.dart';
import 'package:medapp/models/prescription.dart';
import 'package:medapp/models/radiology.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medapp/models/doctor_list_response.dart';

class DoctorService {
  final Dio _dio = DioHttpClient().dio;
  final String baseUrl = Config.apiBaseUrl;

  // Doctor Profile Methods
  Future<Map<String, dynamic>> getDoctorProfile(String doctorId) async {
    try {
      final response =
          await _dio.get('/profile', queryParameters: {'id': doctorId});
      return response.data;
    } catch (e) {
      print("❌ Error retrieving doctor profile: $e");
      throw 'Could not retrieve doctor profile';
    }
  }

  // Get all doctors with pagination support
  Future<DoctorListResponse> getDoctors(
      {int page = 1, int pageSize = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/doctors/',
        options: Options(
          headers: token != null ? {"Authorization": "Bearer $token"} : null,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        return DoctorListResponse.fromJson(response.data);
      } else {
        throw 'Failed to load doctors: ${response.statusMessage}';
      }
    } on DioException catch (e) {
      print("❌ DioError retrieving doctors: ${e.type} - ${e.message}");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw 'Connection timeout. Please check your internet connection.';
      }
      throw 'Network error retrieving doctors: ${e.message}';
    } catch (e) {
      print("❌ Error retrieving doctors: $e");
      throw 'Could not retrieve doctors';
    }
  }

  // Get a list of doctors without pagination (for simple use cases)
  Future<List<Doctor>> getAllDoctors() async {
    try {
      final response =
          await getDoctors(pageSize: 100); // Get a larger page size
      return response.items;
    } catch (e) {
      print("❌ Error retrieving all doctors: $e");
      throw 'Could not retrieve doctors';
    }
  }

  // Get a specific doctor by ID
  Future<Doctor> getDoctorById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/doctors/$id',
        options: Options(
          headers: token != null ? {"Authorization": "Bearer $token"} : null,
        ),
      );

      return Doctor.fromJson(response.data);
    } catch (e) {
      print("❌ Error retrieving doctor by ID: $e");
      throw 'Could not retrieve doctor details';
    }
  }

  // Radiology Related Methods
  Future<RadiologyExamination> requestRadiologyExamination(
      Map<String, dynamic> examinationData) async {
    try {
      final response = await _dio.post('/integration/request-radiology',
          data: examinationData);
      return RadiologyExamination.fromJson(response.data);
    } catch (e) {
      print("❌ Error requesting radiology examination: $e");
      throw 'Could not create radiology examination request';
    }
  }

  // Added to support RadiologyRequestScreen
  Future<RadiologyExamination> requestRadiologyExam(
      Map<String, dynamic> examinationData) async {
    return requestRadiologyExamination(examinationData);
  }

  Future<List<RadiologyReport>> getRadiologyReports() async {
    try {
      final response = await _dio.get('/integration/radiology/reports');
      final reports = List<Map<String, dynamic>>.from(response.data);
      return reports.map((report) => RadiologyReport.fromJson(report)).toList();
    } catch (e) {
      print("❌ Error retrieving radiology reports: $e");
      throw 'Could not retrieve radiology reports';
    }
  }

  Future<RadiologyReport> getRadiologyReportById(String reportId) async {
    try {
      final response =
          await _dio.get('/integration/radiology/reports/$reportId');
      return RadiologyReport.fromJson(response.data);
    } catch (e) {
      print("❌ Error retrieving radiology report details: $e");
      throw 'Could not retrieve radiology report details';
    }
  }

  // Patient Related Methods
  Future<Map<String, dynamic>> getPatientHistory(String patientId) async {
    try {
      final response =
          await _dio.get('/integration/patient-history/$patientId');
      return response.data;
    } catch (e) {
      print("❌ Error retrieving patient history: $e");
      throw 'Could not retrieve patient history';
    }
  }

  Future<Map<String, dynamic>> notifyPatient(
      String patientId, Map<String, dynamic> notificationData) async {
    try {
      final response = await _dio.post('/integration/notify-patient/$patientId',
          data: notificationData);
      return response.data;
    } catch (e) {
      print("❌ Error sending notification to patient: $e");
      throw 'Could not send notification to patient';
    }
  }

  // Prescription Related Methods
  Future<List<Prescription>> getDoctorPrescriptions() async {
    try {
      // In a real implementation, this would be a call to the API
      // For now, returning mock data
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      final mockPrescriptions = [
        Prescription(
          id: '1',
          patientId: 'p123',
          patientName: 'John Doe',
          doctorId: 'd123',
          doctorName: 'Dr. Smith',
          medications: [
            PrescriptionItem(
              name: 'Ibuprofen',
              dosage: '400mg',
              frequency: 'Every 6 hours',
              duration: '7 days',
              instructions: 'Take with food',
            ),
            PrescriptionItem(
              name: 'Paracetamol',
              dosage: '500mg',
              frequency: 'Every 8 hours as needed',
              duration: '5 days',
            ),
          ],
          date: DateTime.now().subtract(Duration(days: 2)),
          status: PrescriptionStatus.active,
          notes: 'Patient complained of moderate back pain',
        ),
        Prescription(
          id: '2',
          patientId: 'p456',
          patientName: 'Jane Smith',
          doctorId: 'd123',
          doctorName: 'Dr. Smith',
          medications: [
            PrescriptionItem(
              name: 'Amoxicillin',
              dosage: '500mg',
              frequency: 'Every 8 hours',
              duration: '10 days',
              instructions: 'Complete full course',
            ),
          ],
          date: DateTime.now().subtract(Duration(days: 5)),
          status: PrescriptionStatus.completed,
          notes: 'For sinus infection',
        ),
        Prescription(
          id: '3',
          patientId: 'p789',
          patientName: 'Mike Johnson',
          doctorId: 'd123',
          doctorName: 'Dr. Smith',
          medications: [
            PrescriptionItem(
              name: 'Loratadine',
              dosage: '10mg',
              frequency: 'Once daily',
              duration: '30 days',
              instructions: 'Take in the morning',
            ),
          ],
          date: DateTime.now().subtract(Duration(days: 1)),
          status: PrescriptionStatus.active,
        ),
      ];

      return mockPrescriptions;

      // Actual implementation would be:
      // final response = await _dio.get('/integration/prescriptions');
      // final prescriptions = List<Map<String, dynamic>>.from(response.data);
      // return prescriptions.map((prescription) => Prescription.fromJson(prescription)).toList();
    } catch (e) {
      print("❌ Error retrieving prescriptions: $e");
      throw 'Could not retrieve prescriptions';
    }
  }

  Future<Prescription> getPrescriptionDetails(String prescriptionId) async {
    try {
      // In a real implementation, this would be a call to the API
      // For now, returning mock data
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      // Return a mock prescription based on the ID
      return Prescription(
        id: prescriptionId,
        patientId: 'p123',
        patientName: 'John Doe',
        doctorId: 'd123',
        doctorName: 'Dr. Smith',
        medications: [
          PrescriptionItem(
            name: 'Ibuprofen',
            dosage: '400mg',
            frequency: 'Every 6 hours',
            duration: '7 days',
            instructions: 'Take with food',
          ),
          PrescriptionItem(
            name: 'Paracetamol',
            dosage: '500mg',
            frequency: 'Every 8 hours as needed',
            duration: '5 days',
          ),
        ],
        date: DateTime.now().subtract(Duration(days: 2)),
        status: PrescriptionStatus.active,
        notes: 'Patient complained of moderate back pain',
      );

      // Actual implementation would be:
      // final response = await _dio.get('/integration/prescriptions/$prescriptionId');
      // return Prescription.fromJson(response.data);
    } catch (e) {
      print("❌ Error retrieving prescription details: $e");
      throw 'Could not retrieve prescription details';
    }
  }

  Future<Prescription> renewPrescription(String prescriptionId) async {
    try {
      final response =
          await _dio.post('/integration/prescriptions/$prescriptionId/renew');
      return Prescription.fromJson(response.data);
    } catch (e) {
      print("❌ Error renewing prescription: $e");
      throw 'Could not renew prescription';
    }
  }

  Future<Map<String, dynamic>> cancelPrescription(String prescriptionId) async {
    try {
      final response =
          await _dio.post('/integration/prescriptions/$prescriptionId/cancel');
      return response.data;
    } catch (e) {
      print("❌ Error cancelling prescription: $e");
      throw 'Could not cancel prescription';
    }
  }

  // Note: Appointment methods were moved to AppointmentService
}
