import 'package:equatable/equatable.dart';
import 'package:tracking_app/core/base/base_state.dart';

class AuthState extends Equatable {
  final BaseState<bool> authState;
  final bool sessionExpired;

  const AuthState({
    this.authState = const BaseState(),
    this.sessionExpired = false,
  });

  AuthState copyWith({BaseState<bool>? authState, bool? sessionExpired}) {
    return AuthState(
      authState: authState ?? this.authState,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }

  @override
  List<Object?> get props => [authState, sessionExpired];
}
