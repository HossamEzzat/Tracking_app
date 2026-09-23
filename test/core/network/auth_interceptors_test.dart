import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';
import 'package:tracking_app/core/modules/dio_module.dart';
import 'package:tracking_app/core/network/auth_interceptors.dart';
import 'package:tracking_app/core/network/secure_key_value.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_refresher.dart';
import 'package:tracking_app/core/network/token_storage.dart';

import '../../support/scripted_adapter.dart';

void main() {
  late SecureTokenStorage storage;
  late _CountingRefresher refresher;
  late TokenRefreshCoordinator coordinator;
  late ScriptedAdapter adapter;
  late Dio dio;

  setUp(() {
    ApiEndpoints.setResolvedBaseUrl('http://192.168.1.9:8080/api/v1');
    storage = SecureTokenStorage(MemorySecureKeyValue());
    refresher = _CountingRefresher();
    coordinator = TokenRefreshCoordinator(storage, refresher);
    adapter = ScriptedAdapter((_) async => jsonBody({'message': 'no'}, 401));
    dio = provideDio(AuthInterceptors(storage, coordinator));
    dio.httpClientAdapter = adapter;
  });

  tearDown(() => coordinator.dispose());

  test('login 401 does not refresh an existing session', () async {
    await storage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      expiresIn: 900,
    );

    await expectLater(
      dio.post(ApiEndpoints.login, data: {'email': 'a@b.co', 'password': 'pw'}),
      throwsA(isA<DioException>()),
    );

    expect(refresher.calls, 0);
    expect(await storage.getRefreshToken(), 'old-refresh');
  });

  test('a protected 401 refreshes once and retries', () async {
    await storage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      expiresIn: 900,
    );
    refresher.tokens = const AuthTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      expiresIn: 900,
    );
    adapter.onFetch = (options) async {
      final retried = options.extra[AuthRequestExtra.retried] == true;
      if (retried) return jsonBody({'ok': true}, 200);
      return jsonBody({'message': 'expired'}, 401);
    };

    final response = await dio.get('/orders');

    expect(response.statusCode, 200);
    expect(refresher.calls, 1);
    expect(await storage.getAccessToken(), 'new-access');
  });
}

class _CountingRefresher implements TokenRefresher {
  int calls = 0;
  AuthTokens? tokens;

  @override
  Future<AuthTokens?> refresh(String refreshToken) async {
    calls++;
    return tokens;
  }
}
