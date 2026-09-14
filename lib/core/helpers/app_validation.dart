import 'package:tracking_app/core/constant/app_constants.dart';

class AppValidators {
  AppValidators._();

  static final RegExp _passwordPattern = RegExp(r'^(?=.*[A-Z]).{8,}$');

  static final RegExp _registrationPasswordPattern = RegExp(
    r'^(?=.*[A-Z])(?=.*\d).{6,}$',
  );

  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9_]+$');

  static final RegExp _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  static final RegExp _phonePattern = RegExp(r'^01[0125][0-9]{8}$');

  static String? requiredField(String? value, {required String field}) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.fieldIsRequired(field);
    }

    return null;
  }

  static String? usernameValidator(String? value, {String field = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.fieldIsRequired(field);
    }

    if (value.length < 4) {
      return AppConstants.fieldMinLength(field, 4);
    }

    if (value.contains(' ')) {
      return AppConstants.fieldNoSpaces(field);
    }

    if (!_usernamePattern.hasMatch(value)) {
      return AppConstants.onlyLettersNumbersUnderscore;
    }

    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.pleaseEnterYourEmail;
    }

    if (!_emailPattern.hasMatch(value.trim())) {
      return AppConstants.pleaseEnterValidEmail;
    }

    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordIsRequired;
    }

    if (!_passwordPattern.hasMatch(value)) {
      return AppConstants.passwordRequirement;
    }

    return null;
  }

  static String? registrationPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordIsRequired;
    }

    if (!_registrationPasswordPattern.hasMatch(value)) {
      return AppConstants.registrationPasswordRequirement;
    }

    return null;
  }

  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppConstants.confirmPasswordIsRequired;
    }

    if (value != password) {
      return AppConstants.passwordsDoNotMatch;
    }

    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.phoneNumberIsRequired;
    }

    if (!_phonePattern.hasMatch(value.trim())) {
      return AppConstants.validEgyptianPhone;
    }

    return null;
  }

  static String? resetPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.passwordIsRequired;
    }

    if (!_registrationPasswordPattern.hasMatch(value)) {
      return AppConstants.resetPasswordRequirement;
    }

    return null;
  }

  static String? otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.otpRequired;
    }

    if (value.length != 6) {
      return AppConstants.invalidOtp;
    }

    return null;
  }
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the address';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }
  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the recipient name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a city';
    }
    return null;
  }
  static String? validateArea(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an area';
    }
    return null;
  }
 static String? validateVehicleNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Vehicle number is required';
  }

  final vehicleNumberRegex = RegExp(r'^[A-Za-z0-9\u0621-\u064A]+$');

  if (!vehicleNumberRegex.hasMatch(value.trim())) {
    return 'Enter a valid vehicle number';
  }

  return null;
}
static String? validateNationalId(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'National ID is required';
  }

  final id = value.trim();

  if (!RegExp(r'^\d+$').hasMatch(id)) {
    return 'National ID must contain numbers only';
  }

  if (id.length != 14) {
    return 'National ID must be 14 digits';
  }

  return null;
}
}
