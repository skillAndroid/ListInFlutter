// Separate widget for Attributes Page
import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:list_in/features/post/presentation/widgets/color_selectable_widget.dart';
import 'package:list_in/features/post/presentation/widgets/multi_selectable_widget.dart';
import 'package:list_in/features/post/presentation/widgets/one_selectable-widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

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
