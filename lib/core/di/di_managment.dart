// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/language/language_rep.dart';
import 'package:list_in/core/local_data/shared_preferences.dart';
import 'package:list_in/core/router/go_router.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/core/theme/provider/theme_provider.dart';
import 'package:list_in/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';
import 'package:list_in/features/auth/domain/usecases/get_stored_email_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/login_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/register_user_data.dart';
import 'package:list_in/features/auth/domain/usecases/signup_usecase.dart';
import 'package:list_in/features/auth/domain/usecases/verify_email_signup.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/chats/data/repository/chat_repository_impl.dart';
import 'package:list_in/features/chats/data/source/chat_remote_datasource.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';
import 'package:list_in/features/chats/domain/usecase/connect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/disconnect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_history_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_message_status_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_messages_stream_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_user_status_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/message_delivered_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_viewed_usecase.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_bloc.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/explore/data/repository/get_publications_rep_impl.dart';
import 'package:list_in/features/explore/data/source/get_publications_remoute.dart';
import 'package:list_in/features/explore/domain/repository/get_publications_repository.dart';
import 'package:list_in/features/explore/domain/usecase/get_filtered_publications_values_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_prediction_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_publications_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_video_publications_usecase.dart';
import 'package:list_in/features/followers/data/repository/user_social_rep_impl.dart';
import 'package:list_in/features/followers/data/source/user_social_remoute.dart';
import 'package:list_in/features/followers/domain/repository/user_social_repository.dart';
import 'package:list_in/features/followers/domain/usecase/get_user_followers_usecase.dart';
import 'package:list_in/features/followers/domain/usecase/get_user_followings_usecase.dart';
import 'package:list_in/features/followers/presentation/bloc/social_user_bloc.dart';
import 'package:list_in/features/map/data/repositories/location_repository_impl.dart';
import 'package:list_in/features/map/data/sources/location_remote_datasource.dart';
import 'package:list_in/features/map/domain/repositories/location_repository.dart';
import 'package:list_in/features/map/domain/usecases/get_location_usecase.dart';
import 'package:list_in/features/map/domain/usecases/search_locations_usecase.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/child_category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/nomeric_field_model.dart';
import 'package:list_in/features/post/data/models/category_tree/sub_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:list_in/features/post/data/repository/post_repository_impl.dart';
import 'package:list_in/features/post/data/sources/post_local_data_source.dart';
import 'package:list_in/features/post/data/sources/post_remote_data_source.dart';
import 'package:list_in/features/post/domain/repository/post_repository.dart';
import 'package:list_in/features/post/domain/usecases/create_post_usecase.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/domain/usecases/get_locations_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_images_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_video_usecase.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/profile/data/repository/user_profile_rep_impl.dart';
import 'package:list_in/features/profile/data/repository/user_publications_rep_impl.dart';
import 'package:list_in/features/profile/data/sources/user_profile_location_local.dart';
import 'package:list_in/features/profile/data/sources/user_profile_remoute.dart';
import 'package:list_in/features/profile/data/sources/user_publications_remote.dart';
import 'package:list_in/features/profile/domain/repository/user_profile_repository.dart';
import 'package:list_in/features/profile/domain/repository/user_publications_repository.dart';
import 'package:list_in/features/profile/domain/usecases/publication/delete_user_publication_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/publication/get_user_liked_publications_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/publication/get_user_publications_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/publication/update_publication_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/locations/cache_user_location_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/update_user_image_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/update_user_profile_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/video/service/video_compresion_service.dart';
import 'package:list_in/features/visitior_profile/data/repository/another_user_profile_rep_impl.dart';
import 'package:list_in/features/visitior_profile/data/source/another_user_profile_remoute.dart';
import 'package:list_in/features/visitior_profile/domain/repository/another_user_profile_repository.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_profile_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_publications_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/like_publication_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/view_publication_usecase.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_bloc.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<SharedPrefsService>(
    () => SharedPrefsService(sharedPreferences),
  );
  _registerServices();

  // HTTP Clients
  _registerHttpClients();

  // App Router
  _registerAppRouter();

  //======================================================================
  // HIVE INITIALIZATION
  //======================================================================
  await _initializeHive();

  //======================================================================
  // FEATURE REGISTRATIONS
  //======================================================================

  // Auth Feature
  _registerAuthFeature();

  // User Profile Feature
  _registerUserProfileFeature();

  // Publications Feature
  _registerPublicationsFeature();

  // Post Feature
  _registerPostFeature();

  // Social Feature
  _registerSocialFeature();

  // Map Feature
  _registerMapFeature();

  // Global BLoCs
  _registerGlobalBlocs();
  _registerChatFeature();
}

