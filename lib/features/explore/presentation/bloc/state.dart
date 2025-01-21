import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

enum RequestState { idle, inProgress, completed, error }

class HomeTreeState {
  final RequestState initialSearchRequestState;
  final RequestState initialPublicationsRequestState;
  final RequestState secondarySearchRequestState;
  final RequestState secondaryPublicationsRequestState;
  final RequestState searchRequestState;
  final RequestState searchPublicationsRequestState;
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
  final bool isLoading;
  final String? error;
  final bool initialIsPublicationsLoading;
  final bool initialIsLoadingMore;
  final bool searchIsPublicationsLoading;
  final bool searchIsLoadingMore;
  final List<GetPublicationEntity> initialPublications;
  final List<GetPublicationEntity> searchPublications;
  final String? errorInitialPublicationsFetch;
  final bool initialHasReachedMax;
  final int initialCurrentPage;
  final String? errorSearchPublicationsFetch;
  final bool searchHasReachedMax;
  final int searchCurrentPage;
  final String? searchText;
  // sec0ndary
  final bool secondaryIsPublicationsLoading;
  final bool secondaryIsLoadingMore;
  final List<GetPublicationEntity> secondaryPublications;
  final String? errorSecondaryPublicationsFetch;
  final bool secondaryHasReachedMax;
  final int secondaryCurrentPage;

  HomeTreeState({
    this.searchRequestState = RequestState.idle,
    this.searchPublicationsRequestState = RequestState.idle,
    this.initialSearchRequestState = RequestState.idle,
    this.initialPublicationsRequestState = RequestState.idle,
    this.secondarySearchRequestState = RequestState.idle,
    this.secondaryPublicationsRequestState = RequestState.idle,
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
    this.errorInitialPublicationsFetch,
    this.errorSearchPublicationsFetch,
    List<GetPublicationEntity>? initialPublications,
    List<GetPublicationEntity>? searchPublications,
    this.initialIsLoadingMore = false,
    this.initialHasReachedMax = false,
    this.initialCurrentPage = 0,
    this.searchIsLoadingMore = false,
    this.searchHasReachedMax = false,
    this.searchCurrentPage = 0,
    this.searchText,
    this.initialIsPublicationsLoading = false,
    this.searchIsPublicationsLoading = false,
    this.errorSecondaryPublicationsFetch,
    List<GetPublicationEntity>? secondaryPublications,
    this.secondaryIsLoadingMore = false,
    this.secondaryHasReachedMax = false,
    this.secondaryCurrentPage = 0,
    this.secondaryIsPublicationsLoading = false,
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
        initialPublications = initialPublications ?? [],
        searchPublications = searchPublications ?? [],
        secondaryPublications = secondaryPublications ?? [];

  HomeTreeState copyWith({
    RequestState? searchRequestState,
    RequestState? searchPublicationsRequestState,
    RequestState? initialSearchRequestState,
    RequestState? initialPublicationsRequestState,
    RequestState? secondarySearchRequestState,
    RequestState? secondaryPublicationsRequestState,
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
    String? error,
    List<GetPublicationEntity>? searchPublications,
    List<GetPublicationEntity>? initialPublications,
    List<GetPublicationEntity>? secondaryPublications,
    bool? isLoading,
    bool? searchIsPublicationsLoading,
    bool? initialIsPublicationsLoading,
    bool? secondaryIsPublicationsLoading,
    bool? searchIsLoadingMore,
    bool? initialIsLoadingMore,
    bool? secondaryIsLoadingMore,
    String? errorSearchPublicationsFetch,
    String? errorInitialPublicationsFetch,
    String? errorSecondaryPublicationsFetch,
    bool? searchHasReachedMax,
    bool? initialHasReachedMax,
    bool? secondaryHasReachedMax,
    int? searchCurrentPage,
    int? initialCurrentPage,
    int? secondaryCurrentPage,
    String? searchText,
  }) {
    return HomeTreeState(
      searchRequestState: searchRequestState ?? this.searchRequestState,
      searchPublicationsRequestState:
          searchPublicationsRequestState ?? this.searchPublicationsRequestState,
      initialSearchRequestState:
          initialSearchRequestState ?? this.initialSearchRequestState,
      initialPublicationsRequestState: initialPublicationsRequestState ??
          this.initialPublicationsRequestState,
      secondarySearchRequestState:
          secondarySearchRequestState ?? this.secondarySearchRequestState,
      secondaryPublicationsRequestState: secondaryPublicationsRequestState ??
          this.secondaryPublicationsRequestState,
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
      searchPublications: searchPublications ?? this.searchPublications,
      searchHasReachedMax: searchHasReachedMax ?? this.searchHasReachedMax,
      searchCurrentPage: searchCurrentPage ?? this.searchCurrentPage,
      initialPublications: initialPublications ?? this.initialPublications,
      initialHasReachedMax: initialHasReachedMax ?? this.initialHasReachedMax,
      initialCurrentPage: initialCurrentPage ?? this.initialCurrentPage,
      searchText: searchText ?? this.searchText,
      secondaryPublications:
          secondaryPublications ?? this.secondaryPublications,
      secondaryHasReachedMax:
          secondaryHasReachedMax ?? this.secondaryHasReachedMax,
      secondaryCurrentPage: secondaryCurrentPage ?? this.secondaryCurrentPage,
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
