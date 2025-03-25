import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/sub_category_list.dart';

class TopAppRecomendationSubCategory extends StatelessWidget {
  const TopAppRecomendationSubCategory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        // Get the index of the selected catalog from the parent catalogs list
        final selectedCatalogIndex = state.catalogs
            ?.indexWhere((catalog) => catalog.id == state.selectedCatalog?.id);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SubcategoriesList(
              state: state,
              categoryModel: state.selectedCatalog!,
              subcategories: state.selectedCatalog!.childCategories,
              title: state.selectedCatalog!.name,
              categoryIndex:
                  selectedCatalogIndex != -1 ? selectedCatalogIndex : 0,
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
