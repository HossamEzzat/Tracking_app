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

import '../../features/auth/core/data/repos/auth_repository_impl.dart' as _i436;
import '../../features/auth/core/data/session_restorer.dart' as _i690;
import '../../features/auth/core/domain/repos/auth_repository.dart' as _i179;
import '../../features/auth/core/presentation/view_model/auth_cubit.dart'
    as _i571;
import '../../features/auth/login/data/api/auth_api_client.dart' as _i144;
import '../../features/auth/login/data/data_source/remote/auth_remote_data_source.dart'
    as _i441;
import '../../features/auth/login/data/data_source/remote/auth_remote_data_source_impl.dart'
    as _i4;
import '../../features/auth/login/data/repo/auth_repo_impl.dart' as _i641;
import '../../features/auth/login/domain/repo/auth_repo.dart' as _i483;
import '../../features/auth/login/domain/use_case/login_usecase.dart' as _i635;
import '../../features/auth/login/presentation/view_model/login_view_model.dart'
    as _i188;
import '../modules/dio_module.dart' as _i948;
import '../modules/storage_module.dart' as _i348;
import '../network/auth_interceptors.dart' as _i466;
import '../network/safe_call.dart' as _i185;
import '../network/secure_key_value.dart' as _i904;
import '../network/token_refresh_coordinator.dart' as _i381;
import '../network/token_refresh_scheduler.dart' as _i95;
import '../network/token_refresher.dart' as _i1058;
import '../network/token_storage.dart' as _i964;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final dioModule = _$DioModule();
    gh.factory<_i185.SafeCall>(() => _i185.SafeCall());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i1058.TokenRefresher>(() => _i1058.ApiTokenRefresher());
    gh.lazySingleton<_i904.SecureKeyValue>(
      () => _i904.FlutterSecureKeyValue(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i964.TokenStorage>(
      () => _i964.SecureTokenStorage(gh<_i904.SecureKeyValue>()),
    );
    gh.lazySingleton<_i381.TokenRefreshCoordinator>(
      () => _i381.TokenRefreshCoordinator(
        gh<_i964.TokenStorage>(),
        gh<_i1058.TokenRefresher>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i466.AuthInterceptors>(
      () => _i466.AuthInterceptors(
        gh<_i964.TokenStorage>(),
        gh<_i381.TokenRefreshCoordinator>(),
      ),
    );
    gh.lazySingleton<_i95.TokenRefreshScheduler>(
      () => _i95.TokenRefreshScheduler(
        gh<_i964.TokenStorage>(),
        gh<_i381.TokenRefreshCoordinator>(),
      ),
      dispose: (i) => i.stop(),
    );
    gh.lazySingleton<_i179.AuthRepository>(
      () => _i436.AuthRepositoryImpl(
        gh<_i964.TokenStorage>(),
        gh<_i95.TokenRefreshScheduler>(),
        gh<_i381.TokenRefreshCoordinator>(),
      ),
    );
    gh.lazySingleton<_i571.AuthCubit>(
      () => _i571.AuthCubit(gh<_i179.AuthRepository>()),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i690.SessionRestorer>(
      () => _i690.SessionRestorer(
        gh<_i179.AuthRepository>(),
        gh<_i964.TokenStorage>(),
        gh<_i381.TokenRefreshCoordinator>(),
      ),
    );
    gh.singleton<_i361.Dio>(() => dioModule.dio(gh<_i466.AuthInterceptors>()));
    gh.singleton<_i144.AuthApiClient>(
      () => _i144.AuthApiClient(gh<_i361.Dio>()),
    );
    gh.factory<_i441.AuthRemoteDataSource>(
      () => _i4.AuthRemoteDatasourceImpl(gh<_i144.AuthApiClient>()),
    );
    gh.factory<_i483.AuthRepo>(
      () => _i641.AuthRepositoryImpl(
        gh<_i441.AuthRemoteDataSource>(),
        gh<_i185.SafeCall>(),
        gh<_i964.TokenStorage>(),
      ),
    );
    gh.factory<_i635.LoginUseCase>(
      () => _i635.LoginUseCase(gh<_i483.AuthRepo>()),
    );
    gh.factory<_i188.LoginViewModel>(
      () => _i188.LoginViewModel(gh<_i635.LoginUseCase>()),
    );
    return this;
  }
}

class _$StorageModule extends _i348.StorageModule {}

class _$DioModule extends _i948.DioModule {}
