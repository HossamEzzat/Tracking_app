import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';

void main() {
  test('uses the Flower base url and api prefix', () {
    expect(
      ApiEndpoints.normalizeBaseUrl('http://192.168.1.9:8080'),
      'http://192.168.1.9:8080/api/v1',
    );
  });

  test('does not duplicate the api prefix', () {
    expect(
      ApiEndpoints.normalizeBaseUrl('http://192.168.1.9:8080/api/v1/'),
      'http://192.168.1.9:8080/api/v1',
    );
  });

  test('login path matches the identity contract', () {
    expect(ApiEndpoints.login, '/identity/auth/login');
    expect(ApiEndpoints.refresh, '/identity/auth/refresh');
  });
}
