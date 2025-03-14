// ignore_for_file: avoid_print

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/category_tree/blabla.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/child_category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/nomeric_field_model.dart';
import 'package:list_in/features/post/data/models/category_tree/sub_model.dart';
import 'package:list_in/features/post/data/models/location_tree/location_model.dart'
    as models;
import 'package:list_in/features/post/domain/entities/post_entity.dart';
import 'package:list_in/features/post/domain/usecases/create_post_usecase.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_images_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_video_usecase.dart';
import 'package:list_in/features/post/presentation/pages/catalog_screen.dart';
import 'package:list_in/features/profile/domain/usecases/user/locations/cache_user_location_usecase.dart';

class PostProvider extends ChangeNotifier {
  final GetGategoriesUsecase getCatalogsUseCase;
  final UploadImagesUseCase uploadImagesUseCase;
  final UploadVideoUseCase uploadVideoUseCase;
  final CreatePostUseCase createPostUseCase;
  final GetUserLocationUseCase getUserLocationUsecase;

  PostProvider({
    required this.getCatalogsUseCase,
    required this.uploadImagesUseCase,
    required this.uploadVideoUseCase,
    required this.createPostUseCase,
    required this.getUserLocationUsecase,
  });

  Future<void> fetchStoredLocationData() async {
    final locationResult = await getUserLocationUsecase(params: NoParams());

    locationResult.fold(
      (failure) {
        // If there's a failure, use default values
        _country = null;
        _state = null;
        _county = null;
      },
      (locationData) {
        if (locationData != null) {
          debugPrint('🤩🤩country : ${locationData['country']}');
          debugPrint('🤩🤩state : ${locationData['state']}');
          debugPrint('🤩🤩county : ${locationData['county']}');

          // Convert Maps to proper class objects
          if (locationData['country'] != null) {
            _country = models.Country.fromJson(locationData['country']);
          }

          if (locationData['state'] != null) {
            _state = models.State.fromJson(locationData['state']);
          }

          if (locationData['county'] != null) {
            _county = models.County.fromJson(locationData['county']);
          }

          // Update location entity if we have location data
          _location = LocationEntity(
            name: _buildLocationName(),
            coordinates: CoordinatesEntity(
              latitude: locationData['latitude'] ?? 41.3227,
              longitude: locationData['longitude'] ?? 69.2932,
            ),
          );
        }
        notifyListeners();
      },
    );
  }

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
      debugPrint('🤩🤩locationNamr : ${location.name}');
      debugPrint('🤩🤩country : ${_country?.valueRu}');
      debugPrint('🤩🤩state : ${_state?.valueRu}');
      debugPrint('🤩🤩county : ${_county?.valueRu}');
      final post = PostEntity(
        title: _postTitle,
        description: _postDescription,
        price: _price,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        phoneNumber: _phoneNumber,
        allowCalls: _allowCalls,
        callStartTime: _callStartTime,
        callEndTime: _callEndTime,
        locationName: _location.name,
        countryName: _country?.valueRu,
        stateName: _state?.valueRu,
        countyName: _county?.valueRu,
        longitude: _location.coordinates.latitude,
        latitude: _location.coordinates.longitude,
        isGrantedForPreciseLocation:
            _locationSharingMode == LocationSharingMode.region ? false : true,
        productCondition: _productCondition,
        isNegatable: isNegatable,
        childCategoryId: _selectedChildCategory!.id,
        attributeValues: attributeRequests,
        numericValues: getFormattedNumericValues(), // Add this line
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

//
  void getAtributesForPost() {
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

            // Handle child attributes if they exist
            if (attribute.subHelperText != 'null' && value.list.isNotEmpty) {
              // Get the selected child attribute value from the corresponding dynamic attribute
              // Instead of always taking the first item from the list
              AttributeValueModel? selectedChildValue;

              // Find the dynamic attribute that corresponds to this parent attribute
              for (var dynamicAttr in dynamicAttributes) {
                if (dynamicAttr.attributeKey == attribute.attributeKey &&
                    dynamicAttr.subWidgetsType == 'null') {
                  // Find the selected value for this dynamic attribute
                  var dynamicAttrValue =
                      _selectedValues[dynamicAttr.attributeKey];
                  if (dynamicAttrValue is AttributeValueModel) {
                    selectedChildValue = dynamicAttrValue;
                    break;
                  }
                }
              }

              // If a child value was selected, use it; otherwise, fall back to the first one
              SubModel childModel = selectedChildValue != null
                  ? value.list.firstWhere(
                      (subModel) => subModel.name == selectedChildValue!.value,
                      orElse: () => value.list.first)
                  : value.list.first;

              if (childModel.attributeId != null &&
                  childModel.modelId != null) {
                String childCombinationKey =
                    '${childModel.attributeId}_${childModel.modelId}';

                if (!processedCombinations.contains(childCombinationKey) &&
                    childModel.attributeId!.isNotEmpty &&
                    childModel.modelId!.isNotEmpty) {
                  processedCombinations.add(childCombinationKey);
                  attributeRequests.add(AttributeRequestValue(
                    attributeId: childModel.attributeId!,
                    attributeValueIds: [childModel.modelId!],
                  ));
                }
              }
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
              if (value.list.isNotEmpty) {
                // Look for the corresponding selected child value
                String dynamicAttrKey = '${entry.key} Model - ${value.value}';

                AttributeValueModel? selectedChildValue;
                // Find the corresponding dynamic attribute and its selected value
                for (var dynamicAttr in dynamicAttributes) {
                  if (dynamicAttr.attributeKey == dynamicAttrKey) {
                    var dynamicAttrValue =
                        _selectedValues[dynamicAttr.attributeKey];
                    if (dynamicAttrValue is AttributeValueModel) {
                      selectedChildValue = dynamicAttrValue;
                      break;
                    }
                  }
                }

                // If a child value was selected, use it; otherwise, fall back to the first one
                SubModel childModel = selectedChildValue != null
                    ? value.list.firstWhere(
                        (subModel) =>
                            subModel.name == selectedChildValue!.value,
                        orElse: () => value.list.first)
                    : value.list.first;

                if (childModel.attributeId != null &&
                    childModel.modelId != null) {
                  String childCombinationKey =
                      '${childModel.attributeId}_${childModel.modelId}';

                  if (!processedCombinations.contains(childCombinationKey) &&
                      childModel.attributeId!.isNotEmpty &&
                      childModel.modelId!.isNotEmpty) {
                    processedCombinations.add(childCombinationKey);
                    attributeRequests.add(AttributeRequestValue(
                      attributeId: childModel.attributeId!,
                      attributeValueIds: [childModel.modelId!],
                    ));
                  }
                }
              }
            }
          }
        }
      }
    }

    debugPrint("Attribute requests:");
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
    _currentNumericFields = childCategory.numericFields; // Add this line

    if (_selectedChildCategory?.id != childCategory.id) {
      _selectedChildCategory = childCategory;
      _currentAttributes = childCategory.attributes;
      _currentNumericFields = childCategory.numericFields; // Add this line

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
          attributeKeyUz: attribute.attributeKeyUz,
          attributeKeyRu: attribute.attributeKeyRu,
          helperText: attribute.subHelperText,
          helperTextUz: attribute.subFilterTextUz,
          helperTextRu: attribute.subFilterTextRu,
          subHelperText: 'null',
          subHelperTextUz: 'null',
          subFilterTextRu: 'null',
          widgetType: attribute.subWidgetsType,
          subWidgetsType: 'null',
          filterText: attribute.filterText,
          filterTextUz: attribute.filterTextUz,
          filterTextRu: attribute.filterTextRu,
          subFilterText: attribute.subFilterText,
          subFilterTextUz: attribute.subFilterTextUz,
          subHelperTextRu: attribute.subFilterTextRu,
          filterWidgetType: attribute.filterWidgetType,
          subFilterWidgetType: attribute.subFilterWidgetType,
          dataType: 'string',
          values: value.list.map((subModel) {
            return AttributeValueModel(
              attributeValueId: subModel.modelId ?? '',
              attributeKeyId: '',
              value: subModel.name ?? '',
              valueUz: subModel.nameUz ?? '',
              valueRu: subModel.nameRu ?? '',
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
                attributeKeyUz:
                    '${attribute.attributeKeyUz} Model - ${value.value}',
                attributeKeyRu:
                    '${attribute.attributeKeyRu} Model - ${value.value}',
                helperText: attribute.subHelperText,
                helperTextUz: attribute.subFilterTextUz,
                helperTextRu: attribute.subFilterTextRu,
                subHelperText: 'null',
                subHelperTextUz: 'null',
                subHelperTextRu: 'null',
                widgetType: attribute.subWidgetsType,
                subWidgetsType: 'null',
                filterText: attribute.filterText,
                filterTextUz: attribute.filterTextUz,
                filterTextRu: attribute.filterTextRu,
                subFilterText: 'null',
                subFilterTextUz: 'null',
                subFilterTextRu: 'null',
                filterWidgetType: attribute.filterWidgetType,
                subFilterWidgetType: 'null',
                dataType: 'string',
                values: value.list
                    .where((subModel) =>
                        subModel.name != null && subModel.name!.isNotEmpty)
                    .map((subModel) => AttributeValueModel(
                          attributeValueId: subModel.modelId ?? '',
                          attributeKeyId: '',
                          value: subModel.name ?? '',
                          valueUz: subModel.nameUz ?? '',
                          valueRu: subModel.nameRu ?? '',
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
    _currentNumericFields = []; // Add this line
    dynamicAttributes = [];
    _selectedValues.clear();
    _numericFieldValues.clear(); // Add this line
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
    _numericFieldValues.clear(); // Add this line
    dynamicAttributes.clear();
    notifyListeners();
  }

  final Map<String, String> _numericFieldValues = {};
  List<NomericFieldModel> _currentNumericFields = [];

  // Getter for numeric fields
  List<NomericFieldModel> get currentNumericFields => _currentNumericFields;
  Map<String, String> get numericFieldValues => _numericFieldValues;

  void setNumericFieldValue(String fieldId, String value) {
    _numericFieldValues[fieldId] = value;
  }

  String? getNumericFieldValue(String fieldId) {
    return _numericFieldValues[fieldId];
  }

  List<NumericRequestValue> getFormattedNumericValues() {
    return _numericFieldValues.entries
        .map((entry) => NumericRequestValue(
              numericFieldId: entry.key,
              numericValue: entry.value.toString(),
            ))
        .toList();
  }

  // Post 2nd part : Seller informations, images & videos, nessary details

  String _buildLocationName() {
    List<String?> parts = [];

    if (_county != null && _county!.valueRu != null) {
      parts.add(_county!.valueRu);
    }

    if (_state != null && _state!.valueRu != null) {
      parts.add(_state!.valueRu);
    }

    if (_country != null && _country!.valueRu != null) {
      parts.add(_country!.valueRu);
    }

    // If no parts are available, return default
    if (parts.isEmpty) {
      return "Yashnobod Tumani, Toshkent";
    }

    return parts.where((part) => part != null && part.isNotEmpty).join(", ");
  }

  String _postTitle = "";
  String _postDescription = "";
  double _price = 0.0;
  bool _isNegatable = false;
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

  // New location details
  models.Country? _country;
  models.State? _state;
  models.County? _county;
  bool _isUsingStoredLocation = true;

  // Getters for location details
  models.Country? get country => _country;
  models.State? get state => _state;
  models.County? get county => _county;
  bool get isUsingStoredLocation => _isUsingStoredLocation;

  // Methods to update location details
  void setCountry(models.Country? newCountry) {
    if (newCountry != _country) {
      _country = newCountry;
      // When country changes, reset state and county
      _state = null;
      _county = null;
      _isUsingStoredLocation = false;
      _updateLocationFromComponents();
      notifyListeners();
    }
  }

  void setState(models.State? newState) {
    if (newState != _state) {
      _state = newState;
      // When state changes, reset county
      _county = null;
      _isUsingStoredLocation = false;
      _updateLocationFromComponents();
      notifyListeners();
    }
  }

  void setCounty(models.County? newCounty) {
    if (newCounty != _county) {
      _county = newCounty;
      _isUsingStoredLocation = false;
      _updateLocationFromComponents();
      notifyListeners();
    }
  }

  void _updateLocationFromComponents() {
    _location = LocationEntity(
      name: _buildLocationName(),
      coordinates: _location.coordinates, // Keep existing coordinates
    );
  }

  String get postTitle => _postTitle;
  String get postDescription => _postDescription;
  double get price => _price;
  bool get isNegatable => _isNegatable;
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

  void changeIsNegatable(bool value) {
    _isNegatable = value;
    notifyListeners();
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
    _isUsingStoredLocation = false;
    notifyListeners();
  }

  void setLocationSharingMode(LocationSharingMode mode) {
    _locationSharingMode = mode;
    notifyListeners();
  }

  String _phoneNumber = '';
  bool _allowCalls = true;
  TimeOfDay _callStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _callEndTime = const TimeOfDay(hour: 18, minute: 0);

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
    _numericFieldValues.clear();
    _currentNumericFields = [];
    _postTitle = "";
    _postDescription = "";
    _price = 0.0;
    _images = [];
    _video = null;

    // Reset location to default, but keep stored location data

    _locationSharingMode = LocationSharingMode.region;
    _isUsingStoredLocation = true;

    _phoneNumber = '+998901234567';
    _allowCalls = true;
    _callStartTime = const TimeOfDay(hour: 9, minute: 0);
    _callEndTime = const TimeOfDay(hour: 18, minute: 0);

    _productCondition = 'NEW_PRODUCT';

    _error = null;
    _isLoading = false;

    notifyListeners();
  }
}
//
