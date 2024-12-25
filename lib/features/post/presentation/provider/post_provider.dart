import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/blabla.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:list_in/features/post/domain/entities/post_entity.dart';
import 'package:list_in/features/post/domain/usecases/create_post_usecase.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_images_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_video_usecase.dart';
import 'package:list_in/features/post/presentation/pages/catalog_screen.dart';

class PostProvider extends ChangeNotifier {
  final GetGategoriesUsecase getCatalogsUseCase;
  final UploadImagesUseCase uploadImagesUseCase;
  final UploadVideoUseCase uploadVideoUseCase;
  final CreatePostUseCase createPostUseCase;
  PostProvider({
    required this.getCatalogsUseCase,
    required this.uploadImagesUseCase,
    required this.uploadVideoUseCase,
    required this.createPostUseCase,
  });

  Future<Either<Failure, List<String>>> uploadImagesRemoute(
      List<XFile> images) async {
    return await uploadImagesUseCase(params: images);
  }

  Future<Either<Failure, String>> uploadVideoRemoute(XFile video) async {
    return await uploadVideoUseCase(params: video);
  }

  List<AttributeRequestValue> attributeRequests = [];
  Future<Either<Failure, String>> createPost() async {
    getAtributesForPost();

    if (!_validatePost()) {
      _updatePostCreationState(
          PostCreationState.error, 'Please fill all required fields');
      return Left(ValidationFailure());
    }

    try {
      String? videoUrl;
      List<String> imageUrls = [];

      // Upload images
      if (_images.isNotEmpty) {
        _updatePostCreationState(PostCreationState.uploadingImages);
        final imagesResult = await uploadImagesRemoute(_images);

        final hasImageUploadFailed = imagesResult.fold(
          (failure) => true,
          (urls) {
            imageUrls = urls;
            return false;
          },
        );

        if (hasImageUploadFailed) {
          _updatePostCreationState(
              PostCreationState.error, 'Failed to upload images');
          return Left(ServerFailure());
        }
      }

      // Upload video if exists
      if (_video != null) {
        _updatePostCreationState(PostCreationState.uploadingVideo);
        final videoResult = await uploadVideoRemoute(_video!);

        final hasVideoUploadFailed = videoResult.fold(
          (failure) => true,
          (url) {
            videoUrl = url;
            return false;
          },
        );

        if (hasVideoUploadFailed) {
          _updatePostCreationState(
              PostCreationState.error, 'Failed to upload video');
          return Left(ServerFailure());
        }
      }

      for (var entry in _selectedAttributeValues.entries) {
        AttributeValueModel value = entry.value;
        attributeRequests.add(AttributeRequestValue(
          attributeId: value.attributeKeyId,
          attributeValueIds: [value.attributeValueId],
        ));
      }

      for (var entry in _selectedValues.entries) {
        if (entry.value is List<AttributeValueModel>) {
          List<AttributeValueModel> values =
              entry.value as List<AttributeValueModel>;
          if (values.isNotEmpty) {
            attributeRequests.add(AttributeRequestValue(
              attributeId: values.first.attributeKeyId,
              attributeValueIds: values.map((v) => v.attributeValueId).toList(),
            ));
          }
        }
      }

      _updatePostCreationState(PostCreationState.creatingPost);
      getAtributesForPost();
      final post = PostEntity(
        title: _postTitle,
        description: _postDescription,
        price: _price,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        locationName: _location.name,
        longitude: _location.coordinates.latitude,
        latitude: _location.coordinates.longitude,
        locationSharingMode: _locationSharingMode,
        productCondition: _productCondition,
        isNegatable: false,
        childCategoryId: _selectedChildCategory?.id ?? '',
        attributeValues: attributeRequests,
      );

      final result = await createPostUseCase(params: post);

      result.fold(
        (failure) => _updatePostCreationState(
            PostCreationState.error, 'Failed to create post'),
        (success) {
          _updatePostCreationState(PostCreationState.success);
          clear();
        },
      );

      return result;
    } catch (e) {
      _updatePostCreationState(
          PostCreationState.error, 'An unexpected error occurred');
      return Left(UnexpectedFailure());
    }
  }

