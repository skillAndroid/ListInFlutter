
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/location_bar.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/explore/presentation/widgets/sub_category_list.dart';
class TopAppRecomendationSubCategory extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const TopAppRecomendationSubCategory({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        // Get the index of the selected catalog from the parent catalogs list
        final selectedCatalogIndex = state.catalogs?.indexWhere(
          (catalog) => catalog.id == state.selectedCatalog?.id
        );

        return Container(
          color: AppColors.bgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SubcategoriesList(
                subcategories: state.selectedCatalog!.childCategories,
                title: state.selectedCatalog!.name,
                categoryIndex: selectedCatalogIndex != -1 ? selectedCatalogIndex : 0,
              ),
              const SizedBox(height: 16),
              const LocationBar(),
              const SizedBox(height: 16),
              RecommendationsRow(recommendations: recommendations),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}