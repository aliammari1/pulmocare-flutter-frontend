import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:medapp/models/appointment.dart';
import 'package:medapp/services/api_service.dart';
import 'package:medapp/utils/DioClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  final Dio _dio = DioHttpClient().dio;
  final String baseUrl = Config.apiBaseUrl;

  // Helper method to get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Create a new appointment
  Future<Appointment> bookAppointment(AppointmentCreate appointmentData) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '$baseUrl/appointments',
        data: appointmentData.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return Appointment.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get appointments for a doctor
  Future<PaginatedAppointmentResponse> getDoctorAppointments({
    required String doctorId,
    AppointmentStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      

      final response = await _dio.get(
        '/appointments/doctor/$doctorId',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return PaginatedAppointmentResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get appointments for a patient
  Future<PaginatedAppointmentResponse> getPatientAppointments({
    required String patientId,
    AppointmentStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dio.get(
        '/appointments/patient/$patientId',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return PaginatedAppointmentResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get appointments between a specific doctor and patient
  Future<PaginatedAppointmentResponse> getDoctorPatientAppointments({
    required String doctorId,
    required String patientId,
    AppointmentStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dio.get(
        '/appointments/doctor/$doctorId/patient/$patientId',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return PaginatedAppointmentResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get appointment details (moved from DoctorService)
  Future<Appointment> getAppointmentDetails(String appointmentId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$baseUrl/appointments/$appointmentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return Appointment.fromJson(response.data);
    } catch (e) {
      print("❌ Error retrieving appointment details: $e");
      throw _handleError(e);
    }
  }

  // Accept appointment (moved from DoctorService)
  Future<Appointment> acceptAppointment(String appointmentId) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '$baseUrl/appointments/$appointmentId/accept',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return Appointment.fromJson(response.data);
    } catch (e) {
      print("❌ Error accepting appointment: $e");
      throw _handleError(e);
    }
  }

  // Reject appointment (moved from DoctorService)
  Future<Map<String, dynamic>> rejectAppointment(String appointmentId) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '$baseUrl/appointments/$appointmentId/reject',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print("❌ Error rejecting appointment: $e");
      throw _handleError(e);
    }
  }

  // Helper method to handle errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final responseData = error.response!.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('detail')) {
          return Exception(responseData['detail']);
        }

        return Exception('Server error: $statusCode');
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('An unexpected error occurred: $error');
  }
}
