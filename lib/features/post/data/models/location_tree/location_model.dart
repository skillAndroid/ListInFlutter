import 'package:hive/hive.dart';
part 'location_model.g.dart';

@HiveType(typeId: 5)
class County {
  @HiveField(0)
  String? value;
  @HiveField(1)
  String? valueUz;
  @HiveField(2)
  String? valueRu;

  County({this.value, this.valueUz, this.valueRu});

  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      value: json['value'],
      valueUz: json['valueUz'],
      valueRu: json['valueRu'],
    );
  }
}

@HiveType(typeId: 4)
class State {
  @HiveField(0)
  String? value;
  @HiveField(1)
  String? valueUz;
  @HiveField(2)
  String? valueRu;
  @HiveField(3)
  List<County>? counties;

  State({this.value, this.valueUz, this.valueRu, this.counties});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      value: json['value'],
      valueUz: json['valueUz'],
      valueRu: json['valueRu'],
      counties: (json['counties'] as List?)
          ?.map((e) => County.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

@HiveType(typeId: 3)
class Country {
  @HiveField(0)
  String? value;
  @HiveField(1)
  String? valueUz;
  @HiveField(2)
  String? valueRu;
  @HiveField(3)
  List<State>? states;

  Country({this.value, this.valueUz, this.valueRu, this.states});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      value: json['value'],
      valueUz: json['valueUz'],
      valueRu: json['valueRu'],
      states: (json['states'] as List?)
          ?.map((e) => State.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}