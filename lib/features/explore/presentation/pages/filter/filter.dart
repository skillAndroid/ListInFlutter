import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<HomeTreeCubit, HomeTreeState>(
        listenWhen: (previous, current) {
          final previousFilters = Set.from(previous.generateFilterParameters());
          final currentFilters = Set.from(current.generateFilterParameters());
          return !setEquals(previousFilters, currentFilters) ||
              previous.childCurrentPage != current.childCurrentPage ||
              previous.childPublicationsRequestState !=
                  current.childPublicationsRequestState;
        },
        listener: (context, state) {
          if (state.selectedCatalog != null) {
            debugPrint("Catalog selected: ${state.selectedCatalog?.name}");
          }
          if (state.selectedChildCategory != null) {
            debugPrint(
                "Child category selected: ${state.selectedChildCategory?.name}");
          }
        },
        builder: (context, state) {
          final cubit = context.read<HomeTreeCubit>();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.selectedCatalog == null)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 2.0,
                    children: state.catalogs?.map((category) {
                          return FilterChip(
                            label: Text(category.name),
                            onSelected: (bool selected) {
                              context
                                  .read<HomeTreeCubit>()
                                  .selectCatalog(category);
                            },
                            selectedColor: Colors.blue[100],
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList() ??
                        [],
                  ),

                // Top row showing selected catalog and child category
                if (state.selectedCatalog != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            cubit.resetCatalogSelection();
                          },
                          child: Text(
                            " > Categories",
                            style: TextStyle(
                              fontSize: 14,
                              color: state.selectedCatalog != null
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            cubit.resetChildCategorySelection();
                          },
                          child: Text(
                            " > ${state.selectedCatalog!.name}",
                            style: TextStyle(
                              fontSize: 14,
                              color: state.selectedCatalog != null
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (state.selectedChildCategory != null)
                          Text(
                            " > ${state.selectedChildCategory!.name}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),

                if (state.selectedCatalog != null &&
                    state.selectedChildCategory == null)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 2.0,
                    children: state.selectedCatalog!.childCategories
                        .map((childCategory) {
                      return FilterChip(
                        label: Text(childCategory.name),
                        onSelected: (bool selected) {
                          context
                              .read<HomeTreeCubit>()
                              .selectChildCategory(childCategory);
                        },
                        selectedColor: Colors.blue[300],
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),

                // Attributes Section
                if (state.selectedChildCategory != null)
                  ...state.orderedAttributes.map((attribute) {
                    final isMultiSelect = attribute.filterWidgetType ==
                            'multiSelectable' ||
                        attribute.filterWidgetType == 'colorMultiSelectable';

                    return _buildHorizontalFilterSection(
                      attribute.filterText,
                      attribute.values.map((value) {
                        final isSelected = isMultiSelect
                            ? cubit.getSelectedValues(attribute).contains(value)
                            : cubit
                                    .getSelectedAttributeValue(attribute)
                                    ?.attributeValueId ==
                                value.attributeValueId;

                        Color? chipColor;
                        if (attribute.filterWidgetType ==
                            'colorMultiSelectable') {
                          chipColor = _getColorFromName(value.value);
                        }

                        return FilterOption(
                          label: value.value,
                          isSelected: isSelected,
                          color: chipColor,
                          onSelected: (selected) {
                            if (isMultiSelect) {
                              if (isSelected) {
                                cubit.clearSelectedAttributeValue(
                                    attribute, value);
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
                        );
                      }).toList(),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalFilterSection(
      String title, List<FilterOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: _buildFilterChip(options[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(FilterOption option) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (option.color != null) ...[
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: option.color == Colors.white
                      ? Colors.grey
                      : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          Text(
            option.label,
            style: TextStyle(
              color: option.isSelected ? AppColors.white : AppColors.black,
              fontWeight:
                  option.isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: option.isSelected,
      onSelected: option.onSelected,
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        smoothness: 0.8,
      ),
      side: BorderSide(color: AppColors.lightGray),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class FilterOption {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color? color;

  FilterOption({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });
}
