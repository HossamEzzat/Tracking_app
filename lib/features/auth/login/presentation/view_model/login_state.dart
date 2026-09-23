import 'package:equatable/equatable.dart';
import 'package:tracking_app/core/base/base_state.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

class LoginState extends Equatable {
  final BaseState<AuthEntity> loginState;
  final AppError? failure;

  const LoginState({this.loginState = const BaseState(), this.failure});

  LoginState copyWith({
    BaseState<AuthEntity>? loginState,
    AppError? failure,
    bool clearFailure = false,
  }) {
    return LoginState(
      loginState: loginState ?? this.loginState,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [loginState, failure];
}
