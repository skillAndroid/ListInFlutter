import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/map/presentation/bloc/MapState.dart';
import 'package:list_in/features/map/presentation/widgets/marker.dart';
import 'package:list_in/features/map/presentation/widgets/show_custom_sheet.dart';
import 'package:list_in/features/map/service/AppLocation.dart';
import 'package:list_in/features/map/service/models.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late YandexMapController _mapController;
  final mapControllerCompleter = Completer<YandexMapController>();
  bool _isCameraMoving = false;
  // Correct types for Yandex Map
  late Point _currentCenter;
  late String _currentLocationName;

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
    _currentCenter = const Point(latitude: 37.7749, longitude: -122.4194);
    _currentLocationName = "Select Location";
  }

  void _showCustomBottomSheet() {
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.bgColor,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (query) {
                    if (query.length >= 3) {
                      context.read<MapBloc>().searchLocations(query);
                    }
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    if (state is MapLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MapSearchResultsState) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: state.locations.length,
                          itemBuilder: (context, index) {
                            final location = state.locations[index];
                            return ListTile(
                              title: Text(location.name),
                              subtitle: Text(location.name),
                              onTap: () {
                                searchController.clear();
                                _moveToCurrentLocation(
                                  AppLatLong(
                                    lat: location.coordinates.latitude,
                                    long: location.coordinates.longitude,
                                  ),
                                  16,
                                );
                                context
                                    .read<MapBloc>()
                                    .navigateToLocation(location);
                                Navigator.pop(context);
                                _mapController;
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
      containerWidget: (content) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: content,
        ),
      ),
    );
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
      onPressed: () => _showCustomBottomSheet(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(110, 36),
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.primary.withOpacity(0.05),
        shape: SmoothRectangleBorder(
          smoothness: 1,
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        elevation: 0,
      ).copyWith(elevation: WidgetStateProperty.all(0)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapIdleState) {
          _currentCenter = state.center;
          _currentLocationName = state.locationName ?? "Select Location";
        }

        return Scaffold(
          backgroundColor: AppColors.littleGreen2,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        YandexMap(
                          onMapCreated:
                              (YandexMapController yandexMapController) {
                            mapControllerCompleter
                                .complete(yandexMapController);
                            _mapController = yandexMapController;
                          },
                          onCameraPositionChanged: (
                            CameraPosition cameraPosition,
                            CameraUpdateReason reason,
                            bool finished,
                          ) {
                            // _handleCameraPositionChanged(
                            //     cameraPosition, finished);
                          },
                        ),
                        Center(
                          child: AnimatedLocationMarker(
                            isMoving: state is MapMovingState,
                            locationNameRetrieved: state is! MapLoadingState,
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          child: FloatingActionButton(
                            onPressed: () {
                              _fetchCurrentLocation();
                            },
                            child: const Icon(Icons.data_saver_on),
                          ),
                        )
                      ],
                    ),
                  ),
                  _buildLocationDetailsCard(_currentLocationName),
                ],
              ),
              _buildTopGradient(),
              _buildSearchButtonContainer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationDetailsCard(String locationName) {
    return BlocBuilder<MapBloc, MapState>(builder: (context, state) {
      final isLoading = state is MapLoadingState;
      return SizedBox(
        height: 175,
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
                                isLoading ? "Loading..." : locationName,
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
                    onPressed: state is! MapLoadingState
                        ? () async {
                            final currentPosition =
                                await _mapController.getCameraPosition();
                            _currentCenter = currentPosition.target;

                            // Inform the Bloc that the camera is idle
                            context
                                .read<MapBloc>()
                                .onCameraIdle(_currentCenter);
                          }
                        : null, // Disable button when loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                    ).copyWith(
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: state is MapLoadingState
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
                ),
              ],
            ),
          ),
        ),
      );
    });
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

    _moveToCurrentLocation(location, 12);
  }

  Future<void> _moveToCurrentLocation(
    AppLatLong appLatLong,
    double zoom,
  ) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: zoom,
        ),
      ),
    );
  }

  void _handleCameraPositionChanged(
      CameraPosition cameraPosition, bool isFinished) {
    if (isFinished) {
      _onCameraIdle();
    } else if (!_isCameraMoving) {
      _onCameraMoveStarted();
    }
  }

  void _onCameraMoveStarted() {
    _isCameraMoving = true;
    context.read<MapBloc>().onCameraMove();
  }

  Future<void> _onCameraIdle() async {
    if (!_isCameraMoving) return; // Prevent duplicate idle calls
    _isCameraMoving = false;

    final currentPosition = await _mapController.getCameraPosition();
    _currentCenter = currentPosition.target;

    // Inform the Bloc that the camera is idle
    context.read<MapBloc>().onCameraIdle(_currentCenter);
  }
}
//