  void getAtributesForPost() {
    // Clear previous requests
    attributeRequests.clear();

    // Set to track processed attribute-value combinations
    final Set<String> processedCombinations = {};

    // Handle single-selection attributes (oneSelectable and colorSelectable)
    for (var entry in _selectedAttributeValues.entries) {
      AttributeModel attribute = entry.key;
      AttributeValueModel value = entry.value;

      // Only process single-selection attributes
      if (attribute.widgetType == 'oneSelectable' ||
          attribute.widgetType == 'colorSelectable') {
        // Create unique key for this combination
        String combinationKey =
            '${value.attributeKeyId}_${value.attributeValueId}';

        // Only add if not processed
        if (!processedCombinations.contains(combinationKey)) {
          processedCombinations.add(combinationKey);

          // Add main attribute
          if (value.attributeKeyId.isNotEmpty &&
              value.attributeValueId.isNotEmpty) {
            attributeRequests.add(AttributeRequestValue(
              attributeId: value.attributeKeyId,
              attributeValueIds: [value.attributeValueId],
            ));
          }

          // Handle child attributes if they exist
          if (attribute.subHelperText != 'null' &&
              value.list.isNotEmpty &&
              value.list.first.attributeId != null &&
              value.list.first.modelId != null) {
            String childCombinationKey =
                '${value.list.first.attributeId}_${value.list.first.modelId}';

            if (!processedCombinations.contains(childCombinationKey) &&
                value.list.first.attributeId!.isNotEmpty &&
                value.list.first.modelId!.isNotEmpty) {
              processedCombinations.add(childCombinationKey);
              attributeRequests.add(AttributeRequestValue(
                attributeId: value.list.first.attributeId!,
                attributeValueIds: [value.list.first.modelId!],
              ));
            }
          }
        }
      }
    }

    // Handle multi-selection attributes
    for (var entry in _selectedValues.entries) {
      if (entry.value is List<AttributeValueModel>) {
        List<AttributeValueModel> values =
            entry.value as List<AttributeValueModel>;
        if (values.isNotEmpty) {
          // Add main multi-selection attribute
          String attributeId = values.first.attributeKeyId;
          List<String> valueIds =
              values.map((v) => v.attributeValueId).toList();

          if (attributeId.isNotEmpty && valueIds.isNotEmpty) {
            attributeRequests.add(AttributeRequestValue(
              attributeId: attributeId,
              attributeValueIds: valueIds,
            ));

            // Handle child attributes for multi-selection if they exist
            for (var value in values) {
              if (value.list.isNotEmpty &&
                  value.list.first.attributeId != null &&
                  value.list.first.modelId != null) {
                String childCombinationKey =
                    '${value.list.first.attributeId}_${value.list.first.modelId}';

                if (!processedCombinations.contains(childCombinationKey) &&
                    value.list.first.attributeId!.isNotEmpty &&
                    value.list.first.modelId!.isNotEmpty) {
                  processedCombinations.add(childCombinationKey);
                  attributeRequests.add(AttributeRequestValue(
                    attributeId: value.list.first.attributeId!,
                    attributeValueIds: [value.list.first.modelId!],
                  ));
                }
              }
            }
          }
        }
      }
    }

    // Debug printing
    print("Attribute requests:");
    for (var request in attributeRequests) {
      print("Attribute ID: ${request.attributeId}");
      print("Attribute Value IDs: ${request.attributeValueIds.join(', ')}");
      print("------------");
    }
  }

  bool _validatePost() {
    return _postTitle.isNotEmpty &&
        _postDescription.isNotEmpty &&
        _price > 0 &&
        _images.isNotEmpty &&
        _selectedCatalog != null &&
        _selectedChildCategory != null;
  }

  PostCreationState _postCreationState = PostCreationState.initial;
  String? _postCreationError;

