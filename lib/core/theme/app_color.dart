import 'package:flutter/material.dart';

class AppColors {
  final Color grey;
  final Color pink;
  final Color black;
  final Color error;
  final Color white;
  final Color disabledButton;
  final Brightness brightness;

  const AppColors({
    required this.grey,
    required this.pink,
    required this.black,
    required this.error,
    required this.white,
    required this.disabledButton,
    required this.brightness,
  });
}

const lightThemeColors = AppColors(
  grey: Color(0xFF969696),
  pink: Color(0xFFD21E6A),
  black: Color(0xFF0C1015),
  error: Color(0xFFCC2B2B),
  white: Color(0xFFFEFEFE),
  disabledButton: Color(0xFF878787),
  brightness: Brightness.light,
);

extension ThemeColors on BuildContext {
  AppColors get colors => lightThemeColors;
}
