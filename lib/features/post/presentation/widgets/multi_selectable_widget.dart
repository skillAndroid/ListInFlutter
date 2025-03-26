// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_value_model.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MultiSelectableWidget extends StatelessWidget {
  final AttributeModel attribute;

  const MultiSelectableWidget({super.key, required this.attribute});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final selectedAttributeValue =
        provider.getSelectedAttributeValue(attribute);
    final selectedValues = attribute.widgetType == 'multiSelectable'
        ? (provider.selectedValues[attribute.attributeKey]
                as List<AttributeValueModel>? ??
            [])
        : (selectedAttributeValue != null ? [selectedAttributeValue] : []);

    return BlocSelector<LanguageBloc, LanguageState, String>(
      selector: (state) =>
          state is LanguageLoaded ? state.languageCode : AppLanguages.english,
      builder: (context, languageCode) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                getLocalizedText(attribute.helperText, attribute.helperTextUz,
                    attribute.helperTextRu, languageCode),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
                      borderRadius: BorderRadius.circular(6.5),
                      child: Container(
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getLocalizedText(value.value, value.valueUz,
                                  value.valueRu, languageCode),
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

            // Dropdown button
            ElevatedButton(
              onPressed: () {
                provider.toggleAttributeOptionsVisibility(attribute);
              },
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: Constants.Arial,
                  ),
                ),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                elevation: WidgetStateProperty.all(0),
                backgroundColor:
                    WidgetStateProperty.all(Theme.of(context).cardColor),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.secondary),
                shape: WidgetStateProperty.all(
                  SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(16),
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
                        '${AppLocalizations.of(context)!.selected} (${selectedValues.length})',
                        style: TextStyle(
                          color: selectedValues.isNotEmpty
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
              alignment: Alignment.topCenter,
              child: provider.isAttributeOptionsVisible(attribute)
                  ? Card(
                      shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              width: 1, color: Theme.of(context).cardColor)),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).cardColor,
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                          getLocalizedText(
                                              value.value,
                                              value.valueUz,
                                              value.valueRu,
                                              languageCode),
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
                                                BorderRadius.circular(6.5),
                                            child: SizedBox(
                                              key: ValueKey<bool>(isSelected),
                                              width: 24,
                                              height: 24,
                                              child: Container(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                        // ignore: deprecated_member_use
                                                        .withOpacity(0.5),
                                                child: isSelected
                                                    ? Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSecondary,
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
                                      fontFamily: Constants.Arial,
                                    ),
                                  ),
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(
                                      Theme.of(context).colorScheme.secondary),
                                  foregroundColor: WidgetStateProperty.all(
                                    Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                  shape: WidgetStateProperty.all(
                                    SmoothRectangleBorder(
                                      smoothness: 1,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  provider.confirmMultiSelection(attribute);
                                  provider.toggleAttributeOptionsVisibility(
                                      attribute);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.confirm,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }
}
