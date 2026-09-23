import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/data/models/login_response.dart';

void main() {
  test('login request sends only email and password', () {
    const request = LoginRequest(email: 'user@example.com', password: 'secret');

    expect(request.toJson(), {
      'email': 'user@example.com',
      'password': 'secret',
    });
  });

  test('login response maps the session contract', () {
    final response = LoginResponse.fromJson({
      'isSuccess': true,
      'statusCode': 200,
      'message': 'Login successful.',
      'data': {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'expiresIn': 900,
        'role': 'Driver',
        'driverApplicationStatus': 'Rejected',
        'canAccessDriverHome': false,
        'driverApplicationRejectionReason': 'Missing documents',
      },
    });

    final session = response.data.toDomain();
    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.expiresIn, 900);
    expect(session.role, 'Driver');
    expect(session.driverApplicationStatus, 'Rejected');
    expect(session.canAccessDriverHome, isFalse);
    expect(session.driverApplicationRejectionReason, 'Missing documents');
  });
}
