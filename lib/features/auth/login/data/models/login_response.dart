import 'package:tracking_app/features/auth/login/domain/entity/auth_entity.dart';

class LoginResponse {
  final bool isSuccess;
  final int statusCode;
  final String message;
  final LoginData data;

  const LoginResponse({
    required this.isSuccess,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isSuccess: json['isSuccess'] == true || json['success'] == true,
      statusCode: _asInt(json['statusCode']),
      message: json['message']?.toString() ?? '',
      data: LoginData.fromJson(_dataMap(json['data'])),
    );
  }
}

class LoginData {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String role;
  final String? driverApplicationStatus;
  final bool canAccessDriverHome;
  final String? driverApplicationRejectionReason;

  const LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.role,
    required this.canAccessDriverHome,
    this.driverApplicationStatus,
    this.driverApplicationRejectionReason,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: _requiredToken(json['accessToken'], 'access token'),
      refreshToken: _requiredToken(json['refreshToken'], 'refresh token'),
      expiresIn: _asInt(json['expiresIn']),
      role: json['role'] as String? ?? '',
      driverApplicationStatus: json['driverApplicationStatus'] as String?,
      canAccessDriverHome: json['canAccessDriverHome'] == true,
      driverApplicationRejectionReason:
          json['driverApplicationRejectionReason'] as String?,
    );
  }

  AuthEntity toDomain() {
    return AuthEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: role,
      expiresIn: expiresIn,
      driverApplicationStatus: driverApplicationStatus,
      canAccessDriverHome: canAccessDriverHome,
      driverApplicationRejectionReason: driverApplicationRejectionReason,
    );
  }
}

Map<String, dynamic> _dataMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  throw const FormatException('Login response is missing data');
}

String _requiredToken(dynamic value, String label) {
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Login response is missing an $label');
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
