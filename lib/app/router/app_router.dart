import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/constants/app_string.dart';
import 'package:tracking_app/core/di/di.dart';
import 'package:tracking_app/core/widgets/message_page.dart';
import 'package:tracking_app/features/auth/login/presentation/view/pages/login_page.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_view_model.dart';
import 'package:tracking_app/features/onboarding/presentation/onboarding_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation ?? AppRoutes.onboarding,
      routes: [
        GoRoute(path: AppRoutes.onboarding, builder: _onboarding),
        GoRoute(path: AppRoutes.login, builder: _login),
        GoRoute(path: AppRoutes.forgotPassword, builder: _forgotPassword),
        GoRoute(path: AppRoutes.applyNow, builder: _applyNow),
        GoRoute(path: AppRoutes.driverHome, builder: _driverHome),
        GoRoute(path: AppRoutes.driverPending, builder: _driverPending),
        GoRoute(path: AppRoutes.driverRejected, builder: _driverRejected),
        GoRoute(path: AppRoutes.driverUnknown, builder: _driverUnknown),
        GoRoute(path: AppRoutes.driverUnavailable, builder: _driverUnavailable),
        GoRoute(path: AppRoutes.customerHome, builder: _customerHome),
        GoRoute(path: AppRoutes.unauthorized, builder: _unauthorized),
      ],
    );
  }

  static Widget _onboarding(BuildContext context, GoRouterState state) {
    return const OnboardingPage();
  }

  static Widget _login(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<LoginViewModel>(),
      child: const LoginPage(),
    );
  }

  static Widget _forgotPassword(BuildContext context, GoRouterState state) {
    return MessagePage(
      title: AppString.forgetPassword,
      message: AppString.forgotPasswordMissing,
      onBack: () => _back(context),
    );
  }

  static Widget _applyNow(BuildContext context, GoRouterState state) {
    return MessagePage(
      title: AppString.applyNow,
      message: AppString.applyNowMissing,
      onBack: () => _back(context),
    );
  }

  static Widget _driverHome(BuildContext context, GoRouterState state) {
    return const MessagePage(
      title: AppString.driverHomeTitle,
      message: AppString.driverHomeTitle,
    );
  }

  static Widget _driverPending(BuildContext context, GoRouterState state) {
    return const MessagePage(
      title: AppString.driverPendingTitle,
      message: AppString.driverPendingBody,
    );
  }

  static Widget _driverRejected(BuildContext context, GoRouterState state) {
    return MessagePage(
      title: AppString.driverRejectedTitle,
      message: _rejectionMessage(state),
    );
  }

  static Widget _driverUnknown(BuildContext context, GoRouterState state) {
    return const MessagePage(
      title: AppString.driverUnknownTitle,
      message: AppString.driverUnknownBody,
    );
  }

  static Widget _driverUnavailable(BuildContext context, GoRouterState state) {
    return const MessagePage(
      title: AppString.driverUnavailableTitle,
      message: AppString.driverUnavailableBody,
    );
  }

  static Widget _customerHome(BuildContext context, GoRouterState state) {
    return const MessagePage(
      title: AppString.customerHomeTitle,
      message: AppString.customerHomeBody,
    );
  }

  static Widget _unauthorized(BuildContext context, GoRouterState state) {
    return const MessagePage(
      title: AppString.unauthorizedTitle,
      message: AppString.unauthorizedBody,
    );
  }

  static String _rejectionMessage(GoRouterState state) {
    final reason = state.uri.queryParameters['reason']?.trim() ?? '';
    if (reason.isEmpty) return AppString.driverRejectedBody;
    return reason;
  }

  static void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.onboarding);
  }
}
