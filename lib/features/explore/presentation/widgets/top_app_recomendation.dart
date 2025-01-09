import 'package:flutter/cupertino.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/widgets/location_bar.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:list_in/features/explore/presentation/widgets/category_list.dart';

class TopAppRecomendationCategory extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const TopAppRecomendationCategory({
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

//
