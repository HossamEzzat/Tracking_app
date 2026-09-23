import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_cubit.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_event.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';
import 'package:tracking_app/features/auth/login/domain/post_auth_route.dart';
import 'package:tracking_app/features/auth/login/presentation/view/pages/widgets/login_app_bar.dart';
import 'package:tracking_app/features/auth/login/presentation/view/pages/widgets/login_form.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_event.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_state.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final LoginViewModel _viewModel;
  bool _rememberMe = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _viewModel = context.read<LoginViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(onBack: () => _back(context)),
      body: BlocConsumer<LoginViewModel, LoginState>(
        listener: _onState,
        builder: (context, state) => _body(state),
      ),
    );
  }

  Widget _body(LoginState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: _form(state),
      ),
    );
  }

  Widget _form(LoginState state) {
    return LoginForm(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      showErrors: _showErrors,
      rememberMe: _rememberMe,
      isLoading: state.loginState.isLoading,
      canContinue: _canContinue,
      failure: state.failure,
      onRememberMe: (value) => setState(() => _rememberMe = value),
      onForgotPassword: () => context.push(AppRoutes.forgotPassword),
      onFieldChanged: _onFieldChanged,
      onSubmit: _submit,
    );
  }

  bool get _canContinue {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  void _onFieldChanged() {
    setState(() {});
    if (_viewModel.state.failure == null) return;
    _viewModel.doEvent(const LoginFailureCleared());
  }

  void _submit() {
    setState(() => _showErrors = true);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _viewModel.state.loginState.isLoading) return;
    _viewModel.doEvent(
      LoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _onState(BuildContext context, LoginState state) {
    final session = state.loginState.data;
    if (session == null ||
        state.loginState.isLoading ||
        state.failure != null) {
      return;
    }
    unawaited(_openSession(context, session));
  }

  Future<void> _openSession(BuildContext context, AuthEntity session) async {
    await context.read<AuthCubit>().doEvent(const AuthLoginSucceeded());
    if (!context.mounted) return;
    context.go(resolveAuthenticatedRoute(session));
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.onboarding);
  }
}
