import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/widgets/map_direction_handler.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class LocationSelectorWidget extends StatefulWidget {
  final LocationEntity? selectedLocation;
  final LocationSharingMode locationSharingMode;
  final Function(LocationSharingMode) onLocationSharingModeChanged;
  final Function() onOpenMap;
  final Function(LocationEntity) onLocationSelected;

  const LocationSelectorWidget({
    super.key,
    this.selectedLocation,
    required this.locationSharingMode,
    required this.onLocationSharingModeChanged,
    required this.onOpenMap,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectorWidget> createState() => _LocationSelectorWidgetState();
}

class _LocationSelectorWidgetState extends State<LocationSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: AppColors.containerColor,
          shape: SmoothRectangleBorder(
            smoothness: 1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onLocationSharingModeChanged(
                            LocationSharingMode.precise),
                        icon: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Exact Location',
                          style: TextStyle(fontSize: 15, fontFamily: "Poppins"),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: SmoothRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          shadowColor: AppColors.transparent,
                          backgroundColor: widget.locationSharingMode ==
                                  LocationSharingMode.precise
                              ? AppColors.black
                              : Colors.grey.shade200,
                          foregroundColor: widget.locationSharingMode ==
                                  LocationSharingMode.precise
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
                        onPressed: () => widget.onLocationSharingModeChanged(
                            LocationSharingMode.region),
                        icon: const Icon(
                          Icons.location_city,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Region Only',
                          style: TextStyle(fontSize: 15, fontFamily: "Poppins"),
                        ),
                        style: ElevatedButton.styleFrom(
                          shadowColor: AppColors.transparent,
                          shape: SmoothRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          backgroundColor: widget.locationSharingMode ==
                                  LocationSharingMode.region
                              ? AppColors.black
                              : Colors.grey.shade200,
                          foregroundColor: widget.locationSharingMode ==
                                  LocationSharingMode.region
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.locationSharingMode == LocationSharingMode.precise
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
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.transparent, width: 0),
              foregroundColor: AppColors.black,
              backgroundColor: AppColors.containerColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: SmoothRectangleBorder(
                smoothness: 1,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: widget.onOpenMap,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.map,
                  size: 24,
                  color: AppColors.black,
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
        if (widget.selectedLocation?.name.isNotEmpty == true)
          _buildSelectedLocationCard(context),
      ],
    );
  }

  Widget _buildSelectedLocationCard(BuildContext context) {
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: AppColors.containerColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmoothClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 140,
                      height: 100,
                      child: Stack(
                        children: [
                          GoogleMap(
                            key: ValueKey(widget.selectedLocation!.coordinates),
                            liteModeEnabled: true,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.selectedLocation!.coordinates.latitude,
                                widget.selectedLocation!.coordinates.longitude,
                              ),
                              zoom: 11,
                            ),
                          ),
                          const Positioned(
                            top: 32,
                            left: 0,
                            right: 0,
                            child: Icon(
                              Ionicons.location,
                              color: AppColors.error,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.translate(
                    offset: Offset(0, 8),
                    child: Icon(
                      Ionicons.location,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            widget.selectedLocation!.name,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SmoothClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () {
                              MapDirectionsHandler.openDirections(
                                widget.selectedLocation!.coordinates.latitude,
                                widget.selectedLocation!.coordinates.longitude,
                              ).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open maps. Please check if you have Google Maps installed or try again later.',
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              color: AppColors.white,
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 4, bottom: 4, left: 8, right: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.location_fill,
                                      size: 17,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Get Direction',
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
