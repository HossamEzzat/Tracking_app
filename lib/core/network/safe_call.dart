import 'package:injectable/injectable.dart';
import 'package:tracking_app/core/base/base_response.dart';
import 'package:tracking_app/core/errors/error_parser.dart';

@injectable
class SafeCall {
  Future<BaseResponse<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return SuccessResponse(await apiCall());
    } catch (e) {
      final error = e is Exception ? e : Exception(e.toString());
      return ErrorResponse(appError: errorParser(error));
    }
  }
}
