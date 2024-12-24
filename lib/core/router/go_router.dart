import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/keep_alive_wrapper.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/undefined_screens_yet/details.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:list_in/features/auth/presentation/pages/verification_page.dart';
import 'package:list_in/features/auth/presentation/pages/welcome_page.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:list_in/features/undefined_screens_yet/wrapper_screen.dart';
import 'package:list_in/features/undefined_screens_yet/list.dart';
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
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn =
          sharedPreferences.getString(Constants.CACHED_AUTH_TOKEN) == null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signup ||
          state.matchedLocation == Routes.welcome ||
          state.matchedLocation == Routes.verification ||
          state.matchedLocation == Routes.userRegisterDetails;
      if (!loggedIn && !isAuthRoute) return Routes.welcome;
      if (loggedIn && isAuthRoute) return Routes.home;
      return null;
    },
    routes: [
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
                path: Routes.home,
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
                path: Routes.events,
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
