import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:smooth_corner/smooth_corner.dart';

class RegisterUserDataPage extends StatefulWidget {
  const RegisterUserDataPage({super.key});

  @override
  State<RegisterUserDataPage> createState() => _RegisterUserDataPageState();
}

class _RegisterUserDataPageState extends State<RegisterUserDataPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  int _currentPage = 0;
  final int _totalPages = 4; // Total number of pages
  int _selectedOption = 0;

  final List<Map<String, String>> options = [
    {
      'title': 'Sell Personal Items',
      'description':
          'Sell your old items easily like electronics, furniture, etc.',
    },
    {
      'title': 'Create a Store',
      'description':
          'Sell multiple products under your brand and gain followers.',
    },
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    } else {
      Navigator.of(context).pop(); // Exit the page if on the first page
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentPage > 0) {
      _previousPage();
      return false; // Prevent default pop behavior
    }
    return true; // Allow default pop behavior (close the screen)
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSignUpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RegistrationUserSuccess) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(
                              -20,
                              0,
                            ), // Move 10 pixels to the left
                            child: IconButton(
                              onPressed: () => _previousPage(),
                              padding:
                                  EdgeInsets.zero, // Removes internal padding
                              icon: const HugeIcon(
                                icon: EvaIcons.arrowIosBack,
                                color: AppColors.black,
                                size: 28,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(
                              -15,
                              0,
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.68, // 66% of screen width
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 0.0,
                                    end: (_currentPage + 1) / _totalPages),
                                duration: const Duration(
                                  milliseconds: 300,
                                ), // Adjust the duration for smoothness
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: AppColors.lightGray,
                                    borderRadius: BorderRadius.circular(2),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppColors.black,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(
                              12,
                              0,
                            ), // Move 10 pixels to the left
                            child: InkWell(
                              onTap: () => {},
                              borderRadius: BorderRadius.circular(16),
                              child: const Padding(
                                padding: EdgeInsets
                                    .zero, // Ensures no extra padding around the icon
                                child: Icon(
                                  EvaIcons.infoOutline,
                                  color: AppColors.black,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Progress Indicator at the top

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildPage(
                                title: 'What can we call you?',
                                subtitle:
                                    'Please enter your name, company name, or a nickname.',
                                child: AuthTextField(
                                  controller: _firstNameController,
                                  labelText: 'John Doe, Nike, or YourNickname',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Name can't be empty";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _buildPage(
                                title: 'What are you looking for?',
                                subtitle: 'Please select your preference.',
                                child: Column(
                                  children:
                                      List.generate(options.length, (index) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedOption = index;
                                        });
                                      },
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                          EdgeInsets.zero,
                                        ),
                                        elevation: WidgetStateProperty.all(
                                          0,
                                        ), // Disable elevation (shadow)
                                      ),
                                      child: Card(
                                        color: _selectedOption == index
                                            ? AppColors.myRedBrown.withOpacity(
                                                0.25) // Change color if selected
                                            : AppColors.containerColor,
                                        elevation: 0,
                                        // margin: const EdgeInsets.symmetric(
                                        //     vertical: 8, horizontal: 0),
                                        shape: SmoothRectangleBorder(
                                          smoothness: 0.8,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Animated circle with increased size and width
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                width: _selectedOption == index
                                                    ? 21
                                                    : 20, // Wider circle when selected
                                                height: _selectedOption == index
                                                    ? 21
                                                    : 20, // Larger circle when selected
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: _selectedOption ==
                                                            index
                                                        ? AppColors
                                                            .black // Border color when selected
                                                        : AppColors
                                                            .gray, // Border color when unselected
                                                    width: _selectedOption ==
                                                            index
                                                        ? 5
                                                        : 2, // Thicker border when selected
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      16), // Space between circle and text
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      options[index]['title']!,
                                                      style: TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            _selectedOption ==
                                                                    index
                                                                ? AppColors
                                                                    .black
                                                                : AppColors
                                                                    .black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      options[index]
                                                          ['description']!,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            _selectedOption ==
                                                                    index
                                                                ? AppColors
                                                                    .black
                                                                : AppColors
                                                                    .black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              _buildPage(
                                title: 'Your Phone Number',
                                subtitle:
                                    'Enter your phone number to stay connected.',
                                child: AuthTextField(
                                  controller: _phoneNumberController,
                                  labelText: 'Phone Number',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              _buildPage(
                                title: 'Secure Your Account',
                                subtitle: 'Create a strong password.',
                                child: AuthTextField(
                                  controller: _passwordController,
                                  labelText: 'Password',
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : _currentPage < 3
                                        ? _nextPage
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              var age = int.tryParse(
                                                      _ageController.text) ??
                                                  0;
                                              context.read<AuthBloc>().add(
                                                    RegisterUserDataSubmitted(
                                                      firstname:
                                                          _firstNameController
                                                              .text,
                                                      lastname:
                                                          _lastNameController
                                                              .text,
                                                      age: age,
                                                      phoneNumber:
                                                          _phoneNumberController
                                                              .text,
                                                      password:
                                                          _passwordController
                                                              .text,
                                                      roles: 'USER',
                                                    ),
                                                  );
                                            }
                                          },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  backgroundColor: AppColors.littleGreen,
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _currentPage < 3
                                            ? 'Continue'
                                            : 'Submit',
                                        style:
                                            const TextStyle(fontFamily: 'Syne'),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Syne',
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.lightText,
            ),
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}
//