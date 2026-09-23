import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tracking_app/app/router/app_router.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/constants/api_endpoints.dart';
import 'package:tracking_app/core/di/di.dart';
import 'package:tracking_app/core/theme/app_color.dart';
import 'package:tracking_app/core/theme/app_theme.dart';
import 'package:tracking_app/features/auth/core/data/session_restorer.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_cubit.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_event.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await ApiEndpoints.loadBaseUrl();
  await configureDependencies();
  final initialLocation = await getIt<SessionRestorer>().restore();
  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatefulWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = AppRouter.createRouter(
    initialLocation: widget.initialLocation,
  );
  late final AuthCubit _authCubit = getIt<AuthCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(_authCubit.doEvent(const AuthCheckRequested()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          return current.sessionExpired && !previous.sessionExpired;
        },
        listener: _onSessionExpired,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => _app(),
        ),
      ),
    );
  }

  Widget _app() {
    return MaterialApp.router(
      routerConfig: _router,
      theme: AppTheme(lightThemeColors).themeData,
      debugShowCheckedModeBanner: false,
      title: 'Flowery rider app',
    );
  }

  void _onSessionExpired(BuildContext context, AuthState state) {
    context.read<AuthCubit>().acknowledgeSessionExpired();
    _router.go(AppRoutes.login);
  }
}
