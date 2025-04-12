// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:list_in/features/details/presentation/widgets/custom_location_header.dart';
import 'package:url_launcher/url_launcher.dart';

class FullScreenMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const FullScreenMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  Future<void> _openInMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56),
          child: CustomLocationHeader(
            locationName: locationName,
            onBackPressed: () => Navigator.pop(context),
            onMapsPressed: _openInMaps,
            elevation: 2,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          )),
      body: GoogleMap(
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 18,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: locationName),
          ),
        },
      ),
    );
  }
}
