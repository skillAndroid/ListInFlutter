// County model
// ignore_for_file: avoid_print

class CountyModel {
  String? value;
  String? valueUz;
  String? valueRu;
  String? countyId;

  CountyModel({
    this.value,
    this.valueUz,
    this.valueRu,
    this.countyId,
  });

  factory CountyModel.fromJson(Map<String, dynamic> json) {
    try {
      return CountyModel(
          value: json['value'] as String?,
          valueUz: json['valueUz'] as String?,
          valueRu: json['valueRu'] as String?,
          countyId: json['countyId'] as String?);
    } catch (e) {
      print("Error parsing CountyModel from JSON: $e");
      print("JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'valueUz': valueUz,
      'valueRu': valueRu,
      'countyId': countyId,
    };
  }
}

// State model
class StateModel {
  String? value;
  String? valueUz;
  String? valueRu;
  String? stateId;

  StateModel({
    this.value,
    this.valueUz,
    this.valueRu,
    this.stateId,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    try {
      return StateModel(
        value: json['value'] as String?,
        valueUz: json['valueUz'] as String?,
        valueRu: json['valueRu'] as String?,
        stateId: json['stateId'] as String?,
      );
    } catch (e) {
      print("Error parsing StateModel from JSON: $e");
      print("JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'valueUz': valueUz,
      'valueRu': valueRu,
      'stateId': stateId,
    };
  }
}

// Country model
class CountryModel {
  String? value;
  String? valueUz;
  String? valueRu;
  String? countryId;

  CountryModel({
    this.value,
    this.valueUz,
    this.valueRu,
    this.countryId,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    try {
      return CountryModel(
        value: json['value'] as String?,
        valueUz: json['valueUz'] as String?,
        valueRu: json['valueRu'] as String?,
        countryId: json['countryId'] as String?,
      );
    } catch (e) {
      print("Error parsing CountryModel from JSON: $e");
      print("JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'valueUz': valueUz,
      'valueRu': valueRu,
      'countryId': countryId,
    };
  }
}
