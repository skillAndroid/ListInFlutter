// ProductTitleWidget - For displaying product title
import 'package:flutter/material.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class ProductTitleWidget extends StatelessWidget {
  final GetPublicationEntity product;

  const ProductTitleWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        product.title,
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
