import 'package:hive/hive.dart';
part 'sub_model.g.dart';

@HiveType(typeId: 4)
class SubModel {
  @HiveField(0)
  String? modelId;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? nameUz;
  @HiveField(3)
  String? nameRu;
  @HiveField(4)
  String? attributeId;
  SubModel(
      {this.modelId, this.name, this.nameUz, this.nameRu, this.attributeId});
  factory SubModel.fromJson(Map<String, dynamic> json) {
    return SubModel(
      modelId: json['modelId'],
      name: json['name'],
      nameUz: json['nameUz'],
      nameRu: json['nameRu'],
      attributeId: json['attributeId'],
    );
  }
}
