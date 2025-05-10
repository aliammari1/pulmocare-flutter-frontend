import 'package:dio/dio.dart';
import 'package:medapp/config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHttpClient {
  static final DioHttpClient _instance = DioHttpClient._internal();
  
  late final Dio dio;

  factory DioHttpClient() => _instance;

  DioHttpClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: false,
    ));
  }
}
