import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_theme.dart';
import 'package:list_in/features/post/presentation/pages/post_screen.dart';

class AppScreens extends StatelessWidget {
  const AppScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = AppTheme.lightTheme;
    AppTheme.setStatusBarAndNavBarColor(theme);
    return MaterialApp(
      title: 'Your App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const PostScreen(), //WelcomePage(),
      routes: {
        '/home': (context) =>
            const Scaffold(body: Center(child: Text('Home Page'))),
      },
    );
  }
}
