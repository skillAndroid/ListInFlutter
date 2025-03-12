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

class NumericRequestValue {
  final String numericFieldId;
  final String numericValue;

  NumericRequestValue({
    required this.numericFieldId,
    required this.numericValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'numericFieldId': numericFieldId,
      'numericValue': numericValue,
    };
  }
}
