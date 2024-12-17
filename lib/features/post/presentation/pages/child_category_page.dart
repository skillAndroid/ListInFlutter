import 'package:flutter/material.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

import '../provider/iii.dart';

class ChildCategoryListPage extends StatelessWidget {
  final Function(ChildCategory) onChildCategorySelected;

  const ChildCategoryListPage({
    super.key,
    required this.onChildCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);
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
                  shape: SmoothRectangleBorder(
                    smoothness: 1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Card(
                        shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: SmoothClipRRect(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AppImages.appLogo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          childCategory.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          childCategory.description,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
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
