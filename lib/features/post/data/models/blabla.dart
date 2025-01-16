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

  @override
  String toString() {
    return 'AttributeRequestValue(attributeId: $attributeId, attributeValueIds: $attributeValueIds)';
  }
}
