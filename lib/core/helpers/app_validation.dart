import 'package:easy_localization/easy_localization.dart';
import 'package:tracking_app/core/localization/local_key.dart';

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
      return LocaleKeys.validationFieldIsRequired.tr(
        namedArgs: {
          'field': field,
        },
      );
    }

    return null;
  }

  static String? usernameValidator(
    String? value, {
    String? field,
  }) {
    final fieldName = field ?? LocaleKeys.name.tr();

    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationFieldIsRequired.tr(
        namedArgs: {
          'field': fieldName,
        },
      );
    }

    if (value.trim().length < 4) {
      return LocaleKeys.validationFieldMinLength.tr(
        namedArgs: {
          'field': fieldName,
          'length': '4',
        },
      );
    }

    if (value.contains(' ')) {
      return LocaleKeys.validationFieldNoSpaces.tr(
        namedArgs: {
          'field': fieldName,
        },
      );
    }

    if (!_usernamePattern.hasMatch(value)) {
      return LocaleKeys.validationOnlyLettersNumbersUnderscore.tr();
    }

    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationPleaseEnterYourEmail.tr();
    }

    if (!_emailPattern.hasMatch(value.trim())) {
      return LocaleKeys.validationPleaseEnterValidEmail.tr();
    }

    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationPasswordIsRequired.tr();
    }

    if (!_passwordPattern.hasMatch(value)) {
      return LocaleKeys.validationPasswordRequirement.tr();
    }

    return null;
  }

  static String? registrationPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationPasswordIsRequired.tr();
    }

    if (!_registrationPasswordPattern.hasMatch(value)) {
      return LocaleKeys.validationRegistrationPasswordRequirement.tr();
    }

    return null;
  }

  static String? confirmPasswordValidator(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationConfirmPasswordIsRequired.tr();
    }

    if (value != password) {
      return LocaleKeys.validationPasswordsDoNotMatch.tr();
    }

    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationPhoneNumberIsRequired.tr();
    }

    if (!_phonePattern.hasMatch(value.trim())) {
      return LocaleKeys.validationValidEgyptianPhone.tr();
    }

    return null;
  }

  static String? resetPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationPasswordIsRequired.tr();
    }

    if (!_registrationPasswordPattern.hasMatch(value)) {
      return LocaleKeys.validationResetPasswordRequirement.tr();
    }

    return null;
  }

  static String? otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationOtpRequired.tr();
    }

    if (value.length != 6) {
      return LocaleKeys.validationInvalidOtp.tr();
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationRequired.tr();
    }

    if (value.trim().length < 5) {
      return LocaleKeys.validationFieldMinLength.tr(
        namedArgs: {
          'field': LocaleKeys.address.tr(),
          'length': '5',
        },
      );
    }

    return null;
  }

  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationRequired.tr();
    }

    if (value.trim().length < 2) {
      return LocaleKeys.validationFieldMinLength.tr(
        namedArgs: {
          'field': LocaleKeys.name.tr(),
          'length': '2',
        },
      );
    }

    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationRequired.tr();
    }

    return null;
  }

  static String? validateArea(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validationRequired.tr();
    }

    return null;
  }

  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationRequired.tr();
    }

    final vehicleNumberRegex =
        RegExp(r'^[A-Za-z0-9\u0621-\u064A]+$');

    if (!vehicleNumberRegex.hasMatch(value.trim())) {
      return LocaleKeys.validationValidVehicleNumber.tr();
    }

    return null;
  }

  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validationRequired.tr();
    }

    final id = value.trim();

    if (!RegExp(r'^\d+$').hasMatch(id)) {
      return LocaleKeys.validationNationalIdNumbersOnly.tr();
    }

    if (id.length != 14) {
      return LocaleKeys.validationNationalIdLength.tr();
    }

    return null;
  }
}
