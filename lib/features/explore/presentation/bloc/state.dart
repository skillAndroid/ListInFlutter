import 'package:equatable/equatable.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

enum PostCreationStatus { initial, loading, success, error }

class HomeTreeState extends Equatable {
  final PostCreationStatus status;
  final String? error;
  final List<CategoryModel>? catalogs;
  final CategoryModel? selectedCatalog;
  final ChildCategoryModel? selectedChildCategory;
  final List<AttributeModel> currentAttributes;
  final List<AttributeModel> dynamicAttributes;
  final Map<String, dynamic> selectedValues;
  final Map<AttributeModel, bool> attributeOptionsVisibility;
  final Map<AttributeModel, AttributeValueModel> selectedAttributeValues;
  final List<AttributeRequestValue> attributeRequests;
  final List<CategoryModel> catalogHistory;
  final List<ChildCategoryModel> childCategoryHistory;

  const HomeTreeState({
    this.status = PostCreationStatus.initial,
    this.error,
    this.catalogs,
    this.selectedCatalog,
    this.selectedChildCategory,
    this.currentAttributes = const [],
    this.dynamicAttributes = const [],
    this.selectedValues = const {},
    this.attributeOptionsVisibility = const {},
    this.selectedAttributeValues = const {},
    this.attributeRequests = const [],
    this.catalogHistory = const [],
    this.childCategoryHistory = const [],
  });

  HomeTreeState copyWith({
    PostCreationStatus? status,
    String? error,
    List<CategoryModel>? catalogs,
    CategoryModel? selectedCatalog,
    ChildCategoryModel? selectedChildCategory,
    List<AttributeModel>? currentAttributes,
    List<AttributeModel>? dynamicAttributes,
    Map<String, dynamic>? selectedValues,
    Map<AttributeModel, bool>? attributeOptionsVisibility,
    Map<AttributeModel, AttributeValueModel>? selectedAttributeValues,
    List<AttributeRequestValue>? attributeRequests,
    List<CategoryModel>? catalogHistory,
    List<ChildCategoryModel>? childCategoryHistory,
  }) {
    return HomeTreeState(
      status: status ?? this.status,
      error: error ?? this.error,
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
      attributeRequests: attributeRequests ?? this.attributeRequests,
      catalogHistory: catalogHistory ?? this.catalogHistory,
      childCategoryHistory: childCategoryHistory ?? this.childCategoryHistory,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        catalogs,
        selectedCatalog,
        selectedChildCategory,
        currentAttributes,
        dynamicAttributes,
        selectedValues,
        attributeOptionsVisibility,
        selectedAttributeValues,
        attributeRequests,
        catalogHistory,
        childCategoryHistory,
      ];
}
