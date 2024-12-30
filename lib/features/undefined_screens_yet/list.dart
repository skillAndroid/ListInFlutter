// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/category_card.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class CategoryItem {
  final String title;
  final String imageUrl;

  CategoryItem({required this.title, required this.imageUrl});
}

class CategoriesList extends StatelessWidget {
  const CategoriesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        return Container(
          color: AppColors.bgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.catalogs != null)
                _buildCategoryRow(
                    state.catalogs!.sublist(0, 1), "Popular Categories"),
              const SizedBox(height: 12), // Increased spacing between sections
              _buildCategoryRow(
                  state.catalogs!.sublist(0, 1), "Featured Categories"),
              const SizedBox(height: 12),
              _buildCategoryRow(
                  state.catalogs!.sublist(0, 1), "More Categories"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(List<CategoryModel> rowItems, String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerColor
            .withOpacity(0.5), // Light grey background for each section
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 6),
              children: rowItems
                  .map((category) => CategoryCard(
                        category: category,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SubcategoriesList extends StatelessWidget {
  final List<ChildCategoryModel> subcategories;
  final String title;

  const SubcategoriesList({
    super.key,
    required this.subcategories,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 6),
              itemCount: subcategories.length,
              itemBuilder: (context, index) => SubcategoryCard(
                category: subcategories[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubcategoryCard extends StatefulWidget {
  final ChildCategoryModel category;

  const SubcategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<SubcategoryCard> createState() => _SubcategoryCardState();
}

class _SubcategoryCardState extends State<SubcategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          context.read<HomeTreeCubit>().selectChildCategory(widget.category);
          // If there are more subcategories, navigate deeper
          if (widget.category.attributes.isNotEmpty) {
            context.go(Routes.attributes);
          } else {
            context.push('/products');
          }
        },
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleController.reverse();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleController.forward();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleController.forward();
        },
        child: ScaleTransition(
          scale: _scaleController,
          child: SmoothClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.2),
                    offset: Offset(0, _isPressed ? 1 : 2),
                    blurRadius: _isPressed ? 2 : 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 16);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (widget.category.attributes.isNotEmpty)
                        Text(
                          '${widget.category.attributes.length} items',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
