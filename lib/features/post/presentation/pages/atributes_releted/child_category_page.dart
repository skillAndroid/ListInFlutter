import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/category_tree/child_category_model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

import '../../provider/post_provider.dart';

class ChildCategoryListPage extends StatelessWidget {
  final Function(ChildCategoryModel) onChildCategorySelected;

  const ChildCategoryListPage({
    super.key,
    required this.onChildCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
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
                  backgroundColor: Theme.of(context).cardColor,
                  shape: SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 60,
                      height: 56,
                      child: Card(
                        color: Theme.of(context).cardColor,
                        shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        elevation: 0,
                        child: SmoothClipRRect(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(0),
                          child: CachedNetworkImage(
                            imageUrl: childCategory.logoUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocSelector<LanguageBloc, LanguageState, String>(
                      selector: (state) => state is LanguageLoaded
                          ? state.languageCode
                          : AppLanguages.english,
                      builder: (context, languageCode) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getLocalizedText(
                                  childCategory.name,
                                  childCategory.nameUz,
                                  childCategory.nameRu,
                                  languageCode),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: Constants.Arial,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 250,
                                child: Text(
                                  getLocalizedText(
                                      childCategory.description,
                                      childCategory.descriptionUz,
                                      childCategory.descriptionRu,
                                      languageCode),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: Constants.Arial,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

String getLocalizedText(
    String? eng, String? uz, String? ru, String languageCode) {
  switch (languageCode) {
    case AppLanguages.uzbek:
      return uz ?? eng ?? '';
    case AppLanguages.russian:
      return ru ?? eng ?? '';
    default:
      return eng ?? '';
  }
}
