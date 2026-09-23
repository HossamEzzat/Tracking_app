import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/core/network/safe_call.dart';
import 'package:tracking_app/core/network/token_storage.dart';
import 'package:tracking_app/features/auth/login/data/data_source/remote/auth_remote_data_source.dart';
import 'package:tracking_app/features/auth/login/data/models/login_request.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';
import 'package:tracking_app/features/auth/login/domain/repo/auth_repo.dart';

@Injectable(as: AuthRepo)
class AuthRepositoryImpl implements AuthRepo {
  final AuthRemoteDataSource remoteDatasource;
  final SafeCall safeCall;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDatasource, this.safeCall, this.tokenStorage);

  @override
  Future<BaseResponse<AuthEntity>> signIn(LoginRequest request) {
    return safeCall.safeApiCall(() => _signIn(request));
  }

  Future<AuthEntity> _signIn(LoginRequest request) async {
    final data = (await remoteDatasource.login(request)).data;
    await tokenStorage.saveSession(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      expiresIn: data.expiresIn,
      profile: AuthProfile(
        role: data.role,
        canAccessDriverHome: data.canAccessDriverHome,
        driverApplicationStatus: data.driverApplicationStatus,
        driverApplicationRejectionReason: data.driverApplicationRejectionReason,
      ),
    );
    return data.toDomain();
  }

  @override
  Future<void> signOut() => tokenStorage.clearTokens();
}
