import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_app/core/network/secure_key_value.dart';
import 'package:tracking_app/core/network/token_storage.dart';

void main() {
  late MemorySecureKeyValue memory;
  late SecureTokenStorage storage;

  setUp(() {
    memory = MemorySecureKeyValue();
    storage = SecureTokenStorage(memory);
  });

  test('session is written only to secure storage keys', () async {
    await storage.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresIn: 900,
      profile: const AuthProfile(
        role: 'Driver',
        canAccessDriverHome: true,
        driverApplicationStatus: 'Approved',
      ),
    );

    expect(memory.values[SecureTokenStorage.accessTokenKey], 'access-token');
    expect(memory.values[SecureTokenStorage.refreshTokenKey], 'refresh-token');
    expect(memory.values[SecureTokenStorage.roleKey], 'Driver');
    expect(memory.values[SecureTokenStorage.driverStatusKey], 'Approved');
    expect(memory.values[SecureTokenStorage.canAccessDriverHomeKey], 'true');
    expect(await storage.readProfile(), isNotNull);
  });

  test('refresh keeps the stored role and status', () async {
    await storage.saveSession(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      expiresIn: 900,
      profile: const AuthProfile(
        role: 'Driver',
        canAccessDriverHome: false,
        driverApplicationStatus: 'PendingReview',
      ),
    );

    await storage.saveTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      expiresIn: 900,
    );

    expect(await storage.getAccessToken(), 'new-access');
    final profile = await storage.readProfile();
    expect(profile?.role, 'Driver');
    expect(profile?.driverApplicationStatus, 'PendingReview');
    expect(profile?.canAccessDriverHome, isFalse);
  });

  test('clear removes every session key', () async {
    await storage.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresIn: 900,
      profile: const AuthProfile(role: 'Customer', canAccessDriverHome: false),
    );

    await storage.clearTokens();

    expect(memory.values, isEmpty);
  });
}
