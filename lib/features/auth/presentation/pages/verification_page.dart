// ignore_for_file: deprecated_member_use

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pinput/pinput.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;
  String? _storedEmail;

  @override
  void initState() {
    super.initState();
    _fetchStoredEmail();
  }

  void _fetchStoredEmail() async {
    final storedEmailResult =
        await context.read<AuthBloc>().getStoredEmailUsecase();
    if (storedEmailResult?.email != null) {
      setState(() {
        _storedEmail = storedEmailResult!.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthVerificationError) {
            setState(() {
              _errorMessage = state.message;
            });
            _formKey.currentState?.validate();
          } else if (state is VerificationSuccess) {
            context.push(Routes.userRegisterDetails);
          }
        },
        builder: (context, state) {
          return SafeArea(
              child: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-10, 0),
                          child: IconButton(
                            onPressed: () => context.pop(),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.asset(
                              AppImages.appLogo,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      'Verify Email!',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkGray
                                .withOpacity(0.75) // Default text color
                            ),
                        children: [
                          TextSpan(
                            text: 'We send verification code to your ',
                          ),
                          TextSpan(
                            text: _storedEmail ??
                                'email', // Use the stored email here
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Pinput(
                      length: 5,
                      controller: _emailController,
                      onChanged: (value) {
                        if (value.length != 5) {
                          setState(() {
                            _errorMessage = null;
                          });
                          context.read<AuthBloc>().add(InputChanged());
                        }
                      },
                      errorText:
                          state is AuthVerificationError ? state.message : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Verification code is empty';
                        } else if (value.length < 5 && value.isNotEmpty) {
                          return "Fill all boxes";
                        }

                        if (_errorMessage != null) {
                          return _errorMessage;
                        }

                        return null;
                      },
                      //
                      errorTextStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                      defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.containerColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: AppColors.lightText,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgColor,
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      EmailVerificationSubmitted(
                                        verificationCode: _emailController.text,
                                      ),
                                    );
                              }
                            },
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                strokeCap: StrokeCap.round,
                                color: AppColors.black,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't get code?",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppins",
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ));
        },
      ),
    );
  }
}
