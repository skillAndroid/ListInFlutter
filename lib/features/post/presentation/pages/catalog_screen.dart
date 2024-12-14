import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Map<String, bool> _expandedAttributes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Selection'),
        leading: Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            // Determine if back navigation is possible
            if (provider.selectedChildCategory != null ||
                provider.selectedCatalog != null) {
              return BackButton(
                onPressed: () {
                  provider.goBack();
                },
              );
            }
            return Container();
          },
        ),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          // First Page: Catalog Selection
          if (provider.selectedCatalog == null) {
            return _buildCatalogList(context, provider);
          }

          // Second Page: Child Category Selection
          if (provider.selectedChildCategory == null) {
            return _buildChildCategoryList(context, provider);
          }

          // Third Page: Attributes Selection
          return _buildAttributesList(context, provider);
        },
      ),
    );
  }

  Widget _buildCatalogList(BuildContext context, CatalogProvider provider) {
    return ListView.builder(
      itemCount: provider.catalogModel?.catalogs.length ?? 0,
      itemBuilder: (context, index) {
        final catalog = provider.catalogModel!.catalogs[index];
        return ListTile(
          title: Text(catalog.name),
          subtitle: Text(catalog.description),
          onTap: () => provider.selectCatalog(catalog),
        );
      },
    );
  }

  Widget _buildChildCategoryList(
      BuildContext context, CatalogProvider provider) {
    return ListView.builder(
      itemCount: provider.selectedCatalog?.childCategories.length ?? 0,
      itemBuilder: (context, index) {
        final childCategory = provider.selectedCatalog!.childCategories[index];
        return ListTile(
          title: Text(childCategory.name),
          subtitle: Text(childCategory.description),
          onTap: () => provider.selectChildCategory(childCategory),
        );
      },
    );
  }

  Widget _buildAttributesList(BuildContext context, CatalogProvider provider) {
    return ListView.builder(
      itemCount: provider.currentAttributes.length,
      itemBuilder: (context, index) {
        final attribute = provider.currentAttributes[index];
        return _buildAttributeExpansionTile(context, provider, attribute);
      },
    );
  }

  Widget _buildAttributeExpansionTile(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    // Determine if this attribute is expanded
    bool isExpanded = _expandedAttributes[attribute.attributeKey] ?? false;

    return ExpansionTile(
      key: Key(attribute.attributeKey),
      title: Text(attribute.attributeKey),
      subtitle: _buildSelectedValuesSubtitle(provider, attribute),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _expandedAttributes[attribute.attributeKey] = expanded;
        });
      },
      children: [
        ..._buildAttributeValueTiles(context, provider, attribute),
        if (attribute.widgetType == 'multiSelectable')
          _buildConfirmButton(context, provider, attribute)
      ],
    );
  }

  Widget? _buildSelectedValuesSubtitle(
      CatalogProvider provider, Attribute attribute) {
    final selectedValue = provider.selectedValues[attribute.attributeKey];
    if (selectedValue == null) return null;

    if (attribute.widgetType == 'oneSelectable' ||
        attribute.widgetType == 'colorSelectable') {
      return Text((selectedValue as AttributeValue).value);
    } else if (attribute.widgetType == 'multiSelectable') {
      final selectedList = selectedValue as List<AttributeValue>;
      return Text(selectedList.map((v) => v.value).join(', '));
    }
    return null;
  }

  List<Widget> _buildAttributeValueTiles(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    return attribute.values.map((value) {
      return ListTile(
        title: Text(value.value),
        trailing: _buildTrailingIcon(provider, attribute, value),
        onTap: () {
          provider.selectAttributeValue(attribute, value);

          // For oneSelectable, collapse the expansion tile
          if (attribute.widgetType == 'oneSelectable'  || attribute.widgetType == 'colorSelectable') {
            setState(() {
              _expandedAttributes[attribute.attributeKey] = false;
            });
          }
        },
      );
    }).toList();
  }

  Widget _buildTrailingIcon(
      CatalogProvider provider, Attribute attribute, AttributeValue value) {
    return provider.isValueSelected(attribute, value)
        ? const Icon(Icons.check_box, color: Colors.blue)
        : const Icon(Icons.check_box_outline_blank);
  }

  Widget _buildConfirmButton(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    return ElevatedButton(
      onPressed: () {
        provider.confirmMultiSelection(attribute);
        setState(() {
          _expandedAttributes[attribute.attributeKey] = false;
        });
      },
      child: const Text('Confirm Selection'),
    );
  }
}
//