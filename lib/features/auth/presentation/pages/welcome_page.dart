import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/auth/presentation/pages/login_page.dart';
import 'package:list_in/features/auth/presentation/pages/signup_page.dart';
import 'package:smooth_corner/smooth_corner.dart';
import '../bloc/auth_bloc.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final double height = 180;
  final double borderRadius = 20;
  final double borderRadiusSmoothness = 0.8;
  final double spaceHeight = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF7DF), // AppColors.littleGreen,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: 1,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: 130,
                                    width: double.infinity,
                                    AppImages.wElectronics,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: height,
                                    width: double.infinity,
                                    AppImages.wAuto,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: height,
                                    AppImages.wCloses,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Second Column with offset of 100
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: height,
                                    AppImages.wBeautyAccessories,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: 120,
                                    width: double.infinity,
                                    AppImages.wAnimals,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: 130,
                                    width: double.infinity,
                                    AppImages.wRealestate,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: 130,
                                    width: double.infinity,
                                    AppImages.wForchildren,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Third Column with offset of 80
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              children: [
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: 90,
                                    width: double.infinity,
                                    AppImages.wHousehold,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: height,
                                    width: double.infinity,
                                    AppImages.wGarden,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: height,
                                    AppImages.wPlats,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                SizedBox(height: spaceHeight),
                                SmoothClipRRect(
                                  smoothness: borderRadiusSmoothness,
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  child: Image.asset(
                                    height: 75,
                                    width: double.infinity,
                                    AppImages.wSport,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, // Start from the top
                  end: Alignment.topCenter,
                  stops: const [0.4, 0.5],
                  colors: [
                    AppColors.white,
                    AppColors.white.withOpacity(0)
                  ], // 70% white, 30% transparent
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 34,
              right: 34,
              child: Expanded(
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
                        child: Image.asset(AppImages.appLogo),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Default text color
                        ),
                        children: [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: 'Sellers',
                            style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 228, 132, 105)
                                // color: AppColors.containerColor,
                                ), // Change color for "Sellers"
                          ),
                          TextSpan(text: ' World'),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: BlocProvider.of<AuthBloc>(context),
                              child: const SignupPage(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: AppColors.littleGreen),
                      child: const Center(
                        child: Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Syne',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: BlocProvider.of<AuthBloc>(context),
                              child: const LoginPage(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20)),
                      child: const Center(
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Syne',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top left
    path.lineTo(0, 0);

    // Draw line to top right
    path.lineTo(size.width, 0);

    // Draw line down right side
    path.lineTo(size.width, size.height * 0.8);

    // Create the wavy bottom
    var firstControlPoint = Offset(size.width * 0.75, size.height * 0.95);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.25, size.height * 0.75);
    var secondEndPoint = Offset(0, size.height * 0.8);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    // Close the path
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
