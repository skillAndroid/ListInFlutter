import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ProductConditionPage extends StatefulWidget {
  const ProductConditionPage({super.key});

  @override
  State<ProductConditionPage> createState() => _ProductConditionPageState();
}

class _ProductConditionPageState extends State<ProductConditionPage> {
  String _selectedCondition = 'NEW_PRODUCT';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PostProvider>(context, listen: false);
    _selectedCondition = provider.productCondition;
  }

  void _updateCondition(String condition) {
    setState(() {
      _selectedCondition = condition;
    });
    final provider = Provider.of<PostProvider>(context, listen: false);
    provider.changeProductCondition(condition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.0, left: 2),
              child: Text(
                AppLocalizations.of(context)!.product_condition,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: Constants.Arial,
                ),
              ),
            ),
            _buildConditionOption(
              title: AppLocalizations.of(context)!.condition_new,
              description: AppLocalizations.of(context)!.unused_product,
              value: 'NEW_PRODUCT',
            ),
            const SizedBox(height: 12),
            _buildConditionOption(
              title: AppLocalizations.of(context)!.condition_used,
              description: AppLocalizations.of(context)!.used_product,
              value: 'USED_PRODUCT',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionOption({
    required String title,
    required String description,
    required String value,
  }) {
    final isSelected = _selectedCondition == value;

    return GestureDetector(
      onTap: () => _updateCondition(value),
      child: SmoothClipRRect(
        smoothness: 1,
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).cardColor,
          width: 1.5,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: Constants.Arial,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: Constants.Arial,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
