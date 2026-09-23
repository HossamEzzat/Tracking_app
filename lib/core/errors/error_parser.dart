import 'package:dio/dio.dart';
import 'package:tracking_app/core/errors/api_exception.dart';
import 'package:tracking_app/core/errors/app_error.dart';

AppError errorParser(Exception exception) {
  if (exception is ApiException) return _parseApiException(exception);
  if (exception is! DioException) return IgnoreError();
  if (exception.error is ForceLogin) return ForceLogin();
  return _parseDioException(exception);
}

AppError _parseApiException(ApiException exception) {
  final fieldErrors = fieldErrorsMessage(exception.errors);
  if (fieldErrors != null) return BadResponseError(fieldErrors);
  return BadResponseError(exception.message, statusCode: exception.statusCode);
}

AppError _parseDioException(DioException exception) {
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => TimeOutError(exception),
    DioExceptionType.badCertificate => BadCertificateError(
      exception,
      'Invalid certificate, please try again later.',
    ),
    DioExceptionType.badResponse => _parseBadResponse(exception),
    DioExceptionType.connectionError => _connectionError(exception),
    DioExceptionType.cancel ||
    DioExceptionType.unknown ||
    DioExceptionType.transformTimeout => IgnoreError(),
  };
}

AppError _connectionError(DioException exception) {
  final detail = '${exception.message} ${exception.error}';
  if (detail.contains('Connection refused') ||
      detail.contains('Failed host lookup') ||
      detail.contains('Network is unreachable') ||
      detail.contains('Connection reset')) {
    return BadResponseError(
      'Cannot reach the server. Start the backend with ./setup.sh and retry.',
    );
  }
  return NoInternetError(exception);
}

AppError _parseBadResponse(DioException exception) {
  final status = exception.response?.statusCode;
  final data = exception.response?.data;
  if (status == 401) return _unauthorized(data);
  if (status == 429) return _rateLimited(data);
  return _bodyError(exception, data, status);
}

AppError _unauthorized(dynamic data) {
  final fields = fieldErrorsMessage(_errorsMap(data));
  if (fields != null) return UnauthorizedError(fields);
  return UnauthorizedError(messageOf(data) ?? 'Invalid email or password.');
}

AppError _rateLimited(dynamic data) {
  return BadResponseError(
    messageOf(data) ?? statusCodeToMessage(429),
    statusCode: 429,
    data: _mapOrNull(data),
  );
}

AppError _bodyError(DioException exception, dynamic data, int? status) {
  if (data is Map<String, dynamic>) return _mappedBody(data, status);
  return BadResponseError(statusCodeToMessage(status), statusCode: status);
}

AppError _mappedBody(Map<String, dynamic> data, int? status) {
  final payload = _mapOrNull(data['data']);
  final code = _errorCode(payload) ?? _errorCode(data);
  final fields =
      fieldErrorsMessage(data['errors']) ??
      fieldErrorsMessage(_validationFieldErrors(payload));
  final message = fields ?? messageOf(data) ?? statusCodeToMessage(status);
  return BadResponseError(
    message,
    code: code,
    data: payload,
    statusCode: status,
  );
}

Map<String, dynamic>? _errorsMap(dynamic data) {
  if (data is! Map) return null;
  final errors = data['errors'];
  if (errors is Map<String, dynamic>) return errors;
  if (errors is! Map) return null;
  return Map<String, dynamic>.from(errors);
}

String? messageOf(dynamic data) {
  if (data is! Map) return null;
  final message = data['message'] ?? data['error'];
  if (message == null) return null;
  final text = message.toString().trim();
  if (text.isEmpty) return null;
  return text;
}

Map<String, dynamic>? _mapOrNull(dynamic raw) {
  if (raw is! Map) return null;
  return Map<String, dynamic>.from(raw);
}

String? _errorCode(Map<String, dynamic>? raw) {
  final code = raw?['code'];
  if (code is! String || code.isEmpty) return null;
  return code;
}

Map<String, dynamic>? _validationFieldErrors(dynamic raw) {
  if (raw is! Map) return null;
  if (raw.containsKey('userId') ||
      raw.containsKey('accessToken') ||
      raw.containsKey('refreshToken') ||
      raw.containsKey('code')) {
    return null;
  }
  final map = Map<String, dynamic>.from(raw);
  if (map.isEmpty) return null;
  final looksLikeFields = map.values.every(
    (value) => value is List || value is String,
  );
  return looksLikeFields ? map : null;
}

String? fieldErrorsMessage(Map<String, dynamic>? errors) {
  if (errors == null) return null;
  final messages = <String>[];
  for (final value in errors.values) {
    if (value is List) {
      messages.addAll(value.map((item) => item.toString()));
    } else if (value != null) {
      messages.add(value.toString());
    }
  }
  if (messages.isEmpty) return null;
  return messages.join('\n');
}

const Map<int, String> statusMessages = {
  400: 'Something went wrong, please try again.',
  401: 'Unauthorized, please login again.',
  403: 'You are not allowed to perform this action.',
  404: 'Resource not found.',
  409: 'Conflict occurred.',
  422: 'Validation failed.',
  429: 'Too many requests, please try again later.',
  500: 'Internal server error, please try again later.',
  502: 'Bad gateway.',
  503: 'Service unavailable.',
  504: 'Gateway timeout.',
};

String statusCodeToMessage(int? statusCode) {
  return statusMessages[statusCode] ??
      'Something went wrong, please try again.';
}
