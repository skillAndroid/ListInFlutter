import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/core/network/network_info_impl.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';
import 'package:list_in/features/auth/domain/usecases/get_stored_email_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/login_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/register_user_data.dart';
import 'package:list_in/features/auth/domain/usecases/signup_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/verify_email_signup.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/map/data/repositories/location_repository_impl.dart';
import 'package:list_in/features/map/data/sources/location_remote_datasource.dart';
import 'package:list_in/features/map/domain/repositories/location_repository.dart';
import 'package:list_in/features/map/domain/usecases/get_location_usecase.dart';
import 'package:list_in/features/map/domain/usecases/search_locations_usecase.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/post/data/repository/catalog_repository_impl.dart';
import 'package:list_in/features/post/data/sources/catalog_remote_data_source.dart';
import 'package:list_in/features/post/domain/repository/catalog_repository.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Get SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signupUseCase: sl(),
      verifyEmailSignupUseCase: sl(),
      registerUserDataUseCase: sl(),
      getStoredEmailUsecase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailSignupUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserDataUseCase(sl()));
  sl.registerLazySingleton(() => GetStoredEmailUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      authLocalDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()));

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(
    () {
      final dio = Dio();
      dio.options.baseUrl = 'https://7cab-62-209-146-62.ngrok-free.app';
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 3);
      return dio;
    },
  );

  sl.registerLazySingleton(() => AuthService(authLocalDataSource: sl()));

  sl.registerFactory(
    () => MapBloc(
      getLocationUseCase: sl(),
      searchLocationsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetLocationUseCase(sl()));
  sl.registerLazySingleton(() => SearchLocationsUseCase(sl()));
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCatalogs(sl()));

  sl.registerLazySingleton<LocationRemoteDatasource>(
      () => LocationRemoteDataSourceImpl(dio: sl()));

  sl.registerFactory(() => PostProvider(
        getCatalogsUseCase: sl<GetCatalogs>(),
      ));

  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(
      dio: sl(),
      authService: sl(),
    ),
  );
}