//======================================================================
// HIVE INITIALIZATION
//======================================================================
Future<void> _initializeHive() async {
  try {
    if (kIsWeb) {
      // For web platform
      await Hive.initFlutter();
    } else {
      try {
        final appDocumentDirectory =
            await path_provider.getApplicationDocumentsDirectory();
        Hive.init(appDocumentDirectory.path);
      } catch (e) {
        // Fallback for platforms where getApplicationDocumentsDirectory might fail
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          Hive.init('./hive_data'); // Simple path for desktop
        } else {
          // Re-throw for other platforms where this shouldn't happen
          rethrow;
        }
      }
    }

    // Register adapters
    _registerHiveAdapters();

    // Open boxes with error handling
    await _openHiveBoxesSafely();
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize Hive: $e\n$stackTrace');
  }
}

void _registerChatFeature() {
  // Get the current user ID from SharedPrefs or another source
  final currentUserId = sl<GlobalBloc>().userId;

  registerChatFeature(sl, currentUserId ?? '');
}

void registerChatFeature(GetIt sl, String currentUserId) {
  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(
      dio: sl(),
      authLocalDataSource: sl(),
      authService: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
      currentUserId: currentUserId,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetChatRoomsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => ConnectUserUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectUserUseCase(sl()));
  sl.registerLazySingleton(() => GetMessageStreamUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatusStreamUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageViewedStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetMessageStatusStreamUseCase(sl()));
  sl.registerLazySingleton(() => GetMessageDeliveredStreamUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => ChatProvider(
      getChatRoomsUseCase: sl(),
      getChatHistoryUseCase: sl(),
      sendMessageUseCase: sl(),
      connectUserUseCase: sl(),
      disconnectUserUseCase: sl(),
      getMessageStreamUseCase: sl(),
      getUserStatusStreamUseCase: sl(),
      sendMessageViewedStatusUseCase: sl(),
      getMessageStatusStreamUseCase: sl(),
      getMessageDeliveredStreamUseCase: sl(),
    ),
  );
}

void _registerHiveAdapters() {
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(ChildCategoryModelAdapter());
  Hive.registerAdapter(AttributeModelAdapter());
  Hive.registerAdapter(AttributeValueModelAdapter());
  Hive.registerAdapter(SubModelAdapter());
  Hive.registerAdapter(NomericFieldModelAdapter());
  Hive.registerAdapter(CountryAdapter());
  Hive.registerAdapter(StateAdapter());
  Hive.registerAdapter(CountyAdapter());
}

Future<void> _openHiveBoxesSafely() async {
  Box? metaBox;
  Box<CategoryModel>? catalogBox;
  Box<Country>? locationBox;

  try {
    // Try to open meta box first - it's critical
    metaBox = await Hive.openBox('meta');

    // Try to open catalog box
    try {
      catalogBox = await Hive.openBox<CategoryModel>('catalogs');
    } catch (e) {
      debugPrint('Failed to open catalog box: $e');
      // Delete and recreate catalog box if corrupted
      await Hive.deleteBoxFromDisk('catalogs');
      catalogBox = await Hive.openBox<CategoryModel>('catalogs');
    }

    // Try to open location box
    try {
      locationBox = await Hive.openBox<Country>('locations');
    } catch (e) {
      debugPrint('Failed to open location box: $e');
      // Delete and recreate location box if corrupted
      await Hive.deleteBoxFromDisk('locations');
      locationBox = await Hive.openBox<Country>('locations');
    }

    // Initialize catalog local data source
    final catalogLocalDataSource = CatalogLocalDataSourceImpl(
        categoryBox: catalogBox, locationBox: locationBox, metaBox: metaBox);
    await catalogLocalDataSource.initialize();
    sl.registerLazySingleton<CatalogLocalDataSource>(
        () => catalogLocalDataSource);
  } catch (e, stackTrace) {
    debugPrint('Critical error in Hive initialization: $e\n$stackTrace');
  }
}

