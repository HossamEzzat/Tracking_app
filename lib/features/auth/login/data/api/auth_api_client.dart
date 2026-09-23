import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/data/models/login_response.dart';

@singleton
class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(_body(response.data));
  }
}

Map<String, dynamic> _body(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  throw const FormatException('Empty login response');
}
