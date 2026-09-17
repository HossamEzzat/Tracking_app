import 'package:easy_localization/easy_localization.dart';

class AppValidators {
  AppValidators._();

  static final RegExp _passwordPattern =
      RegExp(r'^(?=.*[A-Z]).{8,}$');

  static final RegExp _registrationPasswordPattern =
      RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');

  static final RegExp _usernamePattern =
      RegExp(r'^[a-zA-Z0-9_]+$');

  static final RegExp _emailPattern =
      RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  static final RegExp _phonePattern =
      RegExp(r'^01[0125][0-9]{8}$');

  static String? requiredField(
    String? value, {
    required String field,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.field_is_required'.tr(
        namedArgs: {
          'field': field,
        },
      );
    }

    return null;
  }

  static String? usernameValidator(
    String? value, {
    String field = 'Name',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.field_is_required'.tr(
        namedArgs: {
          'field': field,
        },
      );
    }

    if (value.trim().length < 4) {
      return 'validation.field_min_length'.tr(
        namedArgs: {
          'field': field,
          'length': '4',
        },
      );
    }

    if (value.contains(' ')) {
      return 'validation.field_no_spaces'.tr(
        namedArgs: {
          'field': field,
        },
      );
    }

    if (!_usernamePattern.hasMatch(value)) {
      return 'validation.only_letters_numbers_underscore'.tr();
    }

    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.please_enter_your_email'.tr();
    }

    if (!_emailPattern.hasMatch(value.trim())) {
      return 'validation.please_enter_valid_email'.tr();
    }

    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.password_is_required'.tr();
    }

    if (!_passwordPattern.hasMatch(value)) {
      return 'validation.password_requirement'.tr();
    }

    return null;
  }

  static String? registrationPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.password_is_required'.tr();
    }

    if (!_registrationPasswordPattern.hasMatch(value)) {
      return 'validation.registration_password_requirement'.tr();
    }

    return null;
  }

  static String? confirmPasswordValidator(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return 'validation.confirm_password_is_required'.tr();
    }

    if (value != password) {
      return 'validation.passwords_do_not_match'.tr();
    }

    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.phone_number_is_required'.tr();
    }

    if (!_phonePattern.hasMatch(value.trim())) {
      return 'validation.valid_egyptian_phone'.tr();
    }

    return null;
  }

  static String? resetPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.password_is_required'.tr();
    }

    if (!_registrationPasswordPattern.hasMatch(value)) {
      return 'validation.reset_password_requirement'.tr();
    }

    return null;
  }

  static String? otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.otp_required'.tr();
    }

    if (value.length != 6) {
      return 'validation.invalid_otp'.tr();
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }

    if (value.trim().length < 5) {
      return 'validation.field_min_length'.tr(
        namedArgs: {
          'field': 'Address',
          'length': '5',
        },
      );
    }

    return null;
  }

  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }

    if (value.trim().length < 2) {
      return 'validation.field_min_length'.tr(
        namedArgs: {
          'field': 'Name',
          'length': '2',
        },
      );
    }

    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.required'.tr();
    }

    return null;
  }

  static String? validateArea(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.required'.tr();
    }

    return null;
  }

  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }

    final vehicleNumberRegex =
        RegExp(r'^[A-Za-z0-9\u0621-\u064A]+$');

    if (!vehicleNumberRegex.hasMatch(value.trim())) {
      return 'validation.valid_vehicle_number'.tr();
    }

    return null;
  }

  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }

    final id = value.trim();

    if (!RegExp(r'^\d+$').hasMatch(id)) {
      return 'validation.national_id_numbers_only'.tr();
    }

    if (id.length != 14) {
      return 'validation.national_id_length'.tr();
    }

    return null;
  }
}
