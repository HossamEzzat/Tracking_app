import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String role;
  final int expiresIn;
  final String? driverApplicationStatus;
  final bool canAccessDriverHome;
  final String? driverApplicationRejectionReason;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.expiresIn,
    required this.canAccessDriverHome,
    this.driverApplicationStatus,
    this.driverApplicationRejectionReason,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    role,
    expiresIn,
    driverApplicationStatus,
    canAccessDriverHome,
    driverApplicationRejectionReason,
  ];
}
