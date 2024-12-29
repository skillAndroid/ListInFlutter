import 'package:flutter/cupertino.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/widgets/location_bar.dart';
import 'package:list_in/features/undefined_screens_yet/list.dart';

class TopAppRecomendation extends StatelessWidget {
  final List<CategoryItem> categories;
  final List<RecommendationItem> recommendations;

  const TopAppRecomendation({
    super.key,
    required this.categories,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoriesList(categories: categories),
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
//