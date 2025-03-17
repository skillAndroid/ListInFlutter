// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, constant_identifier_names

import 'dart:async';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/config/theme/color_map.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/language/localisation_cache.dart';
import 'package:list_in/core/router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/filters_widgets/numeric_fields_bototm_sheet.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_value_model.dart';
import 'package:list_in/features/post/data/models/category_tree/nomeric_field_model.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late LocalizationCache _localizationCache;

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
    final localizations = AppLocalizations.of(context)!;
    final languageCode = context.select<LanguageBloc, String>((bloc) =>
        bloc.state is LanguageLoaded
            ? (bloc.state as LanguageLoaded).languageCode
            : AppLanguages.english);
    _localizationCache = LocalizationCache(languageCode);
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
                            padding: const EdgeInsets.only(
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
                                          child:
                                              const Icon(Icons.clear_rounded),
                                          onTap: () {
                                            cubit.emit(_initialState);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        InkWell(
                                          onTap: () {
                                            cubit.clearAllNumericFields();
                                            cubit.clearAllSelectedAttributes();
                                            cubit.clearLocationSelection();
                                            cubit.clearPriceRange();
                                            cubit.updateSellerType(
                                                SellerType.ALL, true, '');
                                            cubit.updateCondition(
                                                'ALL', true, '');
                                            cubit.toggleBargain(
                                                false, true, '');
                                            cubit.toggleIsFree(false, true, '');
                                            AppRouter
                                                .shellNavigatorHome.currentState
                                                ?.popUntil(
                                              (route) => route.isFirst,
                                            );
                                            context.pop();
                                            cubit.resetChildCategorySelection();
                                            cubit.resetCatalogSelection();
                                          },
                                          child: Text(
                                            localizations.clear_,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 3),
                                            child: Text(
                                              localizations.filter,
                                              style: const TextStyle(
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

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.page != 'result_page') ...[
                                Text(
                                  localizations.category,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                _buildMainCategories(
                                    state, cubit, languageCode),
                                if (state.selectedCatalog != null) ...[
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Text(
                                    state.selectedCatalog!.name,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  _buildChildCategories(
                                      state, cubit, languageCode),
                                ],
                              ],

                              if (widget.page == "result_page") ...[
                                Text(
                                  localizations.searching,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  state.searchText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              if (state.predictedPriceFrom >= 0)
                                PriceRangeSlider(
                                  localizations: localizations,
                                  min: state.predictedPriceFrom,
                                  max: state.predictedPriceTo,
                                  initialRange: state.priceFrom != null &&
                                          state.priceTo != null
                                      ? RangeValues(
                                          state.priceFrom!, state.priceTo!)
                                      : null,
                                  totalResults: state
                                      .predictedFoundPublications, // Pass the total results

                                  onChanged: (RangeValues values) {
                                    context.read<HomeTreeCubit>().setPriceRange(
                                        values.start, values.end, "");
                                  },
                                ),
                              const SizedBox(
                                height: 24,
                              ),

                              _buildConditionFilter(state, localizations),
                              const SizedBox(
                                height: 24,
                              ),
                              _buildBargainToggle(state, localizations),
                              const SizedBox(
                                height: 24,
                              ),
                              _buildSellerTypeFilter(state, localizations),
                              const SizedBox(
                                height: 24,
                              ),
                              buildLocationFilter(
                                  context, localizations, state, cubit),
                              const SizedBox(
                                height: 16,
                              ),

                              const SizedBox(
                                height: 16,
                              ),
                              // Attributes Section
                              if (state.selectedChildCategory != null)
                                if (state.selectedChildCategory != null) ...[
                                  _buildAttributesSection(state, cubit,
                                      languageCode, context, localizations),
                                ],
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: const SizedBox(
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
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      top: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: BlocBuilder<HomeTreeCubit, HomeTreeState>(
                      builder: (context, state) =>
                          _buildApplyButton(state, localizations),
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

// First, let's create a separate widget for the attributes section
  Widget _buildAttributesSection(
      HomeTreeState state,
      HomeTreeCubit cubit,
      String languageCode,
      BuildContext context,
      AppLocalizations localizations) {
    if (state.selectedChildCategory == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.additional,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
        // Attributes list
        Column(
          children: state.orderedAttributes.map((attribute) {
            return _buildAttributeChip(
              attribute: attribute,
              cubit: cubit,
              languageCode: languageCode,
              context: context,
              localizations: localizations,
            );
          }).toList(),
        ),
        // Numeric fields
        if (state.numericFields.isNotEmpty)
          Column(
            children: state.numericFields.map((numericField) {
              return _buildNumericFieldChip(
                numericField: numericField,
                state: state,
                context: context,
              );
            }).toList(),
          ),
      ],
    );
  }

// Helper widget for attribute chips
  Widget _buildAttributeChip({
    required AttributeModel attribute,
    required HomeTreeCubit cubit,
    required String languageCode,
    required BuildContext context,
    required AppLocalizations localizations,
  }) {
    final selectedValue = cubit.getSelectedAttributeValue(attribute);
    // Get selected values and ensure correct typing
    final dynamic rawSelectedValues = cubit.getSelectedValues(attribute);
    final List<AttributeValueModel> selectedValues;

    // Handle different possible types of rawSelectedValues
    if (rawSelectedValues == null) {
      selectedValues = <AttributeValueModel>[];
    } else if (rawSelectedValues is List<AttributeValueModel>) {
      selectedValues = rawSelectedValues;
    } else if (rawSelectedValues is List) {
      // Cast each element if possible
      selectedValues =
          rawSelectedValues.whereType<AttributeValueModel>().toList();
    } else {
      // Fallback to empty list if unexpected type
      selectedValues = <AttributeValueModel>[];
    }

    // Use the cache instead of calling getLocalizedText directly
    String chipLabel;
    if (attribute.filterWidgetType == 'oneSelectable') {
      chipLabel = selectedValue?.value != null
          ? _localizationCache.getText(selectedValue?.value,
              selectedValue?.valueUz, selectedValue?.valueRu)
          : _localizationCache.getText(attribute.filterText,
              attribute.filterTextUz, attribute.filterTextRu);
    } else {
      if (selectedValues.isEmpty) {
        chipLabel = _localizationCache.getText(attribute.filterText,
            attribute.filterTextUz, attribute.filterTextRu);
      } else if (selectedValues.length == 1) {
        chipLabel = _localizationCache.getText(selectedValues.first.value,
            selectedValues.first.valueUz, selectedValues.first.valueRu);
      } else {
        final baseText = _localizationCache.getText(attribute.filterText,
            attribute.filterTextUz, attribute.filterTextRu);
        chipLabel = '$baseText(${selectedValues.length})';
      }
    }

    // Color indicator logic with proper typing
    Widget? colorIndicator;
    if (attribute.filterWidgetType == 'colorMultiSelectable' &&
        selectedValues.isNotEmpty) {
      colorIndicator = _buildColorIndicator(selectedValues);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: FilterChip(
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          label: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (colorIndicator != null) ...[
                    colorIndicator,
                    const SizedBox(width: 4),
                  ],
                  Text(
                    chipLabel,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              )
            ],
          ),
          side: const BorderSide(width: 1, color: AppColors.containerColor),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 24,
              cornerSmoothing: 0.8,
            ),
          ),
          selected: selectedValue != null,
          backgroundColor: AppColors.white,
          selectedColor: AppColors.white,
          onSelected: (_) {
            if (attribute.values.isNotEmpty && context.mounted) {
              _showAttributeSelectionUI(context, attribute, localizations);
            }
          },
        ),
      ),
    );
  }

// Helper widget for color indicators (now accepts just the selected values)
  Widget? _buildColorIndicator(List<AttributeValueModel> selectedValues) {
    if (selectedValues.isEmpty) {
      return null;
    }

    if (selectedValues.length == 1) {
      // Single color indicator
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: colorMap[selectedValues.first.value] ?? Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(
            color: (colorMap[selectedValues.first.value] == Colors.white)
                ? Colors.grey
                : Colors.transparent,
            width: 1,
          ),
        ),
      );
    } else {
      // Stacked color indicators
      return SizedBox(
        width: 40,
        height: 20,
        child: Stack(
          children: [
            for (int i = 0; i < selectedValues.length; i++)
              Positioned(
                top: 0,
                bottom: 0,
                left: i * 7.0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorMap[selectedValues[i].value] ?? Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (colorMap[selectedValues[i].value] == Colors.white)
                          ? Colors.grey
                          : Colors.transparent,
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

// Helper widget for numeric field chips
  Widget _buildNumericFieldChip({
    required NomericFieldModel numericField,
    required HomeTreeState state,
    required BuildContext context,
  }) {
    final fieldValues = state.numericFieldValues[numericField.id];

    // Determine the display text based on selected values
    String displayText = numericField.fieldName;
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: FilterChip(
          showCheckmark: false,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          label: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayText,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              )
            ],
          ),
          side: BorderSide(width: 1, color: AppColors.containerColor),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 24,
              cornerSmoothing: 0.8,
            ),
          ),
          selected: fieldValues != null,
          backgroundColor: AppColors.white,
          selectedColor: AppColors.white,
          onSelected: (_) {
            _showNumericFieldBottomSheet(context, numericField);
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
              cubit.fetchFilteredPredictionValues();
            },
          ),
        ),
      ),
    );
  }

  void _showSelectionBottomSheet(BuildContext context, AttributeModel attribute,
      AppLocalizations localizations) {
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
        borderRadius: SmoothBorderRadius(
          cornerRadius: 10,
          cornerSmoothing: 0.7,
        ),
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
                  return BlocSelector<LanguageBloc, LanguageState, String>(
                    selector: (state) => state is LanguageLoaded
                        ? state.languageCode
                        : AppLanguages.english,
                    builder: (context, languageCode) {
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
                                      getLocalizedText(
                                          attribute.filterText,
                                          attribute.filterTextUz,
                                          attribute.filterTextRu,
                                          languageCode),
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
                                            cubit.clearSelectedAttribute(
                                                attribute);

                                            cubit.getAtributesForPost();
                                            cubit
                                                .fetchFilteredPredictionValues();
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            foregroundColor: AppColors.black,
                                          ),
                                          child: Text(
                                            localizations.clear_,
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
                                            cubit.clearSelectedAttribute(
                                                attribute);

                                            cubit.getAtributesForPost();
                                            cubit
                                                .fetchFilteredPredictionValues();
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 0),
                                            foregroundColor: AppColors.black,
                                          ),
                                          child: Text(
                                            localizations.clear_,
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
                            color: AppColors.white,
                          ),
                          Expanded(
                            child:
                                attribute.filterWidgetType == 'multiSelectable'
                                    ? _buildMultiSelectList(
                                        context,
                                        attribute,
                                        scrollController,
                                        temporarySelections,
                                        setState,
                                        languageCode,
                                        localizations)
                                    : _buildSingleSelectList(
                                        context,
                                        attribute,
                                        scrollController,
                                        languageCode,
                                      ),
                          ),
                        ],
                      );
                    },
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
    String languageCode,
    AppLocalizations localizations,
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
                          getLocalizedText(
                            value.value,
                            value.valueUz,
                            value.valueRu,
                            languageCode,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.darkBackgroundGray,
                            fontWeight: FontWeight.w500,
                          ),
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
                  cubit.fetchFilteredPredictionValues();
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              child: Text(
                '${localizations.apply} (${(temporarySelections[attribute.attributeKey] as List).length})',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontFamily: Constants.Arial,
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
    String languageCode,
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
              cubit.fetchFilteredPredictionValues();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getLocalizedText(
                        value.value,
                        value.valueUz,
                        value.valueRu,
                        languageCode,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isSelected ? AppColors.black : AppColors.darkGray,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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

  void _showColorMultiSelectDialog(BuildContext context,
      AttributeModel attribute, AppLocalizations localizations) {
    final cubit = context.read<HomeTreeCubit>();
    Map<String, dynamic> temporarySelections = {};

    // Initialize temporary selections with current selections
    final currentSelections = cubit.getSelectedValues(attribute);
    temporarySelections[attribute.attributeKey] =
        List<AttributeValueModel>.from(currentSelections);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
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
                  return BlocSelector<LanguageBloc, LanguageState, String>(
                    selector: (state) => state is LanguageLoaded
                        ? state.languageCode
                        : AppLanguages.english,
                    builder: (context, languageCode) {
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
                                      getLocalizedText(
                                        attribute.filterText,
                                        attribute.filterTextUz,
                                        attribute.filterTextRu,
                                        languageCode,
                                      ),
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
                                            cubit
                                                .fetchFilteredPredictionValues();
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            foregroundColor: AppColors.black,
                                          ),
                                          child: Text(
                                            localizations.clear_,
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
                                final color =
                                    colorMap[value.value] ?? Colors.grey;

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
                                              getLocalizedText(
                                                  value.value,
                                                  value.valueUz,
                                                  value.valueRu,
                                                  languageCode),
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
                                            duration: const Duration(
                                                milliseconds: 200),
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
                                  final selections = temporarySelections[
                                          attribute.attributeKey]
                                      as List<AttributeValueModel>;

                                  if (selections.isEmpty) {
                                    cubit.clearSelectedAttribute(attribute);
                                  } else {
                                    cubit.clearSelectedAttribute(attribute);
                                    for (var value in selections) {
                                      cubit.selectAttributeValue(
                                          attribute, value);
                                    }

                                    cubit.getAtributesForPost();
                                    cubit.fetchFilteredPredictionValues();
                                  }
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  '${localizations.clear_} (${(temporarySelections[attribute.attributeKey] as List).length})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white,
                                    fontFamily: Constants.Arial,
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
              );
            },
          ),
        );
      },
    );
  }

  void _showAttributeSelectionUI(BuildContext context, AttributeModel attribute,
      AppLocalizations localizations) {
    switch (attribute.filterWidgetType) {
      case 'colorMultiSelectable':
        _showColorMultiSelectDialog(context, attribute, localizations);
        break;
      case 'oneSelectable':
      case 'multiSelectable':
        _showSelectionBottomSheet(context, attribute, localizations);
        break;
    }
  }

  Widget _buildAnimatedFilterChip({
    required String label,
    required Function(bool) onSelected,
    required bool isSelected,
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
                color: isSelected ? AppColors.white : AppColors.blue,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            showCheckmark: true,
            selected: isSelected,
            onSelected: onSelected,
            backgroundColor: Colors.white,
            selectedColor: CupertinoColors.activeGreen,
            checkmarkColor: Colors.white,
            elevation: 0,
            pressElevation: 4,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 0.5,
              ),
              side: BorderSide(
                color:
                    isSelected ? Colors.transparent : AppColors.containerColor,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategories(
      HomeTreeState state, HomeTreeCubit cubit, String languageCode) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: state.catalogs?.isEmpty ?? true ? 0.0 : 1.0,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: state.catalogs?.map((category) {
              // Use the cache instead of calling getLocalizedText directly
              final label = _localizationCache.getText(
                  category.name, category.nameUz, category.nameRu);

              return _buildAnimatedFilterChip(
                label: label,
                onSelected: (selected) {
                  if (selected) {
                    cubit.selectCatalog(category);
                  } else {
                    cubit.resetCatalogSelection();
                  }
                  cubit.fetchFilteredPredictionValues();
                },
                isSelected: category.id == state.selectedCatalog?.id,
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget _buildChildCategories(
      HomeTreeState state, HomeTreeCubit cubit, String languageCode) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity:
          state.selectedCatalog?.childCategories.isEmpty ?? true ? 0.0 : 1.0,
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: state.selectedCatalog?.childCategories.map((childCategory) {
              // Use the cache
              final label = _localizationCache.getText(childCategory.name,
                  childCategory.nameUz, childCategory.nameRu);

              return _buildAnimatedFilterChip(
                label: label,
                onSelected: (selected) {
                  if (selected) {
                    cubit.selectChildCategory(childCategory);
                  } else {
                    cubit.resetChildCategorySelection();
                  }
                  cubit.fetchFilteredPredictionValues();
                },
                isSelected: childCategory.id == state.selectedChildCategory?.id,
              );
            }).toList() ??
            [],
      ),
    );
  }

  Widget _buildSellerTypeFilter(
      HomeTreeState state, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8),
          child: Text(
            localizations.seller_type,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: Container(
            decoration: ShapeDecoration(
              color: AppColors.white,
              shape: SmoothRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: AppColors.containerColor,
                ),
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 24,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildSellerTypeOption(
                    localizations.all, SellerType.ALL, state),
                _buildSellerTypeOption(localizations.individual,
                    SellerType.INDIVIDUAL_SELLER, state),
                _buildSellerTypeOption(
                    localizations.shop, SellerType.BUSINESS_SELLER, state),
              ],
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
          context.read<HomeTreeCubit>().updateSellerType(value, true, '');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                fontFamily: Constants.Arial,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.darkGray,
              ),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: Constants.Arial,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBargainToggle(
      HomeTreeState state, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 12),
          child: Text(
            localizations.sorting,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            context
                .read<HomeTreeCubit>()
                .toggleBargain(!state.bargain, true, '');
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 6,
                  cornerSmoothing: 0.8,
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: state.bargain
                        ? CupertinoColors.activeGreen
                        : Colors.transparent,
                    border: Border.all(
                      color: state.bargain
                          ? CupertinoColors.activeGreen
                          : AppColors.lighterGray,
                      width: 2.0,
                    ),
                  ),
                  child: state.bargain
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 1),
                child: Text(
                  localizations.bargain,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        InkWell(
          onTap: () {
            context.read<HomeTreeCubit>().toggleIsFree(!state.isFree, true, '');
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 6,
                  cornerSmoothing: 0.8,
                ),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: state.isFree
                        ? CupertinoColors.activeGreen
                        : Colors.transparent,
                    border: Border.all(
                      color: state.isFree
                          ? CupertinoColors.activeGreen
                          : AppColors.lighterGray,
                      width: 2,
                    ),
                  ),
                  child: state.isFree
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 1),
                child: Text(
                  localizations.for_free,
                  style: const TextStyle(
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

  Widget _buildConditionFilter(
      HomeTreeState state, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8),
          child: Text(
            localizations.condition,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: Container(
            decoration: ShapeDecoration(
              color: AppColors.white,
              shape: SmoothRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: AppColors.containerColor,
                ),
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 24,
                  cornerSmoothing: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildSegmentOption(localizations.all, 'ALL', state),
                _buildSegmentOption(
                    localizations.condition_new, 'NEW_PRODUCT', state),
                _buildSegmentOption(
                    localizations.condition_used, 'USED_PRODUCT', state),
              ],
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
          context.read<HomeTreeCubit>().updateCondition(value, true, "");
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                fontFamily: Constants.Arial,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.darkGray,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: Constants.Arial,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Location filter widget
  Widget buildLocationFilter(
      BuildContext context,
      AppLocalizations localizations,
      HomeTreeState state,
      HomeTreeCubit cubit) {
    debugPrint('locations: ${state.locations?.length}');
    debugPrint('selected country: ${state.selectedCountry?.value}');
    debugPrint('selected state: ${state.selectedState?.value}');
    debugPrint('selected county: ${state.selectedCounty?.value}');
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.location,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Location selection button
          GestureDetector(
            onTap: () {
              _showLocationBottomSheet(context, localizations);
            },
            child: AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.containerColor,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                width: double.infinity,
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.locationDisplayName ??
                            localizations.selectLocation,
                        style: TextStyle(
                          fontSize: 16,
                          color: state.locationDisplayName != null
                              ? Colors.black
                              : AppColors.darkGray,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          if (state.locationDisplayName != null)
                            GestureDetector(
                              behavior: HitTestBehavior
                                  .opaque, // Prevents tap from passing through
                              onTap: () {
                                cubit.clearLocationSelection();
                              },

                              child: Container(
                                padding: EdgeInsets.all(4),
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGray,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Only show popular locations if no location is selected
          if (state.selectedState == null)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildPopularLocations(context, state, cubit),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPopularLocations(
      BuildContext context, HomeTreeState state, HomeTreeCubit cubit) {
    final popularStates = state.selectedCountry?.states?.take(5).toList() ?? [];

    return popularStates.map((stateItem) {
      final stateName = stateItem.valueRu ?? stateItem.value ?? '';

      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            cubit.selectState(stateItem.stateId!);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 1,
                color: AppColors.containerColor,
              ),
            ),
            child: Text(
              stateName,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
    }).toList();
  }

// Replace the _showLocationBottomSheet method with this nested approach
  void _showLocationBottomSheet(
      BuildContext context, AppLocalizations localizations) {
    final cubit = context.read<HomeTreeCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 16,
          cornerSmoothing: 0.7,
        ),
      ),
      builder: (context) {
        return BlocProvider.value(
            value: cubit,
            child:
                _buildNestedSelectionContent(context, localizations, setState));
      },
    );
  }

  Widget _buildNestedSelectionContent(BuildContext context,
      AppLocalizations localizations, StateSetter setSheetState) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        final cubit = context.read<HomeTreeCubit>();
        final states = state.selectedCountry?.states ?? [];

        // Debug information to verify selections
        debugPrint('Selected country: ${state.selectedCountry?.value}');
        debugPrint('Selected state: ${state.selectedState?.value}');
        debugPrint('Selected county: ${state.selectedCounty?.value}');

        return ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.8,
          ),
          child: Container(
            color: AppColors.white,
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.95,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Select location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the layout
                  ],
                ),
                Divider(color: AppColors.containerColor),

                // States list
                Expanded(
                  child: ListView.builder(
                    itemCount: states.length,
                    itemBuilder: (context, index) {
                      final stateItem = states[index];

                      // Strict comparison to ensure only the actually selected state appears selected
                      final isSelected = state.selectedState != null &&
                          state.selectedState!.stateId == stateItem.stateId;

                      // Only expand if actually selected
                      final isExpanded = isSelected;
                      final hasCounties =
                          stateItem.counties?.isNotEmpty == true;

                      return Column(
                        children: [
                          // State item
                          ListTile(
                            title: Text(
                              stateItem.valueRu ?? stateItem.value ?? '',
                              style: TextStyle(
                                // Only apply bold/color if actually selected
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                              ),
                            ),
                            trailing: hasCounties
                                ? Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  )
                                : (isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : null),
                            onTap: () {
                              if (hasCounties) {
                                if (isSelected) {
                                  // If already selected, just toggle expansion
                                  // In this implementation, we'll just deselect it
                                  cubit.clearLocationSelection();
                                } else {
                                  // Select this state
                                  cubit.selectState(stateItem.stateId!);
                                }
                                setSheetState(() {});
                              } else {
                                // No counties, just select the state and close
                                cubit.selectState(stateItem.stateId!);
                                Navigator.pop(context);
                              }
                            },
                          ),

                          // Counties list (animated expansion)
                          if (hasCounties && isExpanded)
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.only(left: 16),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: stateItem.counties?.length ?? 0,
                                itemBuilder: (context, countyIndex) {
                                  final countyItem =
                                      stateItem.counties![countyIndex];

                                  // Strict comparison for county selection
                                  final isCountySelected =
                                      state.selectedCounty != null &&
                                          state.selectedCounty!.countyId ==
                                              countyItem.countyId;

                                  return ListTile(
                                    title: Text(
                                      countyItem.valueRu ??
                                          countyItem.value ??
                                          '',
                                      style: TextStyle(
                                        fontWeight: isCountySelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isCountySelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    trailing: isCountySelected
                                        ? Icon(
                                            Icons.check,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )
                                        : null,
                                    onTap: () {
                                      cubit.selectCounty(countyItem.countyId!);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// debug
  Widget _buildApplyButton(
      HomeTreeState state, AppLocalizations localizations) {
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
                                'country': state.selectedCountry,
                                'state': state.selectedState,
                                'county': state.selectedCounty,
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
                                'country': state.selectedCountry,
                                'state': state.selectedState,
                                'county': state.selectedCounty,
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
                                    'country': state.selectedCountry,
                                    'state': state.selectedState,
                                    'county': state.selectedCounty,
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
                                    'country': state.selectedCountry,
                                    'state': state.selectedState,
                                    'county': state.selectedCounty,
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
                              widget.page != 'initial_filter' &&
                              widget.page != 'result_page') {
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
                                    'country': state.selectedCountry,
                                    'state': state.selectedState,
                                    'county': state.selectedCounty,
                                  },
                                });
                          } else if (widget.page == 'result_page') {
                            context.read<HomeTreeCubit>().filtersTrigered();
                            context.read<HomeTreeCubit>().searchPage(0);
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
                                    'country': state.selectedCountry,
                                    'state': state.selectedState,
                                    'county': state.selectedCounty,
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
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 24,
                            cornerSmoothing: 0.7,
                          ),
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
                              _getPublicationCountText(
                                  state.predictedFoundPublications,
                                  localizations),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                fontFamily: Constants.Arial,
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

  String _getPublicationCountText(int count, AppLocalizations localizations) {
    if (count == 0) {
      return localizations.no_items_found;
    } else if (count >= 1000) {
      final thousands = (count / 1000).floor();
      return '${localizations.show_more_than} ${thousands}k ${localizations.publication_options}';
    } else {
      return '${localizations.show} ${count.toString()} ${localizations.publications}';
    }
  }
}

class PriceRangeSlider extends StatefulWidget {
  final void Function(RangeValues)? onChanged;
  final RangeValues? initialRange;
  final double min;
  final double max;
  final int totalResults;
  final AppLocalizations localizations;

  const PriceRangeSlider({
    super.key,
    this.onChanged,
    this.initialRange,
    required this.min,
    required this.max,
    required this.totalResults,
    required this.localizations,
  });

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  late RangeValues _currentRange;
  Timer? _debounceTimer;

  // Safe default values
  static const double _defaultMin = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeRange();
  }

  @override
  void didUpdateWidget(PriceRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      _initializeRange();
    }
  }

  double _getSafeMin() {
    // Ensure min is a valid finite number
    if (!widget.min.isFinite || widget.min < 0) {
      return _defaultMin;
    }
    return widget.min;
  }

  double _getSafeMax() {
    final safeMin = _getSafeMin();
    // Ensure max is valid and greater than min
    if (!widget.max.isFinite || widget.max <= safeMin) {
      return safeMin + 1000; // Default range if max is invalid
    }
    return widget.max;
  }

  void _initializeRange() {
    final safeMin = _getSafeMin();
    final safeMax = _getSafeMax();

    if (widget.initialRange != null) {
      // Safely clamp initial range values
      final start = widget.initialRange!.start.clamp(safeMin, safeMax);
      final end = widget.initialRange!.end.clamp(start, safeMax);
      _currentRange = RangeValues(start, end);
    } else {
      // Use full range if no initial values
      _currentRange = RangeValues(safeMin, safeMax);
    }
  }

  void _handleRangeChange(RangeValues values) {
    final safeMin = _getSafeMin();
    final safeMax = _getSafeMax();

    // Ensure values are within bounds
    final start = values.start.clamp(safeMin, safeMax);
    final end = values.end.clamp(start, safeMax);

    final newRange = RangeValues(start, end);

    if (_currentRange != newRange) {
      setState(() {
        _currentRange = newRange;
      });

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () {
        widget.onChanged?.call(newRange);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  String _formatPrice(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.round()}';
  }

  @override
  Widget build(BuildContext context) {
    final safeMin = _getSafeMin();
    final safeMax = _getSafeMax();

    // Handle zero results or invalid range
    final bool isDisabled =
        widget.totalResults == 0 || (widget.min == 0 && widget.max == 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.localizations.price_range,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isDisabled)
                Text(
                  widget.localizations.no_results_in_range,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                )
              else
                Text(
                  '${_formatPrice(_currentRange.start)} - ${_formatPrice(_currentRange.end)}',
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 5,
            activeTrackColor: isDisabled
                ? AppColors.containerColor
                : CupertinoColors.activeGreen,
            inactiveTrackColor: AppColors.containerColor,
            thumbColor: isDisabled ? AppColors.containerColor : Colors.white,
            overlayColor: Colors.transparent,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 2,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            values: RangeValues(
              _currentRange.start.clamp(safeMin, safeMax),
              _currentRange.end.clamp(_currentRange.start, safeMax),
            ),
            min: safeMin,
            max: safeMax,
            divisions: 100,
            onChanged: isDisabled ? null : _handleRangeChange,
          ),
        ),
      ],
    );
  }
}

enum SellerType {
  ALL,
  INDIVIDUAL_SELLER,
  BUSINESS_SELLER,
}
