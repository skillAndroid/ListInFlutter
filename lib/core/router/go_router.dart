import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:list_in/features/auth/presentation/pages/verification_page.dart';
import 'package:list_in/features/auth/presentation/pages/welcome_page.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/domain/usecase/get_prediction_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_publications_usecase.dart';
import 'package:list_in/features/explore/domain/usecase/get_video_publications_usecase.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/pages/screens/child_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/detailed_page.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter_home_result_page.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter_secondary_result_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/initial_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/search_page.dart';
import 'package:list_in/features/explore/presentation/pages/screens/search_result_page.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/data/models/nomeric_field_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/pages/profile_editor_page.dart';
import 'package:list_in/features/profile/presentation/pages/profile_screen.dart';
import 'package:list_in/features/profile/presentation/pages/publications_editor_page.dart';
import 'package:list_in/features/undefined_screens_yet/wrapper_screen.dart';
import 'package:list_in/features/video/presentation/pages/video_feed_screen.dart';
import 'package:list_in/features/visitior_profile/visiter_profile.dart';
import 'package:list_in/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static GlobalKey<NavigatorState> get shellNavigatorHome =>
      _shellNavigatorHome;
  final SharedPreferences sharedPreferences;
  final GetGategoriesUsecase getGategoriesUsecase;
  final GetPublicationsUsecase getPublicationsUsecase;
  final GetVideoPublicationsUsecase getVideoPublicationsUsecase;
  final GetPredictionsUseCase getPredictionsUseCase;

  AppRouter({
    required this.sharedPreferences,
    required this.getGategoriesUsecase,
    required this.getPublicationsUsecase,
    required this.getPredictionsUseCase,
    required this.getVideoPublicationsUsecase,
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
      // Auth routes
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
        path: Routes.videosFeed,
        name: RoutesByName.videosFeed,
        builder: (context, state) {
          // Safely handle potential null extra data
          final extraData = state.extra as Map<String, dynamic>?;

          final initialVideos =
              extraData?['videos'] as List<GetPublicationEntity>? ?? [];
          final initialPage = extraData?['video_current_page'] as int? ?? 0;
          final selectedIndex = extraData?['index'] as int? ?? 0;

          return BlocProvider.value(
            value: HomeTreeCubit(
              getCatalogsUseCase: getGategoriesUsecase,
              getPublicationsUseCase: getPublicationsUsecase,
              getPredictionsUseCase: getPredictionsUseCase,
              getVideoPublicationsUsecase: getVideoPublicationsUsecase,
            ),
            child: ListInShorts(
              initialVideos: initialVideos,
              initialPage: initialPage,
              initialIndex: selectedIndex,
            ),
          );
        },
      ),

      GoRoute(
        path: Routes.productDetails,
        builder: (context, state) {
          final product = state.extra as GetPublicationEntity;
          return ProductDetailsScreen(
            key: state.pageKey,
            product: product,
            recommendedProducts: sampleProducts,
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
            products: sampleProducts,
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
                      getPublicationsUseCase: getPublicationsUsecase,
                      getPredictionsUseCase: getPredictionsUseCase,
                      getVideoPublicationsUsecase: getVideoPublicationsUsecase,
                    ),
                    child: InitialHomeTreePage(
                      key: state.pageKey,
                      regularProducts: sampleProducts,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: Routes.filterHomeResult,
                    name: RoutesByName.filterHomeResult,
                    builder: (context, state) {
                      final extraData = state.extra as Map<String, dynamic>;
                      final priceFrom = extraData['priceFrom'] as double?;
                      final priceTo = extraData['priceTo'] as double?;
                      return BlocProvider(
                        create: (_) {
                          final cubit = HomeTreeCubit(
                            getCatalogsUseCase: getGategoriesUsecase,
                            getPublicationsUseCase: getPublicationsUsecase,
                            getPredictionsUseCase: getPredictionsUseCase,
                            getVideoPublicationsUsecase:
                                getVideoPublicationsUsecase,
                          );
                          if (priceFrom != null && priceTo != null) {
                            cubit.setPriceRange(priceFrom, priceTo);
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
                          getPublicationsUseCase: getPublicationsUsecase,
                          getPredictionsUseCase: getPredictionsUseCase,
                          getVideoPublicationsUsecase:
                              getVideoPublicationsUsecase,
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
                        return BlocProvider(
                          create: (_) => HomeTreeCubit(
                            getCatalogsUseCase: getGategoriesUsecase,
                            getPublicationsUseCase: getPublicationsUsecase,
                            getPredictionsUseCase: getPredictionsUseCase,
                            getVideoPublicationsUsecase:
                                getVideoPublicationsUsecase,
                          ),
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
                          );
                          cubit.selectCatalog(category);
                          if (priceFrom != null && priceTo != null) {
                            cubit.setPriceRange(priceFrom, priceTo);
                          }
                          return cubit;
                        },
                        child: FilterSecondaryResultPage(
                          key: state.pageKey,
                          regularProducts: sampleProducts,
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
                          );
                          cubit.selectCatalog(category);

                          if (priceFrom != null && priceTo != null) {
                            cubit.setPriceRange(priceFrom, priceTo);
                          }
                          if (searchText != null) {
                            cubit.updateSearchText(searchText);
                          }
                          return cubit;
                        },
                        child: ChildHomeTreePage(
                          key: state.pageKey,
                          regularProducts: sampleProducts,
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
                                  getPublicationsUseCase:
                                      getPublicationsUsecase,
                                  getPredictionsUseCase: getPredictionsUseCase,
                                  getVideoPublicationsUsecase:
                                      getVideoPublicationsUsecase,
                                );

                                if (priceFrom != null && priceTo != null) {
                                  cubit.setPriceRange(priceFrom, priceTo);
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

                                return cubit;
                              },
                              child: DetailedHomeTreePage(
                                key: state.pageKey,
                                regularProducts: sampleProducts,
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

// Helper functions
ProductEntity findProductById(String id) {
  return sampleProducts.firstWhere(
    (product) => product.id == id,
    orElse: () => throw Exception('Product not found'),
  );
}
