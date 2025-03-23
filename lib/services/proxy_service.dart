import 'package:dio/dio.dart';

class ProxyService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    followRedirects: true,
    validateStatus: (status) => true,
  ));

  static Future<Response> post(String url, dynamic data) async {
    try {
      return await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      print('\n=== خطأ في الاتصال ===');
      print('نوع الخطأ: ${e.type}');
      print('الرسالة: ${e.message}');
      print('البيانات: ${e.response?.data}');
      rethrow;
    }
  }
}
