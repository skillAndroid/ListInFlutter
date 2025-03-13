import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'location_model.g.dart'; // Make sure this file is generated

@HiveType(typeId: 8)
class County {
  @HiveField(0)
  String? value;
  @HiveField(1)
  String? valueUz;
  @HiveField(2)
  String? valueRu;
  @HiveField(3)
  String? countyId;

  County({this.value, this.valueUz, this.valueRu, this.countyId});

  factory County.fromJson(Map<String, dynamic> json) {
    try {
      return County(
          value: json['value'] as String?,
          valueUz: json['valueUz'] as String?,
          valueRu: json['valueRu'] as String?,
          countyId: json['countyId'] as String?);
    } catch (e) {
      debugPrint("Error parsing County from JSON: $e");
      debugPrint("JSON: $json");
      rethrow;
    }
  }
}

@HiveType(typeId: 7)
class State {
  @HiveField(0)
  String? value;
  @HiveField(1)
  String? valueUz;
  @HiveField(2)
  String? valueRu;
  @HiveField(3)
  String? stateId;
  @HiveField(4)
  List<County>? counties;

  State({
    this.value,
    this.valueUz,
    this.valueRu,
    this.stateId,
    this.counties,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    try {
      List<County>? countiesList;

      if (json.containsKey('counties')) {
        final countiesData = json['counties'];
        if (countiesData is List) {
          countiesList = countiesData
              .map((e) => County.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint("Warning: 'counties' is not a List: ${json['counties']}");
          countiesList = [];
        }
      }

      return State(
        value: json['value'] as String?,
        valueUz: json['valueUz'] as String?,
        valueRu: json['valueRu'] as String?,
        stateId: json['stateId'] as String?,
        counties: countiesList ?? [],
      );
    } catch (e) {
      debugPrint("Error parsing State from JSON: $e");
      debugPrint("JSON: $json");
      rethrow;
    }
  }
}

@HiveType(typeId: 6)
class Country {
  @HiveField(0)
  String? value;
  @HiveField(1)
  String? valueUz;
  @HiveField(2)
  String? valueRu;
  @HiveField(3)
  String? countryId;
  @HiveField(4)
  List<State>? states;

  Country({
    this.value,
    this.valueUz,
    this.valueRu,
    this.countryId,
    this.states,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    try {
      List<State>? statesList;

      if (json.containsKey('states')) {
        final statesData = json['states'];
        if (statesData is List) {
          statesList = statesData
              .map((e) => State.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          debugPrint("Warning: 'states' is not a List: ${json['states']}");
          statesList = [];
        }
      }

      return Country(
        value: json['value'] as String?,
        valueUz: json['valueUz'] as String?,
        valueRu: json['valueRu'] as String?,
        countryId: json['countryId'] as String?,
        states: statesList ?? [],
      );
    } catch (e) {
      debugPrint("Error parsing Country from JSON: $e");
      debugPrint("JSON: $json");
      rethrow;
    }
  }
}
