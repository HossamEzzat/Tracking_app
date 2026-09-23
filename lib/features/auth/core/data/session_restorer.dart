import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/core/network/access_token_expiry.dart';
import 'package:tracking_app/core/network/token_refresh_coordinator.dart';
import 'package:tracking_app/core/network/token_storage.dart';
import 'package:tracking_app/features/auth/core/domain/repos/auth_repository.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';
import 'package:tracking_app/features/auth/login/domain/post_auth_route.dart';

@lazySingleton
class SessionRestorer {
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final TokenRefreshCoordinator _coordinator;

  SessionRestorer(this._repository, this._tokenStorage, this._coordinator);

  Future<String> restore() async {
    final session = await _repository.currentSession();
    if (session == null) return _missingSession();
    if (!await _needsRefresh()) return _open(session);
    return _refreshAndRoute(session);
  }

  Future<String> _missingSession() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return AppRoutes.onboarding;
    await _repository.logout();
    return AppRoutes.login;
  }

  Future<bool> _needsRefresh() async {
    final expiry = await _tokenStorage.getAccessTokenExpiry();
    return accessTokenNeedsRefresh(expiry, DateTime.now());
  }

  Future<String> _open(AuthEntity session) async {
    await _repository.startSessionRefresh();
    return resolveAuthenticatedRoute(session);
  }

  Future<String> _refreshAndRoute(AuthEntity session) async {
    try {
      final tokens = await _coordinator.refresh();
      if (tokens == null) return await _dropSession();
      final restored = await _repository.currentSession();
      if (restored == null) return await _dropSession();
      return await _open(restored);
    } on SessionExpiredException {
      return AppRoutes.login;
    } on DioException {
      return await _open(session);
    }
  }

  Future<String> _dropSession() async {
    await _repository.logout();
    return AppRoutes.login;
  }
}
