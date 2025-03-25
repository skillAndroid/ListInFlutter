import 'package:flutter/cupertino.dart';
import 'package:list_in/features/explore/presentation/widgets/category_list.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';

class TopAppRecomendationCategory extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const TopAppRecomendationCategory({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        RecommendationsRow(recommendations: recommendations),
        const SizedBox(height: 2),
        CategoriesList(),
      ],
    );
  }
}

//
