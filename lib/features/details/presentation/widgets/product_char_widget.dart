// ProductCharacteristicsWidget - For displaying product characteristics
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/features/details/presentation/widgets/character_item_widget.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';

class ProductCharacteristicsWidget extends StatelessWidget {
  final GetPublicationEntity product;

  const ProductCharacteristicsWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LanguageBloc, LanguageState, String>(
        selector: (state) =>
            state is LanguageLoaded ? state.languageCode : AppLanguages.english,
        builder: (context, languageCode) {
          final localizations = AppLocalizations.of(context)!;

          // Combine all features into a single list
          final List<MapEntry<String, String>> features = [];

          // Add attributes for the current language
          final attributes = product.attributeValue.attributes[languageCode] ??
              product.attributeValue.attributes['en'] ??
              {};

          attributes.forEach((key, values) {
            if (values.isNotEmpty) {
              final value = values.length == 1 ? values[0] : values.join(', ');
              features.add(MapEntry(key, value));
            }
          });

          // Add numeric values
          for (var numericValue in product.attributeValue.numericValues) {
            if (numericValue.numericValue.isNotEmpty) {
              // Get localized field name based on language
              final fieldName = getLocalizedText(
                numericValue.numericField,
                numericValue.numericFieldUz,
                numericValue.numericFieldRu,
                languageCode,
              );
              features.add(MapEntry(fieldName, numericValue.numericValue));
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.about_this_item,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Show all items
                ...features.map((feature) => CharacteristicItemWidget(
                      label: feature.key,
                      value: feature.value,
                    )),
              ],
            ),
          );
        });
  }
}
