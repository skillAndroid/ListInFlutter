import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/features/app_screens/presentation/app_navigation_screen.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:list_in/features/auth/presentation/pages/verification_page.dart';
import 'package:list_in/features/auth/presentation/pages/welcome_page.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  final SharedPreferences sharedPreferences;

  AppRouter(this.sharedPreferences);

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  late final router = GoRouter(
    refreshListenable: ValueNotifier<int>(0),
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn = sharedPreferences.getString('CACHED_AUTH_TOKEN') == null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/verification';

      
      if (!loggedIn && !isAuthRoute) return '/welcome';

     
      if (loggedIn && isAuthRoute) return '/home';

      // Otherwise, no redirection
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Using ShellRoute instead of StatefulShellRoute
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainWrapper(
            key: ValueKey(state.matchedLocation),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const PostScreen(),
          ),
          GoRoute(
            path: '/events',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const EventsScreen(),
          ),
        ],
      ),
    ],
  );
}
