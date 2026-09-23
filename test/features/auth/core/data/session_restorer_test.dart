import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/network/secure_key_value.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_refresh_scheduler.dart';
import 'package:tracking_app/core/network/token_refresher.dart';
import 'package:tracking_app/core/network/token_storage.dart';
import 'package:tracking_app/features/auth/core/data/repos/auth_repository_impl.dart';
import 'package:tracking_app/features/auth/core/data/session_restorer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemorySecureKeyValue memory;
  late SecureTokenStorage storage;
  late _FakeRefresher refresher;
  late TokenRefreshCoordinator coordinator;
  late TokenRefreshScheduler scheduler;
  late SessionRestorer restorer;

  setUp(() {
    memory = MemorySecureKeyValue();
    storage = SecureTokenStorage(memory);
    refresher = _FakeRefresher();
    coordinator = TokenRefreshCoordinator(storage, refresher);
    scheduler = TokenRefreshScheduler(storage, coordinator);
    restorer = SessionRestorer(
      AuthRepositoryImpl(storage, scheduler, coordinator),
      storage,
      coordinator,
    );
  });

  tearDown(() {
    scheduler.stop();
    coordinator.dispose();
  });

  test('no session opens onboarding', () async {
    expect(await restorer.restore(), AppRoutes.onboarding);
    expect(refresher.calls, 0);
  });

  test('a valid driver session restores without login', () async {
    await _saveDriver(storage);

    expect(await restorer.restore(), AppRoutes.driverHome);
    expect(refresher.calls, 0);
    expect(await storage.getAccessToken(), 'access-token');
  });

  test('an expired session refreshes and keeps the driver route', () async {
    await _saveDriver(storage);
    await _expire(memory);
    refresher.tokens = const AuthTokens(
      accessToken: 'refreshed-access',
      refreshToken: 'refreshed-refresh',
      expiresIn: 900,
    );

    expect(await restorer.restore(), AppRoutes.driverHome);
    expect(await storage.getAccessToken(), 'refreshed-access');
    expect((await storage.readProfile())?.role, 'Driver');
  });

  test('an invalid refresh token clears the session and opens login', () async {
    await _saveDriver(storage);
    await _expire(memory);
    refresher.error = DioException(
      requestOptions: RequestOptions(path: '/identity/auth/refresh'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/identity/auth/refresh'),
        statusCode: 401,
      ),
    );

    expect(await restorer.restore(), AppRoutes.login);
    expect(memory.values, isEmpty);
  });

  test('a network failure during refresh keeps the session', () async {
    await _saveDriver(storage);
    await _expire(memory);
    refresher.error = DioException(
      requestOptions: RequestOptions(path: '/identity/auth/refresh'),
      type: DioExceptionType.connectionError,
      message: 'Network is unreachable',
      error: 'Network is unreachable',
    );

    expect(await restorer.restore(), AppRoutes.driverHome);
    expect(await storage.getAccessToken(), 'access-token');
  });

  test('a stored token without a role returns to login', () async {
    await storage.saveTokens(
      accessToken: 'not-a-jwt',
      refreshToken: 'refresh-token',
      expiresIn: 900,
    );

    expect(await restorer.restore(), AppRoutes.login);
    expect(memory.values, isEmpty);
  });

  test('a jwt role restores when the profile was not stored', () async {
    await storage.saveTokens(
      accessToken: _jwt({'role': 'Customer'}),
      refreshToken: 'refresh-token',
      expiresIn: 900,
    );

    expect(await restorer.restore(), AppRoutes.customerHome);
  });
}

Future<void> _saveDriver(SecureTokenStorage storage) {
  return storage.saveSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresIn: 3600,
    profile: const AuthProfile(
      role: 'Driver',
      canAccessDriverHome: true,
      driverApplicationStatus: 'Approved',
    ),
  );
}

Future<void> _expire(MemorySecureKeyValue memory) {
  final past = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
  return memory.write(
    key: SecureTokenStorage.accessTokenExpiryKey,
    value: past.toIso8601String(),
  );
}

String _jwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode('{"alg":"none"}'));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.sig';
}

class _FakeRefresher implements TokenRefresher {
  int calls = 0;
  AuthTokens? tokens;
  Object? error;

  @override
  Future<AuthTokens?> refresh(String refreshToken) async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return tokens;
  }
}
