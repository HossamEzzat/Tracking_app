import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_storage.dart';

abstract final class AuthRequestExtra {
  static const retried = 'auth_retried';
  static const skipRefresh = 'skip_auth_refresh';
}

@lazySingleton
class AuthInterceptors extends Interceptor {
  final TokenStorage _tokenStorage;
  final TokenRefreshCoordinator _coordinator;
  Dio? _dio;

  AuthInterceptors(this._tokenStorage, this._coordinator);

  void attachDio(Dio dio) {
    _dio = dio;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleError(err, handler);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(err)) {
      handler.next(err);
      return;
    }
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _log('Token refresh skipped: no refresh token');
      handler.next(err);
      return;
    }
    await _refreshAndRetry(err, handler);
  }

  bool _shouldRefresh(DioException err) {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401) return false;
    if (options.extra[AuthRequestExtra.skipRefresh] == true) return false;
    if (options.extra[AuthRequestExtra.retried] == true) return false;
    return !options.path.contains(ApiEndpoints.login);
  }

  Future<void> _refreshAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      await _resolveRefreshed(err, handler);
    } on SessionExpiredException {
      _rejectExpired(err, handler);
    } on DioException {
      _log('Token refresh failed: network or server error');
      handler.next(err);
    } catch (_) {
      await _rejectUnexpected(err, handler);
    }
  }

  Future<void> _resolveRefreshed(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _log('Token refresh started');
    final tokens = await _coordinator.refresh();
    if (tokens == null) {
      _log('Token refresh skipped: no tokens returned');
      handler.next(err);
      return;
    }
    _log('Token refresh succeeded');
    final response = await _retryRequest(
      err.requestOptions,
      tokens.accessToken,
    );
    handler.resolve(response);
  }

  void _rejectExpired(DioException err, ErrorInterceptorHandler handler) {
    _log('Token refresh failed: refresh token invalid or expired');
    handler.reject(_sessionExpiredException(err));
  }

  Future<void> _rejectUnexpected(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _log('Token refresh failed: unexpected error');
    await _tokenStorage.clearTokens();
    handler.reject(_sessionExpiredException(err));
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String accessToken,
  ) {
    final dio = _dio;
    if (dio == null) {
      throw StateError('AuthInterceptors.attachDio was not called');
    }
    options.headers['Authorization'] = 'Bearer $accessToken';
    options.extra[AuthRequestExtra.retried] = true;
    return dio.fetch<dynamic>(options);
  }

  DioException _sessionExpiredException(DioException original) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: DioExceptionType.badResponse,
      error: ForceLogin(),
      message: 'Session expired',
    );
  }

  void _log(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: 'AuthInterceptors');
  }
}
