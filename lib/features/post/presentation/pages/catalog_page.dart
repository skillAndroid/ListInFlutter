import 'package:flutter/material.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/features/post/presentation/pages/model.dart';
import 'package:list_in/features/post/presentation/provider/iii.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class CatalogListPage extends StatelessWidget {
  final Function(Catalog) onCatalogSelected;

  const CatalogListPage({super.key, required this.onCatalogSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);
    final catalogs = provider.catalogModel?.catalogs ?? [];

    return ListView(
      children: [
        for (var catalog in catalogs)
          Column(
            children: [
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () => onCatalogSelected(catalog),
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
                      children: [
                        Text(catalog.name),
                        const SizedBox(height: 6),
                        Text(catalog.description),
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