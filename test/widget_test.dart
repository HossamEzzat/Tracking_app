import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tracking_app/app/router/app_router.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/core/constants/app_string.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/core/theme/app_color.dart';
import 'package:tracking_app/core/theme/app_theme.dart';
import 'package:tracking_app/core/widgets/app_button.dart';
import 'package:tracking_app/features/auth/core/domain/repos/auth_repository.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_cubit.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';
import 'package:tracking_app/features/auth/login/domain/login_failure.dart';
import 'package:tracking_app/features/auth/login/domain/repo/auth_repo.dart';
import 'package:tracking_app/features/auth/login/domain/use_case/login_usecase.dart';
import 'package:tracking_app/features/auth/login/presentation/view/pages/login_page.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_view_model.dart';
import 'package:tracking_app/features/onboarding/presentation/onboarding_page.dart';

import 'support/test_session.dart';

void main() {
  testWidgets('empty email and password show inline validation', (
    tester,
  ) async {
    final harness = await _pumpLogin(tester);

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();

    expect(find.text(AppString.invalidEmail), findsOneWidget);
    expect(find.text(AppString.invalidPassword), findsOneWidget);
    expect(harness.repo.calls, 0);
  });

  testWidgets('invalid email shows the email error only', (tester) async {
    final harness = await _pumpLogin(tester);
    await _enter(tester, email: 'not-an-email', password: 'secret');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();

    expect(find.text(AppString.invalidEmail), findsOneWidget);
    expect(find.text(AppString.invalidPassword), findsNothing);
    expect(harness.repo.calls, 0);
  });

  testWidgets('empty password shows the password error only', (tester) async {
    final harness = await _pumpLogin(tester);
    await _enter(tester, email: 'user@example.com', password: '');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();

    expect(find.text(AppString.invalidPassword), findsOneWidget);
    expect(find.text(AppString.invalidEmail), findsNothing);
    expect(harness.repo.calls, 0);
  });

  testWidgets('editing a field clears its inline error', (tester) async {
    await _pumpLogin(tester);
    await _enter(tester, email: 'not-an-email', password: 'secret');
    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();

    await _enter(tester, email: 'user@example.com');
    await tester.pump();

    expect(find.text(AppString.invalidEmail), findsNothing);
  });

  testWidgets('continue stays disabled until both fields have text', (
    tester,
  ) async {
    await _pumpLogin(tester);
    expect(_buttonColor(tester), lightThemeColors.disabledButton);

    await _enter(tester, email: 'user@example.com', password: 'secret');
    await tester.pump();

    expect(_buttonColor(tester), lightThemeColors.pink);
  });

  testWidgets('invalid credentials show a credential banner', (tester) async {
    final harness = await _pumpLogin(tester);
    harness.repo.response = ErrorResponse(
      appError: UnauthorizedError('Invalid email or password.'),
    );
    await _enter(tester, email: 'user@example.com', password: 'secret');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey(LoginFailureKind.credentials)),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey(LoginFailureKind.network)), findsNothing);
    expect(find.text('Invalid email or password.'), findsOneWidget);
  });

  testWidgets('network failure shows a distinct banner', (tester) async {
    final harness = await _pumpLogin(tester);
    harness.repo.response = ErrorResponse(
      appError: NoInternetError(Exception('offline')),
    );
    await _enter(tester, email: 'user@example.com', password: 'secret');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey(LoginFailureKind.network)),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey(LoginFailureKind.credentials)),
      findsNothing,
    );
    expect(find.text(AppString.invalidEmail), findsNothing);
  });

  testWidgets('rate limit shows its own banner', (tester) async {
    final harness = await _pumpLogin(tester);
    harness.repo.response = ErrorResponse(
      appError: BadResponseError(
        'Too many requests, please try again later.',
        statusCode: 429,
      ),
    );
    await _enter(tester, email: 'user@example.com', password: 'secret');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey(LoginFailureKind.rateLimit)),
      findsOneWidget,
    );
  });

  testWidgets('successful login opens driver home', (tester) async {
    final harness = await _pumpLogin(tester);
    harness.repo.response = SuccessResponse(testSession());
    await _enter(tester, email: 'user@example.com', password: 'secret');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    await tester.pump();

    expect(find.text(AppString.driverHomeTitle), findsOneWidget);
  });

  testWidgets('remember me does not change the login request', (tester) async {
    final harness = await _pumpLogin(tester);
    harness.repo.response = SuccessResponse(testSession());
    await tester.tap(find.byKey(const Key('remember-me')));
    await tester.pump();
    await _enter(tester, email: 'user@example.com', password: 'secret');

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pump();
    await tester.pump();

    expect(harness.repo.last?.toJson(), {
      'email': 'user@example.com',
      'password': 'secret',
    });
  });

  testWidgets('forget password opens the recovery entry', (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.text(AppString.forgetPassword));
    await tester.pumpAndSettle();

    expect(find.text('forgot-screen'), findsOneWidget);
  });

  testWidgets('onboarding login opens the login screen', (tester) async {
    await _pumpOnboarding(tester);

    await tester.tap(find.text(AppString.login));
    await tester.pumpAndSettle();

    expect(find.text('login-screen'), findsOneWidget);
  });

  testWidgets('onboarding apply now opens the application entry', (
    tester,
  ) async {
    await _pumpOnboarding(tester);

    await tester.tap(find.text(AppString.applyNow));
    await tester.pumpAndSettle();

    expect(find.text('apply-screen'), findsOneWidget);
  });

  testWidgets('rejected route shows the rejection reason', (tester) async {
    final router = AppRouter.createRouter(
      initialLocation: '${AppRoutes.driverRejected}?reason=Missing%20documents',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Missing documents'), findsOneWidget);
    expect(find.text(AppString.driverRejectedTitle), findsOneWidget);
  });
}

