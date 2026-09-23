import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/data/models/login_response.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
}
