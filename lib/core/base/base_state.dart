import 'package:equatable/equatable.dart';

class BaseState <T> extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final T? data;
  const BaseState({this.isLoading = false, this.errorMessage = '', this.data});

  BaseState<T> copyWith({bool? isLoading, String? errorMessage,  Object? data = _noData,}) {
    return BaseState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: identical(data, _noData) ? this.data : data as T?,
    );
  }
  @override
  List<Object?> get props =>[isLoading,errorMessage,data];
}
const _noData = Object();