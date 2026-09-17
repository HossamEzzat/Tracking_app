// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../modules/dio_module.dart' as _i948;
import '../network/auth_interceptors.dart' as _i466;
import '../network/safe_call.dart' as _i185;
import '../network/token_refresh.dart' as _i36;
import '../network/token_storage.dart' as _i964;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.factory<_i185.SafeCall>(() => _i185.SafeCall());
    gh.lazySingleton<_i466.AuthSessionNotifier>(
      () => _i466.AuthSessionNotifier(),
    );
    gh.lazySingleton<_i36.TokenRefresher>(() => _i36.ApiTokenRefresher());
    gh.lazySingleton<_i964.TokenStorage>(
      () => _i964.SecureTokenStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i466.AuthInterceptors>(
      () => _i466.AuthInterceptors(
        gh<_i964.TokenStorage>(),
        gh<_i36.TokenRefresher>(),
        gh<_i466.AuthSessionNotifier>(),
      ),
    );
    gh.singleton<_i361.Dio>(
      () => dioModule.provideDio(gh<_i466.AuthInterceptors>()),
    );
    return this;
  }
}

class _$DioModule extends _i948.DioModule {}
