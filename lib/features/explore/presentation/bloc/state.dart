import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

enum PostCreationStatus { initial, loading, success, error }

class HomeTreeState {
  final List<CategoryModel>? catalogs;
  final CategoryModel? selectedCatalog;
  final ChildCategoryModel? selectedChildCategory;
  final bool isLoading;
  final String? error;
  final List<AttributeModel> currentAttributes;
  final List<AttributeModel> dynamicAttributes;
  final Map<String, dynamic> selectedValues;
  final Map<AttributeModel, bool> attributeOptionsVisibility;
  final Map<AttributeModel, AttributeValueModel> selectedAttributeValues;
  final List<CategoryModel> catalogHistory;
  final List<ChildCategoryModel> childCategoryHistory;
  final Map<String, Map<String, dynamic>> childCategorySelections;
  final Map<String, List<AttributeModel>> childCategoryDynamicAttributes;
  final List<AttributeRequestValue> attributeRequests;
  final PostCreationStatus postCreationState;
  final String? postCreationError;
  final double? priceFrom;
  final double? priceTo;

  HomeTreeState({
    this.catalogs,
    this.selectedCatalog,
    this.selectedChildCategory,
    this.isLoading = false,
    this.error,
    List<AttributeModel>? currentAttributes,
    List<AttributeModel>? dynamicAttributes,
    Map<String, dynamic>? selectedValues,
    Map<AttributeModel, bool>? attributeOptionsVisibility,
    Map<AttributeModel, AttributeValueModel>? selectedAttributeValues,
    List<CategoryModel>? catalogHistory,
    List<ChildCategoryModel>? childCategoryHistory,
    Map<String, Map<String, dynamic>>? childCategorySelections,
    Map<String, List<AttributeModel>>? childCategoryDynamicAttributes,
    List<AttributeRequestValue>? attributeRequests,
    this.postCreationState = PostCreationStatus.initial,
    this.postCreationError,
    this.priceFrom,
    this.priceTo,
  })  : currentAttributes = currentAttributes ?? [],
        dynamicAttributes = dynamicAttributes ?? [],
        selectedValues = selectedValues ?? {},
        attributeOptionsVisibility = attributeOptionsVisibility ?? {},
        selectedAttributeValues = selectedAttributeValues ?? {},
        catalogHistory = catalogHistory ?? [],
        childCategoryHistory = childCategoryHistory ?? [],
        childCategorySelections = childCategorySelections ?? {},
        childCategoryDynamicAttributes = childCategoryDynamicAttributes ?? {},
        attributeRequests = attributeRequests ?? [];

  HomeTreeState copyWith({
    List<CategoryModel>? catalogs,
    CategoryModel? selectedCatalog,
    ChildCategoryModel? selectedChildCategory,
    bool? isLoading,
    String? error,
    List<AttributeModel>? currentAttributes,
    List<AttributeModel>? dynamicAttributes,
    Map<String, dynamic>? selectedValues,
    Map<AttributeModel, bool>? attributeOptionsVisibility,
    Map<AttributeModel, AttributeValueModel>? selectedAttributeValues,
    List<CategoryModel>? catalogHistory,
    List<ChildCategoryModel>? childCategoryHistory,
    Map<String, Map<String, dynamic>>? childCategorySelections,
    Map<String, List<AttributeModel>>? childCategoryDynamicAttributes,
    List<AttributeRequestValue>? attributeRequests,
    PostCreationStatus? postCreationState,
    String? postCreationError,
    double? priceFrom,
    double? priceTo,
  }) {
    return HomeTreeState(
      catalogs: catalogs ?? this.catalogs,
      selectedCatalog: selectedCatalog ?? this.selectedCatalog,
      selectedChildCategory:
          selectedChildCategory ?? this.selectedChildCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentAttributes: currentAttributes ?? this.currentAttributes,
      dynamicAttributes: dynamicAttributes ?? this.dynamicAttributes,
      selectedValues: selectedValues ?? this.selectedValues,
      attributeOptionsVisibility:
          attributeOptionsVisibility ?? this.attributeOptionsVisibility,
      selectedAttributeValues:
          selectedAttributeValues ?? this.selectedAttributeValues,
      catalogHistory: catalogHistory ?? this.catalogHistory,
      childCategoryHistory: childCategoryHistory ?? this.childCategoryHistory,
      childCategorySelections:
          childCategorySelections ?? this.childCategorySelections,
      childCategoryDynamicAttributes:
          childCategoryDynamicAttributes ?? this.childCategoryDynamicAttributes,
      attributeRequests: attributeRequests ?? this.attributeRequests,
      postCreationState: postCreationState ?? this.postCreationState,
      postCreationError: postCreationError ?? this.postCreationError,
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
    );
  }

  List<AttributeModel> get orderedAttributes {
    if (dynamicAttributes.isEmpty) return currentAttributes;
    final List<AttributeModel> orderedAttributes = [];
    for (var attr in currentAttributes) {
      orderedAttributes.add(attr);
      final relatedDynamicAttrs = dynamicAttributes
          .where((dynamicAttr) =>
              dynamicAttr.attributeKey.startsWith(attr.attributeKey))
          .toList();
      orderedAttributes.addAll(relatedDynamicAttrs);
    }
    return orderedAttributes;
  }
}
