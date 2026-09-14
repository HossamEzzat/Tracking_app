import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/core/error/error_parser.dart';
@injectable
class SafeCall {
  Future<BaseResponse<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      final response = await apiCall();
      return SuccessResponse(response);
    } catch (e) {
      final appError = errorParser(
        e is Exception ? e : Exception(e.toString()),
      );
      return ErrorResponse(appError: appError);
    }
  }
}
//try catch//
//return safeApiCall(() => api.login());