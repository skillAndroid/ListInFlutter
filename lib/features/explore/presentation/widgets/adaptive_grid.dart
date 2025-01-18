import 'package:flutter/material.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
class AdaptiveProductGrid extends StatelessWidget {
  final List<GetPublicationEntity> publications;

  const AdaptiveProductGrid({
    super.key,
    required this.publications,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= publications.length) return null;
          
          return RemouteRegularProductCard(
            key: ValueKey(publications[index].id),
            product: publications[index],
          );
        },
        childCount: publications.length,
      ),
    );
  }
}