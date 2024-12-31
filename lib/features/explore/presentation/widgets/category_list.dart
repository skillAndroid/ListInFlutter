// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/category_card.dart';
import 'package:list_in/features/post/data/models/category_model.dart';

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
