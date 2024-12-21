import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/presentation/pages/register_details_page.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/post/data/models/attribute.dart';
import 'package:list_in/features/post/data/models/attribute_value.dart';
import 'package:list_in/features/post/data/models/category.dart';
import 'package:list_in/features/post/data/models/child_category.dart';
import 'package:list_in/features/post/data/models/sub_model.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';

class PostProvider extends ChangeNotifier {
  final GetCatalogs getCatalogsUseCase;
  PostProvider({required this.getCatalogsUseCase}) {
    print('DEBUG: PostProvider initialized');
  }

  List<Category>? _catalogs;
  // CatalogModel? _catalogModel;
  Category? _selectedCatalog;
  ChildCategory? _selectedChildCategory;
  bool _isLoading = false;
  String? _error;

  final Map<String, Map<String, dynamic>> _childCategorySelections = {};
  final Map<String, List<Attribute>> _childCategoryDynamicAttributes = {};

  List<Attribute> _currentAttributes = [];
  List<Attribute> dynamicAttributes = [];
  final Map<String, dynamic> _selectedValues = {};

  final List<Category> _catalogHistory = [];
  final List<ChildCategory> _childCategoryHistory = [];

  List<Category>? get catalogs => _catalogs;
  Category? get selectedCatalog => _selectedCatalog;
  ChildCategory? get selectedChildCategory => _selectedChildCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Attribute> get currentAttributes {
    if (dynamicAttributes.isEmpty) return _currentAttributes;
    final List<Attribute> orderedAttributes = [];
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
  final Map<Attribute, bool> _attributeOptionsVisibility = {};
  final Map<Attribute, AttributeValue> _selectedAttributeValues = {};
  void toggleAttributeOptionsVisibility(Attribute attribute) {
    _attributeOptionsVisibility[attribute] =
        !(_attributeOptionsVisibility[attribute] ?? false);
    notifyListeners();
  }

  bool isAttributeOptionsVisible(Attribute attribute) {
    return _attributeOptionsVisibility[attribute] ?? false;
  }

  AttributeValue? getSelectedAttributeValue(Attribute attribute) {
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

  void selectCatalog(Category catalog) {
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

  void selectChildCategory(ChildCategory childCategory) {
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
          List<Attribute>.from(dynamicAttributes);
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

  void selectAttributeValue(Attribute attribute, AttributeValue value) {
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      final currentValue = _selectedValues[attribute.attributeKey];
      if (currentValue == value) return;
      _selectedValues[attribute.attributeKey] = value;
      _handleDynamicAttributeCreation(attribute, value);
    } else if (attribute.widgetType == 'multiSelectable') {
      _selectedValues.putIfAbsent(
          attribute.attributeKey, () => <AttributeValue>[]);
      final list =
          _selectedValues[attribute.attributeKey] as List<AttributeValue>;
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
      Attribute attribute, AttributeValue value) {
    dynamicAttributes.removeWhere(
        (attr) => attr.attributeKey.startsWith('$attribute.attributeKey'));

    if (attribute.subWidgetsType != 'null' &&
        value.list.isNotEmpty &&
        value.list[0].name != null) {
      final newAttribute = Attribute(
        attributeKey: attribute.attributeKey,
        helperText: attribute.subHelperText,
        subHelperText: 'null',
        widgetType: attribute.subWidgetsType,
        subWidgetsType: 'null',
        dataType: 'string',
        values: value.list.map((subModel) {
          return AttributeValue(
            attributeValueId: subModel.modelId ?? '',
            attributeKeyId: '',
            value: subModel.name ?? '',
            list: [],
          );
        }).toList(),
      );

      dynamicAttributes.insert(0, newAttribute);
    }
  }

  bool isValueSelected(Attribute attribute, AttributeValue value) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return selectedValue == value;
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValue>?;
      return selectedList?.contains(value) ?? false;
    }
    return false;
  }

  void preserveAttributeState(Attribute oldAttribute, Attribute newAttribute) {
    if (_attributeOptionsVisibility.containsKey(oldAttribute)) {
      _attributeOptionsVisibility[newAttribute] =
          _attributeOptionsVisibility[oldAttribute]!;
    }
    if (_selectedAttributeValues.containsKey(oldAttribute)) {
      _selectedAttributeValues[newAttribute] =
          _selectedAttributeValues[oldAttribute]!;
    }
  }

  void confirmMultiSelection(Attribute attribute) {
    if (attribute.widgetType == 'multiSelectable') {
      final selectedValues =
          _selectedValues[attribute.attributeKey] as List<AttributeValue>? ??
              [];
      if (selectedValues.isEmpty) return;

      // Clear previous dynamic attributes related to this multi-selection attribute
      dynamicAttributes.removeWhere((attr) =>
          attr.attributeKey.startsWith('${attribute.attributeKey} Model'));

      // Only create dynamic attributes for selected values that have sub-models
      final dynamicAttributesToAdd = selectedValues
          .where((value) =>
              attribute.subWidgetsType != 'null' &&
              value.list.isNotEmpty &&
              value.list.any((subModel) =>
                  subModel.name != null && subModel.name!.isNotEmpty))
          .map((value) => Attribute(
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
                    .map((subModel) => AttributeValue(
                          attributeValueId: subModel.modelId ?? '',
                          attributeKeyId: '',
                          value: subModel.name ?? '',
                          list: [],
                        ))
                    .toList(),
              ))
          .toList();

      // Add new dynamic attributes
      dynamicAttributes.insertAll(0, dynamicAttributesToAdd);
    }

    notifyListeners();
  }

  AttributeValue? getSelectedValue(Attribute attribute) {
    final selectedValue = _selectedValues[attribute.attributeKey];
    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return selectedValue as AttributeValue?;
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValue>?;
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

  void resetSelectionForChildCategory(ChildCategory newChildCategory) {
    _attributeOptionsVisibility.clear();
    _selectedAttributeValues.clear();
    _childCategorySelections.remove(newChildCategory.id);
    _childCategoryDynamicAttributes.remove(newChildCategory.id);
    _selectedValues.clear();
    dynamicAttributes.clear();
    notifyListeners();
  }

  // Post 2nd part : Seller informations, images & videos, nessary details

  // Private field
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

  // Getter to access postTitle
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

  String _productCondition = 'new'; // Default to 'new'

// Add this to your getters
  String get productCondition => _productCondition;

// Add this to your methods
  void changeProductCondition(String condition) {
    if (condition != _productCondition) {
      _productCondition = condition;
      notifyListeners();
    }
  }
}
