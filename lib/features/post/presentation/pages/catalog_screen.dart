import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

// Separate widget for back button
class CatalogBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isVisible;

  const CatalogBackButton(
      {super.key, required this.onTap, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return SmoothClipRRect(
       smoothness: 1,
    borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 36,
        height: 36,
        child: InkWell(
          onTap: onTap,
          child: Card(
            elevation: 0,
            color: AppColors.bgColor,
            shape: SmoothRectangleBorder(
              smoothness: 1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                AppIcons.arrowBackNoShadow,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized CatalogPagerScreen
class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CatalogPagerScreenState createState() => _CatalogPagerScreenState();
}

class _CatalogPagerScreenState extends State<CatalogPagerScreen> {
  late final PageController _pageController;
  late int _currentPage;
  late double _progressValue;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = 0;
    _progressValue = 0.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateProgress(int pageIndex) {
    setState(() {
      _progressValue = (pageIndex + 1) / 3;
    });
  }

  Future<bool> _onWillPop() async {
    final provider = Provider.of<CatalogProvider>(context, listen: false);

    if (_currentPage > 0) {
      _handleBackNavigation(provider);
      return false;
    }

    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return false;
  }

  void _handleBackNavigation(CatalogProvider provider) {
    provider.resetUIState();

    if (_currentPage == 2 || _currentPage == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      if (_currentPage == 1) {
        provider.goBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: _buildAppBar(context),
        body: _buildPageViewBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Create Post',
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: "Poppins",
            fontSize: 21,
            color: AppColors.black),
      ),
      toolbarHeight: 56.0,
      automaticallyImplyLeading: false,
      flexibleSpace: _buildProgressIndicator(),
      leadingWidth: 56,
      leading: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          return Visibility(
            visible: _currentPage >= 0,
            child: Transform.translate(
              offset: const Offset(10, 0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CatalogBackButton(
                  onTap: () => _handleBackNavigation(provider),
                  isVisible: provider.selectedChildCategory != null ||
                      provider.selectedCatalog != null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: _progressValue, end: _progressValue),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.bgColor,
        valueColor:
            const AlwaysStoppedAnimation<Color>(AppColors.containerColor),
        minHeight: double.infinity,
      ),
    );
  }

  Widget _buildPageViewBody(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _updateProgress(index);
              });
            },
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CatalogListPage(
                onCatalogSelected: (catalog) {
                  provider.selectCatalog(catalog);
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              ChildCategoryListPage(
                onChildCategorySelected: (childCategory) {
                  provider.selectChildCategory(childCategory);
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              AttributesPage(
                onNextPressed: () {
                  // Implement next action
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CatalogListPage extends StatelessWidget {
  final Function(Catalog) onCatalogSelected;

  const CatalogListPage({super.key, required this.onCatalogSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);
    final catalogs = provider.catalogModel?.catalogs ?? [];

    return ListView(
      children: [
        for (var catalog in catalogs)
          Column(
            children: [
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () => onCatalogSelected(catalog),
                style: ElevatedButton.styleFrom(
                  shape: SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Card(
                        shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: SmoothClipRRect(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AppImages.appLogo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(catalog.name),
                        const SizedBox(height: 6),
                        Text(catalog.description),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class ChildCategoryListPage extends StatelessWidget {
  final Function(ChildCategory) onChildCategorySelected;

  const ChildCategoryListPage({
    super.key,
    required this.onChildCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);
    final childCategories = provider.selectedCatalog?.childCategories ?? [];

    return ListView(
      children: [
        for (var childCategory in childCategories)
          Column(
            children: [
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () => onChildCategorySelected(childCategory),
                style: ElevatedButton.styleFrom(
                  shape: SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Card(
                        shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: SmoothClipRRect(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AppImages.appLogo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          childCategory.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          childCategory.description,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// Separate widget for Attributes Page
class AttributesPage extends StatelessWidget {
  final VoidCallback onNextPressed;

  const AttributesPage({super.key, required this.onNextPressed});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 70.0, top: 12),
          child: ListView.builder(
            itemCount: provider.currentAttributes.length,
            itemBuilder: (context, index) {
              final attribute = provider.currentAttributes[index];
              return _buildAttributeWidget(context, provider, attribute);
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: SmoothRectangleBorder(
                      smoothness: 1, borderRadius: BorderRadius.circular(10)),
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white),
              onPressed: onNextPressed,
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Next'),
              ),
            ),
          ),
        ),
      ],
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            attribute.helperText,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
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
                      vertical: 14.0,
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
                          size: 24,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                // Smooth animation for expanding/collapsing the Card
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
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
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                        vertical: 8.0,
                                        horizontal: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            value.value,
                                            style: const TextStyle(
                                              fontSize: 13,
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
          height: 14,
        ),
      ],
    );
  }

  Widget _buildColorSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    final Map<String, Color> colorMap = {
      'Black': Colors.black,
      'Gray': Colors.grey,
      'Silver': Colors.grey,
      'Blue': Colors.blue,
      'Gold': Colors.yellow,
      'White': Colors.white
    };

    final selectedValue = provider.getSelectedAttributeValue(attribute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            attribute.helperText,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
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
                          fontSize: 15,
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
                      vertical: 14,
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
                          size: 24,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                // Smooth animation for expanding/collapsing the Card
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
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
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                              fontSize: 13,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SmoothClipRRect(
                                            smoothness: 1,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: Container(
                                              width: 14,
                                              height: 14,
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
          height: 14,
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            attribute.helperText,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 4,
              runSpacing: 4,
              children: selectedValues.map((value) {
                return SmoothClipRRect(
                  smoothness: 1,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    color: AppColors.containerColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          value.value,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        ElevatedButton(
          onPressed: () {
            provider.toggleAttributeOptionsVisibility(attribute);
          },
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'),
            ),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            elevation: WidgetStateProperty.all(0),
            foregroundColor: WidgetStateProperty.all(Colors.black),
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
              vertical: 14,
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
                  size: 24,
                  color: AppColors.black,
                ),
              ],
            ),
          ),
        ),

        // AnimatedSize with ConstrainedBox
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          alignment: Alignment.topCenter,
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scrollable list of values with max height
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: attribute.values.length,
                              itemBuilder: (context, index) {
                                var value = attribute.values[index];
                                bool isSelected =
                                    provider.isValueSelected(attribute, value);

                                return InkWell(
                                  onTap: () {
                                    provider.selectAttributeValue(
                                        attribute, value);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          value.value,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          transitionBuilder:
                                              (child, animation) {
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
                                              width: 24,
                                              height: 24,
                                              child: Container(
                                                color: isSelected
                                                    ? AppColors.black
                                                    : AppColors.gray
                                                        // ignore: deprecated_member_use
                                                        .withOpacity(0.5),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Colors.white,
                                                      )
                                                    : const SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
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
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(
          height: 14,
        ),
      ],
    );
  }
}
//
