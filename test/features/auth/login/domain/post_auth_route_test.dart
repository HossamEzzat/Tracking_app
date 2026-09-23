import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/app/router/app_routes.dart';
import 'package:tracking_app/features/auth/login/domain/post_auth_route.dart';

import '../../../../support/test_session.dart';

void main() {
  test('approved driver with home access opens driver home', () {
    final route = resolveAuthenticatedRoute(
      testSession(status: 'Approved', canAccess: true),
    );

    expect(route, AppRoutes.driverHome);
  });

  test('pending driver opens the review route', () {
    final route = resolveAuthenticatedRoute(
      testSession(status: 'PendingReview', canAccess: false),
    );

    expect(route, AppRoutes.driverPending);
  });

  test('rejected driver opens the rejection route with the reason', () {
    final route = resolveAuthenticatedRoute(
      testSession(
        status: 'Rejected',
        canAccess: false,
        reason: 'Missing documents',
      ),
    );

    expect(route, '${AppRoutes.driverRejected}?reason=Missing+documents');
  });

  test('approved driver without home access does not open driver home', () {
    final route = resolveAuthenticatedRoute(
      testSession(status: 'Approved', canAccess: false),
    );

    expect(route, AppRoutes.driverUnavailable);
  });

  test('driver home access wins over a pending status', () {
    final route = resolveAuthenticatedRoute(
      testSession(status: 'PendingReview', canAccess: true),
    );

    expect(route, AppRoutes.driverHome);
  });

  test('unknown driver status opens the unknown route', () {
    final route = resolveAuthenticatedRoute(
      testSession(status: null, canAccess: false),
    );

    expect(route, AppRoutes.driverUnknown);
  });

  test('customer opens the customer route', () {
    final route = resolveAuthenticatedRoute(
      testSession(role: 'Customer', status: null, canAccess: false),
    );

    expect(route, AppRoutes.customerHome);
  });

  test('any other role is unauthorized', () {
    final route = resolveAuthenticatedRoute(
      testSession(role: 'Admin', status: null, canAccess: false),
    );

    expect(route, AppRoutes.unauthorized);
  });
}
