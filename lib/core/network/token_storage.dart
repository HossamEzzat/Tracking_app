import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/network/secure_key_value.dart';

class AuthProfile {
  final String role;
  final bool canAccessDriverHome;
  final String? driverApplicationStatus;
  final String? driverApplicationRejectionReason;

  const AuthProfile({
    required this.role,
    required this.canAccessDriverHome,
    this.driverApplicationStatus,
    this.driverApplicationRejectionReason,
  });
}

abstract interface class TokenStorage {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<DateTime?> getAccessTokenExpiry();

  Future<AuthProfile?> readProfile();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  });

  Future<void> saveAccessToken(String accessToken, {int? expiresIn});

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
    required AuthProfile profile,
  });

  Future<void> clearTokens();
}

@LazySingleton(as: TokenStorage)
class SecureTokenStorage implements TokenStorage {
  final SecureKeyValue _secureStorage;

  SecureTokenStorage(this._secureStorage);

  static const accessTokenKey = 'USER_TOKEN';
  static const refreshTokenKey = 'REFRESH_TOKEN';
  static const accessTokenExpiryKey = 'ACCESS_TOKEN_EXPIRY';
  static const roleKey = 'USER_ROLE';
  static const driverStatusKey = 'DRIVER_APPLICATION_STATUS';
  static const canAccessDriverHomeKey = 'CAN_ACCESS_DRIVER_HOME';
  static const rejectionReasonKey = 'DRIVER_REJECTION_REASON';

  static const _sessionKeys = <String>[
    accessTokenKey,
    refreshTokenKey,
    accessTokenExpiryKey,
    roleKey,
    driverStatusKey,
    canAccessDriverHomeKey,
    rejectionReasonKey,
  ];

  @override
  Future<String?> getAccessToken() {
    return _secureStorage.read(key: accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: refreshTokenKey);
  }

  @override
  Future<DateTime?> getAccessTokenExpiry() async {
    final raw = await _secureStorage.read(key: accessTokenExpiryKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<AuthProfile?> readProfile() async {
    final role = await _secureStorage.read(key: roleKey);
    if (role == null || role.isEmpty) return null;
    return _profileFrom(role);
  }

  Future<AuthProfile> _profileFrom(String role) async {
    final status = await _secureStorage.read(key: driverStatusKey);
    final access = await _secureStorage.read(key: canAccessDriverHomeKey);
    final reason = await _secureStorage.read(key: rejectionReasonKey);
    return AuthProfile(
      role: role,
      canAccessDriverHome: access == 'true',
      driverApplicationStatus: _emptyToNull(status),
      driverApplicationRejectionReason: _emptyToNull(reason),
    );
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
  }) async {
    await Future.wait([
      _secureStorage.write(key: accessTokenKey, value: accessToken),
      _secureStorage.write(key: refreshTokenKey, value: refreshToken),
      _writeExpiry(expiresIn),
    ]);
  }

  @override
  Future<void> saveAccessToken(String accessToken, {int? expiresIn}) async {
    await Future.wait([
      _secureStorage.write(key: accessTokenKey, value: accessToken),
      _writeExpiry(expiresIn),
    ]);
  }

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    int? expiresIn,
    required AuthProfile profile,
  }) async {
    await saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
    await _writeProfile(profile);
  }

  Future<void> _writeProfile(AuthProfile profile) {
    final values = <String, String>{
      roleKey: profile.role,
      driverStatusKey: profile.driverApplicationStatus ?? '',
      canAccessDriverHomeKey: '${profile.canAccessDriverHome}',
      rejectionReasonKey: profile.driverApplicationRejectionReason ?? '',
    };
    return Future.wait(
      values.entries.map(
        (entry) => _secureStorage.write(key: entry.key, value: entry.value),
      ),
    );
  }

  Future<void> _writeExpiry(int? expiresIn) async {
    if (expiresIn == null || expiresIn <= 0) return;
    final expiry = DateTime.now().toUtc().add(Duration(seconds: expiresIn));
    await _secureStorage.write(
      key: accessTokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  @override
  Future<void> clearTokens() {
    return Future.wait(
      _sessionKeys.map((key) => _secureStorage.delete(key: key)),
    );
  }
}

String? _emptyToNull(String? value) {
  if (value == null || value.isEmpty) return null;
  return value;
}
