import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class CatalogListPage extends StatelessWidget {
  final Function(CategoryModel) onCatalogSelected;

  const CatalogListPage({super.key, required this.onCatalogSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PostProvider>(context);
    final catalogs = provider.catalogs ?? [];

    return ListView(
      children: [
        for (var catalog in catalogs)
          Column(
            children: [
              SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () => onCatalogSelected(catalog),
                style: ElevatedButton.styleFrom(
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
                        color: AppColors.containerColor,
                        shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        elevation: 0,
                        child: SmoothClipRRect(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(0),
                          child: CachedNetworkImage(
                            imageUrl: catalog.logoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<LanguageBloc, LanguageState>(
                          builder: (context, state) {
                            String nameToShow =
                                catalog.nameUz; // Default fallback

                            if (state is LanguageLoaded) {
                              switch (state.languageCode) {
                                case AppLanguages.russian:
                                  nameToShow = catalog.nameRu;
                                  break;
                                case AppLanguages.uzbek:
                                  nameToShow = catalog.nameUz;
                                  break;
                                case AppLanguages.english:
                                  nameToShow = catalog
                                      .name; // Assuming this is the English name
                                  break;
                              }
                            }

                            return Text(
                              nameToShow,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: Constants.Arial,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: SizedBox(
                            width: 250,
                            child: Text(
                              catalog.description,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
//
