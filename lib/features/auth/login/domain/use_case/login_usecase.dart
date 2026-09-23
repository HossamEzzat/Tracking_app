import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';
import 'package:tracking_app/features/auth/login/domain/repo/auth_repo.dart';

@injectable
class LoginUseCase {
  final AuthRepo repo;

  LoginUseCase(this.repo);

  Future<BaseResponse<AuthEntity>> call(LoginRequest request) {
    return repo.signIn(request);
  }
}