Future<void> _enter(
  WidgetTester tester, {
  String? email,
  String? password,
}) async {
  if (email != null) {
    await tester.enterText(find.byKey(const Key('email-field')), email);
  }
  if (password != null) {
    await tester.enterText(find.byKey(const Key('password-field')), password);
  }
  await tester.pump();
}

Color _buttonColor(WidgetTester tester) {
  return tester
      .widget<AppButton>(find.byKey(const Key('continue-button')))
      .backgroundColor;
}

Future<_LoginHarness> _pumpLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = _RecordingAuthRepo();
  final viewModel = LoginViewModel(LoginUseCase(repo));
  final cubit = AuthCubit(_FakeSessionRepository());
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) =>
            BlocProvider.value(value: viewModel, child: const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const Text('forgot-screen'),
      ),
      GoRoute(
        path: AppRoutes.driverHome,
        builder: (_, _) => const Text(AppString.driverHomeTitle),
      ),
    ],
  );
  addTearDown(() async {
    router.dispose();
    await cubit.close();
    await viewModel.close();
  });
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => BlocProvider.value(
        value: cubit,
        child: MaterialApp.router(
          theme: AppTheme(lightThemeColors).themeData,
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pump();
  return _LoginHarness(repo);
}

Future<void> _pumpOnboarding(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const Scaffold(body: Text('login-screen')),
      ),
      GoRoute(
        path: AppRoutes.applyNow,
        builder: (_, _) => const Scaffold(body: Text('apply-screen')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp.router(
        theme: AppTheme(lightThemeColors).themeData,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

class _LoginHarness {
  final _RecordingAuthRepo repo;

  _LoginHarness(this.repo);
}

class _RecordingAuthRepo implements AuthRepo {
  int calls = 0;
  LoginRequest? last;
  BaseResponse<AuthEntity> response = ErrorResponse(
    appError: UnauthorizedError('unused'),
  );

  @override
  Future<BaseResponse<AuthEntity>> signIn(LoginRequest request) async {
    calls++;
    last = request;
    return response;
  }

  @override
  Future<void> signOut() async {}
}

class _FakeSessionRepository implements AuthRepository {
  @override
  Future<AuthEntity?> currentSession() async => null;

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<void> startSessionRefresh() async {}

  @override
  void stopSessionRefresh() {}

  @override
  Stream<void> get sessionExpired => const Stream.empty();
}
