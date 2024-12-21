




class SubModel {
  String? modelId;
  String? name;
  String? attributeId;
  SubModel({this.modelId, this.name, this.attributeId});
  factory SubModel.fromJson(Map<String, dynamic> json) {
    return SubModel(
      modelId: json['modelId'],
      name: json['name'],
      attributeId: json['attributeId'],
    );
  }
}
