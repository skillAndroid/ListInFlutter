import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';

class ProductPriceWidget extends StatelessWidget {
  final GetPublicationEntity product;

  const ProductPriceWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Text.rich(
      TextSpan(
        text: "${formatPrice(product.price.toString())} ", // Main price
        style: TextStyle(
          fontSize: 24,
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w800,
          fontFamily: Constants.Arial,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: localizations.currency, // Currency text
            style: TextStyle(
              fontSize: 18, // Smaller font size
              fontWeight: FontWeight.w400, // Lighter weight
              color: Theme.of(context).colorScheme.surface,
              fontFamily: Constants.Arial,
            ),
          ),
        ],
      ),
    );
  }
}
