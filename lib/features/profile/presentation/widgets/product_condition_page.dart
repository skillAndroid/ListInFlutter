import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';

class ProductConditionWidget extends StatefulWidget {
  const ProductConditionWidget({super.key});

  @override
  State<ProductConditionWidget> createState() => _ProductConditionPageState();
}

class _ProductConditionPageState extends State<ProductConditionWidget> {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0, left: 2),
              child: Text(
                'What\'s the condition of your product?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Syne",
                ),
              ),
            ),
            _buildConditionOption(
              title: 'New',
              description: 'Unused product with original packaging',
              value: 'NEW_PRODUCT',
            ),
            const SizedBox(height: 12),
            _buildConditionOption(
              title: 'Used',
              description: 'Product has been used before',
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
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.black : Colors.transparent,
          width: 2,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.containerColor,
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
                        fontFamily: "Syne",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: "Syne",
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
                    color: isSelected ? AppColors.black : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.black,
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
