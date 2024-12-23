import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:pinput/pinput.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;
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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is VerificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email Verified!')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: BlocProvider.of<AuthBloc>(context),
                  child: const RegisterUserDataPage(),
                ),
              ),
            );
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
                          offset: const Offset(
                              -10, 0), // Move 10 pixels to the left
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            padding:
                                EdgeInsets.zero, // Removes internal padding
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
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Syne',
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightText // Default text color
                            ),
                        children: [
                          TextSpan(
                            text: 'We send verification code to your ',
                          ),
                          TextSpan(
                            text: 'sweetfoxnew@gmail.com',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray,
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
                          border: Border.all(color: AppColors.primary),
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
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        foregroundColor: AppColors.black,
                        backgroundColor: AppColors.littleGreen,
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
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Syne',
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
                                fontFamily: "Syne",
                                color: AppColors.secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // const SizedBox(height: 16),
                  ],
                )),
          ));
        },
      ),
    );
  }

//
}
//
