import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:provider/provider.dart';

class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CatalogPagerScreenState createState() => _CatalogPagerScreenState();
}

class _CatalogPagerScreenState extends State<CatalogPagerScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Selection'),
        leading: Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return _buildBackButton(provider);
          },
        ),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCatalogPage(context, provider),
                _buildChildCategoryPage(context, provider),
                _buildAttributesPage(context, provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _endTask(context),
        child: const Icon(Icons.check),
      ),
    );
  }

  void _endTask(BuildContext context) {
    // Access the provider
    final provider = Provider.of<CatalogProvider>(context, listen: false);

    // Collect the data
    final selectedCatalog = provider.selectedCatalog?.name ?? 'None';
    final selectedChildCategory =
        provider.selectedChildCategory?.name ?? 'None';
    final selectedAttributes = provider.currentAttributes.map((attribute) {
      final value = provider.getSelectedAttributeValue(attribute);
      if (attribute.widgetType == 'multiSelectable') {
        // Multi-select attributes
        final selectedValues = provider.selectedValues[attribute.attributeKey];
        return '${attribute.attributeKey}: ${selectedValues?.map((v) => v.value).join(", ") ?? "None"}';
      }
      return '${attribute.attributeKey}: ${value?.value ?? "None"}';
    }).join("\n");

    // Show the collected data
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selected Data'),
          content: Text(
            'Catalog: $selectedCatalog\n'
            'Child Category: $selectedChildCategory\n'
            'Attributes:\n$selectedAttributes',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackButton(CatalogProvider provider) {
    if (provider.selectedChildCategory != null ||
        provider.selectedCatalog != null) {
      return BackButton(
        onPressed: () {
          provider.resetUIState();
          if (_pageController.page == 2) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (_pageController.page == 1) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            provider.goBack();
          }
        },
      );
    }
    return Container();
  }

  Widget _buildCatalogPage(BuildContext context, CatalogProvider provider) {
    return ListView.builder(
      itemCount: provider.catalogModel?.catalogs.length ?? 0,
      itemBuilder: (context, index) {
        final catalog = provider.catalogModel!.catalogs[index];
        return ListTile(
          title: Text(catalog.name),
          subtitle: Text(catalog.description),
          onTap: () {
            provider.selectCatalog(catalog);
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  Widget _buildChildCategoryPage(
      BuildContext context, CatalogProvider provider) {
    return ListView.builder(
      itemCount: provider.selectedCatalog?.childCategories.length ?? 0,
      itemBuilder: (context, index) {
        final childCategory = provider.selectedCatalog!.childCategories[index];
        return ListTile(
          title: Text(childCategory.name),
          subtitle: Text(childCategory.description),
          onTap: () {
            provider.selectChildCategory(childCategory);
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }

  Widget _buildAttributesPage(BuildContext context, CatalogProvider provider) {
    return ListView.builder(
      itemCount: provider.currentAttributes.length,
      itemBuilder: (context, index) {
        final attribute = provider.currentAttributes[index];
        return _buildAttributeWidget(context, provider, attribute);
      },
    );
  }

  Widget _buildAttributeWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    switch (attribute.widgetType) {
      case 'oneSelectable':
        return _buildOneSelectorWidget(context, provider, attribute);
      case 'colorSelectable':
        return _buildColorSelectorWidget(context, provider, attribute);
      case 'multiSelectable':
        return _buildMultiSelectorWidget(context, provider, attribute);
      default:
        return ListTile(
          title: Text('Unsupported attribute type: ${attribute.widgetType}'),
        );
    }
  }

  Widget _buildOneSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    // Use the provider to track the selected value for this specific attribute
    final selectedValue = provider.getSelectedAttributeValue(attribute);

    return Column(
      children: [
        Text(attribute.helperText),
        Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Toggle the visibility of options for this specific attribute
                    provider.toggleAttributeOptionsVisibility(attribute);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Show the selected value or attribute key
                      Text(
                        selectedValue?.value ?? attribute.attributeKey,
                        style: TextStyle(
                            color: selectedValue != null
                                ? Colors.black
                                : Colors.grey),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),

                // Only show options if this attribute's options are set to visible
                if (provider.isAttributeOptionsVisible(attribute))
                  Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: attribute.values.length,
                      itemBuilder: (context, index) {
                        var value = attribute.values[index];
                        return ListTile(
                          title: Text(value.value),
                          onTap: () {
                            // Select the value through the provider
                            provider.selectAttributeValue(attribute, value);
                            // Hide the options
                            provider
                                .toggleAttributeOptionsVisibility(attribute);
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    // A map to link color names to actual colors
    final Map<String, Color> colorMap = {
      'Black': Colors.black,
      'Silver': Colors.grey,
    };

    final selectedValue = provider.getSelectedAttributeValue(attribute);

    return Column(
      children: [
        Text(attribute.helperText),
        Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Toggle the visibility of options for this specific attribute
                    provider.toggleAttributeOptionsVisibility(attribute);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Show the selected value or attribute key
                      Text(
                        selectedValue?.value ?? attribute.attributeKey,
                        style: TextStyle(
                          color: selectedValue != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        color: colorMap[selectedValue?.value] ??
                            Colors.transparent,
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),

                // Only show options if this attribute's options are set to visible
                if (provider.isAttributeOptionsVisible(attribute))
                  Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: attribute.values.length,
                      itemBuilder: (context, index) {
                        var value = attribute.values[index];
                        return ListTile(
                          title: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8.0),
                                color:
                                    colorMap[value.value] ?? Colors.transparent,
                              ),
                              Text(value.value),
                            ],
                          ),
                          onTap: () {
                            // Select the value through the provider
                            provider.selectAttributeValue(attribute, value);
                            // Hide the options
                            provider
                                .toggleAttributeOptionsVisibility(attribute);
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMultiSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    final selectedAttributeValue =
        provider.getSelectedAttributeValue(attribute);
    final selectedValues = attribute.widgetType == 'multiSelectable'
        ? (provider.selectedValues[attribute.attributeKey]
                as List<AttributeValue>? ??
            [])
        : (selectedAttributeValue != null ? [selectedAttributeValue] : []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display helper text
        Text(attribute.helperText),

        Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only show selected values if there are confirmed selections
                if (selectedValues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      alignment:
                          WrapAlignment.start, // Align to the start of the row
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedValues.map((value) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(value.value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Main selection button
                ElevatedButton(
                  onPressed: () {
                    // Toggle the visibility of options for this specific attribute
                    provider.toggleAttributeOptionsVisibility(attribute);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Show confirmed selections or attribute key
                      Expanded(
                        child: Text(
                          selectedValues.isNotEmpty
                              ? selectedValues.map((v) => v.value).join(', ')
                              : attribute.attributeKey,
                          style: TextStyle(
                            color: selectedValues.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),

                // Options card - only show when attribute options are visible
                if (provider.isAttributeOptionsVisible(attribute))
                  Card(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: attribute.values.length,
                          itemBuilder: (context, index) {
                            var value = attribute.values[index];
                            return CheckboxListTile(
                              title: Text(value.value),
                              value: provider.isValueSelected(attribute, value),
                              onChanged: (bool? selected) {
                                provider.selectAttributeValue(attribute, value);
                              },
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              provider.confirmMultiSelection(attribute);
                              // Hide options after confirmation
                              provider
                                  .toggleAttributeOptionsVisibility(attribute);
                            },
                            child: const Text('Confirm Selection'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
