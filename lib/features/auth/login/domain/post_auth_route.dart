import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

String resolveAuthenticatedRoute(AuthEntity session) {
  if (_isRole(session.role, 'Customer')) return AppRoutes.customerHome;
  if (!_isRole(session.role, 'Driver')) return AppRoutes.unauthorized;
  if (session.canAccessDriverHome) return AppRoutes.driverHome;
  return _driverStatusRoute(session);
}

String _driverStatusRoute(AuthEntity session) {
  switch (session.driverApplicationStatus) {
    case 'PendingReview':
      return AppRoutes.driverPending;
    case 'Rejected':
      return rejectedRoute(session.driverApplicationRejectionReason);
    case 'Approved':
      return AppRoutes.driverUnavailable;
    default:
      return AppRoutes.driverUnknown;
  }
}

String rejectedRoute(String? reason) {
  final value = reason?.trim() ?? '';
  if (value.isEmpty) return AppRoutes.driverRejected;
  return '${AppRoutes.driverRejected}?reason=${Uri.encodeQueryComponent(value)}';
}

bool _isRole(String role, String expected) {
  return role.trim().toLowerCase() == expected.toLowerCase();
}
