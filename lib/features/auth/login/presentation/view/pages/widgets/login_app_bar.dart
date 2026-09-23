import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracking_app/core/constants/app_string.dart';
import 'package:tracking_app/core/theme/app_color.dart';

class LoginAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const LoginAppBar({super.key, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Row(
        children: [
          IconButton(
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: context.colors.black,
              size: 20.sp,
            ),
          ),
          Text(AppString.login),
        ],
      ),
    );
  }
}
