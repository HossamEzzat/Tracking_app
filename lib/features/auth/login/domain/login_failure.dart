import 'package:tracking_app/core/errors/app_error.dart';

enum LoginFailureKind { credentials, network, rateLimit, server }

LoginFailureKind classifyLoginFailure(AppError error) {
  if (error is UnauthorizedError || error is ForceLogin) {
    return LoginFailureKind.credentials;
  }
  if (_isNetwork(error)) return LoginFailureKind.network;
  if (error is BadResponseError && error.statusCode == 429) {
    return LoginFailureKind.rateLimit;
  }
  return LoginFailureKind.server;
}

bool _isNetwork(AppError error) {
  if (error is NoInternetError ||
      error is TimeOutError ||
      error is BadCertificateError) {
    return true;
  }
  return error is BadResponseError &&
      error.message.startsWith('Cannot reach the server');
}
