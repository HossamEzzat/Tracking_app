import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tracking_app/core/constants/app_string.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/core/helpers/app_validators.dart';
import 'package:tracking_app/core/theme/app_color.dart';
import 'package:tracking_app/core/widgets/app_button.dart';
import 'package:tracking_app/features/auth/login/presentation/view/pages/widgets/server_error_banner.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool showErrors;
  final bool rememberMe;
  final bool isLoading;
  final bool canContinue;
  final AppError? failure;
  final ValueChanged<bool> onRememberMe;
  final VoidCallback onForgotPassword;
  final VoidCallback onFieldChanged;
  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.showErrors,
    required this.rememberMe,
    required this.isLoading,
    required this.canContinue,
    required this.failure,
    required this.onRememberMe,
    required this.onForgotPassword,
    required this.onFieldChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: showErrors
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: _fields(context),
    );
  }

  Widget _fields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (failure != null) ServerErrorBanner(error: failure!),
        _emailField(),
        SizedBox(height: 16.h),
        _passwordField(),
        SizedBox(height: 8.h),
        _options(context),
        SizedBox(height: 24.h),
        _continueButton(context),
      ],
    );
  }

  Widget _emailField() {
    return TextFormField(
      key: const Key('email-field'),
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: AppValidators.loginEmail,
      onChanged: (_) => onFieldChanged(),
      decoration: const InputDecoration(
        labelText: AppString.email,
        hintText: AppString.enterYourEmail,
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      key: const Key('password-field'),
      controller: passwordController,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      validator: AppValidators.loginPassword,
      onChanged: (_) => onFieldChanged(),
      onFieldSubmitted: (_) => onSubmit(),
      decoration: const InputDecoration(
        labelText: AppString.password,
        hintText: AppString.enterYourPassword,
      ),
    );
  }

  Widget _options(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _rememberMe(context)),
        _forgotPassword(context),
      ],
    );
  }

  Widget _rememberMe(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          key: const Key('remember-me'),
          value: rememberMe,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (value) => onRememberMe(value ?? false),
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            AppString.rememberMe,
            style: TextStyle(color: context.colors.black, fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onForgotPassword,
      child: Text(
        AppString.forgetPassword,
        style: TextStyle(
          color: context.colors.black,
          fontSize: 14.sp,
          decoration: TextDecoration.underline,
          decorationColor: context.colors.black,
        ),
      ),
    );
  }

  Widget _continueButton(BuildContext context) {
    final colors = context.colors;
    return AppButton(
      key: const Key('continue-button'),
      text: AppString.continueLabel,
      isLoading: isLoading,
      onPressed: onSubmit,
      backgroundColor: canContinue ? colors.pink : colors.disabledButton,
      foregroundColor: colors.white,
    );
  }
}
