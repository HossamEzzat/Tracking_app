import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/core/errors/error_parser.dart';
import 'package:tracking_app/features/auth/login/domain/login_failure.dart';

void main() {
  test('401 is a credential error, not a network error', () {
    final error = errorParser(
      _dioError(401, {'message': 'Invalid email or password.'}),
    );

    expect(error, isA<UnauthorizedError>());
    expect(error.message, 'Invalid email or password.');
    expect(classifyLoginFailure(error), LoginFailureKind.credentials);
    expect(classifyLoginFailure(error), isNot(LoginFailureKind.network));
  });

  test('401 without a body still stays a credential error', () {
    final error = errorParser(_dioError(401, null));

    expect(error, isA<UnauthorizedError>());
    expect(classifyLoginFailure(error), LoginFailureKind.credentials);
  });

  test('connection failure is a network error', () {
    final error = errorParser(
      DioException(
        requestOptions: RequestOptions(path: '/identity/auth/login'),
        type: DioExceptionType.connectionError,
        message: 'Network is unreachable',
        error: 'Network is unreachable',
      ),
    );

    expect(classifyLoginFailure(error), LoginFailureKind.network);
  });

  test('timeout is a network error', () {
    final error = errorParser(
      DioException(
        requestOptions: RequestOptions(path: '/identity/auth/login'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    expect(error, isA<TimeOutError>());
    expect(classifyLoginFailure(error), LoginFailureKind.network);
  });

  test('429 is rate limiting', () {
    final error = errorParser(
      _dioError(429, {'message': 'Too many requests, please try again later.'}),
    );

    expect(error, isA<BadResponseError>());
    expect((error as BadResponseError).statusCode, 429);
    expect(classifyLoginFailure(error), LoginFailureKind.rateLimit);
  });

  test('500 is a server error', () {
    final error = errorParser(
      _dioError(500, {
        'message': 'Internal server error, please try again later.',
      }),
    );

    expect(classifyLoginFailure(error), LoginFailureKind.server);
  });
}

DioException _dioError(int status, Object? data) {
  final request = RequestOptions(path: '/identity/auth/login');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: request, statusCode: status, data: data),
  );
}
