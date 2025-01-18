import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:list_in/core/network/network_info.dart';
import 'package:list_in/core/network/network_info_impl.dart';
import 'package:list_in/core/router/go_router.dart';
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
import 'package:list_in/features/explore/data/repository/get_publications_rep_impl.dart';
import 'package:list_in/features/explore/data/source/get_publications_remoute.dart';
import 'package:list_in/features/explore/domain/get_publications_usecase.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/map/data/repositories/location_repository_impl.dart';
import 'package:list_in/features/map/data/sources/location_remote_datasource.dart';
import 'package:list_in/features/map/domain/repositories/location_repository.dart';
import 'package:list_in/features/map/domain/usecases/get_location_usecase.dart';
import 'package:list_in/features/map/domain/usecases/search_locations_usecase.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/data/models/sub_model.dart';
import 'package:list_in/features/post/data/repository/post_repository_impl.dart';
import 'package:list_in/features/post/data/sources/post_local_data_source.dart';
import 'package:list_in/features/post/data/sources/post_remote_data_source.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';
import 'package:list_in/features/post/domain/usecases/create_post_usecase.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_images_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_video_usecase.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/profile/data/repository/user_profile_rep_impl.dart';
import 'package:list_in/features/profile/data/repository/user_publications_rep_impl.dart';
import 'package:list_in/features/profile/data/sources/user_profile_remoute.dart';
import 'package:list_in/features/profile/data/sources/user_publications_remote.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';
import 'package:list_in/features/profile/domain/usecases/publication/get_user_publications_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/update_user_image_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/update_user_profile_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() => AppRouter(sl<SharedPreferences>()));

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(ChildCategoryModelAdapter());
  Hive.registerAdapter(AttributeModelAdapter());
  Hive.registerAdapter(AttributeValueModelAdapter());
  Hive.registerAdapter(SubModelAdapter());

  final catalogBox = await Hive.openBox<CategoryModel>('catalogs');

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
  sl.registerLazySingleton(() => GetUserDataUseCase(sl()));
  sl.registerLazySingleton(() =>
      UpdateUserProfileUseCase(repository: sl(), authLocalDataSource: sl()));
  sl.registerLazySingleton(() => UploadUserImagesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      authLocalDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserProfileRemoute>(
      () => UserProfileRemouteImpl(dio: sl(), authService: sl()));

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
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  sl.registerLazySingleton(
    () {
      final dio = Dio();
      dio.options.baseUrl = 'http://listin.uz';
      dio.options.connectTimeout = const Duration(seconds: 10);
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

  sl.registerFactory(() =>
      HomeTreeCubit(getCatalogsUseCase: sl(), getPublicationsUseCase: sl()));

  sl.registerLazySingleton(() => GetPublicationsUsecase(sl()));
  sl.registerLazySingleton(() => GetLocationUseCase(sl()));
  sl.registerLazySingleton(() => SearchLocationsUseCase(sl()));
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetGategoriesUsecase(sl()));
// UseCases
  sl.registerLazySingleton(() => UploadImagesUseCase(sl()));
  sl.registerLazySingleton(() => UploadVideoUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));

  sl.registerLazySingleton<LocationRemoteDatasource>(
      () => LocationRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<CatalogLocalDataSource>(
    () => CatalogLocalDataSourceImpl(categoryBox: catalogBox),
  );

  sl.registerLazySingleton<PublicationsRepository>(
    () => PublicationsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PublicationsRemoteDataSource>(
    () => PublicationsRemoteDataSourceImpl(dio: sl(), authService: sl()),
  );

  sl.registerFactory(() => PostProvider(
        getCatalogsUseCase: sl<GetGategoriesUsecase>(),
        uploadImagesUseCase: sl<UploadImagesUseCase>(),
        uploadVideoUseCase: sl<UploadVideoUseCase>(),
        createPostUseCase: sl<CreatePostUseCase>(),
      ));

  sl.registerFactory(
    () => UserProfileBloc(
      updateUserProfileUseCase: sl(),
      uploadUserImagesUseCase: sl(),
      getUserDataUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
        remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(
      dio: sl(),
      authService: sl(),
    ),
  );

  sl.registerFactory(
      () => UserPublicationsBloc(getUserPublicationsUseCase: sl()));
  sl.registerLazySingleton<UserPublicationsRepository>(
      () => UserPublicationsRepositoryImpl(
            networkInfo: sl(),
            remoteDataSource: sl(),
          ));

  sl.registerLazySingleton(() => GetUserPublicationsUseCase(sl()));

  sl.registerLazySingleton<UserPublicationsRemoteDataSource>(
      () => UserPublicationsRemoteDataSourceImpl(dio: sl(), authService: sl()));
}
