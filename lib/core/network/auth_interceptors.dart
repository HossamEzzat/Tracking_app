import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/error/app_error.dart';
import 'package:tracking_app/core/network/token_refresh.dart';
import 'package:tracking_app/core/network/token_storage.dart';

/// Request [RequestOptions.extra] keys used by [AuthInterceptors].
abstract final class AuthRequestExtra {
  /// Marks a request that has already been retried after a token refresh.
  static const retried = 'auth_retried';

  /// Marks the refresh-token HTTP call so it never triggers another refresh.
  ///
  /// Currently unused: [ApiTokenRefresher] performs the refresh call on its
  /// own [Dio] instance (no [AuthInterceptors] attached), so it can never
  /// re-enter this interceptor.
  ///
  /// Kept for forward compatibility in case the refresh call is ever routed
  /// through the main Dio instance.
  static const skipRefresh = 'skip_auth_refresh';
}

/// Notifies the application when the authentication session expires.
@lazySingleton
class AuthSessionNotifier extends ChangeNotifier {
  void notifySessionExpired() {
    notifyListeners();
  }
}

/// Attaches the access token and transparently refreshes on 401.
///
/// Header contract:
/// `Authorization: Bearer <accessToken>`.
@lazySingleton
class AuthInterceptors extends Interceptor {
  AuthInterceptors(
    this._tokenStorage,
    this._tokenRefresher,
    this._authSessionNotifier,
  );

  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;
  final AuthSessionNotifier _authSessionNotifier;

  /// Set by [DioModule] after Dio is created to avoid a DI cycle.
  Dio? _dio;

  Completer<AuthTokens?>? _refreshCompleter;

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
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    _handleError(err, handler);
  }

  Future<void> _handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final statusCode = err.response?.statusCode;

    final skipRefresh =
        options.extra[AuthRequestExtra.skipRefresh] == true;

    final alreadyRetried =
        options.extra[AuthRequestExtra.retried] == true;

    if (statusCode != 401 || skipRefresh || alreadyRetried) {
      return handler.next(err);
    }

    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      _log('Token refresh skipped: no refresh token');
      return handler.next(err);
    }

    try {
      _log('Token refresh started');

      final tokens = await _refreshTokens(refreshToken);

      if (tokens == null) {
        // Backend reported failure (or refresher not configured)
        // without a transport-level error.
        //
        // Do not clear the session here because the refresh failure
        // has already been handled by the single-flight refresh flow.
        _log('Token refresh skipped: no tokens returned');
        return handler.next(err);
      }

      await _persistTokens(tokens);

      _log('Token refresh succeeded');

      try {
        final response = await _retryRequest(
          options,
          tokens.accessToken,
        );

        return handler.resolve(response);
      } catch (_) {
        // The refresh succeeded, but the retry request failed.
        //
        // Unlike the refresh flow, there is no shared completer here
        // that can guarantee this happens only once.
        _log('Retry request failed after token refresh');

        await _expireSession();

        return handler.reject(
          _sessionExpiredException(err),
        );
      }
    } on DioException catch (refreshError) {
      final refreshStatus = refreshError.response?.statusCode;

      if (refreshStatus == 401 || refreshStatus == 400) {
        _log(
          'Token refresh failed: refresh token invalid or expired',
        );

        // Session expiration is already handled once inside
        // _refreshTokens() by the first caller.
        return handler.reject(
          _sessionExpiredException(err),
        );
      }

      _log('Token refresh failed: network or server error');

      return handler.next(err);
    } catch (_) {
      _log('Token refresh failed: unexpected error');

      // Session expiration is already handled once inside
      // _refreshTokens() by the first caller.
      return handler.reject(
        _sessionExpiredException(err),
      );
    }
  }

  /// Single-flight refresh:
  /// concurrent 401s share one refresh Future.
  Future<AuthTokens?> _refreshTokens(
    String refreshToken,
  ) {
    final inFlight = _refreshCompleter;

    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<AuthTokens?>();

    _refreshCompleter = completer;

    Future<void>(() async {
      try {
        final tokens = await _tokenRefresher.refresh(refreshToken);

        if (!completer.isCompleted) {
          completer.complete(tokens);
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          // Only the first caller that owns this completer
          // is allowed to expire the session and notify listeners.
          await _expireSession();
          _authSessionNotifier.notifySessionExpired();

          completer.completeError(error, stackTrace);
        }
      } finally {
        _refreshCompleter = null;
      }
    });

    return completer.future;
  }

  Future<void> _persistTokens(
    AuthTokens tokens,
  ) async {
    final newRefresh = tokens.refreshToken;

    if (newRefresh != null && newRefresh.isNotEmpty) {
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: newRefresh,
      );
    } else {
      await _tokenStorage.saveAccessToken(
        tokens.accessToken,
      );
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String accessToken,
  ) {
    final dio = _dio;

    if (dio == null) {
      throw StateError(
        'AuthInterceptors.attachDio was not called',
      );
    }

    options.headers['Authorization'] = 'Bearer $accessToken';
    options.extra[AuthRequestExtra.retried] = true;

    return dio.fetch<dynamic>(options);
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clearTokens();
    _log('Session expired');
  }

  DioException _sessionExpiredException(
    DioException original,
  ) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: DioExceptionType.badResponse,
      error: ForceLogin(),
      message: 'Session expired',
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'AuthInterceptors',
      );
    }
  }
}