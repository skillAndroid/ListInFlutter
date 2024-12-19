// Separate widget for Attributes Page
import 'package:flutter/material.dart';
import 'package:list_in/features/post/data/models/model.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/post/presentation/widgets/color_selectable_widget.dart';
import 'package:list_in/features/post/presentation/widgets/multi_selectable_widget.dart';
import 'package:list_in/features/post/presentation/widgets/one_selectable-widget.dart';
import 'package:provider/provider.dart';

class AttributesPage extends StatelessWidget {

  const AttributesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: ListView.builder(
            itemCount: provider.currentAttributes.length,
            itemBuilder: (context, index) {
              final attribute = provider.currentAttributes[index];
              return _buildAttributeWidget(context, provider, attribute);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeWidget(
      BuildContext context, CatalogProvider provider, Attribute attribute) {
    switch (attribute.widgetType) {
      case 'oneSelectable':
        return OneSelectableWidget(attribute: attribute);
      case 'colorSelectable':
        return ColorSelectableWidget(attribute: attribute);
      case 'multiSelectable':
        return MultiSelectableWidget(attribute: attribute);
      default:
        return ListTile(
          title: Text('Unsupported attribute type: ${attribute.widgetType}'),
        );
    }
  }
}
