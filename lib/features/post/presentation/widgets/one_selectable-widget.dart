import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/category_tree/attribute_model.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class OneSelectableWidget extends StatelessWidget {
  final AttributeModel attribute;

  const OneSelectableWidget({super.key, required this.attribute});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final selectedValue = provider.getSelectedAttributeValue(attribute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: BlocSelector<LanguageBloc, LanguageState, String>(
            selector: (state) => state is LanguageLoaded
                ? state.languageCode
                : AppLanguages.english,
            builder: (context, languageCode) {
              return Text(
                getLocalizedText(
                    attribute.attributeKey,
                    attribute.attributeKeyUz,
                    attribute.attributeKeyRu,
                    languageCode),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Consumer<PostProvider>(
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
                        side: BorderSide(
                            width: 1, color: Theme.of(context).cardColor),
                        borderRadius: BorderRadius.circular(16),
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
                        BlocSelector<LanguageBloc, LanguageState, String>(
                          selector: (state) => state is LanguageLoaded
                              ? state.languageCode
                              : AppLanguages.english,
                          builder: (context, languageCode) {
                            // Different text widgets based on language
                            switch (languageCode) {
                              case AppLanguages.uzbek:
                                return Text(
                                  selectedValue?.valueUz ??
                                      attribute.attributeKeyUz,
                                  style: TextStyle(
                                    color: selectedValue != null
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                );

                              case AppLanguages.russian:
                                return Text(
                                  selectedValue?.valueRu ??
                                      attribute.attributeKeyRu,
                                  style: TextStyle(
                                    color: selectedValue != null
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                );

                              default: // English or fallback
                                return Text(
                                  selectedValue?.value ??
                                      attribute.attributeKey,
                                  style: TextStyle(
                                    color: selectedValue != null
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                );
                            }
                          },
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
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: provider.isAttributeOptionsVisible(attribute)
                      ? Card(
                          shape: SmoothRectangleBorder(
                              smoothness: 1,
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).cardColor)),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Theme.of(context).cardColor,
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
                                      provider.selectAttributeValue(
                                          attribute, value);
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
                                          BlocSelector<LanguageBloc,
                                              LanguageState, String>(
                                            selector: (state) =>
                                                state is LanguageLoaded
                                                    ? state.languageCode
                                                    : AppLanguages.english,
                                            builder: (context, languageCode) {
                                              return Text(
                                                getLocalizedText(
                                                    value.value,
                                                    value.valueUz,
                                                    value.valueRu,
                                                    languageCode),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: Constants.Arial,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              );
                                            },
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
        const SizedBox(height: 14),
      ],
    );
  }
}
