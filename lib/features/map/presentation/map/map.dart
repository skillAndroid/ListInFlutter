// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/map/presentation/bloc/MapState.dart';
import 'package:list_in/features/map/presentation/widgets/marker.dart';
import 'package:list_in/features/map/presentation/widgets/search_text_field.dart';
import 'package:list_in/features/map/presentation/widgets/show_custom_sheet.dart';
import 'package:list_in/features/map/service/AppLocation.dart';
import 'package:list_in/features/map/service/models.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ListInMap extends StatefulWidget {
  const ListInMap({super.key});

  @override
  State<ListInMap> createState() => _ListInMapState();
}

class _ListInMapState extends State<ListInMap> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(55.755826, 37.617300), // Default to Moscow
    zoom: 20,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _controllerCompleter.complete(controller);
  }

  void _moveToLocation(LatLng location, double zoom) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        ),
      ),
    );
  }

  String _currentLocationName = "Select Location";
  CoordinatesEntity _selectedLocationCoordinates =
      const CoordinatesEntity(latitude: 55.755826, longitude: 37.617300);

  late LocationEntity _currentSelectedLocation;

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  Widget _buildTopGradient() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.white.withOpacity(0.8),
            AppColors.white.withOpacity(0.6),
            AppColors.white.withOpacity(0.4),
            AppColors.white.withOpacity(0.2),
            AppColors.white.withAlpha(1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: () => _showCustomBottomSheet(_currentLocationName),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 36),
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.primary.withOpacity(0.05),
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.black.withOpacity(0.2),
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
            color: Colors.black,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 10),
          const Text(
            'Search',
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.littleGreen2,
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
                        shape: SmoothRectangleBorder(
                            smoothness: 1,
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 4,
                        backgroundColor: AppColors.white,
                        onPressed: () {
                          _fetchCurrentLocation();
                        },
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: Image.asset(
                            AppIcons.geoLocationIc,
                            color: AppColors.myRedBrown,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 8,
                      child: FloatingActionButton(
                        shape: SmoothRectangleBorder(
                            smoothness: 1,
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 4,
                        backgroundColor: AppColors.white,
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_outlined,
                          color: AppColors.black,
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
          _currentLocationName = state.locationName ?? "Select Location";
          _selectedLocationCoordinates = CoordinatesEntity(
            latitude: state.center.latitude,
            longitude: state.center.longitude,
          );
        } else if (state is MapLoadingState) {
          isLoading = true;
        } else if (state is MapErrorState) {}
        return SizedBox(
          height: 183,
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            color: AppColors.white,
            shape: SmoothRectangleBorder(
              smoothness: 0.8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            elevation: 8,
            shadowColor: AppColors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(
                    color: AppColors.bgColor,
                    thickness: 1,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment:
                              MainAxisAlignment.start, // Add this line
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  textAlign: TextAlign.start,
                                  isLoading
                                      ? "Loading..."
                                      : _currentLocationName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
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
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentLocationName != "Select Location") {
                          final selectedLocation = LocationEntity(
                            name: _currentLocationName,
                            coordinates: _selectedLocationCoordinates,
                          );
                          setState(() {
                            _currentSelectedLocation = selectedLocation;
                          });
                          Navigator.pop(context, _currentSelectedLocation);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                      ).copyWith(
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: const Text(
                        key: ValueKey('text'),
                        "Ready",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
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
    final location = await LocationService()
        .getCurrentLocation()
        .catchError((_) => const MoscowLocation());

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
                    color: AppColors.bgColor,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                ),
                Card(
                  elevation: 8,
                  color: AppColors.white,
                  shadowColor: AppColors.bgColor.withOpacity(0.2),
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
                                color: AppColors.littleGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondaryColor,
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
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        color: AppColors.bgColor,
                        endIndent: 16,
                        indent: 16,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: SearchTextField(
                          controller: searchController,
                          labelText: "Enter your location",
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
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.black,
                            strokeWidth: 2,
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
                                      color: AppColors.green,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        location.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                searchController.clear();
                                _moveToLocation(
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
                                context.pop();
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
//
}
//
