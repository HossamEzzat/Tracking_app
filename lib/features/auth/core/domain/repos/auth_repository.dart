import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  Future<bool> isAuthenticated();

  Future<AuthEntity?> currentSession();

  Future<void> logout();

  Future<void> startSessionRefresh();

  void stopSessionRefresh();

  Stream<void> get sessionExpired;
}
