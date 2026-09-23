import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/core/constants/app_string.dart';
import 'package:tracking_app/core/helpers/app_validators.dart';

void main() {
  test('empty email is invalid', () {
    expect(AppValidators.loginEmail(''), AppString.invalidEmail);
    expect(AppValidators.loginEmail('   '), AppString.invalidEmail);
    expect(AppValidators.loginEmail(null), AppString.invalidEmail);
  });

  test('malformed email is invalid', () {
    expect(AppValidators.loginEmail('not-an-email'), AppString.invalidEmail);
  });

  test('valid email passes', () {
    expect(AppValidators.loginEmail('user@example.com'), isNull);
  });

  test('empty password is invalid', () {
    expect(AppValidators.loginPassword(''), AppString.invalidPassword);
    expect(AppValidators.loginPassword(null), AppString.invalidPassword);
  });

  test('any non-empty password passes local validation', () {
    expect(AppValidators.loginPassword('secret'), isNull);
  });
}
