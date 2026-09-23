import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';
import 'package:tracking_app/core/network/auth_interceptors.dart';

@module
abstract class DioModule {
  @singleton
  Dio dio(AuthInterceptors authInterceptors) => provideDio(authInterceptors);
}

Dio provideDio(AuthInterceptors authInterceptors) {
  final dio = Dio(_baseOptions());
  dio.interceptors.add(authInterceptors);
  authInterceptors.attachDio(dio);
  return dio;
}

BaseOptions _baseOptions() {
  return BaseOptions(
    baseUrl: ApiEndpoints.resolvedBaseUrl,
    receiveTimeout: const Duration(seconds: 60),
    connectTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
    headers: const {'Content-Type': 'application/json'},
  );
}
