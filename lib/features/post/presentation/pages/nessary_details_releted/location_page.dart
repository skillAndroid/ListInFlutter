import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/map/map.dart';
import 'package:list_in/features/map/presentation/widgets/map_direction_handler.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your current location',
              style: TextStyle(
                fontFamily: "Syne",
                color: AppColors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            const Text(
              'This screen shows your current location according to your profile data. If you make change this will result to your profile data also!',
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
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
                            onPressed: () => provider.setLocationSharingMode(
                                LocationSharingMode.precise),
                            icon: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Exact Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: Constants.Arial,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: SmoothRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              shadowColor: AppColors.transparent,
                              backgroundColor: provider.locationSharingMode ==
                                      LocationSharingMode.precise
                                  ? AppColors.black
                                  : Colors.grey.shade200,
                              foregroundColor: provider.locationSharingMode ==
                                      LocationSharingMode.precise
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 50,
                          width: 150,
                          child: ElevatedButton.icon(
                            onPressed: () => provider.setLocationSharingMode(
                                LocationSharingMode.region),
                            icon: const Icon(
                              Icons.location_city,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Region Only',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: Constants.Arial,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shadowColor: AppColors.transparent,
                              shape: SmoothRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              backgroundColor: provider.locationSharingMode ==
                                      LocationSharingMode.region
                                  ? AppColors.black
                                  : Colors.grey.shade200,
                              foregroundColor: provider.locationSharingMode ==
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
                      provider.locationSharingMode ==
                              LocationSharingMode.precise
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
                  side:
                      const BorderSide(color: AppColors.transparent, width: 0),
                  foregroundColor: AppColors.black,
                  backgroundColor: AppColors.containerColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _showLocationPicker(context, provider),
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
                      'Change Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (provider.location.name.isNotEmpty) _buildMapPreview(provider),
          ],
        );
      },
    );
  }

  Widget _buildMapPreview(PostProvider provider) {
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
                            key: ValueKey(provider.location.coordinates),
                            liteModeEnabled: true,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                provider.location.coordinates.latitude,
                                provider.location.coordinates.longitude,
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
                            provider.location.name,
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
                                provider.location.coordinates.latitude,
                                provider.location.coordinates.longitude,
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

  Future<void> _showLocationPicker(
      BuildContext context, PostProvider provider) async {
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
      provider.setLocation(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location updated to: ${result.name}")),
      );
    }
  }
}
