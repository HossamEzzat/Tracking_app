import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/network/jwt_payload.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_refresh_scheduler.dart';
import 'package:tracking_app/core/network/token_storage.dart';
import 'package:tracking_app/features/auth/core/domain/repos/auth_repository.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final TokenStorage _tokenStorage;
  final TokenRefreshScheduler _scheduler;
  final TokenRefreshCoordinator _coordinator;

  AuthRepositoryImpl(this._tokenStorage, this._scheduler, this._coordinator);

  @override
  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthEntity?> currentSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (_isBlank(accessToken) || _isBlank(refreshToken)) return null;
    final profile = await _tokenStorage.readProfile();
    final claims = decodeJwtPayload(accessToken!);
    final role = profile?.role ?? roleFromClaims(claims);
    if (role == null || role.isEmpty) return null;
    return _session(accessToken, refreshToken!, role, profile, claims);
  }

  AuthEntity _session(
    String accessToken,
    String refreshToken,
    String role,
    AuthProfile? profile,
    Map<String, dynamic>? claims,
  ) {
    return AuthEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: role,
      expiresIn: 0,
      canAccessDriverHome: _canAccess(profile, claims),
      driverApplicationStatus: _status(profile, claims),
      driverApplicationRejectionReason: _reason(profile, claims),
    );
  }

  bool _canAccess(AuthProfile? profile, Map<String, dynamic>? claims) {
    return profile?.canAccessDriverHome ??
        claimBool(claims, 'canAccessDriverHome') ??
        false;
  }

  String? _status(AuthProfile? profile, Map<String, dynamic>? claims) {
    return profile?.driverApplicationStatus ??
        claimString(claims, 'driverApplicationStatus');
  }

  String? _reason(AuthProfile? profile, Map<String, dynamic>? claims) {
    return profile?.driverApplicationRejectionReason ??
        claimString(claims, 'driverApplicationRejectionReason');
  }

  @override
  Future<void> logout() => _tokenStorage.clearTokens();

  @override
  Future<void> startSessionRefresh() => _scheduler.start();

  @override
  void stopSessionRefresh() => _scheduler.stop();

  @override
  Stream<void> get sessionExpired => _coordinator.sessionExpired;
}

bool _isBlank(String? value) => value == null || value.isEmpty;
