import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/auth/presentation/widgets/location_page.dart';
import 'package:list_in/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/map/map.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

enum LocationSharingMode { precise, region }

class RegisterUserDataPage extends StatefulWidget {
  const RegisterUserDataPage({super.key});

  @override
  State<RegisterUserDataPage> createState() => _RegisterUserDataPageState();
}

class _RegisterUserDataPageState extends State<RegisterUserDataPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final _nikeNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  LocationEntity _location = const LocationEntity(
    name: '',
    coordinates: CoordinatesEntity(latitude: 0, longitude: 0),
  );

  late int _currentPage;
  final int _totalPages = 5;
  final UserType _userType = UserType.individualSeller;
  int _selectedOption = 0;
  LocationSharingMode _locationSharingPreference = LocationSharingMode.region;

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
  void initState() {
    super.initState();
    _currentPage = 0;
  }

  @override
  void dispose() {
    _nikeNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!_validateCurrentPage()) return;

    if (_currentPage < _totalPages - 1) {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _nikeNameController.text.isNotEmpty;
      case 2:
        return _phoneNumberController.text.isNotEmpty;
      case 3:
        return _passwordController.text.length >= 6;
      case 4:
        return _location.name.isNotEmpty;
      default:
        return true;
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _submitRegistration() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_location.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please selection location')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterUserDataSubmitted(
            nikeName: _nikeNameController.text,
            phoneNumber: _phoneNumberController.text,
            password: _passwordController.text,
            isGrantedForPreciseLocation:
                _locationSharingPreference == LocationSharingMode.precise,
            locationName: _location.name,
            latitude: _location.coordinates.latitude,
            longitude: _location.coordinates.longitude,
            userType: _userType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        _previousPage();
        return false;
      },
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSignUpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RegistrationUserSuccess) {
              context.pushReplacement(Routes.home);
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
                            ),
                            child: IconButton(
                              onPressed: () => _previousPage(),
                              padding: EdgeInsets.zero,
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
                                ),
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
                            ),
                            child: InkWell(
                              onTap: () => {},
                              borderRadius: BorderRadius.circular(16),
                              child: const Padding(
                                padding: EdgeInsets.zero,
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
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            child: _buildPageViewBody()),
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
                                    : _currentPage == _totalPages - 1
                                        ? _submitRegistration
                                        : _nextPage,
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
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _currentPage < 4
                                            ? 'Continue'
                                            : 'Submit',
                                        style:
                                            const TextStyle(fontFamily: 'Syne'),
                                      ),
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
      ),
    );
  }

  Widget _buildPageViewBody() {
    final List<PageData> pages = [
      PageData(
        title: 'What can we call you?',
        subtitle: 'Please enter your name, company name, or a nickname.',
        content: AuthTextField(
          controller: _nikeNameController,
          labelText: 'John Doe, Nike, or YourNickname',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Name can't be empty";
            }
            return null;
          },
        ),
      ),
      PageData(
        title: 'What are you looking for?',
        subtitle: 'Please select your preference.',
        content: Column(
          children: List.generate(
            options.length,
            (index) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOption = index;
                      });
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: Card(
                      color: _selectedOption == index
                          ? AppColors.myRedBrown.withOpacity(0.25)
                          : AppColors.containerColor,
                      elevation: 0,
                      shape: SmoothRectangleBorder(
                        smoothness: 0.8,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _selectedOption == index ? 21 : 20,
                              height: _selectedOption == index ? 21 : 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedOption == index
                                      ? AppColors.black
                                      : AppColors.grey,
                                  width: _selectedOption == index ? 5 : 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    options[index]['title']!,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedOption == index
                                          ? AppColors.black
                                          : AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    options[index]['description']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: _selectedOption == index
                                          ? AppColors.black
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index < options.length - 1) const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
      PageData(
        title: 'Your Phone Number',
        subtitle: 'Enter your phone number to stay connected.',
        content: AuthTextField(
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
      PageData(
        title: 'Secure Your Account',
        subtitle: 'Create a strong password.',
        content: AuthTextField(
          controller: _passwordController,
          labelText: 'Password',
          obscureText: true,
          validator: (value) {
            if (_currentPage != 3) {
              return null;
            }
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
      PageData(
        title: 'Select Your Location',
        subtitle: 'Tap to select your location on the map.',
        content: LocationSelectorWidget(
          selectedLocation: _location,
          locationSharingMode: _locationSharingPreference,
          onLocationSharingModeChanged: (mode) {
            setState(() {
              _locationSharingPreference = mode;
            });
          },
          onOpenMap: _showLocationPicker,
          onLocationSelected: (location) {
            setState(() {
              _location = location;
            });
          },
        ),
      ),
    ];

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _totalPages,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        final page = pages[index];
        return _buildPage(
          title: page.title,
          subtitle: page.subtitle,
          child: page.content,
        );
      },
    );
  }

// Add this class to store page data

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

  Future<void> _showLocationPicker() async {
    final result = await showModalBottomSheet<LocationEntity>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) => FractionallySizedBox(
        heightFactor: 1.0,
        child: Scaffold(body: ListInMap()),
      ),
    );

    if (result != null) {
      setState(() {
        _location = result;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No Location selected"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class PageData {
  final String title;
  final String subtitle;
  final Widget content;

  PageData({
    required this.title,
    required this.subtitle,
    required this.content,
  });
}
