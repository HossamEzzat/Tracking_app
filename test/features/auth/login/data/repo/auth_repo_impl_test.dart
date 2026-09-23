import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/core/modules/dio_module.dart';
import 'package:tracking_app/core/network/auth_interceptors.dart';
import 'package:tracking_app/core/network/safe_call.dart';
import 'package:tracking_app/core/network/secure_key_value.dart';
import 'package:tracking_app/core/network/token_refresher.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_storage.dart';
import 'package:tracking_app/features/auth/login/data/api/auth_api_client.dart';
import 'package:tracking_app/features/auth/login/data/data_source/remote/auth_remote_data_source_impl.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/data/repo/auth_repo_impl.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

import '../../../../../support/scripted_adapter.dart';

void main() {
  late MemorySecureKeyValue memory;
  late SecureTokenStorage storage;
  late ScriptedAdapter adapter;
  late TokenRefreshCoordinator coordinator;
  late AuthRepositoryImpl repository;

  setUp(() {
    ApiEndpoints.setResolvedBaseUrl('http://192.168.1.9:8080/api/v1');
    memory = MemorySecureKeyValue();
    storage = SecureTokenStorage(memory);
    adapter = ScriptedAdapter((_) async => jsonBody(_successBody(), 200));
    final refresher = _UnusedRefresher();
    coordinator = TokenRefreshCoordinator(storage, refresher);
    final dio = provideDio(AuthInterceptors(storage, coordinator));
    dio.httpClientAdapter = adapter;
    repository = AuthRepositoryImpl(
      AuthRemoteDatasourceImpl(AuthApiClient(dio)),
      SafeCall(),
      storage,
    );
  });

  tearDown(() => coordinator.dispose());

  test('successful login persists the session securely', () async {
    final result = await repository.signIn(_request);

    expect(result, isA<SuccessResponse<AuthEntity>>());
    expect(memory.values[SecureTokenStorage.accessTokenKey], 'access-token');
    expect(memory.values[SecureTokenStorage.refreshTokenKey], 'refresh-token');
    expect(memory.values[SecureTokenStorage.roleKey], 'Driver');
    expect(adapter.lastOptions?.path, ApiEndpoints.login);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.data, _request.toJson());
  });

  test('401 does not save tokens or look like a network failure', () async {
    adapter.onFetch = (_) async {
      return jsonBody({'message': 'Invalid email or password.'}, 401);
    };

    final result = await repository.signIn(_request);

    expect(result, isA<ErrorResponse<AuthEntity>>());
    final error = (result as ErrorResponse<AuthEntity>).appError;
    expect(error, isA<UnauthorizedError>());
    expect(error.message, 'Invalid email or password.');
    expect(memory.values, isEmpty);
  });

  test('a connectivity failure is not stored as a session', () async {
    adapter.onFetch = (options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'Network is unreachable',
        error: 'Network is unreachable',
      );
    };

    final result = await repository.signIn(_request);

    expect(result, isA<ErrorResponse<AuthEntity>>());
    final error = (result as ErrorResponse<AuthEntity>).appError;
    expect(error, isA<BadResponseError>());
    expect(error.message, contains('Cannot reach the server'));
    expect(memory.values, isEmpty);
  });
}

const _request = LoginRequest(email: 'user@example.com', password: 'secret');

Map<String, dynamic> _successBody() {
  return {
    'isSuccess': true,
    'statusCode': 200,
    'message': 'Login successful.',
    'data': {
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'expiresIn': 900,
      'role': 'Driver',
      'driverApplicationStatus': 'Approved',
      'canAccessDriverHome': true,
      'driverApplicationRejectionReason': null,
    },
  };
}

class _UnusedRefresher implements TokenRefresher {
  @override
  Future<AuthTokens?> refresh(String refreshToken) async {
    throw StateError('login must not refresh');
  }
}