//======================================================================
// HTTP CLIENTS
//======================================================================
void _registerHttpClients() {
  // Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options
      ..baseUrl = 'http://listin.uz'
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(minutes: 3)
      ..sendTimeout = const Duration(minutes: 3);

    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) {
        client
          ..idleTimeout = const Duration(seconds: 15)
          ..connectionTimeout = const Duration(seconds: 15)
          ..maxConnectionsPerHost = 7
          ..autoUncompress = true;

        return client;
      };
    }
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    return dio;
  });

  // HTTP Client
  sl.registerLazySingleton<http.Client>(() {
    return RetryClient(
      http.Client(),
      retries: 3,
      when: (response) => response.statusCode >= 500,
      onRetry: (req, res, retryCount) {
        return Future.delayed(Duration(seconds: retryCount));
      },
    );
  });
}

void _registerServices() {
  sl.registerLazySingleton<VideoCompressionService>(
    () => VideoCompressionService(),
  );
}

//======================================================================
// APP ROUTER
//======================================================================
void _registerAppRouter() {
  sl.registerLazySingleton(
    () => AppRouter(
      sharedPreferences: sl<SharedPreferences>(),
      getGategoriesUsecase: sl<GetGategoriesUsecase>(),
      getLocationsUsecase: sl<GetLocationsUsecase>(),
      getPublicationsUsecase: sl<GetPublicationsUsecase>(),
      getPredictionsUseCase: sl<GetPredictionsUseCase>(),
      getVideoPublicationsUsecase: sl<GetVideoPublicationsUsecase>(),
      getFilteredPublicationsValuesUsecase:
          sl<GetFilteredPublicationsValuesUsecase>(),
      globalBloc: sl<GlobalBloc>(),
    ),
  );
}

//======================================================================
// GLOBAL BLOCS
//======================================================================
void _registerGlobalBlocs() {
  // Auth Service
  sl.registerLazySingleton(() => AuthService(authLocalDataSource: sl()));

  // Language
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepository(prefsService: sl()),
  );

  sl.registerFactory<LanguageBloc>(
    () => LanguageBloc(repository: sl()),
  );

  // Theme
  sl.registerFactory<ThemeBloc>(
    () => ThemeBloc(sl<SharedPrefsService>()),
  );

  // Global Bloc
  sl.registerLazySingleton(() => GlobalBloc(
        followUserUseCase: sl(),
        likePublicationUsecase: sl(),
        viewPublicationUsecase: sl(),
        authLocalDataSource: sl(),
      ));

  // Liked Publications Bloc
  sl.registerFactory(() => LikedPublicationsBloc(
        getLikedPublicationsUseCase: sl(),
        globalBloc: sl(),
      ));
}

