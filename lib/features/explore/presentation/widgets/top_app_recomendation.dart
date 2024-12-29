import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/location_bar.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/undefined_screens_yet/list.dart';

class TopAppRecomendation extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const TopAppRecomendation({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoriesList(),
          const SizedBox(height: 16),
          const LocationBar(),
          const SizedBox(height: 16),
          RecommendationsRow(recommendations: recommendations),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TopAppRecomendation2 extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const TopAppRecomendation2({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        return Container(
          color: AppColors.bgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SubcategoriesList(
                  subcategories: state.selectedCatalog!.childCategories,
                  title:  state.selectedCatalog!.name),
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
//
