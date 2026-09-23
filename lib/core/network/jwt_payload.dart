import 'dart:convert';

Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded);
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);
    return null;
  } catch (_) {
    return null;
  }
}

const microsoftRoleClaim =
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

String? claimString(Map<String, dynamic>? claims, String key) {
  final value = claims?[key];
  if (value is String && value.trim().isNotEmpty) return value;
  if (value is! List || value.isEmpty || value.first is! String) return null;
  final first = value.first as String;
  if (first.trim().isEmpty) return null;
  return first;
}

bool? claimBool(Map<String, dynamic>? claims, String key) {
  final value = claims?[key];
  if (value is bool) return value;
  return null;
}

String? roleFromClaims(Map<String, dynamic>? claims) {
  return claimString(claims, 'role') ??
      claimString(claims, 'Role') ??
      claimString(claims, microsoftRoleClaim);
}
