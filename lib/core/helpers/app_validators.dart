import 'package:tracking_app/core/constants/app_string.dart';

class AppValidators {
  AppValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  static String? loginEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      return AppString.invalidEmail;
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return AppString.invalidPassword;
    return null;
  }
}
