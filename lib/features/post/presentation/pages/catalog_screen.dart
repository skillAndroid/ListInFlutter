import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:provider/provider.dart';

class CatalogPagerScreen extends StatefulWidget {
  const CatalogPagerScreen({Key? key}) : super(key: key);

  @override
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
          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // First Page: Catalog Selection
              _buildCatalogPage(context, provider),

              // Second Page: Child Category Selection
              _buildChildCategoryPage(context, provider),

              // Third Page: Attributes Selection
              _buildAttributesPage(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton(CatalogProvider provider) {
    if (provider.selectedChildCategory != null ||
        provider.selectedCatalog != null) {
      return BackButton(
        onPressed: () {
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
    return ExpansionTile(
      title: Text(attribute.attributeKey),
      children: attribute.values.map((value) {
        return ListTile(
          title: Text(value.value),
          trailing: provider.isValueSelected(attribute, value)
              ? const Icon(Icons.check_circle, color: Colors.blue)
              : null,
          onTap: () {
            provider.selectAttributeValue(attribute, value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildColorSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    return ExpansionTile(
      title: Text(attribute.attributeKey),
      children: attribute.values.map((value) {
        return ListTile(
          title: Text(value.value),
          trailing: provider.isValueSelected(attribute, value)
              ? const Icon(Icons.check_circle, color: Colors.blue)
              : null,
          onTap: () {
            provider.selectAttributeValue(attribute, value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectorWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    return ExpansionTile(
      title: Text(attribute.attributeKey),
      children: [
        ...attribute.values.map((value) {
          return CheckboxListTile(
            title: Text(value.value),
            value: provider.isValueSelected(attribute, value),
            onChanged: (bool? selected) {
              provider.selectAttributeValue(attribute, value);
            },
          );
        }).toList(),
        ElevatedButton(
          onPressed: () {
            provider.confirmMultiSelection(attribute);
          },
          child: const Text('Confirm Selection'),
        ),
      ],
    );
  }
}
