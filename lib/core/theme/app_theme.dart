import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracking_app/core/theme/app_color.dart';

class AppTheme {
  final AppColors colors;
  final ThemeData themeData;

  AppTheme(this.colors) : themeData = _themeData(colors);
}

ThemeData _themeData(AppColors colors) {
  final borderRadius = BorderRadius.circular(10.r);
  return ThemeData(
    colorScheme: _colorScheme(colors),
    brightness: colors.brightness,
    scaffoldBackgroundColor: colors.white,
    appBarTheme: _appBarTheme(colors),
    inputDecorationTheme: _inputTheme(colors, borderRadius),
    elevatedButtonTheme: _buttonTheme(colors),
    checkboxTheme: _checkboxTheme(colors),
  );
}

ColorScheme _colorScheme(AppColors colors) {
  return ColorScheme(
    brightness: colors.brightness,
    primary: colors.pink,
    onPrimary: colors.white,
    secondary: colors.pink,
    onSecondary: colors.white,
    error: colors.error,
    onError: colors.white,
    surface: colors.white,
    onSurface: colors.black,
  );
}

AppBarTheme _appBarTheme(AppColors colors) {
  return AppBarTheme(
    backgroundColor: colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleSpacing: 0,
    iconTheme: IconThemeData(color: colors.black, size: 22.sp),
    titleTextStyle: TextStyle(
      color: colors.black,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    ),
  );
}

InputDecorationTheme _inputTheme(AppColors colors, BorderRadius radius) {
  final idle = BorderSide(color: const Color(0xFFD5D5D5));
  final error = BorderSide(color: colors.error);
  return InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    labelStyle: TextStyle(color: colors.black, fontSize: 14.sp),
    hintStyle: TextStyle(color: colors.grey, fontSize: 16.sp),
    errorStyle: TextStyle(color: colors.error, fontSize: 13.sp),
    border: _outline(radius, idle),
    enabledBorder: _outline(radius, idle),
    focusedBorder: _outline(radius, BorderSide(color: colors.pink)),
    errorBorder: _outline(radius, error),
    focusedErrorBorder: _outline(radius, error),
  );
}

OutlineInputBorder _outline(BorderRadius radius, BorderSide side) {
  return OutlineInputBorder(borderRadius: radius, borderSide: side);
}

ElevatedButtonThemeData _buttonTheme(AppColors colors) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colors.pink,
      foregroundColor: colors.white,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
      elevation: 0,
    ),
  );
}

CheckboxThemeData _checkboxTheme(AppColors colors) {
  return CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return colors.pink;
      return colors.white;
    }),
    side: BorderSide(color: colors.grey, width: 1.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
  );
}
