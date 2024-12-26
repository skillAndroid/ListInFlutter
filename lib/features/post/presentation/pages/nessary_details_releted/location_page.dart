import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/map/map.dart';
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
            const Text(
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
              'This screen shows your current location according to your profile data. You can make temporary changes for this post, or update your profile location permanently through your profile settings.',
              style: TextStyle(
                color: AppColors.darkGray,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 8,
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
                            icon: const Icon(Icons.location_on),
                            label: const Text(
                              'Exact Location',
                              style: TextStyle(
                                  fontSize: 15, fontFamily: "Poppins"),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: AppColors.transparent,
                              backgroundColor: provider.locationSharingMode ==
                                      LocationSharingMode.precise
                                  ? AppColors.black
                                  : Colors.grey.shade300,
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
                            icon: const Icon(Icons.location_city),
                            label: const Text(
                              'Region Only',
                              style: TextStyle(
                                  fontSize: 15, fontFamily: "Poppins"),
                            ),
                            style: ElevatedButton.styleFrom(
                              shadowColor: AppColors.transparent,
                              elevation: 0,
                              backgroundColor: provider.locationSharingMode ==
                                      LocationSharingMode.region
                                  ? AppColors.black
                                  : Colors.grey.shade300,
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
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: AppColors.transparent, width: 0),
                  foregroundColor: AppColors.black,
                  backgroundColor: AppColors.bgColor,
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
                    Icon(Icons.map_outlined, size: 24),
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
            const SizedBox(height: 12),
            if (provider.location.name.isNotEmpty) _buildMapPreview(provider),
          ],
        );
      },
    );
  }

  Widget _buildMapPreview(PostProvider provider) {
    return Column(
      children: [
        SmoothClipRRect(
          smoothness: 1,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: GoogleMap(
              key: ValueKey(provider.location.coordinates),
              liteModeEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  provider.location.coordinates.latitude,
                  provider.location.coordinates.longitude,
                ),
                zoom: 11,
              ),
              markers: {
                Marker(
                  alpha: 1,
                  rotation: 0.5,
                  markerId: const MarkerId('selected_location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                  position: LatLng(
                    provider.location.coordinates.latitude,
                    provider.location.coordinates.longitude,
                  ),
                  infoWindow: InfoWindow(title: provider.location.name),
                ),
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            provider.location.name,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }

  Future<void> _showLocationPicker(
      BuildContext context, PostProvider provider) async {
    final result = await showModalBottomSheet<LocationEntity>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) => const FractionallySizedBox(
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
