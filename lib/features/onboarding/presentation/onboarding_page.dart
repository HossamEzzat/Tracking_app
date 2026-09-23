import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/constants/app_string.dart';
import 'package:tracking_app/core/theme/app_color.dart';
import 'package:tracking_app/core/widgets/app_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _content(context)));
  }

  Widget _content(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hero(),
          const Spacer(),
          _loginButton(context, colors),
          SizedBox(height: 16.h),
          _applyButton(context, colors),
          SizedBox(height: 28.h),
          Center(child: Text(AppString.appVersion, style: _versionStyle())),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _hero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Image.asset(
          'assets/images/rider_welcome.png',
          height: 280.h,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 28.h),
        Text(AppString.welcomeTitle, style: _titleStyle(lightThemeColors)),
      ],
    );
  }

  Widget _loginButton(BuildContext context, AppColors colors) {
    return AppButton(
      text: AppString.login,
      onPressed: () => context.push(AppRoutes.login),
      backgroundColor: colors.pink,
      foregroundColor: colors.white,
    );
  }

  Widget _applyButton(BuildContext context, AppColors colors) {
    return AppButton(
      text: AppString.applyNow,
      onPressed: () => context.push(AppRoutes.applyNow),
      backgroundColor: colors.white,
      foregroundColor: colors.black,
      borderColor: const Color(0xFFD5D5D5),
    );
  }

  TextStyle _titleStyle(AppColors colors) {
    return TextStyle(
      color: colors.black,
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
  }

  TextStyle _versionStyle() {
    return TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13.sp);
  }
}
