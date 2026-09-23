abstract class AppError {
  final Exception? exception;
  final String message;

  AppError(this.exception, this.message);
}

class TimeOutError extends AppError {
  TimeOutError(Exception exception)
    : super(exception, 'Connection timeout, please try again.');
}

class NoInternetError extends AppError {
  NoInternetError(Exception exception)
    : super(exception, 'No internet connection, please try again.');
}

class BadCertificateError extends AppError {
  BadCertificateError(super.exception, super.message);
}

class UnauthorizedError extends AppError {
  UnauthorizedError([String message = 'Invalid email or password.'])
    : super(null, message);
}

class IgnoreError extends AppError {
  IgnoreError() : super(null, 'Something went wrong.');
}

class ForceLogin extends AppError {
  ForceLogin() : super(null, 'Your session has expired. Please login again.');
}

class BadResponseError extends AppError {
  final String? code;
  final Map<String, dynamic>? data;
  final int? statusCode;

  BadResponseError(String message, {this.code, this.data, this.statusCode})
    : super(null, message);
}
