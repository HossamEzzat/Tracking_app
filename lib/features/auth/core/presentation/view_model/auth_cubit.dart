import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/base/base_state.dart';
import 'package:tracking_app/features/auth/core/domain/repos/auth_repository.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_event.dart';
import 'package:tracking_app/features/auth/core/presentation/view_model/auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  AuthCubit(this._authRepository) : super(const AuthState()) {
    _sessionExpiredSubscription = _authRepository.sessionExpired.listen(
      (_) => _handleSessionExpired(),
    );
  }

  Future<void> doEvent(AuthEvent event) async {
    switch (event) {
      case AuthCheckRequested():
        await _checkAuth();
      case AuthLogoutRequested():
        await _logout();
      case AuthLoginSucceeded():
        await _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (isAuthenticated) await _authRepository.startSessionRefresh();
    emit(
      state.copyWith(
        authState: BaseState(data: isAuthenticated),
        sessionExpired: false,
      ),
    );
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    _authRepository.stopSessionRefresh();
    emit(
      state.copyWith(
        authState: const BaseState(data: false),
        sessionExpired: false,
      ),
    );
  }

  void _handleSessionExpired() {
    _authRepository.stopSessionRefresh();
    emit(
      state.copyWith(
        authState: const BaseState(data: false),
        sessionExpired: true,
      ),
    );
  }

  void acknowledgeSessionExpired() {
    if (!state.sessionExpired) return;
    emit(state.copyWith(sessionExpired: false));
  }

  @override
  @disposeMethod
  Future<void> close() {
    _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
