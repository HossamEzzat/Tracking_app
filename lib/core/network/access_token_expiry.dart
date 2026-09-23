const accessTokenRefreshMargin = Duration(seconds: 30);

bool accessTokenNeedsRefresh(DateTime? expiry, DateTime now) {
  if (expiry == null) return false;
  final fireAt = expiry.subtract(accessTokenRefreshMargin);
  return !fireAt.isAfter(now.toUtc());
}
