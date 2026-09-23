import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/network/access_token_expiry.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_storage.dart';

@lazySingleton
class TokenRefreshScheduler with WidgetsBindingObserver {
  final TokenStorage _tokenStorage;
  final TokenRefreshCoordinator _coordinator;
  final Duration _safetyMargin;
  final Duration _retryDelay;

  @factoryMethod
  TokenRefreshScheduler(this._tokenStorage, this._coordinator)
    : _safetyMargin = accessTokenRefreshMargin,
      _retryDelay = const Duration(seconds: 30);

  @visibleForTesting
  TokenRefreshScheduler.withDurations(
    this._tokenStorage,
    this._coordinator, {
    required this._safetyMargin,
    required this._retryDelay,
  });

  Timer? _timer;
  bool _active = false;
  bool _observing = false;

  Future<void> start() async {
    _active = true;
    _observe();
    await _scheduleFromStorage();
  }

  @disposeMethod
  void stop() {
    _active = false;
    _timer?.cancel();
    _timer = null;
    if (!_observing) return;
    WidgetsBinding.instance.removeObserver(this);
    _observing = false;
  }

  void _observe() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_active || state != AppLifecycleState.resumed) return;
    unawaited(_scheduleFromStorage());
  }

  Future<void> _scheduleFromStorage({bool allowImmediate = true}) async {
    if (!_active) return;
    _timer?.cancel();
    final expiry = await _tokenStorage.getAccessTokenExpiry();
    if (expiry == null) {
      _log('Nothing scheduled: no known expiry');
      return;
    }
    await _schedule(expiry, allowImmediate: allowImmediate);
  }

  Future<void> _schedule(
    DateTime expiry, {
    required bool allowImmediate,
  }) async {
    final delay = expiry
        .subtract(_safetyMargin)
        .difference(DateTime.now().toUtc());
    if (!delay.isNegative) {
      _arm(delay);
      return;
    }
    if (!allowImmediate) return;
    await _refreshNow();
  }

  void _arm(Duration delay) {
    _log('Scheduled proactive refresh in ${delay.inSeconds}s');
    _timer = Timer(delay, () => unawaited(_refreshNow()));
  }

  Future<void> _refreshNow() async {
    if (!_active) return;
    try {
      await _refreshActiveSession();
    } on SessionExpiredException {
      _log('Proactive refresh failed: refresh token invalid or expired');
      stop();
    } catch (_) {
      _log('Proactive refresh failed: retrying in ${_retryDelay.inSeconds}s');
      _timer = Timer(_retryDelay, () => unawaited(_refreshNow()));
    }
  }

  Future<void> _refreshActiveSession() async {
    _log('Proactive refresh started');
    final tokens = await _coordinator.refresh();
    if (tokens == null) {
      _log('Proactive refresh skipped: no tokens returned');
      return;
    }
    _log('Proactive refresh succeeded');
    await _scheduleFromStorage(allowImmediate: false);
  }

  void _log(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: 'TokenRefreshScheduler');
  }
}
