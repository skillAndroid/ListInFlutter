// ignore_for_file: deprecated_member_use

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import '../bloc/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignUpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is EmailReceivedSuccess) {
            context.push(Routes.verification);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Transform.translate(
                              offset: const Offset(-10, 0),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                padding: EdgeInsets.zero,
                                icon: const HugeIcon(
                                  icon: EvaIcons.arrowIosBack,
                                  color: AppColors.black,
                                  size: 32,
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-6, 0),
                              child: SmoothClipRRect(
                                smoothness: 1,
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.asset(
                                  AppImages.appLogo,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      localizations.createAccount,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        fontFamily: Constants.Arial,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.5),
                      child: Text(
                        localizations.createAccountMessage,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGray.withOpacity(0.75)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _emailController,
                      labelText: localizations.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.enterEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: SmoothRectangleBorder(
                            smoothness: 0.8,
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                context.read<AuthBloc>().add(
                                      SignupSubmitted(
                                        email: _emailController.text,
                                      ),
                                    );
                              }
                            },
                      child: state is AuthLoading
                          ?  SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                strokeCap: StrokeCap.round,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              localizations.continuee,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: Constants.Arial,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.lightText.withOpacity(0.75),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              localizations.or,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.lightText.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: SmoothRectangleBorder(
                                  smoothness: 0.8,
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            onPressed: () {},
                            child:  Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                const  Icon(
                                    Ionicons.logo_google,
                                    //color: AppColors.littleGreen,
                                    color: AppColors.black,
                                    size: 21,
                                  ),
                                const  SizedBox(width: 18),
                                  Text(
                                    localizations.continueWithGoogle,
                                    style:const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: Constants.Arial,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: SmoothRectangleBorder(
                                  smoothness: 0.8,
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            onPressed: () {
                              // Handle Continue with Facebook
                            },
                            child:  Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                 const Icon(
                                    EvaIcons.facebook,
                                    size: 24,
                                    //color: AppColors.littleGreen,
                                    color: AppColors.black,
                                  ),
                                const  SizedBox(width: 15),
                                  Text(
                                     localizations.continueWithFacebook,
                                    style:const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: Constants.Arial,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: SmoothRectangleBorder(
                                  smoothness: 0.8,
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            onPressed: () {
                              // Handle Continue with Apple
                            },
                            child:  Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                 const Icon(
                                    Ionicons.logo_apple,
                                    //color: AppColors.littleGreen,
                                    color: AppColors.black,
                                    size: 24,
                                  ),
                                 const SizedBox(width: 16),
                                  Text(
                                    localizations.continueWithApple,
                                    style:const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: Constants.Arial,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          localizations.alreadyHaveAccount,
                          style:const TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                              fontFamily: Constants.Arial,
                              fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => context.pushReplacement(Routes.login),
                          child: Text(
                            localizations.logIn,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontFamily: Constants.Arial,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
