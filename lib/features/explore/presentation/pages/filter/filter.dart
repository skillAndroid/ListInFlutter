import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';

// ignore: must_be_immutable
class FiltersPage extends StatefulWidget {
  String page;
  FiltersPage({super.key, required this.page});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  RangeValues _priceRange = RangeValues(0, 1000);
  String? _selectedLocation;
  String _selectedCondition = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.page == "child" || widget.page == 'ssssss') {
        context.read<HomeTreeCubit>().resetChildCategorySelection();
      }
      if (widget.page == "initial" || widget.page == "initial_filter") {
        context.read<HomeTreeCubit>().resetCatalogSelection();
      }
    });
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<HomeTreeCubit, HomeTreeState>(
        listenWhen: (previous, current) {
          final previousFilters = Set.from(previous.generateFilterParameters());
          final currentFilters = Set.from(current.generateFilterParameters());
          return !setEquals(previousFilters, currentFilters) ||
              previous.childCurrentPage != current.childCurrentPage;
        },
        listener: (context, state) {
          if (state.selectedCatalog != null ||
              state.selectedChildCategory != null) {
            _slideController.forward(from: 0);
          }
        },
        builder: (context, state) {
          final cubit = context.read<HomeTreeCubit>();

          return CustomScrollView(
            slivers: [
              // Sticky Header
              SliverAppBar(
                pinned: true,
                floating: true,
                elevation: 0,
                backgroundColor: Colors.white,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade50,
                          Colors.green.shade50,
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: _buildBreadcrumbs(state, cubit),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Range Slider
                      _buildPriceRangeSlider(),

                      // Condition Filter
                      _buildConditionFilter(),

                      // Location Filter
                      _buildLocationFilter(),

                      // Categories Section
                      if (state.selectedCatalog == null)
                        _buildMainCategories(state, cubit),

                      // Child Categories
                      if (state.selectedCatalog != null &&
                          state.selectedChildCategory == null)
                        _buildChildCategories(state, cubit),

                      // Attributes Section
                      if (state.selectedChildCategory != null)
                        ...state.orderedAttributes.map((attribute) =>
                            _buildAnimatedAttributeSection(
                                attribute, cubit, state)),

                      _buildApplyButton(state)
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbs(HomeTreeState state, HomeTreeCubit cubit) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBreadcrumbItem(
              "Categories", () => cubit.resetCatalogSelection(),
              isActive: state.selectedCatalog == null),
          if (state.selectedCatalog != null) ...[
            Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            _buildBreadcrumbItem(
              state.selectedCatalog!.name,
              () => cubit.resetChildCategorySelection(),
              isActive: state.selectedChildCategory == null,
            ),
          ],
          if (state.selectedChildCategory != null) ...[
            Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            _buildBreadcrumbItem(
              state.selectedChildCategory!.name,
              null,
              isActive: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(String text, Function()? onTap,
      {bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 16),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 100,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
            activeColor: Colors.blue.shade400,
            inactiveColor: Colors.grey.shade200,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_priceRange.start.round()}'),
              Text('\$${_priceRange.end.round()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategories(HomeTreeState state, HomeTreeCubit cubit) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: state.catalogs?.isEmpty ?? true ? 0.0 : 1.0,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: state.catalogs?.map((category) {
              return _buildAnimatedFilterChip(
                label: category.name,
                onSelected: (selected) {
                  cubit.selectCatalog(category);
                },
                isSelected: false,
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget _buildAnimatedFilterChip({
    required String label,
    required Function(bool) onSelected,
    required bool isSelected,
    Color? color,
  }) {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: Hero(
        tag: 'chip_$label',
        child: Material(
          color: Colors.transparent,
          child: FilterChip(
            label: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: onSelected,
            backgroundColor: Colors.white,
            selectedColor: Colors.blue.shade400,
            checkmarkColor: Colors.white,
            elevation: isSelected ? 2 : 0,
            pressElevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildChildCategories(HomeTreeState state, HomeTreeCubit cubit) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity:
          state.selectedCatalog?.childCategories.isEmpty ?? true ? 0.0 : 1.0,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: state.selectedCatalog!.childCategories.map((childCategory) {
          return _buildAnimatedFilterChip(
            label: childCategory.name,
            onSelected: (selected) {
              cubit.selectChildCategory(childCategory);
            },
            isSelected: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedAttributeSection(
    dynamic attribute,
    HomeTreeCubit cubit,
    HomeTreeState state,
  ) {
    final isMultiSelect = attribute.filterWidgetType == 'multiSelectable' ||
        attribute.filterWidgetType == 'colorMultiSelectable';

    return AnimatedSlide(
      duration: Duration(milliseconds: 400),
      offset: Offset(0, 0),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                attribute.filterText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: attribute.values.length,
                itemBuilder: (context, index) {
                  final value = attribute.values[index];
                  final isSelected = isMultiSelect
                      ? cubit.getSelectedValues(attribute).contains(value)
                      : cubit
                              .getSelectedAttributeValue(attribute)
                              ?.attributeValueId ==
                          value.attributeValueId;

                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: _buildAnimatedFilterChip(
                      label: value.value,
                      isSelected: isSelected,
                      onSelected: (selected) {
                        if (isMultiSelect) {
                          if (isSelected) {
                            cubit.clearSelectedAttributeValue(attribute, value);
                          } else {
                            cubit.selectAttributeValue(attribute, value);
                          }
                        } else {
                          if (isSelected) {
                            cubit.clearSelectedAttribute(attribute);
                          } else {
                            cubit.clearSelectedAttribute(attribute);
                            cubit.selectAttributeValue(attribute, value);
                          }
                        }
                        cubit.getAtributesForPost();
                      },
                      color:
                          attribute.filterWidgetType == 'colorMultiSelectable'
                              ? _getColorFromName(value.value)
                              : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionFilter() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildConditionChip('All', 'all'),
              SizedBox(width: 8),
              _buildConditionChip('New', 'new'),
              SizedBox(width: 8),
              _buildConditionChip('Used', 'used'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String label, String value) {
    return AnimatedScale(
      duration: Duration(milliseconds: 200),
      scale: _selectedCondition == value ? 1.05 : 1.0,
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCondition == value,
        onSelected: (selected) {
          setState(() {
            _selectedCondition = value;
          });
        },
        selectedColor: Colors.blue.shade400,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          color:
              _selectedCondition == value ? Colors.white : Colors.grey.shade800,
          fontWeight:
              _selectedCondition == value ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade400, size: 20),
              SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter location...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.blue.shade400),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.my_location, color: Colors.blue.shade400),
                    onPressed: () {
                      // Handle get current location
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
              ),
            ),
          ),
          // Popular locations chips
          if (_selectedLocation?.isEmpty ?? true)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPopularLocationChip('New York'),
                  _buildPopularLocationChip('Los Angeles'),
                  _buildPopularLocationChip('Chicago'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularLocationChip(String location) {
    return AnimatedScale(
      duration: Duration(milliseconds: 200),
      scale: _selectedLocation == location ? 1.05 : 1.0,
      child: ActionChip(
        label: Text(
          location,
          style: TextStyle(
            color: _selectedLocation == location
                ? Colors.white
                : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        backgroundColor: _selectedLocation == location
            ? Colors.blue.shade400
            : Colors.grey.shade100,
        onPressed: () {
          setState(() {
            _selectedLocation = location;
          });
        },
        elevation: 0,
        pressElevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildApplyButton(HomeTreeState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.selectedCatalog != null &&
                                state.selectedChildCategory != null) {
                              final attributeState = {
                                'selectedValues': state.selectedValues,
                                'selectedAttributeValues':
                                    state.selectedAttributeValues.map(
                                  (key, value) =>
                                      MapEntry(key.attributeKey, value),
                                ),
                                'dynamicAttributes': state.dynamicAttributes,
                                'attributeRequests': state.attributeRequests,
                              };
                              context.pop();
                              if (widget.page == "initial" ||
                                  widget.page == "child" ||
                                  widget.page == "initial_filter" ||
                                  widget.page == 'ssssss') {
                                debugPrint("🐁🐁😡😡😡❤️❤️${widget.page}");
                                context
                                    .pushNamed(RoutesByName.attributes, extra: {
                                  'category': state.selectedCatalog,
                                  'childCategory': state.selectedChildCategory,
                                  'attributeState': attributeState,
                                });
                                context
                                    .read<HomeTreeCubit>()
                                    .resetChildCategorySelection();
                              } else {
                                context.read<HomeTreeCubit>().filtersTrigered();
                                context.read<HomeTreeCubit>().fetchChildPage(0);
                              }

                              return;
                            }

                            if (state.selectedCatalog != null) {
                              context.pop();
                              if (widget.page == 'initial' ||
                                  widget.page == 'initial_filter') {
                                context.pushNamed(RoutesByName.subcategories,
                                    extra: {
                                      'category': state.selectedCatalog,
                                    });
                                context
                                    .read<HomeTreeCubit>()
                                    .resetCatalogSelection();
                              } else if (widget.page == "child") {
                                debugPrint("🐁🐁😡😡😡❤️❤️${widget.page}");
                                context.pushNamed(
                                    RoutesByName.filterSecondaryResult,
                                    extra: {'category': state.selectedCatalog});
                              } else {
                                debugPrint("🐁🐁😡😡😡❤️❤️${widget.page}");
                                context.read<HomeTreeCubit>().filtersTrigered();
                                context
                                    .read<HomeTreeCubit>()
                                    .fetchSecondaryPage(0);
                              }

                              return;
                            }
                            if (state.selectedCatalog == null ||
                                state.selectedChildCategory == null) {
                              context.pop();
                              if (widget.page == 'initial_filter') {
                                context.read<HomeTreeCubit>().filtersTrigered();
                                context
                                    .read<HomeTreeCubit>()
                                    .fetchInitialPage(0);
                              } else {
                                context
                                    .pushNamed(RoutesByName.filterHomeResult);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade400,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.check_circle_outline, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? _getColorFromName(String colorName) {
    final colorMap = {
      'Silver': Colors.grey[300],
      'Pink': Colors.pink,
      'Rose Gold': Color(0xFFB76E79),
      'Space Gray': Color(0xFF4A4A4A),
      'Blue': Colors.blue,
      'Yellow': Colors.yellow,
      'Green': Colors.green,
      'Purple': Colors.purple,
      'White': Colors.white,
      'Red': Colors.red,
      'Black': Colors.black,
    };
    return colorMap[colorName];
  }
}

class CustomChipTheme extends ChipThemeData {
  static ChipThemeData get theme => ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade400,
        disabledColor: Colors.grey.shade200,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        secondaryLabelStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      );
}

extension ColorUtils on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
