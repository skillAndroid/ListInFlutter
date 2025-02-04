import 'package:list_in/features/explore/domain/enties/prediction_entity.dart';
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

  final RequestState videoSearchRequestState;
  final RequestState videoPublicationsRequestState;

  final RequestState childSearchRequestState;
  final RequestState childPublicationsRequestState;

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

  final bool childIsPublicationsLoading;
  final bool childIsLoadingMore;

  final List<PublicationPairEntity> initialPublications;
  final bool secondaryIsPublicationsLoading;
  final bool videoIsPublicationsLoading;
  final List<PublicationPairEntity> childPublications;

  final List<PublicationPairEntity> searchPublications;

  final String? errorInitialPublicationsFetch;
  final String? errorSearchPublicationsFetch;
  final String? errorChildPublicationsFetch;

  final bool initialHasReachedMax;
  final int initialCurrentPage;
  final int searchCurrentPage;

  final bool childHasReachedMax;
  final bool filtersTrigered;
  final int childCurrentPage;
  final bool searchHasReachedMax;

  final String? searchText;
  // sec0ndary

  final bool secondaryIsLoadingMore;
  final List<PublicationPairEntity> secondaryPublications;

  final bool videoIsLoadingMore;
  final List<GetPublicationEntity> videoPublications;

  final String? errorSecondaryPublicationsFetch;
  final bool secondaryHasReachedMax;
  final int secondaryCurrentPage;

  final String? errorVideoPublicationsFetch;
  final bool videoHasReachedMax;
  final int videoCurrentPage;

  final List<PredictionEntity> predictions;
  final RequestState predictionsRequestState;
  final String? errorPredictionsFetch;

  HomeTreeState({
    this.searchRequestState = RequestState.idle,
    this.searchPublicationsRequestState = RequestState.idle,
    this.initialSearchRequestState = RequestState.idle,
    this.initialPublicationsRequestState = RequestState.idle,
    this.secondarySearchRequestState = RequestState.idle,
    this.secondaryPublicationsRequestState = RequestState.idle,
    this.videoSearchRequestState = RequestState.idle,
    this.videoPublicationsRequestState = RequestState.idle,
    this.childSearchRequestState = RequestState.idle,
    this.childPublicationsRequestState = RequestState.idle,
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
    this.errorChildPublicationsFetch,
    this.errorInitialPublicationsFetch,
    this.errorSearchPublicationsFetch,
    List<PublicationPairEntity>? initialPublications,
    List<PublicationPairEntity>? searchPublications,
    List<PublicationPairEntity>? childPublications,
    this.initialIsLoadingMore = false,
    this.initialHasReachedMax = false,
    this.initialCurrentPage = 0,
    this.searchIsLoadingMore = false,
    this.searchHasReachedMax = false,
    this.searchCurrentPage = 0,
    this.childIsLoadingMore = false,
    this.childHasReachedMax = false,
    this.filtersTrigered = false,
    this.childCurrentPage = 0,
    this.searchText,
    this.initialIsPublicationsLoading = false,
    this.childIsPublicationsLoading = false,
    this.searchIsPublicationsLoading = false,
    this.errorSecondaryPublicationsFetch,
    this.errorVideoPublicationsFetch,
    List<PublicationPairEntity>? secondaryPublications,
    this.secondaryIsLoadingMore = false,
    this.secondaryHasReachedMax = false,
    this.secondaryCurrentPage = 0,
    this.secondaryIsPublicationsLoading = false,
    List<GetPublicationEntity>? videoPublications,
    this.videoIsLoadingMore = false,
    this.videoHasReachedMax = false,
    this.videoCurrentPage = 0,
    this.videoIsPublicationsLoading = false,
    this.predictions = const [],
    this.predictionsRequestState = RequestState.idle,
    this.errorPredictionsFetch,
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
        secondaryPublications = secondaryPublications ?? [],
        videoPublications = videoPublications ?? [],
        childPublications = childPublications ?? [];

  HomeTreeState copyWith({
    RequestState? searchRequestState,
    RequestState? searchPublicationsRequestState,
    RequestState? initialSearchRequestState,
    RequestState? initialPublicationsRequestState,
    RequestState? secondarySearchRequestState,
    RequestState? secondaryPublicationsRequestState,
    RequestState? videoSearchRequestState,
    RequestState? videoPublicationsRequestState,
    RequestState? childSearchRequestState,
    RequestState? childPublicationsRequestState,
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
    double? priceFrom = double.nan,
    double? priceTo = double.nan,
    String? error,
    List<PublicationPairEntity>? searchPublications,
    List<PublicationPairEntity>? initialPublications,
    List<PublicationPairEntity>? secondaryPublications,
    List<GetPublicationEntity>? videoPublications,
    List<PublicationPairEntity>? childPublications,
    bool? isLoading,
    bool? searchIsPublicationsLoading,
    bool? initialIsPublicationsLoading,
    bool? secondaryIsPublicationsLoading,
    bool? videoIsPublicationsLoading,
    bool? childIsPublicationsLoading,
    bool? searchIsLoadingMore,
    bool? initialIsLoadingMore,
    bool? secondaryIsLoadingMore,
    bool? videoIsLoadingMore,
    bool? childIsLoadingMore,
    String? errorSearchPublicationsFetch,
    String? errorInitialPublicationsFetch,
    String? errorSecondaryPublicationsFetch,
    String? errorVideoPublicationsFetch,
    String? errorChildPublicationsFetch,
    bool? searchHasReachedMax,
    bool? initialHasReachedMax,
    bool? secondaryHasReachedMax,
    bool? videoHasReachedMax,
    bool? childHasReachedMax,
    bool? filtersTrigered,
    int? searchCurrentPage,
    int? initialCurrentPage,
    int? secondaryCurrentPage,
    int? videoCurrentPage,
    int? childCurrentPage,
    String? searchText,
    List<PredictionEntity>? predictions,
    RequestState? predictionsRequestState,
    String? errorPredictionsFetch,
    bool clearSelectedCatalog = false,
    bool clearSelectedChildCategory = false,
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
      videoSearchRequestState:
          videoSearchRequestState ?? this.videoSearchRequestState,
      videoPublicationsRequestState:
          videoPublicationsRequestState ?? this.videoPublicationsRequestState,
      childSearchRequestState:
          childSearchRequestState ?? this.childSearchRequestState,
      childPublicationsRequestState:
          childPublicationsRequestState ?? this.childPublicationsRequestState,
      catalogs: catalogs ?? this.catalogs,
      selectedCatalog: clearSelectedCatalog
          ? null
          : (selectedCatalog ?? this.selectedCatalog),
      selectedChildCategory: clearSelectedChildCategory
          ? null
          : (selectedChildCategory ?? this.selectedChildCategory),
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
      priceFrom: priceFrom == null
          ? null
          : (priceFrom.isNaN ? this.priceFrom : priceFrom),
      priceTo:
          priceTo == null ? null : (priceTo.isNaN ? this.priceTo : priceTo),
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
      videoPublications: videoPublications ?? this.videoPublications,
      videoHasReachedMax: videoHasReachedMax ?? this.videoHasReachedMax,
      videoCurrentPage: videoCurrentPage ?? this.videoCurrentPage,
      childPublications: childPublications ?? this.childPublications,
      childHasReachedMax: childHasReachedMax ?? this.childHasReachedMax,
      filtersTrigered: filtersTrigered ?? this.filtersTrigered,
      childCurrentPage: childCurrentPage ?? this.childCurrentPage,
      predictions: predictions ?? this.predictions,
      predictionsRequestState:
          predictionsRequestState ?? this.predictionsRequestState,
      errorPredictionsFetch: errorPredictionsFetch,
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
