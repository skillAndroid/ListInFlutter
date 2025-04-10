import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/config/theme/app_theme.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/router/go_router.dart';
import 'package:list_in/core/theme/provider/theme_provider.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/followers/presentation/bloc/social_user_bloc.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_bloc.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_bloc.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'core/di/di_managment.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<PostProvider>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => di.sl<ThemeBloc>()..add(InitThemeEvent()),
          ),
          BlocProvider(
            create: (_) => di.sl<GlobalBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<AuthBloc>(),
          ),
          BlocProvider<MapBloc>(
            create: (_) => di.sl<MapBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<LanguageBloc>()..add(LoadLanguageEvent()),
          ),
          BlocProvider<UserProfileBloc>(
            create: (_) => di.sl<UserProfileBloc>(),
          ),
          BlocProvider<UserPublicationsBloc>(
            create: (_) => di.sl<UserPublicationsBloc>(),
          ),
          BlocProvider<PublicationUpdateBloc>(
            create: (_) => di.sl<PublicationUpdateBloc>(),
          ),
          BlocProvider<AnotherUserProfileBloc>(
            create: (_) => di.sl<AnotherUserProfileBloc>(),
          ),
          BlocProvider<DetailsBloc>(
            create: (_) => di.sl<DetailsBloc>(),
          ),
          BlocProvider<LikedPublicationsBloc>(
              create: (_) => di.sl<LikedPublicationsBloc>()),
          BlocProvider<SocialUserBloc>(create: (_) => di.sl<SocialUserBloc>())
        ],
        child: MyApp(router: di.sl<AppRouter>().router),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    // Enable edge-to-edge mode with both overlays visible
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        // Determine which theme to use
        final isDarkMode =
            themeState is ThemeLoaded ? themeState.isDarkMode : false;

        // Set the status bar and navigation bar colors based on theme
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDarkMode
              ? AppTheme.darkTheme.scaffoldBackgroundColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ));

        return BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            Locale locale = const Locale(AppLanguages.english);
            if (langState is LanguageLoaded) {
              locale = Locale(langState.languageCode);
            }

            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(0.85)),
              child: MaterialApp.router(
                title: 'Your App',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                builder: (context, child) {
                  // This is where we control padding for top and bottom system UI
                  return SafeArea(
                    // Only apply padding to the bottom, not to the top
                    top: false,
                    bottom: true,
                    child: child ?? const SizedBox(),
                  );
                },
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLanguages.supportedLocales,
                locale: locale,
              ),
            );
          },
        );
      },
    );
  }
}
