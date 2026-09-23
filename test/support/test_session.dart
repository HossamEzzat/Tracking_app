import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

AuthEntity testSession({
  String role = 'Driver',
  String? status = 'Approved',
  bool canAccess = true,
  String? reason,
}) {
  return AuthEntity(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    role: role,
    expiresIn: 900,
    driverApplicationStatus: status,
    canAccessDriverHome: canAccess,
    driverApplicationRejectionReason: reason,
  );
}
