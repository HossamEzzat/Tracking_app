
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/constant/app_constants.dart';
import 'package:tracking_app/features/auth/presentation/login/page/login_page.dart';
class AppRouter {
  AppRouter._();

  static GoRouter createRouter({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation ?? AppRoutes.login,
      errorBuilder: _errorBuilder,
      routes: [
        _loginRoute(),

      ],
    );
  }

  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text(AppConstants.pageNotFound)));
  }

  static GoRoute _loginRoute() {
    return GoRoute(
      path: AppRoutes.login,
      builder: (context, state) {
        return 
           LoginPage();
          
      },
    );
  }

}