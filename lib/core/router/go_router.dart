import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/keep_alive_wrapper.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:list_in/features/auth/presentation/pages/verification_page.dart';
import 'package:list_in/features/auth/presentation/pages/welcome_page.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/pages/child_page.dart';
import 'package:list_in/features/explore/presentation/pages/detailed_page.dart';
import 'package:list_in/features/explore/presentation/pages/initial_page.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:list_in/features/profile/presentation/profile_page.dart';
import 'package:list_in/features/details/presentation/pages/details.dart';
import 'package:list_in/features/undefined_screens_yet/wrapper_screen.dart';
import 'package:list_in/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  final SharedPreferences sharedPreferences;
  AppRouter(this.sharedPreferences);

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
        path: Routes.productDetails,
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final extraProducts = state.extra;

          final List<ProductEntity> recommendedProducts;
          if (extraProducts is List<ProductEntity>) {
            recommendedProducts = extraProducts;
          } else {
            recommendedProducts = getRecommendedProducts(productId);
          }

          final productDetails = findProductById(productId);

          return ProductDetailsScreen(
            key: state.pageKey,
            productId: productId,
            recommendedProducts: recommendedProducts,
            productDetails: productDetails,
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
                  return InitialHomeTreePage(
                    key: state.pageKey,
                    regularProducts: sampleProducts,
                    advertisedProducts: sampleVideos,
                  );
                },
                routes: [
                  GoRoute(
                    name: RoutesByName.subcategories,
                    path: Routes.subcategories,
                    builder: (context, state) => ChildHomeTreePage(
                      key: state.pageKey,
                      regularProducts: sampleProducts,
                      advertisedProducts: sampleVideos,
                    ),
                    routes: [
                      GoRoute(
                        name: RoutesByName.attributes,
                        path: Routes.attributes,
                        builder: (context, state) => DetailedHomeTreePage(
                          key: state.pageKey,
                          regularProducts: sampleProducts,
                          advertisedProducts: sampleVideos,
                        ),
                      ),
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
                name: "Profile",
                builder: (context, state) {
                  return ProfileScreen(
                    key: state.pageKey,
                  );
                },
                routes: [
                  // here should be profile datas : ))
                ],
              ),
            ],
          ),
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
