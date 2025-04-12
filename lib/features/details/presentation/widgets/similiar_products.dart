// SimilarProductsWidget - For displaying similar products
import 'package:flutter/material.dart';
import 'package:list_in/features/details/presentation/widgets/products_grid_details_pade.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SimilarProductsWidget extends StatelessWidget {
  final GetPublicationEntity product;
  final bool isOwner;

  const SimilarProductsWidget({
    super.key,
    required this.product,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isOwner ? localizations.your_post : localizations.user_other_posts,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ProductsGridWidget(isOwner: isOwner),
      ],
    );
  }
}
