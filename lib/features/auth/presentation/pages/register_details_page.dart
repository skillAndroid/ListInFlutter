// ignore_for_file: deprecated_member_use

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:list_in/features/auth/presentation/widgets/location_page.dart';
import 'package:list_in/features/auth/presentation/widgets/validars.dart';
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
  final int _totalPages = 4;
  final UserType _userType = UserType.individualSeller;
  int _selectedOption = 0;
  LocationSharingMode _locationSharingPreference = LocationSharingMode.precise;

  late List<Map<String, String>> options;

  @override
  void initState() {
    super.initState();
    // options[0]['title'] = AppLocalizations.of(context)!.sellPersonalItems;
    // options[0]['description'] =
    //     AppLocalizations.of(context)!.sellPersonalItemsDesc;
    // options[1]['title'] = AppLocalizations.of(context)!.createStore;
    // options[1]['description'] = AppLocalizations.of(context)!.createStoreDesc;
    _currentPage = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize options with proper localization
    options = LocalizedOptions.getOptions(context);
    // Fallback if localization failed
    if (options.isEmpty) {
      final locale = Localizations.localeOf(context);
      options = LocalizedOptions.getFallbackOptions(locale.languageCode);
    }
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final snackBarBackgroundColor =
        isDarkMode ? Colors.grey[900] : Colors.white;
    final snackBarTextColor = isDarkMode ? Colors.white : Colors.black;

    void showCustomSnackBar(String message, {IconData? icon}) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final snackBarBackgroundColor =
          isDarkMode ? Colors.grey[900] : Colors.white;
      final snackBarTextColor = isDarkMode ? Colors.white : Colors.black;
      final snackBarIconColor =
          isDarkMode ? Colors.blue[300] : Colors.blue[700];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: snackBarIconColor, size: 24),
                SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: snackBarTextColor, fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: snackBarBackgroundColor,
          behavior: SnackBarBehavior.floating,
          elevation: 10, // Делаем тень
          shape: SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Закругляем углы
            side: BorderSide(
              color: isDarkMode ? Colors.blueGrey : Colors.grey[300]!,
              width: 1.2, // Добавляем лёгкий контур
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Отступы
          duration: Duration(seconds: 3), // Время отображения
        ),
      );
    }

    switch (_currentPage) {
      case 0:
        if (_nikeNameController.text.isEmpty) {
          showCustomSnackBar(
              ValidationMessages.getMessage(context, 'nameEmpty'));
          return false;
        }
        return true;
      case 2:
        if (_phoneNumberController.text.isEmpty) {
          showCustomSnackBar(
              ValidationMessages.getMessage(context, 'phoneNumberEmpty'));
          return false;
        }
        return true;
      // case 3:
      //   if (_passwordController.text.isEmpty) {
      //     showCustomSnackBar(
      //         ValidationMessages.getMessage(context, 'passwordEmpty'));
      //     return false;
      //   }
      //   if (_passwordController.text.length < 6) {
      //     showCustomSnackBar(
      //         ValidationMessages.getMessage(context, 'passwordMinLength'));
      //     return false;
      //   }
      //   return true;
      case 3:
        if (_location.name.isEmpty) {
          showCustomSnackBar(AppLocalizations.of(context)!.selectLocation);
          return false;
        }
        return true;
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
        SnackBar(
            content: Text(AppLocalizations.of(context)!.fillRequiredFields)),
      );
      return;
    }

    if (_location.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectLocation)),
      );
      return;
    }

    final cleanedLocationName = cleanLocationName(_location.name);
    final locationDetails = parseLocationName(_location.name);

    context.read<AuthBloc>().add(
          RegisterUserDataSubmitted(
            nikeName: _nikeNameController.text,
            phoneNumber: _phoneNumberController.text,
            password: _passwordController.text,
            isGrantedForPreciseLocation:
                _locationSharingPreference == LocationSharingMode.precise,
            locationName: cleanedLocationName, // Use the cleaned location name
            latitude: _location.coordinates.latitude,
            longitude: _location.coordinates.longitude,
            userType: _userType,
            county: locationDetails['county'],
            city: locationDetails['city'],
            state: locationDetails['state'],
            country: locationDetails['country'],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        _previousPage();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              icon: HugeIcon(
                                icon: EvaIcons.arrowIosBack,
                                color: Theme.of(context).colorScheme.secondary,
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
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary,
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
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  EvaIcons.infoOutline,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                          child: _buildPageViewBody(),
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
                                    : _currentPage == _totalPages - 1
                                        ? _submitRegistration
                                        : _nextPage,
                                style: ElevatedButton.styleFrom(
                                  shape: SmoothRectangleBorder(
                                      smoothness: 0.8,
                                      borderRadius: BorderRadius.circular(16)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: AppColors.primary,
                                ),
                                child: state is AuthLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      )
                                    : Text(
                                        _currentPage < 3
                                            ? localizations.continuee
                                            : localizations.submit,
                                        style: TextStyle(
                                          fontFamily: Constants.Arial,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
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

  // Updated _buildPageViewBody method with improved options section
  Widget _buildPageViewBody() {
    final localizations = AppLocalizations.of(context)!;
    final List<PageData> pages = [
      PageData(
        title: localizations.whatCanWeCallYou,
        subtitle: localizations.enterYourName,
        content: AuthTextField(
          controller: _nikeNameController,
          labelText: localizations.exampleNames,
          validator: (value) => AuthValidators.validateName(context, value),
        ),
      ),
      PageData(
        title: localizations.whatAreYouLookingFor,
        subtitle: localizations.selectPreference,
        content: Column(
          children: List.generate(
            options.length,
            (index) {
              return Column(
                children: [
                  OptionCard(
                    isSelected: _selectedOption == index,
                    title: options[index]['title']!,
                    description: options[index]['description']!,
                    onTap: () {
                      setState(() {
                        _selectedOption = index;
                      });
                    },
                  ),
                  if (index < options.length - 1) const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
      PageData(
        title: localizations.yourPhoneNumber,
        subtitle: localizations.enterPhoneNumberPrompt,
        content: AuthTextField(
          controller: _phoneNumberController,
          labelText: localizations.phoneNumber,
          keyboardType: TextInputType.phone,
          validator: (value) =>
              AuthValidators.validatePhoneNumber(context, value),
        ),
      ),
      // PageData(
      //   title: localizations.secureYourAccount,
      //   subtitle: localizations.createStrongPassword,
      //   content: AuthTextField(
      //     controller: _passwordController,
      //     labelText: localizations.password,
      //     obscureText: true,
      //     validator: (value) => AuthValidators.validatePassword(context, value),
      //   ),
      // ),
      PageData(
        title: localizations.selectLocation,
        subtitle: localizations.tapToSelectLocation,
        content: LocationSelectorWidget(
          selectedLocation: _location,
          locationSharingMode: _locationSharingPreference,
          onLocationSharingModeChanged: (mode) {
            setState(() {
              _locationSharingPreference = mode;
            });
          },
          onOpenMap: _showLocationPicker,
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: Constants.Arial,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }

  Future<void> _showLocationPicker() async {
    final localizations = AppLocalizations.of(context)!;
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
      _showCustomSnackBar(localizations.noLocationSelected,
          icon: Icons.location_off);
    }
  }

  void _showCustomSnackBar(String message, {IconData? icon}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final snackBarBackgroundColor =
        isDarkMode ? Colors.grey[900] : Colors.white;
    final snackBarTextColor = isDarkMode ? Colors.white : Colors.black;
    final snackBarIconColor = isDarkMode ? Colors.red[300] : Colors.red[700];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: snackBarIconColor, size: 24),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: snackBarTextColor, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: snackBarBackgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        shape: SmoothRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDarkMode ? Colors.blueGrey : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: Duration(seconds: 3),
      ),
    );
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

String cleanLocationName(String locationName) {
  // List of unwanted keywords or phrases to remove
  final unwantedKeywords = ['county:', 'state:', 'country:', 'city:'];

  // Remove unwanted keywords from the location name
  for (final keyword in unwantedKeywords) {
    locationName = locationName.replaceAll(keyword, '').trim();
  }

  // Remove extra spaces and commas
  locationName = locationName.replaceAll(RegExp(r'\s+'), ' ').trim();
  locationName = locationName.replaceAll(RegExp(r',+'), ',').trim();

  return locationName;
}

Map<String, String?> parseLocationName(String locationName) {
  // Initialize the result map with null values
  Map<String, String?> result = {
    'county': null,
    'city': null,
    'state': null,
    'country': null,
  };

  print("🔍 Starting to parse location: '$locationName'");

  // If locationName is empty, return the map with null values
  if (locationName.isEmpty) {
    print("⚠️ Location name is empty!");
    return result;
  }

  // Split the location name by commas and trim whitespace
  final parts = locationName.split(',').map((part) => part.trim()).toList();
  print("📋 Split parts: $parts");

  // Check each part for key identifiers
  for (int i = 0; i < parts.length; i++) {
    String part = parts[i];
    if (part.isEmpty) {
      print("⚠️ Part $i is empty, skipping");
      continue;
    }

    print("🔎 Checking part [$i]: '$part'");

    // Look for key identifiers in each part
    if (part.toLowerCase().contains('county:')) {
      final value = part
          .substring(part.toLowerCase().indexOf('county:') + 'county:'.length)
          .trim();
      print("🏡 Found county: '$value'");
      if (value.isNotEmpty) result['county'] = value;
    } else if (part.toLowerCase().contains('city:')) {
      final value = part
          .substring(part.toLowerCase().indexOf('city:') + 'city:'.length)
          .trim();
      print("🏙️ Found city: '$value'");
      if (value.isNotEmpty) result['city'] = value;
    } else if (part.toLowerCase().contains('state:')) {
      final value = part
          .substring(part.toLowerCase().indexOf('state:') + 'state:'.length)
          .trim();
      print("🏛️ Found state: '$value'");
      if (value.isNotEmpty) result['state'] = value;
    } else if (part.toLowerCase().contains('country:')) {
      final value = part
          .substring(part.toLowerCase().indexOf('country:') + 'country:'.length)
          .trim();
      print("🌎 Found country: '$value'");
      if (value.isNotEmpty) result['country'] = value;
    } else {
      print("❓ No identifier found in part [$i]: '$part'");
    }
  }

  print("✅ Final parsed result: $result");
  return result;
}
