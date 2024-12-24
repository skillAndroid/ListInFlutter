import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
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

  LocationEntity location = const LocationEntity(
      name: '', coordinates: CoordinatesEntity(latitude: 0, longitude: 0));

  int _currentPage = 0;
  final int _totalPages = 5;
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
  void dispose() {
    _nikeNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
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
      context.pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentPage > 0) {
      _previousPage();
      return false;
    }
    return true;
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
              context.pushReplacement(AppPath.home);
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
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildPage(
                                title: 'What can we call you?',
                                subtitle:
                                    'Please enter your name, company name, or a nickname.',
                                child: AuthTextField(
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
                              _buildPage(
                                title: 'What are you looking for?',
                                subtitle: 'Please select your preference.',
                                child: Column(
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
                                              padding: WidgetStateProperty.all(
                                                EdgeInsets.zero,
                                              ),
                                              elevation:
                                                  WidgetStateProperty.all(
                                                0,
                                              ),
                                            ),
                                            child: Card(
                                              color: _selectedOption == index
                                                  ? AppColors.myRedBrown
                                                      // ignore: deprecated_member_use
                                                      .withOpacity(0.25)
                                                  : AppColors.containerColor,
                                              elevation: 0,
                                              shape: SmoothRectangleBorder(
                                                smoothness: 0.8,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Row(
                                                  children: [
                                                    AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      width: _selectedOption ==
                                                              index
                                                          ? 21
                                                          : 20,
                                                      height: _selectedOption ==
                                                              index
                                                          ? 21
                                                          : 20,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              _selectedOption ==
                                                                      index
                                                                  ? AppColors
                                                                      .black
                                                                  : AppColors
                                                                      .gray,
                                                          width:
                                                              _selectedOption ==
                                                                      index
                                                                  ? 5
                                                                  : 2,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            options[index]
                                                                ['title']!,
                                                            style: TextStyle(
                                                              fontSize: 19,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: _selectedOption ==
                                                                      index
                                                                  ? AppColors
                                                                      .black
                                                                  : AppColors
                                                                      .black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            options[index][
                                                                'description']!,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: _selectedOption ==
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
                                          ),
                                          if (index < options.length - 1)
                                            const SizedBox(height: 8),
                                        ],
                                      );
                                    },
                                  ),
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
                              _buildPage(
                                title: 'Select Your Location',
                                subtitle:
                                    'Tap to select your location on the map.',
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      color: AppColors.bgColor,
                                      shape: SmoothRectangleBorder(
                                        smoothness: 1,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 50,
                                                  width: 150,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      setState(() {
                                                        _locationSharingPreference =
                                                            LocationSharingMode
                                                                .precise;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.location_on,
                                                    ),
                                                    label: const Text(
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              "Poppins"),
                                                      'Exact Location',
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      shadowColor:
                                                          AppColors.transparent,
                                                      backgroundColor:
                                                          _locationSharingPreference ==
                                                                  LocationSharingMode
                                                                      .precise
                                                              ? AppColors.black
                                                              : Colors.grey
                                                                  .shade300,
                                                      foregroundColor:
                                                          _locationSharingPreference ==
                                                                  LocationSharingMode
                                                                      .precise
                                                              ? Colors.white
                                                              : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                SizedBox(
                                                  height: 50,
                                                  width: 150,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      setState(() {
                                                        _locationSharingPreference =
                                                            LocationSharingMode
                                                                .region;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.location_city),
                                                    label: const Text(
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontFamily:
                                                                "Poppins"),
                                                        'Region Only'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shadowColor:
                                                          AppColors.transparent,
                                                      elevation: 0,
                                                      backgroundColor:
                                                          _locationSharingPreference ==
                                                                  LocationSharingMode
                                                                      .region
                                                              ? AppColors.black
                                                              : Colors.grey
                                                                  .shade300,
                                                      foregroundColor:
                                                          _locationSharingPreference ==
                                                                  LocationSharingMode
                                                                      .region
                                                              ? Colors.white
                                                              : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              _locationSharingPreference ==
                                                      LocationSharingMode
                                                          .precise
                                                  ? '• Shares exact coordinates\n• Most accurate for precise services'
                                                  : '• Shares general area\n• Protects specific location details',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),

                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 8),
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppColors.transparent,
                                              width: 0),
                                          foregroundColor: AppColors.black,
                                          backgroundColor: AppColors.bgColor,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: SmoothRectangleBorder(
                                            smoothness: 1,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            enableDrag: false,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) =>
                                                const FractionallySizedBox(
                                              heightFactor: 1.0,
                                              child: Scaffold(
                                                body: LocationSelectionPage(),
                                              ),
                                            ),
                                          ).then((result) {
                                            if (result != null) {
                                              setState(() {
                                                location = result;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "${result.name} ?? ${result.coordinates.latitude} // ${result.coordinates.longitude}"),
                                                  ),
                                                );
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "No Location selected")),
                                              );
                                            }
                                          });
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.map_outlined,
                                              size: 24,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Open Map',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    if (location.name != "")
                                      Column(
                                        children: [
                                          SmoothClipRRect(
                                            smoothness: 1,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 200,
                                              child: GoogleMap(
                                                key: ValueKey(
                                                    location.coordinates),
                                                liteModeEnabled: true,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: LatLng(
                                                    location
                                                        .coordinates.latitude,
                                                    location
                                                        .coordinates.longitude,
                                                  ),
                                                  zoom: 11,
                                                ),
                                                markers: {
                                                  Marker(
                                                    alpha: 1,
                                                    rotation: 0.5,
                                                    markerId: const MarkerId(
                                                      'selected_location',
                                                    ),
                                                    icon: BitmapDescriptor
                                                        .defaultMarkerWithHue(
                                                      BitmapDescriptor
                                                          .hueOrange,
                                                    ), // Preset colors
                                                    position: LatLng(
                                                      location
                                                          .coordinates.latitude,
                                                      location.coordinates
                                                          .longitude,
                                                    ),
                                                    infoWindow: InfoWindow(
                                                        title: location.name),
                                                  ),
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(
                                              8.0,
                                            ),
                                            child: Text(
                                              location.name,
                                              style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                    //
                                  ],
                                ),
                              )
                              //
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
                                    : _currentPage < 4
                                        ? _nextPage
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // Check if location.name is empty or "Select Location"
                                              if (location.name.isEmpty ||
                                                  location.name ==
                                                      "Select Location") {
                                                // Show a Scaffold or Alert to the user to select a location
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please select a valid location.'),
                                                  ),
                                                );
                                                // Optionally, you could navigate to the location selection page
                                                // Navigator.pushNamed(context, '/locationSelection');
                                              } else {
                                                // Proceed with the registration if location is valid
                                                context.read<AuthBloc>().add(
                                                      RegisterUserDataSubmitted(
                                                        nikeName:
                                                            _nikeNameController
                                                                .text,
                                                        phoneNumber:
                                                            _phoneNumberController
                                                                .text,
                                                        password:
                                                            _passwordController
                                                                .text,
                                                        roles:
                                                            'INDIVIDUAL_SELLER',
                                                        isGrantedForPreciseLocation:
                                                            _locationSharingPreference ==
                                                                LocationSharingMode
                                                                    .precise,
                                                        locationName:
                                                            location.name,
                                                        latitude: location
                                                            .coordinates
                                                            .latitude,
                                                        longitude: location
                                                            .coordinates
                                                            .longitude,
                                                      ),
                                                    );
                                              }
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
