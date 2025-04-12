import 'package:flutter/material.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final GetPublicationEntity product;

  const ProductDescriptionWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.description,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