  PostCreationState get postCreationState => _postCreationState;
  String? get postCreationError => _postCreationError;

  void _updatePostCreationState(PostCreationState state, [String? error]) {
    _postCreationState = state;
    _postCreationError = error;
    notifyListeners();
  }

  List<CategoryModel>? _catalogs;
  CategoryModel? _selectedCatalog;
  ChildCategoryModel? _selectedChildCategory;
  bool _isLoading = false;
  String? _error;

  final Map<String, Map<String, dynamic>> _childCategorySelections = {};
  final Map<String, List<AttributeModel>> _childCategoryDynamicAttributes = {};

  List<AttributeModel> _currentAttributes = [];
  List<AttributeModel> dynamicAttributes = [];
  final Map<String, dynamic> _selectedValues = {};

  final List<CategoryModel> _catalogHistory = [];
  final List<ChildCategoryModel> _childCategoryHistory = [];

  List<CategoryModel>? get catalogs => _catalogs;
  CategoryModel? get selectedCatalog => _selectedCatalog;
  ChildCategoryModel? get selectedChildCategory => _selectedChildCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AttributeModel> get currentAttributes {
    if (dynamicAttributes.isEmpty) return _currentAttributes;
    final List<AttributeModel> orderedAttributes = [];
    for (var attr in _currentAttributes) {
      orderedAttributes.add(attr);
      final relatedDynamicAttrs = dynamicAttributes
          .where((dynamicAttr) =>
              dynamicAttr.attributeKey.startsWith(attr.attributeKey))
          .toList();
      orderedAttributes.addAll(relatedDynamicAttrs);
    }
    return orderedAttributes;
  }

  Map<String, dynamic> get selectedValues => _selectedValues;
  final Map<AttributeModel, bool> _attributeOptionsVisibility = {};
  final Map<AttributeModel, AttributeValueModel> _selectedAttributeValues = {};
  void toggleAttributeOptionsVisibility(AttributeModel attribute) {
    _attributeOptionsVisibility[attribute] =
        !(_attributeOptionsVisibility[attribute] ?? false);
    notifyListeners();
  }

  bool isAttributeOptionsVisible(AttributeModel attribute) {
    return _attributeOptionsVisibility[attribute] ?? false;
  }

  AttributeValueModel? getSelectedAttributeValue(AttributeModel attribute) {
    return _selectedAttributeValues[attribute];
  }

