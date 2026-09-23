import 'package:tracking_app/core/errors/app_error.dart';

sealed class BaseResponse<T> {
  const BaseResponse();
}

class SuccessResponse<T> extends BaseResponse<T> {
  final T data;

  const SuccessResponse(this.data);
}

class ErrorResponse<T> extends BaseResponse<T> {
  final AppError appError;

  const ErrorResponse({required this.appError});

  String get errorMessage => appError.message;
}
