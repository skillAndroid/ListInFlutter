import 'package:flutter/material.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/presentation/map/map.dart';

class LocationPickerModal extends StatelessWidget {
  final Function(LocationEntity) onLocationSelected;

  const LocationPickerModal({
    super.key,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 1.0,
      child: Scaffold(
        body: ListInMap(),
      ),
    );
  }
}
