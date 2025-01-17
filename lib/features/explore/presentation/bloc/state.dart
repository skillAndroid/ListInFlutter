import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

class HomeTreeState {
  final List<CategoryModel>? catalogs;
  final CategoryModel? selectedCatalog;
  final ChildCategoryModel? selectedChildCategory;
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
  final double? priceFrom;
  final double? priceTo;
  final List<PublicationEntity> publications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedMax;
  final int currentPage;

  HomeTreeState({
    this.catalogs,
    this.selectedCatalog,
    this.selectedChildCategory,
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
    this.priceFrom,
    this.priceTo,
    this.isLoading = false,
    this.error,
    List<PublicationEntity>? publications,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 0,
  })  : currentAttributes = currentAttributes ?? [],
        dynamicAttributes = dynamicAttributes ?? [],
        selectedValues = selectedValues ?? {},
        attributeOptionsVisibility = attributeOptionsVisibility ?? {},
        selectedAttributeValues = selectedAttributeValues ?? {},
        catalogHistory = catalogHistory ?? [],
        childCategoryHistory = childCategoryHistory ?? [],
        childCategorySelections = childCategorySelections ?? {},
        childCategoryDynamicAttributes = childCategoryDynamicAttributes ?? {},
        attributeRequests = attributeRequests ?? [],
        publications = publications ?? [];
  HomeTreeState copyWith({
    List<CategoryModel>? catalogs,
    CategoryModel? selectedCatalog,
    ChildCategoryModel? selectedChildCategory,
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
    double? priceFrom,
    double? priceTo,
    List<PublicationEntity>? publications,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return HomeTreeState(
      catalogs: catalogs ?? this.catalogs,
      selectedCatalog: selectedCatalog ?? this.selectedCatalog,
      selectedChildCategory:
          selectedChildCategory ?? this.selectedChildCategory,
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
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
      publications: publications ?? this.publications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
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
