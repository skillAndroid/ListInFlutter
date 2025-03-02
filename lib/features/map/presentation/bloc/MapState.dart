import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';

abstract class MapState {}

class MapIdleState extends MapState {
  final LatLng center;
  final String? locationName;
  MapIdleState(this.center, {this.locationName});
}

class MapMovingState extends MapState {}

class MapLoadingState extends MapState {}

class MapErrorState extends MapState {
  final String message;
  MapErrorState(this.message);
}

class MapSearchResultsState extends MapState {
  final List<LocationEntity> locations;
  MapSearchResultsState(this.locations);
}

class MapLocationConfirmedState extends MapState {}
