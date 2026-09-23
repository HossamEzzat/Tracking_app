import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';

class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
  });
}

abstract interface class TokenRefresher {
  Future<AuthTokens?> refresh(String refreshToken);
}

@LazySingleton(as: TokenRefresher)
class ApiTokenRefresher implements TokenRefresher {
  final Dio _dio;

  ApiTokenRefresher()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.resolvedBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {'Content-Type': 'application/json'},
        ),
      );

  @override
  Future<AuthTokens?> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );
    return _tokensFrom(response.data);
  }
}

AuthTokens? _tokensFrom(Map<String, dynamic>? body) {
  if (body == null || body['isSuccess'] != true) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final accessToken = data['accessToken'];
  if (accessToken is! String || accessToken.isEmpty) return null;
  final refreshToken = data['refreshToken'];
  final expiresIn = data['expiresIn'];
  return AuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken is String ? refreshToken : null,
    expiresIn: expiresIn is int ? expiresIn : null,
  );
}
