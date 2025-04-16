import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/di/di_managment.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:list_in/features/auth/presentation/pages/verification_page.dart';
import 'package:list_in/features/auth/presentation/pages/welcome_page.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/pages/chat_room.dart';
import 'package:list_in/features/chats/presentation/pages/chat_rooms_screen.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/usecase/get_filtered_publications_values_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_prediction_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_publications_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_video_publications_usecase.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter_home_result_page.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter_secondary_result_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/child_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/detailed_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/initial_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/search_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/search_result_page.dart';
import 'package:list_in/features/followers/presentation/pages/social_conection_page.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/category_tree/blabla.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/child_category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/nomeric_field_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/domain/usecases/get_locations_usecase.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/pages/new_profili_desing.dart';
import 'package:list_in/features/profile/presentation/pages/profile_editor_page.dart';
import 'package:list_in/features/profile/presentation/pages/profile_screen.dart';
import 'package:list_in/features/profile/presentation/pages/publications_editor_page.dart';
import 'package:list_in/features/undefined_screens_yet/wrapper_screen.dart';
import 'package:list_in/features/video/presentation/pages/video_feed_screen.dart';
import 'package:list_in/features/visitior_profile/presentation/pages/new_visitor_profile.dart';
import 'package:list_in/features/visitior_profile/presentation/pages/visiter_profile.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static GlobalKey<NavigatorState> get shellNavigatorHome =>
      _shellNavigatorHome;
  final SharedPreferences sharedPreferences;
  final GetGategoriesUsecase getGategoriesUsecase;
  final GetPublicationsUsecase getPublicationsUsecase;
  final GetVideoPublicationsUsecase getVideoPublicationsUsecase;
  final GetPredictionsUseCase getPredictionsUseCase;
  final GetFilteredPublicationsValuesUsecase
      getFilteredPublicationsValuesUsecase;
  final GetLocationsUsecase getLocationsUsecase;
  final GlobalBloc globalBloc;

  AppRouter({
    required this.sharedPreferences,
    required this.getGategoriesUsecase,
    required this.getPublicationsUsecase,
    required this.getLocationsUsecase,
    required this.getPredictionsUseCase,
    required this.getVideoPublicationsUsecase,
    required this.getFilteredPublicationsValuesUsecase,
    required this.globalBloc,
  });

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: "shellHome");

  static final _shellNavigatorProfile =
      GlobalKey<NavigatorState>(debugLabel: "shellProfile");

  late final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn =
          sharedPreferences.getString(Constants.CACHED_AUTH_TOKEN) != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signup ||
          state.matchedLocation == Routes.welcome ||
          state.matchedLocation == Routes.verification ||
          state.matchedLocation == Routes.userRegisterDetails;

      if (!loggedIn && !isAuthRoute) return Routes.welcome;
      if (loggedIn && isAuthRoute) return Routes.home;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.socialConnections,
        builder: (context, state) {
          // Get data from the extra parameter instead of query parameters
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          final userId = extra['userId'] as String;
          final username = extra['username'] as String;
          final initialTab = extra['initialTab'] as String? ?? 'followers';

          return SocialConnectionsPage(
            userId: userId,
            username: username,
            initialTab: initialTab,
          );
        },
      ),
      GoRoute(
        path: Routes.chats,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ChatBloc>(),
          child: const ChatRoomsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.room,
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final roomName = state.uri.queryParameters['roomName'] ?? 'Chat Room';
          return BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: ChatRoomScreen(
              roomId: roomId,
              roomName: roomName,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: Routes.verification,
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: Routes.userRegisterDetails,
        builder: (context, state) => const RegisterUserDataPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.post,
        builder: (context, state) => const PostScreen(),
      ),
      GoRoute(
        path: Routes.publicationsEdit,
        builder: (context, state) {
          return PublicationsEditorPage(
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: Routes.productDetails,
        builder: (context, state) {
          final product = state.extra as GetPublicationEntity;
          return BlocProvider(
            create: (context) => sl<DetailsBloc>(),
            child: ProductDetailsScreen(
              key: state.pageKey,
              product: product,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.anotherUserProfile,
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final userId = extraData['userId'];
          return VisitorProfileScreen(
            userId: userId,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainWrapper(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: Routes.home,
                name: "Home",
                builder: (context, state) {
                  return BlocProvider(
                    create: (_) => HomeTreeCubit(
                      getCatalogsUseCase: getGategoriesUsecase,
                      getLocationsUsecase: getLocationsUsecase,
                      getPublicationsUseCase: getPublicationsUsecase,
                      getPredictionsUseCase: getPredictionsUseCase,
                      getVideoPublicationsUsecase: getVideoPublicationsUsecase,
                      getFilteredPublicationsValuesUsecase:
                          getFilteredPublicationsValuesUsecase,
                      globalBloc: globalBloc,
                    ),
                    child: InitialHomeTreePage(
                      key: state.pageKey,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: Routes.videosFeed,
                    name: RoutesByName.videosFeed,
                    builder: (context, state) {
                      // Safely handle potential null extra data
                      final extraData = state.extra as Map<String, dynamic>?;

                      final initialVideos =
                          extraData?['videos'] as List<GetPublicationEntity>? ??
                              [];
                      final initialPage =
                          extraData?['video_current_page'] as int? ?? 0;
                      final selectedIndex = extraData?['index'] as int? ?? 0;

                      return BlocProvider.value(
                        value: HomeTreeCubit(
                          getCatalogsUseCase: getGategoriesUsecase,
                          getLocationsUsecase: getLocationsUsecase,
                          getPublicationsUseCase: getPublicationsUsecase,
                          getPredictionsUseCase: getPredictionsUseCase,
                          getVideoPublicationsUsecase:
                              getVideoPublicationsUsecase,
                          getFilteredPublicationsValuesUsecase:
                              getFilteredPublicationsValuesUsecase,
                          globalBloc: globalBloc,
                        ),
                        child: ListInShorts(
                          key: state.pageKey,
                          initialVideos: initialVideos,
                          initialPage: initialPage,
                          initialIndex: selectedIndex,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: Routes.filterHomeResult,
                    name: RoutesByName.filterHomeResult,
                    builder: (context, state) {
                      final extraData = state.extra as Map<String, dynamic>;
                      final priceFrom = extraData['priceFrom'] as double?;
                      final priceTo = extraData['priceTo'] as double?;
                      final filterState =
                          extraData['filterState'] as Map<String, dynamic>?;
                      return BlocProvider(
                        create: (_) {
                          final cubit = HomeTreeCubit(
                            getCatalogsUseCase: getGategoriesUsecase,
                            getLocationsUsecase: getLocationsUsecase,
                            getPublicationsUseCase: getPublicationsUsecase,
                            getPredictionsUseCase: getPredictionsUseCase,
                            getVideoPublicationsUsecase:
                                getVideoPublicationsUsecase,
                            getFilteredPublicationsValuesUsecase:
                                getFilteredPublicationsValuesUsecase,
                            globalBloc: globalBloc,
                          );
                          if (priceFrom != null && priceTo != null) {
                            cubit.setPriceRange(
                                priceFrom, priceTo, 'FILTER_HOME_RESULT');
                          }
                          if (filterState != null) {
                            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                            cubit.emit(
                              cubit.state.copyWith(
                                bargain: filterState['bargain'] as bool,
                                isFree: filterState['isFree'] as bool,
                                condition: filterState['condition'] as String,
                                sellerType:
                                    filterState['sellerType'] as SellerType,
                                selectedCountry:
                                    filterState['country'] as Country,
                                selectedState: filterState['state'],
                                selectedCounty:
                                    filterState['county'] as County?,
                              ),
                            );
                          }
                          return cubit;
                        },
                        child: FilterHomeResultPage(
                          key: state.pageKey,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: Routes.searchResult,
                    name: RoutesByName.searchResult,
                    builder: (context, state) {
                      return BlocProvider(
                        create: (_) => HomeTreeCubit(
                          getCatalogsUseCase: getGategoriesUsecase,
                          getLocationsUsecase: getLocationsUsecase,
                          getPublicationsUseCase: getPublicationsUsecase,
                          getPredictionsUseCase: getPredictionsUseCase,
                          getVideoPublicationsUsecase:
                              getVideoPublicationsUsecase,
                          getFilteredPublicationsValuesUsecase:
                              getFilteredPublicationsValuesUsecase,
                          globalBloc: globalBloc,
                        ),
                        child: SearchResultPage(
                          key: state.pageKey,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                      path: Routes.search,
                      name: RoutesByName.search,
                      builder: (context, state) {
                        final extraData = state.extra as Map<String, dynamic>;
                        final priceFrom = extraData['priceFrom'] as double?;
                        final priceTo = extraData['priceTo'] as double?;
                        final filterState =
                            extraData['filterState'] as Map<String, dynamic>?;
                        return BlocProvider(
                          create: (_) {
                            final cubit = HomeTreeCubit(
                              getCatalogsUseCase: getGategoriesUsecase,
                              getPublicationsUseCase: getPublicationsUsecase,
                              getLocationsUsecase: getLocationsUsecase,
                              getPredictionsUseCase: getPredictionsUseCase,
                              getVideoPublicationsUsecase:
                                  getVideoPublicationsUsecase,
                              getFilteredPublicationsValuesUsecase:
                                  getFilteredPublicationsValuesUsecase,
                              globalBloc: globalBloc,
                            );
                            if (priceFrom != null && priceTo != null) {
                              cubit.setPriceRange(
                                priceFrom,
                                priceTo,
                                "CHILD",
                              );
                            }
                            if (filterState != null) {
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              cubit.emit(
                                cubit.state.copyWith(
                                  bargain: filterState['bargain'] as bool,
                                  isFree: filterState['isFree'] as bool,
                                  condition: filterState['condition'] as String,
                                  sellerType:
                                      filterState['sellerType'] as SellerType,
                                  selectedCountry:
                                      filterState['country'] as Country,
                                  selectedState: filterState['state'],
                                  selectedCounty:
                                      filterState['county'] as County?,
                                ),
                              );
                            }
                            return cubit;
                          },
                          child: SearchPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  GoRoute(
                    name: RoutesByName.filterSecondaryResult,
                    path: Routes.filterSecondaryResult,
                    builder: (context, state) {
                      final extraData = state.extra as Map<String, dynamic>;
                      final category = extraData['category'] as CategoryModel?;
                      final priceFrom = extraData['priceFrom'] as double?;
                      final priceTo = extraData['priceTo'] as double?;
                      final filterState =
                          extraData['filterState'] as Map<String, dynamic>?;
                      if (category == null) {
                        return const Scaffold(
                          body: Center(
                              child: Text('Error: Invalid category data')),
                        );
                      }

                      return BlocProvider(
                        create: (_) {
                          final cubit = HomeTreeCubit(
                            getCatalogsUseCase: getGategoriesUsecase,
                            getPublicationsUseCase: getPublicationsUsecase,
                            getPredictionsUseCase: getPredictionsUseCase,
                            getLocationsUsecase: getLocationsUsecase,
                            getVideoPublicationsUsecase:
                                getVideoPublicationsUsecase,
                            getFilteredPublicationsValuesUsecase:
                                getFilteredPublicationsValuesUsecase,
                            globalBloc: globalBloc,
                          );
                          cubit.selectCatalog(category);
                          if (priceFrom != null && priceTo != null) {
                            cubit.setPriceRange(
                                priceFrom, priceTo, "FILTER_SECONDARY_RESULT");
                          }
                          if (filterState != null) {
                            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                            cubit.emit(
                              cubit.state.copyWith(
                                bargain: filterState['bargain'] as bool,
                                isFree: filterState['isFree'] as bool,
                                condition: filterState['condition'] as String,
                                sellerType:
                                    filterState['sellerType'] as SellerType,
                                selectedCountry:
                                    filterState['country'] as Country,
                                selectedState: filterState['state'],
                                selectedCounty:
                                    filterState['county'] as County?,
                              ),
                            );
                          }
                          return cubit;
                        },
                        child: FilterSecondaryResultPage(
                          key: state.pageKey,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    name: RoutesByName.subcategories,
                    path: Routes.subcategories,
                    builder: (context, state) {
                      final extraData = state.extra as Map<String, dynamic>;
                      final category = extraData['category'] as CategoryModel?;
                      final searchText = extraData['searchText'] as String?;
                      final priceFrom = extraData['priceFrom'] as double?;
                      final priceTo = extraData['priceTo'] as double?;
                      final filterState =
                          extraData['filterState'] as Map<String, dynamic>?;

                      if (category == null) {
                        return const Scaffold(
                          body: Center(
                              child: Text('Error: Invalid category data')),
                        );
                      }

                      return BlocProvider(
                        create: (_) {
                          final cubit = HomeTreeCubit(
                            getCatalogsUseCase: getGategoriesUsecase,
                            getPublicationsUseCase: getPublicationsUsecase,
                            getPredictionsUseCase: getPredictionsUseCase,
                            getVideoPublicationsUsecase:
                                getVideoPublicationsUsecase,
                            getLocationsUsecase: getLocationsUsecase,
                            getFilteredPublicationsValuesUsecase:
                                getFilteredPublicationsValuesUsecase,
                            globalBloc: globalBloc,
                          );
                          cubit.selectCatalog(category);

                          if (priceFrom != null && priceTo != null) {
                            cubit.setPriceRange(
                                priceFrom, priceTo, "SUBCATEGORY");
                          }
                          if (searchText != null) {
                            cubit.updateSearchText(searchText);
                          }

                          if (filterState != null) {
                            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                            cubit.emit(
                              cubit.state.copyWith(
                                bargain: filterState['bargain'] as bool,
                                isFree: filterState['isFree'] as bool,
                                condition: filterState['condition'] as String,
                                sellerType:
                                    filterState['sellerType'] as SellerType,
                                selectedCountry:
                                    filterState['country'] as Country,
                                selectedState: filterState['state'],
                                selectedCounty:
                                    filterState['county'] as County?,
                              ),
                            );
                          }
                          return cubit;
                        },
                        child: ChildHomeTreePage(
                          key: state.pageKey,
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                          name: RoutesByName.attributes,
                          path: Routes.attributes,
                          builder: (context, state) {
                            final extraData =
                                state.extra as Map<String, dynamic>;
                            final parentCategory =
                                extraData['category'] as CategoryModel?;
                            final childCategory = extraData['childCategory']
                                as ChildCategoryModel?;

                            final attributeState = extraData['attributeState']
                                as Map<String, dynamic>?;

                            final parentAttributeKeyId =
                                extraData['parentAttributeKeyId'] as String?;
                            final parentAttributeValueId =
                                extraData['parentAttributeValueId'] as String?;
                            final childAttributeKeyId =
                                extraData['childAttributeKeyId'] as String?;
                            final childAttributeValueId =
                                extraData['childAttributeValueId'] as String?;

                            final numericFieldState =
                                extraData['numericFieldState']
                                    as Map<String, dynamic>?;

                            final priceFrom = extraData['priceFrom'] as double?;
                            final priceTo = extraData['priceTo'] as double?;

                            final filterState = extraData['filterState']
                                as Map<String, dynamic>?;

                            if (parentCategory == null ||
                                childCategory == null) {
                              return const Scaffold(
                                body: Center(
                                    child:
                                        Text('Error: Invalid category data')),
                              );
                            }

                            return BlocProvider(
                              create: (_) {
                                final cubit = HomeTreeCubit(
                                  getCatalogsUseCase: getGategoriesUsecase,
                                  getLocationsUsecase: getLocationsUsecase,
                                  getPublicationsUseCase:
                                      getPublicationsUsecase,
                                  getPredictionsUseCase: getPredictionsUseCase,
                                  getVideoPublicationsUsecase:
                                      getVideoPublicationsUsecase,
                                  getFilteredPublicationsValuesUsecase:
                                      getFilteredPublicationsValuesUsecase,
                                  globalBloc: globalBloc,
                                );

                                if (priceFrom != null && priceTo != null) {
                                  cubit.setPriceRange(
                                      priceFrom, priceTo, "CHILD");
                                }

                                cubit
                                  ..selectCatalog(parentCategory)
                                  ..selectChildCategory(childCategory);

                                if (attributeState != null) {
                                  final selectedValues =
                                      attributeState['selectedValues']
                                          as Map<String, dynamic>;
                                  final selectedAttributeValues =
                                      (attributeState['selectedAttributeValues']
                                              as Map<String, dynamic>)
                                          .map((key, value) => MapEntry(
                                                cubit.state.orderedAttributes
                                                    .firstWhere(
                                                  (attr) =>
                                                      attr.attributeKey == key,
                                                ),
                                                value as AttributeValueModel,
                                              ));
                                  final dynamicAttributes =
                                      attributeState['dynamicAttributes']
                                          as List<AttributeModel>;
                                  final attributeRequests =
                                      attributeState['attributeRequests']
                                          as List<AttributeRequestValue>;

                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  cubit.emit(cubit.state.copyWith(
                                    selectedValues: selectedValues,
                                    selectedAttributeValues:
                                        selectedAttributeValues,
                                    dynamicAttributes: dynamicAttributes,
                                    attributeRequests: attributeRequests,
                                  ));
                                }

                                if (parentAttributeKeyId != null &&
                                    parentAttributeValueId != null) {
                                  cubit.selectAttributeById(
                                    parentAttributeKeyId,
                                    parentAttributeValueId,
                                  );
                                }

                                if (childAttributeKeyId != null &&
                                    childAttributeValueId != null) {
                                  cubit.selectAttributeById(
                                    childAttributeKeyId,
                                    childAttributeValueId,
                                  );
                                }

                                // Handle numeric field state
                                if (numericFieldState != null) {
                                  final numericFields =
                                      numericFieldState['numericFields']
                                          as List<NomericFieldModel>;
                                  final numericFieldValues =
                                      numericFieldState['numericFieldValues']
                                          as Map<String, Map<String, int>>;

                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  cubit.emit(cubit.state.copyWith(
                                    numericFields: numericFields,
                                    numericFieldValues: numericFieldValues,
                                  ));
                                }

                                if (filterState != null) {
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  cubit.emit(
                                    cubit.state.copyWith(
                                      bargain: filterState['bargain'] as bool,
                                      isFree: filterState['isFree'] as bool,
                                      condition:
                                          filterState['condition'] as String,
                                      sellerType: filterState['sellerType']
                                          as SellerType,
                                      selectedCountry:
                                          filterState['country'] as Country,
                                      selectedState: filterState['state'],
                                      selectedCounty:
                                          filterState['county'] as County?,
                                    ),
                                  );
                                }

                                return cubit;
                              },
                              child: DetailedHomeTreePage(
                                key: state.pageKey,
                              ),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/no",
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: Routes.profile,
                name: RoutesByName.profile,
                builder: (context, state) {
                  return ProfileScreen(
                    key: state.pageKey,
                  );
                },
                routes: [
                  GoRoute(
                    path: Routes.profileEdit,
                    name: RoutesByName.profileEdit,
                    builder: (context, state) {
                      final userData = state.extra as UserProfileEntity;
                      debugPrint("✅user country: ${userData.country}");
                      debugPrint("✅user state: ${userData.state}");
                      debugPrint("✅user county: ${userData.county}");
                      return ProfileEditor(
                        key: state.pageKey,
                        userData: userData,
                      );
                    },
                  )
                ],
              ),
            ],
          )
        ],
      ),
    ],
  );
}
