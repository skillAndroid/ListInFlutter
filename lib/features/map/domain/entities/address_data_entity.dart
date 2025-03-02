import 'package:list_in/features/map/data/models/address_data_model.dart';

class AddressDetailsEntity {
  final String combinedAddress;
  final String county;
  final String city;
  final String state;
  final String country;

  AddressDetailsEntity({
    required this.combinedAddress,
    required this.county,
    required this.city,
    required this.state,
    required this.country,
  });
}

extension AddressDetailsModelExtension on AddressDetailsModel {
  AddressDetailsEntity toEntity() {
    return AddressDetailsEntity(
      combinedAddress: combinedAddress,
      county: county,
      city: city,
      state: state,
      country: country,
    );
  }
}
