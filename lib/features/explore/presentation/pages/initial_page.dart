// catalog_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/features/explore/domain/enties/advertised_product_entity.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';

class InitialHomeTreePage extends StatefulWidget {
  final List<AdvertisedProductEntity> advertisedProducts;
  final List<ProductEntity> regularProducts;
  const InitialHomeTreePage({
    super.key,
    required this.advertisedProducts,
    required this.regularProducts,
  });

  @override
  State<InitialHomeTreePage> createState() => _InitialHomeTreePageState();
}

class _InitialHomeTreePageState extends State<InitialHomeTreePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeTreeCubit>().fetchCatalogs();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      buildWhen: (previous, current) =>
          previous.catalogs != current.catalogs ||
          previous.isLoading != current.isLoading ||
          previous.hasError != current.hasError,
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.hasError) {
          return Scaffold(
            body: Center(child: Text(state.error!)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Categories'),
          ),
          body: ListView.builder(
            itemCount: state.catalogs?.length ?? 0,
            itemBuilder: (context, index) {
              final catalog = state.catalogs![index];
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(catalog.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<HomeTreeCubit>().selectCatalog(catalog);
                  context.push('/subcategories');
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ChildCategoriesScreen extends StatelessWidget {
  const ChildCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      buildWhen: (previous, current) =>
          previous.selectedCatalog != current.selectedCatalog,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.selectedCatalog?.name ?? 'Subcategories'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<HomeTreeCubit>().goBack();
                context.pop();
              },
            ),
          ),
          body: ListView.builder(
            itemCount: state.selectedCatalog?.childCategories.length ?? 0,
            itemBuilder: (context, index) {
              final childCategory =
                  state.selectedCatalog!.childCategories[index];
              return ListTile(
                leading: const Icon(Icons.subdirectory_arrow_right),
                title: Text(childCategory.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context
                      .read<HomeTreeCubit>()
                      .selectChildCategory(childCategory);
                  context.push('/attributes');
                },
              );
            },
          ),
        );
      },
    );
  }
}

class AttributesScreen extends StatelessWidget {
  const AttributesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        final attributes = state.allAttributes;

        return Scaffold(
          appBar: AppBar(
            title: Text(state.selectedChildCategory?.name ?? 'Filters'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<HomeTreeCubit>().goBack();
                context.pop();
              },
            ),
          ),
          body: Column(
            children: [
              // Enhanced horizontal scrollable chips
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: attributes.length,
                  itemBuilder: (context, index) {
                    final attribute = attributes[index];
                    final selectedValue = context
                        .read<HomeTreeCubit>()
                        .getSelectedAttributeValue(attribute);
                    final selectedValues = context
                        .read<HomeTreeCubit>()
                        .getSelectedValues(attribute);

                    String chipLabel = attribute.helperText;
                    if (attribute.widgetType == 'multiSelectable' &&
                        selectedValues.isNotEmpty) {
                      chipLabel =
                          '${attribute.helperText} (${selectedValues.length})';
                    } else if (selectedValue != null) {
                      chipLabel = selectedValue.value;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          chipLabel,
                          style: TextStyle(
                            color: selectedValue != null ||
                                    selectedValues.isNotEmpty
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        ),
                        selected:
                            selectedValue != null || selectedValues.isNotEmpty,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        onSelected: (_) {
                          if (attribute.values.isNotEmpty) {
                            _showAttributeSelectionUI(context, attribute);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  void _showSelectionBottomSheet(
      BuildContext context, AttributeModel attribute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            attribute.helperText,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: attribute.widgetType == 'multiSelectable'
                        ? _buildMultiSelectList(
                            context, attribute, scrollController)
                        : _buildSingleSelectList(
                            context, attribute, scrollController),
                  ),
                  if (attribute.widgetType == 'multiSelectable')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context
                                    .read<HomeTreeCubit>()
                                    .clearSelection(attribute);
                              },
                              child: const Text('Clear All'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                context
                                    .read<HomeTreeCubit>()
                                    .confirmMultiSelection(attribute);
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showColorSelectDialog(BuildContext context, AttributeModel attribute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(attribute.helperText),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: attribute.values.map((value) {
                  final isSelected = context
                      .read<HomeTreeCubit>()
                      .isValueSelected(attribute, value);
                  return InkWell(
                    onTap: () {
                      context
                          .read<HomeTreeCubit>()
                          .selectAttributeValue(attribute, value);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(value.value),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _isLightColor(_parseColor(value.value))
                                  ? Colors.black
                                  : Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  void _showAttributeSelectionUI(
      BuildContext context, AttributeModel attribute) {
    switch (attribute.widgetType) {
      case 'colorSelectable':
        _showColorSelectDialog(context, attribute);
        break;
      case 'oneSelectable':
      case 'multiSelectable':
        _showSelectionBottomSheet(context, attribute);
        break;
    }
  }

  Widget _buildMultiSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ListView.builder(
          controller: scrollController,
          itemCount: attribute.values.length,
          itemBuilder: (context, index) {
            final value = attribute.values[index];
            final isSelected =
                context.read<HomeTreeCubit>().isValueSelected(attribute, value);

            return CheckboxListTile(
              title: Text(value.value),
              value: isSelected,
              onChanged: (bool? checked) {
                context
                    .read<HomeTreeCubit>()
                    .selectAttributeValue(attribute, value);
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSingleSelectList(
    BuildContext context,
    AttributeModel attribute,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      controller: scrollController,
      itemCount: attribute.values.length,
      itemBuilder: (context, index) {
        final value = attribute.values[index];
        final isSelected =
            context.read<HomeTreeCubit>().isValueSelected(attribute, value);

        return ListTile(
          title: Text(value.value),
          trailing:
              isSelected ? const Icon(Icons.check, color: Colors.green) : null,
          onTap: () {
            context
                .read<HomeTreeCubit>()
                .selectAttributeValue(attribute, value);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse('FF${colorString.substring(1)}', radix: 16));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}
