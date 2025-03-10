// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/attribute_model.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ColorSelectableWidget extends StatelessWidget {
  final AttributeModel attribute;

  const ColorSelectableWidget({super.key, required this.attribute});

  final Map<String, Color> colorMap = const {
    'Black': Colors.black,
    'Gray': Colors.grey,
    'Silver': Colors.grey,
    'Blue': Colors.blue,
    'Gold': Colors.yellow,
    'White': Colors.white
  };

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
                getLocalizedText(attribute.helperText, attribute.helperTextUz,
                    attribute.helperTextRu, languageCode),
                style: const TextStyle(
                  color: AppColors.black,
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
                        WidgetStateProperty.all(AppColors.containerColor),
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
                        Row(
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
                                        ? AppColors.black
                                        : AppColors.darkGray,
                                  ),
                                );

                              case AppLanguages.russian:
                                return Text(
                                  selectedValue?.valueRu ??
                                      attribute.attributeKeyRu,
                                  style: TextStyle(
                                    color: selectedValue != null
                                        ? AppColors.black
                                        : AppColors.darkGray,
                                  ),
                                );

                              default: // English or fallback
                                return Text(
                                  selectedValue?.value ??
                                      attribute.attributeKey,
                                  style: TextStyle(
                                    color: selectedValue != null
                                        ? AppColors.black
                                        : AppColors.darkGray,
                                  ),
                                );
                            }
                          },
                        ),
                            const SizedBox(width: 8),
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
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: provider.isAttributeOptionsVisible(attribute)
                      ? Card(
                          shape: SmoothRectangleBorder(
                              smoothness: 1,
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  width: 1, color: AppColors.containerColor)),
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
                                      provider.selectAttributeValue(
                                          attribute, value);
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
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: Constants.Arial,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              );
                                            },
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
        const SizedBox(height: 14),
      ],
    );
  }
}
