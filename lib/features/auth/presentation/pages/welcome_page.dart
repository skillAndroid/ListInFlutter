// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/language/screen/language_picker_screen.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final double height = 180;
  final double borderRadius = 20;
  final double borderRadiusSmoothness = 0.8;
  final double spaceHeight = 5;
  bool _isLoadingVisible = false;
  bool _isMounted = false;
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _setupGoogleSignInListener(context);
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only handle loading states if this component is still mounted
        if (!_isMounted) return;

        if (state is AuthLoading) {
          // Check if we're still on the welcome page by checking the current route
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute == Routes.welcome) {
            _showLoading(context);
          }
        } else {
          // Dismiss loading indicator if it's showing
          if (_isLoadingVisible) {
            Navigator.of(context, rootNavigator: true).pop();
            _isLoadingVisible = false;
          }

          if (state is AuthSuccess) {
            // User authenticated - go to home page
            context.pushReplacement(Routes.home);
          } else if (state is GoogleUserNeedsRegistration) {
            // Store the email for registration
            // You might need to create a mechanism to store this email temporarily
            // This could be a shared preference, or passing as a route parameter

            // Navigate to registration page
            context.push(Routes.userRegisterDetails, extra: {
              'email': state.email
            } // Pass email as parameter if your router supports this
                );
          } else if (state is AuthLoginError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildImageGrid(),
              ),
              _buildGradientOverlay(),
              _buildWelcomeOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildImageColumn([
                _buildSmoothImage(AppImages.wElectronics, height: 130),
                _buildSmoothImage(AppImages.wAuto),
                _buildSmoothImage(AppImages.wCloses),
              ]),
              _buildImageColumn([
                _buildSmoothImage(AppImages.wBeautyAccessories),
                _buildSmoothImage(AppImages.wAnimals, height: 120),
                _buildSmoothImage(AppImages.wRealestate, height: 130),
                _buildSmoothImage(AppImages.wForchildren, height: 130),
              ]),
              _buildImageColumn([
                _buildSmoothImage(AppImages.wHousehold, height: 90),
                _buildSmoothImage(AppImages.wGarden),
                _buildSmoothImage(AppImages.wPlats),
                _buildSmoothImage(AppImages.wSport, height: 75),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageColumn(List<Widget> images) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            SizedBox(height: spaceHeight),
            ...images,
          ],
        ),
      ),
    );
  }

  Widget _buildSmoothImage(String assetPath, {double height = 180}) {
    return Padding(
      padding: EdgeInsets.only(bottom: spaceHeight),
      child: SmoothClipRRect(
        smoothness: borderRadiusSmoothness,
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          width: 2,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Image.asset(
          assetPath,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0.4, 0.5],
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeOverlay(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add language selector button here
          _buildLanguageSelector(context),

          SmoothClipRRect(
            smoothness: 1,
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 70,
              width: 70,
              child: Image.asset(
                AppImages.appLogo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildWelcomeText(),
          const SizedBox(height: 24),

          // Google Sign In button
          SizedBox(
            width: double.infinity,
            child: _buildGoogleSignInButton(context),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildEmailSignInButton(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

// Google Sign In button with official Google styling
  Widget _buildGoogleSignInButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // For mobile, use your existing button
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 1,
        shape: SmoothRectangleBorder(
            smoothness: 0.8,
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).cardColor)),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      onPressed: () => _handleGoogleSignIn(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the official Google "G" logo as an asset
            SizedBox(
              width: 21,
              height: 21,
              child: Image.asset(
                'assets/images/google_ic_org.png', // Add this to your assets
                errorBuilder: (context, error, stackTrace) => Icon(
                  Ionicons.logo_google,
                  color: CupertinoColors.activeBlue, // Google blue
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Text(
              localizations.continueWithGoogle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: Constants.Arial,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Google Sign In button with official Google styling
  Widget _buildEmailSignInButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // For mobile, use your existing button
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 1,
        shape: SmoothRectangleBorder(
            smoothness: 0.8,
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).cardColor)),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
      onPressed: () => context.push(Routes.login),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use the official Google "G" logo as an asset
            SizedBox(
                width: 21,
                height: 21,
                child: Icon(
                  Ionicons.mail,
                  color: CupertinoColors.activeBlue, // Google blue
                  size: 21,
                )),
            const SizedBox(width: 18),
            Text(
              localizations.logIn,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: Constants.Arial,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Add a listener to handle the Google sign-in for web
  void _setupGoogleSignInListener(BuildContext context) {
    if (kIsWeb) {
      final GoogleSignIn webGoogleSignIn = GoogleSignIn(
        clientId:
            '907103281951-hs8760vautubke7h6s54889ri4juqp3t.apps.googleusercontent.com',
        scopes: ['email', 'profile', 'openid'],
      );

      webGoogleSignIn.onCurrentUserChanged
          .listen((GoogleSignInAccount? account) async {
        if (account != null) {
          // When user signs in, get their ID token
          final GoogleSignInAuthentication auth = await account.authentication;
          if (auth.idToken != null) {
            print('Google ID Token from listener: ${auth.idToken}');
            print('Google User Email from listener: ${account.email}');

            // Dispatch event to AuthBloc
            context.read<AuthBloc>().add(
                  GoogleAuthSubmitted(
                    idToken: auth.idToken!,
                    email: account.email,
                  ),
                );

            // Sign out from Google after getting the tokens
            await webGoogleSignIn.signOut();
          }
        }
      });

      // Try silent sign-in on initialization
      webGoogleSignIn.signInSilently();
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Show loading indicator
      _showLoading(context);

      // Your existing Android/iOS implementation
      final GoogleSignIn tempGoogleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId:
            '907103281951-hs8760vautubke7h6s54889ri4juqp3t.apps.googleusercontent.com',
        signInOption: SignInOption.standard,
      );

      final GoogleSignInAccount? googleUser = await tempGoogleSignIn.signIn();

      // Dismiss loading indicator
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        if (idToken != null && idToken.isNotEmpty) {
          print('Google ID Token: $idToken');
          print('Google User Email: ${googleUser.email}');

          context.read<AuthBloc>().add(
                GoogleAuthSubmitted(
                  idToken: idToken,
                  email: googleUser.email,
                ),
              );

          await tempGoogleSignIn.signOut();
        } else {
          _showErrorSnackBar(context, AppLocalizations.of(context)!.error);
        }
      } else {
        print('Sign in cancelled by user');
      }
    } catch (error) {
      // Dismiss loading indicator if it's still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
      }

      print('Detailed Google Sign In Error: $error');

      // Get localizations
      final localizations = AppLocalizations.of(context)!;

      // More specific error messages
      String errorMessage = localizations.googleSignInFailed;
      if (error.toString().contains('network_error')) {
        errorMessage = localizations.networkErrorOccurred;
      } else if (error.toString().contains('popup_closed') ||
          error.toString().contains('popup_closed_by_user')) {
        errorMessage = localizations.signInCancelled;
      }

      _showErrorSnackBar(context, errorMessage);
    }
  }

  void _showLoading(BuildContext context) {
    _isLoadingVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SmoothClipRRect(
            smoothness: 0.7,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Success message
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Create a new method for the language selector
  Widget _buildLanguageSelector(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        // Get current language code
        String currentLang = 'en';
        if (state is LanguageLoaded) {
          currentLang = state.languageCode;
        }

        // Map language code to display text
        final languageMap = {
          'en': 'EN',
          'ru': 'RU',
          'uz': 'UZ',
        };

        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LanguageSelectionScreen()),
                );
              },
              child: SmoothClipRRect(
                smoothness: 0.8,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Image.asset(
                          AppIcons.languageIc,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        languageMap[currentLang] ?? 'EN',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    final localizations = AppLocalizations.of(context)!;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
        children: [
          TextSpan(text: localizations.listInWorld),
        ],
      ),
    );
  }
}
