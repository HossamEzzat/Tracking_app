import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<AuthEntity>> signIn(LoginRequest request);

  Future<void> signOut();
}