  Future<void> fetchCatalogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCatalogsUseCase(params: NoParams());
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _catalogs = null;
      },
      (catalogs) {
        _catalogs = catalogs;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'Network connection error';
      default:
        return 'Unexpected error';
    }
  }

  void selectCatalog(CategoryModel catalog) {
    if (_selectedCatalog == null || _selectedCatalog?.id != catalog.id) {
      _childCategorySelections.clear();
      _childCategoryDynamicAttributes.clear();
    }

    if (_selectedCatalog != null &&
        !_catalogHistory.contains(_selectedCatalog)) {
      _catalogHistory.add(_selectedCatalog!);
    }
    _selectedCatalog = catalog;
    _selectedChildCategory = null;
    _currentAttributes = [];
    dynamicAttributes = [];
    _selectedValues.clear();
    notifyListeners();
  }

  void selectChildCategory(ChildCategoryModel childCategory) {
    final previousChildCategoryId = _selectedChildCategory?.id;
    if (previousChildCategoryId != null &&
        previousChildCategoryId != childCategory.id) {
      resetSelectionForChildCategory(childCategory);
    }
    if (_selectedChildCategory != null &&
        !_childCategoryHistory.contains(_selectedChildCategory)) {
      _childCategoryHistory.add(_selectedChildCategory!);
    }
    _selectedChildCategory = childCategory;
    _currentAttributes = childCategory.attributes;
    if (_selectedChildCategory?.id != childCategory.id) {
      _selectedChildCategory = childCategory;
      _currentAttributes = childCategory.attributes;
      if (_childCategorySelections.containsKey(childCategory.id)) {
        _selectedValues.clear();
        _selectedValues.addAll(_childCategorySelections[childCategory.id]!);
        dynamicAttributes =
            _childCategoryDynamicAttributes[childCategory.id] ?? [];
      } else {
        _selectedValues.clear();
        dynamicAttributes.clear();
      }
      if (previousChildCategoryId != null &&
          previousChildCategoryId != childCategory.id) {
        final preservedDynamicAttributes =
            dynamicAttributes.where((dynamicAttr) {
          return _currentAttributes.any(
              (attr) => dynamicAttr.attributeKey.startsWith(attr.attributeKey));
        }).toList();
        dynamicAttributes = preservedDynamicAttributes;
      }
    }
    notifyListeners();
  }

  void goBack() {
    if (_selectedChildCategory != null) {
      _saveCurrentSelections();
      if (_childCategoryHistory.isNotEmpty) {
        final previousChildCategory = _childCategoryHistory.removeLast();
        _selectedChildCategory = previousChildCategory;
        _restorePreviousSelections();
        _currentAttributes = previousChildCategory.attributes;
      } else {
        _selectedChildCategory = null;
        resetUIState();
        _selectedValues.clear();
        // dynamicAttributes.clear();
        // _currentAttributes.clear();
      }
    } else if (_selectedCatalog != null) {
      if (_catalogHistory.isNotEmpty) {
        _selectedCatalog = _catalogHistory.removeLast();
      } else {
        _selectedCatalog = null;
      }
      resetUIState();
    }
    notifyListeners();
  }

  void _saveCurrentSelections() {
    if (_selectedChildCategory != null) {
      _childCategorySelections[_selectedChildCategory!.id] =
          Map<String, dynamic>.from(_selectedValues);
      _childCategoryDynamicAttributes[_selectedChildCategory!.id] =
          List<AttributeModel>.from(dynamicAttributes);
    }
  }

  void _restorePreviousSelections() {
    if (_selectedChildCategory != null) {
      _selectedValues.clear();
      _selectedValues
          .addAll(_childCategorySelections[_selectedChildCategory!.id] ?? {});
      dynamicAttributes.clear();
      dynamicAttributes.addAll(
          _childCategoryDynamicAttributes[_selectedChildCategory!.id] ?? []);
      _currentAttributes = _selectedChildCategory!.attributes;
    }
  }

  void selectAttributeValue(
      AttributeModel attribute, AttributeValueModel value) {
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      final currentValue = _selectedValues[attribute.attributeKey];
      if (currentValue == value) return;
      _selectedValues[attribute.attributeKey] = value;
      _handleDynamicAttributeCreation(attribute, value);
    } else if (attribute.widgetType == 'multiSelectable') {
      _selectedValues.putIfAbsent(
          attribute.attributeKey, () => <AttributeValueModel>[]);
      final list =
          _selectedValues[attribute.attributeKey] as List<AttributeValueModel>;
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    }
    _selectedAttributeValues[attribute] = value;
    notifyListeners();
  }

  void _handleDynamicAttributeCreation(
      AttributeModel attribute, AttributeValueModel value) {
    if (attribute.subWidgetsType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      bool alreadyExists = dynamicAttributes.any((attr) =>
          attr.attributeKey == attribute.attributeKey &&
          attr.subWidgetsType == 'null' &&
          attr.values.length == value.list.length &&
          attr.values.every((existingValue) => value.list
              .any((newValue) => existingValue.value == newValue.name)));

      if (!alreadyExists) {
        final newAttribute = AttributeModel(
          attributeKey: attribute.attributeKey,
          helperText: attribute.subHelperText,
          subHelperText: 'null',
          widgetType: attribute.subWidgetsType,
          subWidgetsType: 'null',
          dataType: 'string',
          values: value.list.map((subModel) {
            return AttributeValueModel(
              attributeValueId: subModel.modelId ?? '',
              attributeKeyId: '',
              value: subModel.name ?? '',
              list: [],
            );
          }).toList(),
        );

        dynamicAttributes.removeWhere(
          (attr) =>
              attr.attributeKey == attribute.attributeKey &&
              attr.subWidgetsType == 'null',
        );

        dynamicAttributes.insert(0, newAttribute);
      }
    }
  }

  bool isValueSelected(AttributeModel attribute, AttributeValueModel value) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return selectedValue == value;
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValueModel>?;
      return selectedList?.contains(value) ?? false;
    }
    return false;
  }

  void preserveAttributeState(
      AttributeModel oldAttribute, AttributeModel newAttribute) {
    if (_attributeOptionsVisibility.containsKey(oldAttribute)) {
      _attributeOptionsVisibility[newAttribute] =
          _attributeOptionsVisibility[oldAttribute]!;
    }
    if (_selectedAttributeValues.containsKey(oldAttribute)) {
      _selectedAttributeValues[newAttribute] =
          _selectedAttributeValues[oldAttribute]!;
    }
  }

  void confirmMultiSelection(AttributeModel attribute) {
    if (attribute.widgetType == 'multiSelectable') {
      final selectedValues = _selectedValues[attribute.attributeKey]
              as List<AttributeValueModel>? ??
          [];
      if (selectedValues.isEmpty) return;

      dynamicAttributes.removeWhere((attr) =>
          attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

      final dynamicAttributesToAdd = selectedValues
          .where((value) =>
              attribute.subWidgetsType != 'null' &&
              value.list.isNotEmpty &&
              value.list.any((subModel) =>
                  subModel.name != null && subModel.name!.isNotEmpty))
          .map((value) => AttributeModel(
                attributeKey:
                    '${attribute.attributeKey} Model - ${value.value}',
                helperText: attribute.subHelperText,
                subHelperText: 'null',
                widgetType: attribute.subWidgetsType,
                subWidgetsType: 'null',
                dataType: 'string',
                values: value.list
                    .where((subModel) =>
                        subModel.name != null && subModel.name!.isNotEmpty)
                    .map((subModel) => AttributeValueModel(
                          attributeValueId: subModel.modelId ?? '',
                          attributeKeyId: '',
                          value: subModel.name ?? '',
                          list: [],
                        ))
                    .toList(),
              ))
          .toList();

      dynamicAttributes.insertAll(0, dynamicAttributesToAdd);
    }

    notifyListeners();
  }

  AttributeValueModel? getSelectedValue(AttributeModel attribute) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return selectedValue as AttributeValueModel?;
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValueModel>?;
      return selectedList!.isNotEmpty ? selectedList.first : null;
    }
    return null;
  }

  void resetCatalogSelection() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();
  }

  void resetChildCategorySelection() {
    _selectedChildCategory = null;
    if (_selectedCatalog != null) {
      _childCategorySelections.remove(_selectedChildCategory?.id);
      _childCategoryDynamicAttributes.remove(_selectedChildCategory?.id);
      _selectedAttributeValues.clear();
      _attributeOptionsVisibility.clear();
    }
  }

  void resetSelection() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _currentAttributes = [];
    dynamicAttributes = [];
    _selectedValues.clear();
    _catalogHistory.clear();
    _childCategoryHistory.clear();
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();
    notifyListeners();
  }

  void resetUIState() {
    _attributeOptionsVisibility.clear();
    notifyListeners();
  }

  void resetSelectionForChildCategory(ChildCategoryModel newChildCategory) {
    _attributeOptionsVisibility.clear();
    _selectedAttributeValues.clear();
    _childCategorySelections.remove(newChildCategory.id);
    _childCategoryDynamicAttributes.remove(newChildCategory.id);
    _selectedValues.clear();
    dynamicAttributes.clear();
    notifyListeners();
  }

  // Post 2nd part : Seller informations, images & videos, nessary details

  String _postTitle = "";
  String _postDescription = "";
  double _price = 0.0;
  List<XFile> _images = [];
  XFile? _video;
  LocationEntity _location = const LocationEntity(
    name: "Yashnobod Tumani, Toshkent",
    coordinates: CoordinatesEntity(
      latitude: 41.3227,
      longitude: 69.2932,
    ),
  );
  LocationSharingMode _locationSharingMode = LocationSharingMode.region;

  String get postTitle => _postTitle;
  String get postDescription => _postDescription;
  double get price => _price;
  List<XFile> get images => _images;
  XFile? get video => _video;
  LocationEntity get location => _location;
  LocationSharingMode get locationSharingMode => _locationSharingMode;

  void changePostTitle(String title) {
    if (title.isNotEmpty && title != _postTitle) {
      _postTitle = title;
      notifyListeners();
    }
  }

  void changePostDescription(String description) {
    if (description.isNotEmpty && description != _postDescription) {
      _postDescription = description;
      notifyListeners();
    }
  }

  void changePrice(double newPrice) {
    if (newPrice >= 0 && newPrice != _price) {
      _price = newPrice;
      notifyListeners();
    }
  }

  String getFormattedPrice() {
    return _price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  void setImages(List<XFile> newImages) {
    if (newImages.isNotEmpty) {
      _images = newImages;
      notifyListeners();
    }
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  void setVideo(XFile newVideo) {
    _video = newVideo;
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }

  void clearVideo() {
    _video = null;
    notifyListeners();
  }

  void setLocation(LocationEntity newLocation) {
    _location = newLocation;
    notifyListeners();
  }

  void setLocationSharingMode(LocationSharingMode mode) {
    _locationSharingMode = mode;
    notifyListeners();
  }

  String _phoneNumber = '+998901234567'; // Default phone number
  bool _allowCalls = true;
  TimeOfDay _callStartTime =
      const TimeOfDay(hour: 9, minute: 0); // Default 9 AM
  TimeOfDay _callEndTime = const TimeOfDay(hour: 18, minute: 0); // Default 6 PM

  // Phone-related getters
  String get phoneNumber => _phoneNumber;
  bool get allowCalls => _allowCalls;
  TimeOfDay get callStartTime => _callStartTime;
  TimeOfDay get callEndTime => _callEndTime;

  // Phone-related methods
  void setPhoneNumber(String number) {
    if (number.isNotEmpty && number != _phoneNumber) {
      _phoneNumber = number;
      notifyListeners();
    }
  }

  void setAllowCalls(bool allow) {
    _allowCalls = allow;
    notifyListeners();
  }

  void setCallTime(TimeOfDay start, TimeOfDay end) {
    _callStartTime = start;
    _callEndTime = end;
    notifyListeners();
  }

  String _productCondition = 'NEW_PRODUCT';

// Add this to your getters
  String get productCondition => _productCondition;

// Add this to your methods
  void changeProductCondition(String condition) {
    if (condition != _productCondition) {
      _productCondition = condition;
      notifyListeners();
    }
  }

  void clear() {
    _selectedCatalog = null;
    _selectedChildCategory = null;
    _catalogHistory.clear();
    _childCategoryHistory.clear();

    _currentAttributes = [];
    dynamicAttributes = [];
    _selectedValues.clear();
    _attributeOptionsVisibility.clear();
    _selectedAttributeValues.clear();
    _childCategorySelections.clear();
    _childCategoryDynamicAttributes.clear();

    _postTitle = "";
    _postDescription = "";
    _price = 0.0;
    _images = [];
    _video = null;

    _location = const LocationEntity(
      name: "Yashnobod Tumani, Toshkent",
      coordinates: CoordinatesEntity(
        latitude: 41.3227,
        longitude: 69.2932,
      ),
    );
    _locationSharingMode = LocationSharingMode.region;

    _phoneNumber = '+998901234567';
    _allowCalls = true;
    _callStartTime = const TimeOfDay(hour: 9, minute: 0);
    _callEndTime = const TimeOfDay(hour: 18, minute: 0);

    _productCondition = 'new';

    _error = null;
    _isLoading = false;

    notifyListeners();
  }
}
