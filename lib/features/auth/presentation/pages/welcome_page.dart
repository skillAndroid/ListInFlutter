import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        side: const BorderSide(width: 2, color: AppColors.white),
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
            AppColors.white,
            // ignore: deprecated_member_use
            AppColors.white.withOpacity(0),
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
          _buildElevatedButton(
            context,
            label: 'Create an Account',
            color: AppColors.littleGreen,
            onPressed: () => context.push(Routes.signup),
          ),
          const SizedBox(height: 8),
          _buildElevatedButton(
            context,
            label: 'Log In',
            color: AppColors.transparent,
            onPressed: () => context.push(Routes.login),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: 'Welcome to '),
          TextSpan(
            text: 'ListIn',
            style: TextStyle(
              color: Color.fromARGB(255, 11, 100, 54),
            ),
          ),
          TextSpan(text: ' World'),
        ],
      ),
    );
  }

  Widget _buildElevatedButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: color,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'Syne',
          ),
        ),
      ),
    );
  }
}
