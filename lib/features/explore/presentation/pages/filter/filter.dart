// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/screens/detailed_page.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/nomeric_field_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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

  String? _selectedLocation;
  String _selectedCondition = 'ALL';

  late HomeTreeState _initialState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialState = context.read<HomeTreeCubit>().state;

      if (widget.page == "child" || widget.page == 'ssssss') {
        context.read<HomeTreeCubit>().resetChildCategorySelection();
      }
      if (widget.page == "initial" || widget.page == "initial_filter") {
        context.read<HomeTreeCubit>().resetCatalogSelection();
      }
      context.read<HomeTreeCubit>().fetchFilteredPredictionValues();
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
    final cubit = context.read<HomeTreeCubit>();
    return WillPopScope(
      onWillPop: () async {
        cubit.emit(_initialState);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocConsumer<HomeTreeCubit, HomeTreeState>(
          listenWhen: (previous, current) {
            final previousFilters =
                Set.from(previous.generateFilterParameters());
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
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: CustomScrollView(
                    slivers: [
                      // Sticky Header
                      SliverAppBar(
                          pinned: true,
                          floating: false,
                          automaticallyImplyLeading: false,
                          scrolledUnderElevation: 0,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          flexibleSpace: Padding(
                            padding: EdgeInsets.only(
                              top: 8,
                              left: 16,
                              right: 16,
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Icon(Icons.clear_rounded),
                                          onTap: () {
                                            cubit.emit(_initialState);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Text(
                                          "Clear",
                                          style: TextStyle(
                                              fontSize: 15, color: Colors.blue),
                                        )
                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 3),
                                            child: Text(
                                              "Filter",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                              ],
                            ),
                          )),

                      // Main Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              _buildMainCategories(state, cubit),

                              if (state.selectedCatalog != null) ...[
                                SizedBox(
                                  height: 24,
                                ),
                                Text(
                                  state.selectedCatalog!.name,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                _buildChildCategories(state, cubit),
                              ],

                              if (state.predictedPriceFrom >= 0)
                                PriceRangeSlider(
                                  min: state.predictedPriceFrom >= 0
                                      ? state.predictedPriceFrom
                                      : 0,
                                  max: state.predictedPriceTo >= 1
                                      ? state.predictedPriceTo
                                      : 1,
                                  initialRange: state.priceFrom != null &&
                                          state.priceTo != null
                                      ? RangeValues(
                                          state.priceFrom!, state.priceTo!)
                                      : null,
                                ),
                              SizedBox(
                                height: 24,
                              ),

                              _buildConditionFilter(state),
                              SizedBox(
                                height: 24,
                              ),
                              _buildBargainToggle(state),
                              SizedBox(
                                height: 24,
                              ),
                              _buildSellerTypeFilter(state),
                              SizedBox(
                                height: 24,
                              ),
                              _buildLocationFilter(),
                              SizedBox(
                                height: 16,
                              ),

                              SizedBox(
                                height: 16,
                              ),
                              // Attributes Section
                              if (state.selectedChildCategory != null)
                                if (state.selectedChildCategory != null) ...[
                                  Text(
                                    'Additional',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Column(
                                    children: state.orderedAttributes
                                        .map((attribute) {
                                      final selectedValue = cubit
                                          .getSelectedAttributeValue(attribute);
                                      final selectedValues =
                                          cubit.getSelectedValues(attribute);

                                      // Color mapping
                                      final Map<String, Color> colorMap = {
                                        'Silver': Colors.grey[300]!,
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

                                      // Determine chip label based on selection type and count
                                      String chipLabel;
                                      if (attribute.filterWidgetType ==
                                          'oneSelectable') {
                                        chipLabel = selectedValue?.value ??
                                            attribute.filterText;
                                      } else {
                                        if (selectedValues.isEmpty) {
                                          chipLabel = attribute.filterText;
                                        } else if (selectedValues.length == 1) {
                                          chipLabel =
                                              selectedValues.first.value;
                                        } else {
                                          chipLabel =
                                              '${attribute.filterText}(${selectedValues.length})';
                                        }
                                      }

                                      Widget? colorIndicator;
                                      if (attribute.filterWidgetType ==
                                              'colorMultiSelectable' &&
                                          selectedValues.isNotEmpty) {
                                        if (selectedValues.length == 1) {
                                          // Single color indicator
                                          colorIndicator = Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: colorMap[selectedValues
                                                      .first.value] ??
                                                  Colors.grey,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: (colorMap[selectedValues
                                                            .first.value] ==
                                                        Colors.white)
                                                    ? Colors.grey
                                                    : Colors.transparent,
                                                width: 1,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Stacked color indicators
                                          colorIndicator = SizedBox(
                                            width: 40,
                                            height: 20,
                                            child: Stack(
                                              children: [
                                                for (int i = 0;
                                                    i < selectedValues.length;
                                                    i++)
                                                  Positioned(
                                                    top: 0,
                                                    bottom: 0,
                                                    left: i * 7.0,
                                                    child: Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        color: colorMap[
                                                                selectedValues[
                                                                        i]
                                                                    .value] ??
                                                            Colors.grey,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: (colorMap[
                                                                      selectedValues[
                                                                              i]
                                                                          .value] ==
                                                                  Colors.white)
                                                              ? Colors.grey
                                                              : Colors
                                                                  .transparent,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        }
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: FilterChip(
                                            showCheckmark: false,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                            label: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    if (colorIndicator !=
                                                        null) ...[
                                                      colorIndicator,
                                                      const SizedBox(width: 4),
                                                    ],
                                                    Text(
                                                      chipLabel,
                                                      style: TextStyle(
                                                        color: selectedValue !=
                                                                null
                                                            ? AppColors.black
                                                            : AppColors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 16,
                                                )
                                              ],
                                            ),
                                            side: BorderSide(
                                                width: 1,
                                                color:
                                                    AppColors.containerColor),
                                            shape: SmoothRectangleBorder(
                                              smoothness: 1,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            selected: selectedValue != null,
                                            backgroundColor: AppColors.white,
                                            selectedColor: AppColors.white,
                                            onSelected: (_) {
                                              if (attribute.values.isNotEmpty &&
                                                  mounted) {
                                                _showAttributeSelectionUI(
                                                    context, attribute);
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  // Add this after the existing attributes Column
                                  if (state.numericFields.isNotEmpty) ...[
                                    Column(
                                      children: state.numericFields
                                          .map((numericField) {
                                        final fieldValues =
                                            state.numericFieldValues[
                                                numericField.id];

                                        // Determine the display text based on selected values
                                        String displayText =
                                            numericField.fieldName;
                                        if (fieldValues != null) {
                                          final from = fieldValues['from'];
                                          final to = fieldValues['to'];

                                          if (from != null && to != null) {
                                            displayText = '$from - $to';
                                          } else if (from != null) {
                                            displayText = '≥ $from';
                                          } else if (to != null) {
                                            displayText = '≤ $to';
                                          }
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: FilterChip(
                                              showCheckmark: false,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 16),
                                              label: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    displayText,
                                                    style: TextStyle(
                                                      color: AppColors.black,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    size: 16,
                                                  )
                                                ],
                                              ),
                                              side: BorderSide(
                                                  width: 1,
                                                  color:
                                                      AppColors.containerColor),
                                              shape: SmoothRectangleBorder(
                                                smoothness: 1,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              selected: fieldValues != null,
                                              backgroundColor: AppColors.white,
                                              selectedColor: AppColors.white,
                                              onSelected: (_) {
                                                _showNumericFieldBottomSheet(
                                                    context, numericField);
                                              },
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 80,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      top: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: BlocBuilder<HomeTreeCubit, HomeTreeState>(
                      builder: (context, state) => _buildApplyButton(state),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showNumericFieldBottomSheet(
      BuildContext context, NomericFieldModel field) {
    final cubit = context.read<HomeTreeCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NumericFieldBottomSheet(
            field: field,
            initialValues: cubit.state.numericFieldValues[field.id],
            onRangeSelected: (from, to) {
              cubit.setNumericFieldRange(field.id, from, to);
            },
          ),
        ),
      ),
    );
  }

  void _showSelectionBottomSheet(
      BuildContext context, AttributeModel attribute) {
    Map<String, dynamic> temporarySelections = {};
    final cubit = context.read<HomeTreeCubit>();

    if (attribute.filterWidgetType == 'multiSelectable') {
      // Create a deep copy of current selections to avoid modifying the original state
      final currentSelections = cubit.getSelectedValues(attribute);
      temporarySelections[attribute.attributeKey] =
          List<AttributeValueModel>.from(currentSelections);
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: SmoothRectangleBorder(
        smoothness: 0.8,
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: StatefulBuilder(
            builder: (context, setState) {
              double calculateInitialSize(List<dynamic> values) {
                if (values.length >= 20) return 0.9;
                if (values.length >= 15) return 0.8;
                if (values.length >= 10) return 0.65;
                if (values.length >= 5) return 0.53;
                return values.length * 0.12;
              }

              return DraggableScrollableSheet(
                initialChildSize: calculateInitialSize(attribute.values),
                maxChildSize: attribute.values.length >= 20
                    ? 0.9
                    : calculateInitialSize(attribute.values),
                minChildSize: 0,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // New toolbar with centered title
                      SizedBox(
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Centered title
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  attribute.filterText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Left and right buttons
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  if (attribute.filterWidgetType ==
                                          'multiSelectable' &&
                                      cubit
                                          .getSelectedValues(attribute)
                                          .isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        cubit.clearSelectedAttribute(attribute);

                                        cubit.getAtributesForPost();
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        foregroundColor: AppColors.black,
                                      ),
                                      child: Text(
                                        'Clear',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  else if (cubit.getSelectedAttributeValue(
                                          attribute) !=
                                      null)
                                    TextButton(
                                      onPressed: () {
                                        cubit.clearSelectedAttribute(attribute);

                                        cubit.getAtributesForPost();
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0),
                                        foregroundColor: AppColors.black,
                                      ),
                                      child: Text(
                                        'clear',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 48),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: AppColors.containerColor,
                      ),
                      Expanded(
                        child: attribute.filterWidgetType == 'multiSelectable'
                            ? _buildMultiSelectList(
                                context,
                                attribute,
                                scrollController,
                                temporarySelections,
                                setState,
                              )
                            : _buildSingleSelectList(
                                context,
                                attribute,
                                scrollController,
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMultiSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
    Map<String, dynamic> temporarySelections,
    StateSetter setState,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: attribute.values.length,
            itemBuilder: (context, index) {
              final value = attribute.values[index];
              final selections = temporarySelections[attribute.attributeKey]
                      as List<AttributeValueModel>? ??
                  [];

              final isSelected = selections.contains(value);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selections.remove(value);
                      } else {
                        selections.add(value);
                      }
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.lightGray,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 17,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          value.value,
                          style: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.darkBackgroundGray,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 8),
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<HomeTreeCubit>();
                final selections = temporarySelections[attribute.attributeKey]
                    as List<AttributeValueModel>;

                if (selections.isEmpty) {
                  cubit.clearSelectedAttribute(attribute);

                  cubit.getAtributesForPost();
                } else {
                  cubit.clearSelectedAttribute(attribute);
                  for (var value in selections) {
                    cubit.selectAttributeValue(attribute, value);
                  }

                  cubit.getAtributesForPost();
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: SmoothRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply (${(temporarySelections[attribute.attributeKey] as List).length})',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
  ) {
    final cubit = context.read<HomeTreeCubit>();
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: attribute.values.length,
      itemBuilder: (context, index) {
        final value = attribute.values[index];
        final selectedValue = cubit.getSelectedAttributeValue(attribute);
        final isSelected =
            selectedValue?.attributeValueId == value.attributeValueId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isSelected) {
                cubit.clearSelectedAttribute(attribute);
              } else {
                cubit.selectAttributeValue(attribute, value);
              }
              Navigator.pop(context);
              cubit.getAtributesForPost();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.value,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isSelected ? AppColors.black : AppColors.darkGray,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.transparent,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : AppColors.white,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 17,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorMultiSelectDialog(
      BuildContext context, AttributeModel attribute) {
    final cubit = context.read<HomeTreeCubit>();
    Map<String, dynamic> temporarySelections = {};

    // Initialize temporary selections with current selections
    final currentSelections = cubit.getSelectedValues(attribute);
    temporarySelections[attribute.attributeKey] =
        List<AttributeValueModel>.from(currentSelections);

    final Map<String, Color> colorMap = {
      'Silver': Colors.grey[300]!,
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

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: SmoothRectangleBorder(
        smoothness: 0.8,
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: StatefulBuilder(
            builder: (context, setState) {
              double calculateInitialSize(List<dynamic> values) {
                if (values.length >= 20) return 0.9;
                if (values.length >= 15) return 0.8;
                if (values.length >= 10) return 0.65;
                if (values.length >= 5) return 0.5;
                return values.length * 0.08;
              }

              return DraggableScrollableSheet(
                initialChildSize: calculateInitialSize(attribute.values),
                maxChildSize: attribute.values.length >= 20
                    ? 0.9
                    : calculateInitialSize(attribute.values),
                minChildSize: 0,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  attribute.filterText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Ionicons.close),
                                    onPressed: () => Navigator.pop(context),
                                    color: AppColors.black,
                                  ),
                                  if (cubit
                                      .getSelectedValues(attribute)
                                      .isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        cubit.clearAllSelectedAttributes();
                                        cubit.getAtributesForPost();
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        foregroundColor: AppColors.black,
                                      ),
                                      child: Text(
                                        'Clear',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 48),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: AppColors.containerColor,
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: attribute.values.length,
                          itemBuilder: (context, index) {
                            final value = attribute.values[index];
                            final selections =
                                temporarySelections[attribute.attributeKey]
                                        as List<AttributeValueModel>? ??
                                    [];
                            final isSelected = selections.contains(value);
                            final color = colorMap[value.value] ?? Colors.grey;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selections.remove(value);
                                    } else {
                                      selections.add(value);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: color == Colors.white
                                                ? Colors.grey
                                                : Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          value.value,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isSelected
                                                ? AppColors.black
                                                : AppColors.darkGray,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.lightGray,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.white,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 17,
                                                color: AppColors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 32, top: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              final cubit = context.read<HomeTreeCubit>();
                              final selections =
                                  temporarySelections[attribute.attributeKey]
                                      as List<AttributeValueModel>;

                              if (selections.isEmpty) {
                                cubit.clearSelectedAttribute(attribute);
                              } else {
                                cubit.clearSelectedAttribute(attribute);
                                for (var value in selections) {
                                  cubit.selectAttributeValue(attribute, value);
                                }

                                cubit.getAtributesForPost(); // Add this line
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              shape: SmoothRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Apply (${(temporarySelections[attribute.attributeKey] as List).length})',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.white,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showAttributeSelectionUI(
      BuildContext context, AttributeModel attribute) {
    switch (attribute.filterWidgetType) {
      case 'colorMultiSelectable':
        _showColorMultiSelectDialog(context, attribute);
        break;
      case 'oneSelectable':
      case 'multiSelectable':
        _showSelectionBottomSheet(context, attribute);
        break;
    }
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
                color: isSelected ? AppColors.black : AppColors.blue,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            showCheckmark: true,
            selected: isSelected,
            onSelected: onSelected,
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryLight2,
            checkmarkColor: Colors.black,
            elevation: 0,
            pressElevation: 4,
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isSelected ? Colors.transparent : AppColors.containerColor,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularLocationChip(String location) {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: Hero(
        tag: 'chip_$location',
        child: Material(
          color: Colors.transparent,
          child: FilterChip(
            label: Text(
              location,
              style: TextStyle(
                color: _selectedLocation == location
                    ? AppColors.black
                    : AppColors.blue,
                fontWeight: _selectedLocation == location
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            showCheckmark: true,
            selected: _selectedLocation == location,
            onSelected: (selected) {
              setState(() {
                _selectedLocation = location;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryLight2,
            checkmarkColor: Colors.black,
            elevation: 0,
            pressElevation: 4,
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _selectedLocation == location
                    ? Colors.transparent
                    : AppColors.containerColor,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategories(HomeTreeState state, HomeTreeCubit cubit) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: state.catalogs?.isEmpty ?? true ? 0.0 : 1.0,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: state.catalogs?.map((category) {
              return _buildAnimatedFilterChip(
                label: category.name,
                onSelected: (selected) {
                  if (selected) {
                    cubit.selectCatalog(category);
                  } else {
                    cubit.resetCatalogSelection();
                  }
                },
                isSelected: category.id == state.selectedCatalog?.id,
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget _buildChildCategories(HomeTreeState state, HomeTreeCubit cubit) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity:
          state.selectedCatalog?.childCategories.isEmpty ?? true ? 0.0 : 1.0,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: state.selectedCatalog?.childCategories.map((childCategory) {
              return _buildAnimatedFilterChip(
                label: childCategory.name,
                onSelected: (selected) {
                  if (selected) {
                    cubit.selectChildCategory(childCategory);
                  } else {
                    cubit.resetChildCategorySelection();
                  }
                },
                isSelected: childCategory.id == state.selectedChildCategory?.id,
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget _buildSellerTypeFilter(HomeTreeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8),
          child: Text(
            'Seller Type',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: SmoothClipRRect(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(width: 1, color: AppColors.containerColor),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildSellerTypeOption('All', SellerType.ALL, state),
                  _buildSellerTypeOption(
                      'Individual', SellerType.INDIVIDUAL_SELLER, state),
                  _buildSellerTypeOption(
                      'Shop', SellerType.BUSINESS_SELLER, state),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerTypeOption(
      String label, SellerType value, HomeTreeState state) {
    final isSelected = state.sellerType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<HomeTreeCubit>().updateSellerType(value, true);
        },
        child: SmoothClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.containerColor : Colors.transparent,
            ),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.darkGray,
              ),
              child: Text(
                label,
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBargainToggle(HomeTreeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 12),
          child: Text(
            'Sorting',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            context.read<HomeTreeCubit>().toggleBargain(!state.bargain, true);
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: state.bargain
                        ? AppColors.primaryLight2
                        : Colors.transparent,
                    border: Border.all(
                      color: state.bargain
                          ? AppColors.primaryLight2
                          : AppColors.lighterGray,
                      width: 2.0,
                    ),
                  ),
                  child: state.bargain
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 1),
                child: Text(
                  'Borgain',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        InkWell(
          onTap: () {
            context.read<HomeTreeCubit>().toggleIsFree(!state.isFree, true);
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: state.isFree
                        ? AppColors.primaryLight2
                        : Colors.transparent,
                    border: Border.all(
                      color: state.isFree
                          ? AppColors.primaryLight2
                          : AppColors.lighterGray,
                      width: 2,
                    ),
                  ),
                  child: state.isFree
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 1),
                child: Text(
                  'For Free',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionFilter(HomeTreeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8),
          child: Text(
            'Condition',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: SmoothClipRRect(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(width: 1, color: AppColors.containerColor),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
              ),
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildSegmentOption('All', 'ALL', state),
                  _buildSegmentOption('New', 'NEW_PRODUCT', state),
                  _buildSegmentOption('Used', 'USED_PRODUCT', state),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentOption(String label, String value, HomeTreeState state) {
    final isSelected = state.condition == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<HomeTreeCubit>().updateCondition(value, true);
        },
        child: SmoothClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.containerColor : Colors.transparent,
            ),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.darkGray,
              ),
              child: Text(
                label,
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: SmoothClipRRect(
                  side: BorderSide(width: 1, color: AppColors.containerColor),
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Location',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGray,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          )
                        ],
                      ),
                    ),
                  ))),
          // Popular locations chips
          //  if (_selectedLocation?.isEmpty ?? true)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                _buildPopularLocationChip('Toshkent'),
                _buildPopularLocationChip('Buxoro'),
                _buildPopularLocationChip('Andijon'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(HomeTreeState state) {
    return Column(
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
                              (key, value) => MapEntry(key.attributeKey, value),
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
                            debugPrint("🐁🐁😡😡😡❤️❤️${state.priceFrom}");
                            debugPrint("🐁🐁😡😡😡❤️❤️${state.priceTo}");
                            context.pushNamed(RoutesByName.attributes, extra: {
                              'category': state.selectedCatalog,
                              'childCategory': state.selectedChildCategory,
                              'attributeState': attributeState,
                              'priceFrom': state.priceFrom,
                              'priceTo': state.priceTo,
                              'numericFieldState': {
                                'numericFields': state.numericFields,
                                'numericFieldValues': state.numericFieldValues,
                              },
                              'filterState': {
                                'bargain': state.bargain,
                                'isFree': state.isFree,
                                'condition': state.condition,
                                'sellerType': state.sellerType,
                              },
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
                            context
                                .pushNamed(RoutesByName.subcategories, extra: {
                              'category': state.selectedCatalog,
                              'priceFrom': state.priceFrom,
                              'priceTo': state.priceTo,
                              'filterState': {
                                'bargain': state.bargain,
                                'isFree': state.isFree,
                                'condition': state.condition,
                                'sellerType': state.sellerType,
                              },
                            });
                            context
                                .read<HomeTreeCubit>()
                                .resetCatalogSelection();
                          } else if (widget.page == "child") {
                            debugPrint("🐁🐁😡😡😡❤️❤️${widget.page}");
                            context.pushNamed(
                                RoutesByName.filterSecondaryResult,
                                extra: {
                                  'category': state.selectedCatalog,
                                  'priceFrom': state.priceFrom,
                                  'priceTo': state.priceTo,
                                  'filterState': {
                                    'bargain': state.bargain,
                                    'isFree': state.isFree,
                                    'condition': state.condition,
                                    'sellerType': state.sellerType,
                                  },
                                });
                          } else if (widget.page != "child" &&
                              widget.page != "ssssss" &&
                              widget.page != "initial" &&
                              widget.page != 'initial_filter') {
                            AppRouter.shellNavigatorHome.currentState?.popUntil(
                                (route) =>
                                    route.settings.name ==
                                    RoutesByName.subcategories);
                            context.pushNamed(
                                RoutesByName.filterSecondaryResult,
                                extra: {
                                  'category': state.selectedCatalog,
                                  'priceFrom': state.priceFrom,
                                  'priceTo': state.priceTo,
                                  'filterState': {
                                    'bargain': state.bargain,
                                    'isFree': state.isFree,
                                    'condition': state.condition,
                                    'sellerType': state.sellerType,
                                  },
                                });
                          } else {
                            debugPrint("🐁🐁😡😡😡❤️❤️${widget.page}");
                            context.read<HomeTreeCubit>().filtersTrigered();
                            context.read<HomeTreeCubit>().fetchSecondaryPage(0);
                          }

                          return;
                        }
                        if (state.selectedCatalog == null ||
                            state.selectedChildCategory == null) {
                          context.pop();
                          if (widget.page == 'initial_filter') {
                            context.read<HomeTreeCubit>().filtersTrigered();
                            context.read<HomeTreeCubit>().fetchInitialPage(0);
                          } else if (widget.page != 'initial' &&
                              widget.page != 'initial_filter') {
                            AppRouter.shellNavigatorHome.currentState
                                ?.popUntil((route) => route.isFirst);
                            context.pushNamed(RoutesByName.filterHomeResult,
                                extra: {
                                  'priceFrom': state.priceFrom,
                                  'priceTo': state.priceTo,
                                  'filterState': {
                                    'bargain': state.bargain,
                                    'isFree': state.isFree,
                                    'condition': state.condition,
                                    'sellerType': state.sellerType,
                                  },
                                });
                          } else {
                            context.pushNamed(RoutesByName.filterHomeResult,
                                extra: {
                                  'priceFrom': state.priceFrom,
                                  'priceTo': state.priceTo,
                                  'filterState': {
                                    'bargain': state.bargain,
                                    'isFree': state.isFree,
                                    'condition': state.condition,
                                    'sellerType': state.sellerType,
                                  },
                                });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 17),
                        shape: SmoothRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.filteredValuesRequestState ==
                              RequestState.inProgress)
                            const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                strokeCap: StrokeCap.round,
                                color: Colors.white,
                              ),
                            ),
                          if (state.filteredValuesRequestState !=
                              RequestState.inProgress)
                            Text(
                              'Show ${state.predictedFoundPublications} publications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                fontFamily: "Poppins",
                              ),
                            ),
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

class PriceRangeSlider extends StatefulWidget {
  final void Function(RangeValues)? onChanged;
  final RangeValues initialRange;
  final double min;
  final double max;

  PriceRangeSlider({
    super.key,
    this.onChanged,
    RangeValues? initialRange,
    required this.min,
    required this.max,
  }) : initialRange = initialRange ?? RangeValues(0, 1000);

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  late RangeValues _range;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleRangeChange(RangeValues values) {
    setState(() => _range = values);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      context.read<HomeTreeCubit>().setPriceRange(values.start, values.end);
      widget.onChanged?.call(values);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price range',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${_range.start.round()} - \$${_range.end.round()}',
                    style: TextStyle(
                      color: AppColors.blue.withOpacity(0.75),
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 5,
                activeTrackColor: AppColors.primaryLight2,
                inactiveTrackColor: Colors.grey[200],
                thumbColor: Colors.white,
                overlayColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  elevation: 2,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: RangeSlider(
                values: _range,
                min: widget.min,
                max: widget.max,
                onChanged: _handleRangeChange,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum SellerType {
  ALL,
  INDIVIDUAL_SELLER,
  BUSINESS_SELLER,
}
