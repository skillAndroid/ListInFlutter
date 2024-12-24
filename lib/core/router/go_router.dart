import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/keep_alive_wrapper.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/details.dart';
import 'package:list_in/features/app_screens/presentation/app_navigation_screen.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:list_in/features/auth/presentation/pages/verification_page.dart';
import 'package:list_in/features/auth/presentation/pages/welcome_page.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:list_in/list.dart';
import 'package:list_in/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  final SharedPreferences sharedPreferences;
  AppRouter(this.sharedPreferences);

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final _homeNavigatorKey = GlobalKey<NavigatorState>();
  static final _eventsNavigatorKey = GlobalKey<NavigatorState>();

  late final router = GoRouter(
    refreshListenable: ValueNotifier<int>(0),
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppPath.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn =
          sharedPreferences.getString(Constants.CACHED_AUTH_TOKEN) != null;
      final isAuthRoute = state.matchedLocation == AppPath.login ||
          state.matchedLocation == AppPath.signup ||
          state.matchedLocation == AppPath.welcome ||
          state.matchedLocation == AppPath.verification ||
          state.matchedLocation == AppPath.userRegisterDetails;
      if (!loggedIn && !isAuthRoute) return AppPath.welcome;
      if (loggedIn && isAuthRoute) return AppPath.home;
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppPath.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppPath.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppPath.verification,
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: AppPath.userRegisterDetails,
        builder: (context, state) => const RegisterUserDataPage(),
      ),
      GoRoute(
        path: AppPath.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppPath.post,
        builder: (context, state) => const PostScreen(),
      ),

      GoRoute(
        path: AppPath.productDetails,
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          final extraProducts = state.extra;

          // Handle type casting safely
          final List<Product> recommendedProducts;
          if (extraProducts is List<Product>) {
            recommendedProducts = extraProducts;
          } else {
            recommendedProducts = getRecommendedProducts(productId);
          }

          return ProductDetailsScreen(
            productId: productId,
            recommendedProducts: recommendedProducts,
          );
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            key: ValueKey(state.matchedLocation),
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppPath.home,
                builder: (context, state) => KeepAliveWrapper(
                  child: ProductListScreen(
                    advertisedProducts: sampleVideos,
                    regularProducts: sampleProducts,
                  ),
                ),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _eventsNavigatorKey,
            routes: [
              GoRoute(
                path: AppPath.events,
                builder: (context, state) => const KeepAliveWrapper(
                  child: EventsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
