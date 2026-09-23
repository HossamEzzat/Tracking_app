import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/network/token_refresher.dart';
import 'package:tracking_app/core/network/token_storage.dart';

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

@lazySingleton
class TokenRefreshCoordinator {
  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;

  TokenRefreshCoordinator(this._tokenStorage, this._tokenRefresher);

  Completer<AuthTokens?>? _inFlight;
  final _sessionExpiredController = StreamController<void>.broadcast();
  late final Stream<void> sessionExpired = _sessionExpiredController.stream;

  Future<AuthTokens?> refresh() {
    final existing = _inFlight;
    if (existing != null) return existing.future;
    final completer = Completer<AuthTokens?>();
    _inFlight = completer;
    unawaited(_run(completer));
    return completer.future;
  }

  Future<void> _run(Completer<AuthTokens?> completer) async {
    try {
      await _refreshInto(completer);
    } on DioException catch (error) {
      await _completeDioError(completer, error);
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _refreshInto(Completer<AuthTokens?> completer) async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      completer.complete(null);
      return;
    }
    final tokens = await _tokenRefresher.refresh(refreshToken);
    if (tokens == null) {
      completer.complete(null);
      return;
    }
    await _persist(tokens);
    completer.complete(tokens);
  }

  Future<void> _completeDioError(
    Completer<AuthTokens?> completer,
    DioException error,
  ) async {
    final status = error.response?.statusCode;
    if (status == 401 || status == 400) {
      await _tokenStorage.clearTokens();
      _sessionExpiredController.add(null);
      completer.completeError(const SessionExpiredException());
      return;
    }
    completer.completeError(error, error.stackTrace);
  }

  Future<void> _persist(AuthTokens tokens) async {
    final newRefresh = tokens.refreshToken;
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: newRefresh,
        expiresIn: tokens.expiresIn,
      );
      return;
    }
    await _tokenStorage.saveAccessToken(
      tokens.accessToken,
      expiresIn: tokens.expiresIn,
    );
  }

  @disposeMethod
  void dispose() {
    _sessionExpiredController.close();
  }
}
