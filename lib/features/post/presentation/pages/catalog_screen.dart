import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
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
    final selectedValue = provider.getSelectedAttributeValue(attribute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attribute.helperText,
          style: const TextStyle(
            color: AppColors.gray,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    provider.toggleAttributeOptionsVisibility(attribute);
                  },
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins'),
                    ),
                    padding: WidgetStateProperty.all(
                        EdgeInsets.zero), // Removes padding
                    elevation:
                        WidgetStateProperty.all(0), // Removes all elevation
                    foregroundColor: WidgetStateProperty.all(
                        Colors.black), // Text/Icon color
                    shape: WidgetStateProperty.all(
                      SmoothRectangleBorder(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedValue?.value ?? attribute.attributeKey,
                          style: TextStyle(
                            color: selectedValue != null
                                ? AppColors.black
                                : AppColors.darkGray,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                // Smooth animation for expanding/collapsing the Card
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: provider.isAttributeOptionsVisible(attribute)
                      ? Card(
                          shape: SmoothRectangleBorder(
                            smoothness: 1,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.containerColor,
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: attribute.values.length,
                                itemBuilder: (context, index) {
                                  var value = attribute.values[index];
                                  return InkWell(
                                    onTap: () {
                                      // Select the value through the provider
                                      provider.selectAttributeValue(
                                          attribute, value);
                                      // Hide the options
                                      provider.toggleAttributeOptionsVisibility(
                                          attribute);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            value.value,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

//
  Widget _buildColorSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    // A map to link color names to actual colors
    final Map<String, Color> colorMap = {
      'Black': Colors.black,
      'Silver': Colors.grey,
    };

    final selectedValue = provider.getSelectedAttributeValue(attribute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attribute.helperText,
          style: const TextStyle(
            color: AppColors.gray,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    provider.toggleAttributeOptionsVisibility(attribute);
                  },
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins'),
                    ),
                    padding: WidgetStateProperty.all(
                        EdgeInsets.zero), // Removes padding
                    elevation:
                        WidgetStateProperty.all(0), // Removes all elevation
                    foregroundColor: WidgetStateProperty.all(
                        Colors.black), // Text/Icon color
                    shape: WidgetStateProperty.all(
                      SmoothRectangleBorder(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              selectedValue?.value ?? attribute.attributeKey,
                              style: TextStyle(
                                color: selectedValue != null
                                    ? AppColors.black
                                    : AppColors.darkGray,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            SmoothClipRRect(
                              smoothness: 1,
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 16,
                                height: 16,
                                color: colorMap[selectedValue?.value] ??
                                    Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                // Smooth animation for expanding/collapsing the Card
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: provider.isAttributeOptionsVisible(attribute)
                      ? Card(
                          shape: SmoothRectangleBorder(
                            smoothness: 1,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.containerColor,
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: attribute.values.length,
                                itemBuilder: (context, index) {
                                  var value = attribute.values[index];
                                  return InkWell(
                                    onTap: () {
                                      // Select the value through the provider
                                      provider.selectAttributeValue(
                                          attribute, value);
                                      // Hide the options
                                      provider.toggleAttributeOptionsVisibility(
                                          attribute);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            value.value,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SmoothClipRRect(
                                            smoothness: 1,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              color: colorMap[value.value] ??
                                                  Colors.transparent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 8,
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
        Text(
          attribute.helperText,
          style: const TextStyle(
            color: AppColors.gray,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        if (selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: selectedValues.map((value) {
                return SmoothClipRRect(
                  smoothness: 1,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: AppColors.containerColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          value.value,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Main selection button (unchanged)
        ElevatedButton(
          onPressed: () {
            provider.toggleAttributeOptionsVisibility(attribute);
          },
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'),
            ),
            padding:
                WidgetStateProperty.all(EdgeInsets.zero), // Removes padding
            elevation: WidgetStateProperty.all(0), // Removes all elevation
            foregroundColor:
                WidgetStateProperty.all(Colors.black), // Text/Icon color
            shape: WidgetStateProperty.all(
              SmoothRectangleBorder(
                smoothness: 1,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Selected (${selectedValues.length})',
                    style: TextStyle(
                      color: selectedValues.isNotEmpty
                          ? AppColors.black
                          : AppColors.darkGray,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
        ),

        // AnimatedSize with ConstrainedBox
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease, // Match the color selector's curve
          alignment: Alignment.topCenter, // Important for animation origin
          child: provider.isAttributeOptionsVisible(attribute)
              ? Card(
                  shape: SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.containerColor,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: attribute.values.length,
                            itemBuilder: (context, index) {
                              var value = attribute.values[index];
                              bool isSelected =
                                  provider.isValueSelected(attribute, value);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      value.value,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        provider.selectAttributeValue(
                                            attribute, value);
                                      },
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                        child: SmoothClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: SizedBox(
                                            key: ValueKey<bool>(isSelected),
                                            width: 18,
                                            height: 18,
                                            child: Container(
                                              color: isSelected
                                                  ? AppColors.black
                                                  : AppColors.gray
                                                      // ignore: deprecated_member_use
                                                      .withOpacity(0.5),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 13,
                                                      color: Colors.white,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  textStyle: WidgetStateProperty.all(
                                    const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins'),
                                  ),
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor:
                                      WidgetStateProperty.all(AppColors.black),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                  shape: WidgetStateProperty.all(
                                    SmoothRectangleBorder(
                                      smoothness: 1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  provider.confirmMultiSelection(attribute);
                                  provider.toggleAttributeOptionsVisibility(
                                      attribute);
                                },
                                child: const Text(
                                  'Confirm',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
