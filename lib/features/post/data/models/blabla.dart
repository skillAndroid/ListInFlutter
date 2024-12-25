class AttributeRequestValue {
  final String attributeId;
  final List<String> attributeValueIds;

  AttributeRequestValue({
    required this.attributeId,
    required this.attributeValueIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'attributeId': attributeId,
      'attributeValueIds': attributeValueIds,
    };
  }
}
