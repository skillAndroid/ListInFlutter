// ignore: must_be_immutable
// ignore_for_file: deprecated_member_use, invalid_return_type_for_catch_error

import 'dart:async';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/theme/provider/theme_provider.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/map/presentation/bloc/MapState.dart';
import 'package:list_in/features/map/presentation/widgets/marker.dart';
import 'package:list_in/features/map/presentation/widgets/search_text_field.dart';
import 'package:list_in/features/map/presentation/widgets/show_custom_sheet.dart';
import 'package:list_in/features/map/service/AppLocation.dart';

// ignore: must_be_immutable
class ListInMap extends StatefulWidget {
  LatLng? coordinates;
  ListInMap({
    super.key,
    this.coordinates,
  });

  @override
  State<ListInMap> createState() => _ListInMapState();
}

class _ListInMapState extends State<ListInMap> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  late final CameraPosition _initialCameraPosition;

  static const LatLng _defaultLocation = LatLng(41.312128, 69.241796);
  // Dark mode map style JSON string
  // Enhanced dark mode map style JSON string with better contrast for buildings

  // Enhanced dark mode map style with highly contrasted buildings
  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  ''';

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Get the current theme state from the ThemeBloc
    final themeState = context.read<ThemeBloc>().state;
    final isDarkMode =
        themeState is ThemeLoaded ? themeState.isDarkMode : false;

    // Apply dark style if in dark mode
    if (isDarkMode) {
      _mapController!.setMapStyle(_darkMapStyle);
    }

    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
  }

  Future<void> _moveToLocation(LatLng location, double zoom) async {
    try {
      final controller = await _controllerCompleter.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: zoom,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error moving camera: $e');
    }
  }

  String _currentLocationName = "Select Location";
  late CoordinatesEntity _selectedLocationCoordinates;
  // ignore: unused_field
  late LocationEntity _currentSelectedLocation;

  @override
  void initState() {
    super.initState();
    final initialLocation = widget.coordinates ?? _defaultLocation;
    _initialCameraPosition = CameraPosition(
      target: initialLocation,
      zoom: 20,
    );

    _selectedLocationCoordinates = CoordinatesEntity(
      latitude: initialLocation.latitude,
      longitude: initialLocation.longitude,
    );
    _initPermission().ignore();
  }

  Widget _buildTopGradient() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
            Theme.of(context).scaffoldBackgroundColor.withAlpha(1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    final localizations = AppLocalizations.of(context)!;
    return ElevatedButton(
      onPressed: () => _showCustomBottomSheet(_currentLocationName),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 36),
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        elevation: 0,
      ).copyWith(elevation: WidgetStateProperty.all(0)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 4),
          Image.asset(
            AppIcons.searchIcon,
            color: Theme.of(context).colorScheme.secondary,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 10),
          Text(
            localizations.search,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: Constants.Arial,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _initialCameraPosition,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      onCameraMove: (position) {
                        context.read<MapBloc>().onCameraMove();
                      },
                      onCameraIdle: () async {
                        final LatLng position = await _mapController!.getLatLng(
                          ScreenCoordinate(
                            x: MediaQuery.of(context).size.width ~/ 2,
                            y: MediaQuery.of(context).size.height ~/ 2,
                          ),
                        );

                        context.read<MapBloc>().onCameraIdle(position);
                      },
                    ),
                    const Center(
                      child: AnimatedLocationMarker(),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 8,
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 4,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        onPressed: () {
                          _fetchCurrentLocation();
                        },
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: Image.asset(
                            AppIcons.geoLocationIc,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 8,
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 4,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        onPressed: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              _buildLocationDetailsCard(),
            ],
          ),
          _buildTopGradient(),
          _buildSearchButtonContainer(),
        ],
      ),
    );
  }

  Widget _buildLocationDetailsCard() {
    final localizations = AppLocalizations.of(context)!;
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = false;
        if (state is MapIdleState) {
          _currentLocationName =
              state.locationName ?? localizations.selectLocation;
          _selectedLocationCoordinates = CoordinatesEntity(
            latitude: state.center.latitude,
            longitude: state.center.longitude,
          );
        } else if (state is MapLoadingState) {
          isLoading = true;
        } else if (state is MapErrorState) {}
        return SizedBox(
          height: 185,
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.selectLocation,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation05,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  textAlign: TextAlign.start,
                                  isLoading
                                      ? localizations.loading
                                      : cleanLocationName(_currentLocationName),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentLocationName !=
                            localizations.selectLocation) {
                          final selectedLocation = LocationEntity(
                            name: _currentLocationName,
                            coordinates: _selectedLocationCoordinates,
                          );
                          setState(() {
                            _currentSelectedLocation = selectedLocation;
                          });
                          Navigator.of(context).pop(selectedLocation);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.selectLocationFirst),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 16,
                            cornerSmoothing: 1,
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                      ).copyWith(
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: Text(
                        key: ValueKey('text'),
                        localizations.ready,
                        style: TextStyle(
                          fontFamily: Constants.Arial,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButtonContainer() {
    return SizedBox(
      height: 72,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildSearchButton()],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final location = await LocationService().getCurrentLocation().catchError(
        (_) =>
            const LatLng(41.312128, 69.241796)); // Changed to Tashkent default

    _moveToLocation(LatLng(location.lat, location.long), 20);
  }

  void _showCustomBottomSheet(String locationName) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.95;
    final searchController = TextEditingController();

    showCustomModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final localizations = AppLocalizations.of(context)!;
          return Container(
            width: double.infinity,
            height: bottomSheetHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                ),
                Card(
                  elevation: 8,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shadowColor: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.2),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 12, right: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                locationName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        endIndent: 16,
                        indent: 16,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: SearchTextField(
                          controller: searchController,
                          labelText: localizations.enterYourLocation,
                          onChanged: (query) {
                            if (query.length >= 3) {
                              context.read<MapBloc>().searchLocations(query);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    if (state is MapLoadingState) {
                      return Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: Transform.scale(
                            scale: 0.7,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.secondary,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                      );
                    }
                    if (state is MapSearchResultsState &&
                        state.locations.isNotEmpty) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: state.locations.length,
                          itemBuilder: (context, index) {
                            final location = state.locations[index];
                            return InkWell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        location.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                searchController.clear();
                                await _moveToLocation(
                                  LatLng(
                                    location.coordinates.latitude,
                                    location.coordinates.longitude,
                                  ),
                                  20,
                                );
                                setState(() {
                                  _currentLocationName = location.name;
                                  _selectedLocationCoordinates =
                                      location.coordinates;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
