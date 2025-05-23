// ignore_for_file: deprecated_member_use

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthSuccess) {
            context.pushReplacement(Routes.home);
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
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(
                              -10, 0), // Move 10 pixels to the left
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding:
                                EdgeInsets.zero, // Removes internal padding
                            icon: HugeIcon(
                              icon: EvaIcons.arrowIosBack,
                              color: Theme.of(context).colorScheme.secondary,
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
                    const SizedBox(height: 40),
                    Text(
                      localizations.helloDeveloper,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.secondary,
                        fontFamily: Constants.Arial,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.5),
                      child: Text(
                        localizations.accessExplanation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.75),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _emailController,
                      labelText: localizations.emailBig,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.enterEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _passwordController,
                      labelText: localizations.password,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.enterPassword;
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
                        foregroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                context.read<AuthBloc>().add(
                                      LoginSubmitted(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                              }
                            },
                      child: state is AuthLoading
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                strokeCap: StrokeCap.round,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          : Text(
                              localizations.logIn,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: Constants.Arial,
                              ),
                            ),
                    ),
                    // const SizedBox(height: 24),
                    // Center(
                    //   child: GestureDetector(
                    //     onTap: () {},
                    //     child: Text(
                    //       localizations.forgotPassword,
                    //       style: TextStyle(
                    //         color: Theme.of(context).colorScheme.secondary,
                    //         fontSize: 16,
                    //         fontFamily: Constants.Arial,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 2),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Container(
                    //           height: 1,
                    //           color: AppColors.lightText.withOpacity(0.75),
                    //         ),
                    //       ),
                    //       Padding(
                    //         padding: EdgeInsets.symmetric(horizontal: 16),
                    //         child: Text(
                    //           localizations.or,
                    //           style: const TextStyle(
                    //             fontSize: 14,
                    //             color: AppColors.grey,
                    //           ),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Container(
                    //           height: 1,
                    //           color: AppColors.lightText.withOpacity(0.75),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 22),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           shape: SmoothRectangleBorder(
                    //               smoothness: 0.8,
                    //               borderRadius: BorderRadius.circular(16)),
                    //           padding: const EdgeInsets.symmetric(vertical: 18),
                    //           foregroundColor:
                    //               Theme.of(context).scaffoldBackgroundColor,
                    //           backgroundColor:
                    //               Theme.of(context).colorScheme.secondary,
                    //         ),
                    //         onPressed: () =>
                    //             context.pushReplacement(Routes.signup),
                    //         child: Center(
                    //           child: Text(
                    //             localizations.createAccount,
                    //             style: const TextStyle(
                    //               fontSize: 17,
                    //               fontWeight: FontWeight.w700,
                    //               fontFamily: Constants.Arial,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
