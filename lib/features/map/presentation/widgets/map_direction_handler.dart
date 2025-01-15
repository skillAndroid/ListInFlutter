import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapDirectionsHandler {
  static Future<void> openDirections(
      double destinationLat, double destinationLng) async {
    // Check if Google Maps is installed
    final Uri googleMapsUrl =
        Uri.parse('google.navigation:q=$destinationLat,$destinationLng&mode=d');

    // Fallback URL for web browser
    final Uri webUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng');

    try {
      // Try to launch Google Maps app first
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      }
      // If Google Maps app is not installed, open in browser
      else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
 
      debugPrint('Error launching maps: $e');
      
    }
  }
}
