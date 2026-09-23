import 'package:flutter/material.dart';

abstract class AppColors {
  MaterialColor get grey;
  MaterialColor get pink;
  MaterialColor get black;

  Color get error;
  Color get white;
  Color get disabledButton;
  Brightness get brightness;
}

class LightThemeColor implements AppColors {
  @override
  Brightness get brightness => Brightness.light;

  @override
  Color get disabledButton => const Color(0xff878787);

  @override
  Color get error => const Color(0xFFCC2B2B);

  @override
  MaterialColor get grey => const MaterialColor(0xffF9F9F9, <int, Color>{
    50: Color(0xFFFDFDFD),
    100: Color(0xFFFDFDFD),
    200: Color(0xFFFCFCFC),
    300: Color(0xFFFBFBFB),
    400: Color(0xFFFAFAFA),
    500: Color(0xFFF9F9F9),
    600: Color(0xFFBDBDBD),
    700: Color(0xFF969696),
    800: Color(0xFF707070),
    900: Color(0xFF535353),
  });

  @override
  MaterialColor get black => const MaterialColor(0xff0c1015, <int, Color>{
    10: Color(0xFFcecfd0),
    50: Color(0xFF34383c),
    100: Color(0xFF020304),
  });

  @override
  MaterialColor get pink => const MaterialColor(0xFFD21E6A, <int, Color>{
    50: Color(0xFFF4DBE4),
    500: Color(0xFFD21E6A),
    600: Color(0xFFA21F53),
  });

  @override
  Color get white => const Color(0xfffefefe);
}

final lightThemeColors = LightThemeColor();

extension ThemeColors on BuildContext {
  AppColors get colors => lightThemeColors;
}