//======================================================================
// AUTH FEATURE
//======================================================================
void _registerAuthFeature() {
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signupUseCase: sl(),
      verifyEmailSignupUseCase: sl(),
      registerUserDataUseCase: sl(),
      getStoredEmailUsecase: sl(),
      googleAuthUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailSignupUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserDataUseCase(sl()));
  sl.registerLazySingleton(() => GetStoredEmailUsecase(sl()));
  sl.registerLazySingleton(() => GoogleAuthUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

//======================================================================
// USER PROFILE FEATURE
//======================================================================
void _registerUserProfileFeature() {
  // BLoCs
  sl.registerFactory(
    () => UserProfileBloc(
      updateUserProfileUseCase: sl(),
      uploadUserImagesUseCase: sl(),
      getUserDataUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AnotherUserProfileBloc(
      getUserDataUseCase: sl(),
      getPublications: sl(),
      globalBloc: sl(),
    ),
  );

  sl.registerFactory(
    () => DetailsBloc(
      getUserDataUseCase: sl(),
      getPublications: sl(),
      followUserUseCase: sl(),
      globalBloc: sl(),
    ),
  );

  sl.registerFactory(() => PublicationUpdateBloc(
        updatePostUseCase: sl(),
        uploadImagesUseCase: sl(),
        uploadVideoUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetUserDataUseCase(sl(), sl()));
  sl.registerLazySingleton(() =>
      UpdateUserProfileUseCase(repository: sl(), authLocalDataSource: sl()));
  sl.registerLazySingleton(() => UploadUserImagesUseCase(sl()));
  sl.registerLazySingleton(() => GetAnotherUserDataUseCase(sl()));
  sl.registerLazySingleton(() => GetUserLocationUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePostUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: sl(),
      localUserData: sl(),
    ),
  );

  sl.registerLazySingleton<AnotherUserProfileRepository>(
    () => AnotherUserProfileRepImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserProfileLocationLocalImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<UserProfileRemoute>(
    () => UserProfileRemouteImpl(dio: sl(), authService: sl()),
  );

  sl.registerLazySingleton<AnotherUserProfileRemoute>(
    () => AnotherUserProfileRemouteImpl(dio: sl(), authService: sl()),
  );
}

//======================================================================
// PUBLICATIONS FEATURE
//======================================================================
void _registerPublicationsFeature() {
  // BLoCs
  sl.registerFactory(() => UserPublicationsBloc(
        getUserPublicationsUseCase: sl(),
        deletePublicationUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetPublicationsUsecase(sl()));
  sl.registerLazySingleton(() => GetFilteredPublicationsValuesUsecase(sl()));
  sl.registerLazySingleton(() => GetPublicationsByIdUsecase(sl()));
  sl.registerLazySingleton(() => GetPredictionsUseCase(sl()));
  sl.registerLazySingleton(() => GetVideoPublicationsUsecase(sl()));
  sl.registerLazySingleton(() => GetUserPublicationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserLikedPublicationsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserPublicationUsecase(sl()));
  sl.registerLazySingleton(() => LikePublicationUsecase(sl()));
  sl.registerLazySingleton(() => ViewPublicationUsecase(sl()));

  // Repositories
  sl.registerLazySingleton<PublicationsRepository>(
    () => PublicationsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<UserPublicationsRepository>(
    () => UserPublicationsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<PublicationsRemoteDataSource>(
    () => PublicationsRemoteDataSourceImpl(dio: sl(), authService: sl()),
  );

  sl.registerLazySingleton<UserPublicationsRemoteDataSource>(
    () => UserPublicationsRemoteDataSourceImpl(dio: sl(), authService: sl()),
  );
}

//======================================================================
// POST FEATURE
//======================================================================
void _registerPostFeature() {
  // Providers
  sl.registerFactory(() => PostProvider(
        getCatalogsUseCase: sl<GetGategoriesUsecase>(),
        uploadImagesUseCase: sl<UploadImagesUseCase>(),
        uploadVideoUseCase: sl<UploadVideoUseCase>(),
        createPostUseCase: sl<CreatePostUseCase>(),
        getUserLocationUsecase: sl<GetUserLocationUseCase>(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetGategoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetLocationsUsecase(sl()));
  sl.registerLazySingleton(() => UploadImagesUseCase(sl()));
  sl.registerLazySingleton(() => UploadVideoUseCase(
        sl(),
        sl(),
        compressionQuality: VideoQuality.low,
      ));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(
      dio: sl(),
      authService: sl(),
    ),
  );
}

//======================================================================
// SOCIAL FEATURE
//======================================================================
void _registerSocialFeature() {
  // BLoCs
  sl.registerFactory<SocialUserBloc>(
    () => SocialUserBloc(
      getUserFollowersUseCase: sl(),
      getUserFollowingsUseCase: sl(),
      globalBloc: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton<GetUserFollowersUseCase>(
    () => GetUserFollowersUseCase(sl()),
  );

  sl.registerLazySingleton<GetUserFollowingsUseCase>(
    () => GetUserFollowingsUseCase(sl()),
  );

  sl.registerLazySingleton(() => FollowUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<UserSocialRepository>(
    () => UserSocialRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<UserSocialRemoteDataSource>(
    () => UserSocialRemoteDataSourceImpl(
      dio: sl(),
      authService: sl(),
    ),
  );
}

//======================================================================
// MAP FEATURE
//======================================================================
void _registerMapFeature() {
  // BLoCs
  sl.registerFactory(
    () => MapBloc(
      getLocationUseCase: sl(),
      searchLocationsUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetLocationUseCase(sl()));
  sl.registerLazySingleton(() => SearchLocationsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<LocationRemoteDatasource>(
    () => LocationRemoteDataSourceImpl(dio: sl()),
  );
}
