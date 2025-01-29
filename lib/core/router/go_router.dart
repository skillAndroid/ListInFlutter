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
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/pages/child_page.dart';
import 'package:list_in/features/explore/presentation/pages/detailed_page.dart';
import 'package:list_in/features/explore/presentation/pages/initial_page.dart';
import 'package:list_in/features/explore/presentation/pages/search_page.dart';
import 'package:list_in/features/explore/presentation/pages/search_result_page.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/presentation/pages/profile_editor_page.dart';
import 'package:list_in/features/profile/presentation/pages/profile_screen.dart';
import 'package:list_in/features/undefined_screens_yet/wrapper_screen.dart';
import 'package:list_in/features/video/presentation/pages/video_feed_screen.dart';
import 'package:list_in/features/visitior_profile/visiter_profile.dart';
import 'package:list_in/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  final SharedPreferences sharedPreferences;
  final GetGategoriesUsecase getGategoriesUsecase;
  final GetPublicationsUsecase getPublicationsUsecase;
  final GetPredictionsUseCase getPredictionsUseCase;

  AppRouter({
    required this.sharedPreferences,
    required this.getGategoriesUsecase,
    required this.getPublicationsUsecase,
    required this.getPredictionsUseCase,
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
        path: Routes.videosFeed,
        name: RoutesByName.videosFeed,
        builder: (context, state) => ListInShorts(data: sampleVideos),
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
        builder: (context, state) => VisitorProfileScreen(
          userId: 'userId',
          products: sampleProducts,
        ),
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
                    ),
                    child: InitialHomeTreePage(
                      key: state.pageKey,
                      regularProducts: sampleProducts,
                      advertisedProducts: sampleVideos,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: Routes.searchResult,
                    name: RoutesByName.searchResult,
                    builder: (context, state) {
                      return BlocProvider(
                        create: (_) => HomeTreeCubit(
                          getCatalogsUseCase: getGategoriesUsecase,
                          getPublicationsUseCase: getPublicationsUsecase,
                          getPredictionsUseCase: getPredictionsUseCase,
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
                          ),
                          child: SearchPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  GoRoute(
                    name: RoutesByName.subcategories,
                    path: Routes.subcategories,
                    builder: (context, state) {
                      final extraData = state.extra as Map<String, dynamic>;
                      final category = extraData['category'] as CategoryModel?;
                      final searchText = extraData['searchText'] as String?;

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
                          );
                          cubit.selectCatalog(category);
                          if (searchText != null) {
                            cubit.updateSearchText(searchText);
                          }
                          return cubit;
                        },
                        child: ChildHomeTreePage(
                          key: state.pageKey,
                          regularProducts: sampleProducts,
                          advertisedProducts: sampleVideos,
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
                            final searchText =
                                extraData['searchText'] as String?;

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
                                );
                                cubit
                                  ..selectCatalog(parentCategory)
                                  ..selectChildCategory(childCategory);
                                if (searchText != null) {
                                  cubit.updateSearchText(searchText);
                                }
                                return cubit;
                              },
                              child: DetailedHomeTreePage(
                                key: state.pageKey,
                                regularProducts: sampleProducts,
                                advertisedProducts: sampleVideos,
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
