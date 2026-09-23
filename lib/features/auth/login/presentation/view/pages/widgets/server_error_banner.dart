import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/features/auth/login/domain/login_failure.dart';

class ServerErrorBanner extends StatelessWidget {
  final AppError error;

  const ServerErrorBanner({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final kind = classifyLoginFailure(error);
    final colors = _BannerColors.of(kind);
    return Container(
      key: ValueKey(kind),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: _decoration(colors),
      child: _message(colors),
    );
  }

  BoxDecoration _decoration(_BannerColors colors) {
    return BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: colors.foreground),
    );
  }

  Widget _message(_BannerColors colors) {
    return Row(
      children: [
        Icon(colors.icon, color: colors.foreground, size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(child: Text(error.message, style: _textStyle(colors))),
      ],
    );
  }

  TextStyle _textStyle(_BannerColors colors) {
    return TextStyle(color: colors.foreground, fontSize: 14.sp);
  }
}

class _BannerColors {
  final Color background;
  final Color foreground;
  final IconData icon;

  const _BannerColors(this.background, this.foreground, this.icon);

  static _BannerColors of(LoginFailureKind kind) => _styles[kind]!;

  static const _styles = {
    LoginFailureKind.credentials: _BannerColors(
      Color(0xFFFFEBEE),
      Color(0xFFCC2B2B),
      Icons.error_outline,
    ),
    LoginFailureKind.network: _BannerColors(
      Color(0xFFFFF4E5),
      Color(0xFF8A5A00),
      Icons.wifi_off,
    ),
    LoginFailureKind.rateLimit: _BannerColors(
      Color(0xFFF3E5F5),
      Color(0xFF6A1B9A),
      Icons.timer_outlined,
    ),
    LoginFailureKind.server: _BannerColors(
      Color(0xFFF3F4F6),
      Color(0xFF374151),
      Icons.cloud_off,
    ),
  };
}
