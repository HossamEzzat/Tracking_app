import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/core/errors/app_error.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';
import 'package:tracking_app/features/auth/login/domain/use_case/login_usecase.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_event.dart';
import 'package:tracking_app/features/auth/login/presentation/view_model/login_state.dart';

@injectable
class LoginViewModel extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginViewModel(this._loginUseCase) : super(const LoginState());

  void doEvent(LoginEvent event) {
    switch (event) {
      case LoginSubmitted():
        _login(event.email, event.password);
      case LoginFailureCleared():
        _clearFailure();
    }
  }

  Future<void> _login(String email, String password) async {
    _emitLoading();
    final response = await _loginUseCase(
      LoginRequest(email: email, password: password),
    );
    _emitResult(response);
  }

  void _emitLoading() {
    emit(
      state.copyWith(
        clearFailure: true,
        loginState: state.loginState.copyWith(isLoading: true),
      ),
    );
  }

  void _emitResult(BaseResponse<AuthEntity> response) {
    switch (response) {
      case SuccessResponse<AuthEntity>():
        _emitSuccess(response.data);
      case ErrorResponse<AuthEntity>():
        _emitFailure(response.appError);
    }
  }

  void _emitSuccess(AuthEntity session) {
    emit(
      state.copyWith(
        clearFailure: true,
        loginState: state.loginState.copyWith(isLoading: false, data: session),
      ),
    );
  }

  void _emitFailure(AppError error) {
    emit(
      state.copyWith(
        failure: error,
        loginState: state.loginState.copyWith(isLoading: false),
      ),
    );
  }

  void _clearFailure() {
    if (state.failure == null) return;
    emit(state.copyWith(clearFailure: true));
  }
}
