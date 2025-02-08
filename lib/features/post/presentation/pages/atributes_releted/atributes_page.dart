// Separate widget for Attributes Page
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/data/models/nomeric_field_model.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/features/post/presentation/widgets/color_selectable_widget.dart';
import 'package:list_in/features/post/presentation/widgets/multi_selectable_widget.dart';
import 'package:list_in/features/post/presentation/widgets/one_selectable-widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class AttributesPage extends StatelessWidget {
  const AttributesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);

    // Calculate total items (attributes + numeric fields)
    final totalItems = provider.currentAttributes.length +
        provider.currentNumericFields.length;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: ListView.builder(
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // If index is within attributes range
              if (index < provider.currentAttributes.length) {
                final attribute = provider.currentAttributes[index];
                return _buildAttributeWidget(context, provider, attribute);
              }
              // If index is for numeric fields
              else {
                final numericFieldIndex =
                    index - provider.currentAttributes.length;
                final numericField =
                    provider.currentNumericFields[numericFieldIndex];
                return _buildNumericFieldWidget(
                    context, provider, numericField);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeWidget(
      BuildContext context, PostProvider provider, AttributeModel attribute) {
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

  Widget _buildNumericFieldWidget(BuildContext context, PostProvider provider,
      NomericFieldModel numericField) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numericField.fieldName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (numericField.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(
                numericField.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          const SizedBox(height: 8),
          SmoothClipRRect(
            side: BorderSide(width: 1, color: AppColors.containerColor),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: AppColors.white,
              width: double.infinity,
              height: 52,
              child: Center(
                child: TextFormField(
                  initialValue: provider
                      .getNumericFieldValue(numericField.id)
                      ?.toString(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // If the first character is '0', reject the input
                      if (newValue.text.startsWith('0') &&
                          newValue.text.isNotEmpty) {
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  decoration: InputDecoration(
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter value',
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 20,
                        color: AppColors.black,
                      ),
                      onPressed: () {
                        provider.setNumericFieldValue(numericField.id, '0');
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final numericValue = value.toString();
                      provider.setNumericFieldValue(
                          numericField.id, numericValue);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
