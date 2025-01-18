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
                    state.catalogs!.sublist(0, 3), "Popular Categories"),
              const SizedBox(height: 4),
              if (state.catalogs != null) // Increased spacing between sections
                _buildCategoryRow(
                    state.catalogs!.sublist(3, 6), "Featured Categories"),
              if (state.catalogs != null) 
              const SizedBox(height: 4),
               if (state.catalogs != null) 
              _buildCategoryRow(
                  state.catalogs!.sublist(6, 9), "More Categories"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(List<CategoryModel> rowItems, String title) {
    final List<List<Map<String, dynamic>>> rowsConfigs = [
      // First row configs (Popular)
      [
        {
          'maxWidth': 50.0,
          'imageFit': BoxFit.cover,
          'offset': const Offset(16, 4),
          'width': 75.0,
          'height': 60.0,
          'radius': 0.0
        },
        {
          'maxWidth': 60.0,
          'imageFit': BoxFit.contain,
          'offset': const Offset(12, -2),
          'width': 60.0,
          'height': 60.0,
          'radius': 0.0
        },
        {
          'maxWidth': 70.0,
          'imageFit': BoxFit.cover,
          'offset': const Offset(8, 12),
          'width': 90.0,
          'height': 70.0,
          'radius': 0.0
        },
      ],
      // Second row configs (Featured)
      [
        {
          'maxWidth': 60.0,
          'imageFit': BoxFit.cover,
          'offset': const Offset(4, 5),
          'width': 50.0,
          'height': 65.0,
          'radius': 0.0
        },
        {
          'maxWidth': 60.0,
          'imageFit': BoxFit.cover,
          'offset': const Offset(4, 14),
          'width': 65.0,
          'height': 65.0,
          'radius': 0.0
        },
        {
          'maxWidth': 60.0,
          'imageFit': BoxFit.cover,
          'offset': const Offset(4, 2),
          'width': 50.0,
          'height': 60.0,
          'radius': 0.0
        },
      ],
      // Third row configs (More)
      [
        {
          'maxWidth': 60.0,
          'imageFit': BoxFit.contain,
          'offset': const Offset(-2, 4),
          'width': 68.0,
          'height': 58.0,
          'radius': 0.0
        },
        {
          'maxWidth': 77.0,
          'imageFit': BoxFit.cover,
          'offset': const Offset(-4, 8),
          'width': 70.0,
          'height': 64.0,
          'radius': 0.0
        },
        {
          'maxWidth': 65.0,
          'imageFit': BoxFit.fitHeight,
          'offset': const Offset(-4, 2),
          'width': 60.0,
          'height': 60.0,
          'radius': 0.0
        },
      ],
    ];

    int rowPosition = 0;
    if (title == "Featured Categories") {
      // Using localization
      rowPosition = 1;
    } else if (title == "More Categories") {
      // Using localization
      rowPosition = 2;
    }

    // Get the configs for current row
    final List<Map<String, dynamic>> currentRowConfigs =
        rowsConfigs[rowPosition];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
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
            height: 68,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 6),
              children: rowItems.asMap().entries.map((entry) {
                int globalIndex = entry.key;
                CategoryModel category = entry.value;

                // Get configuration for this index
                final config = currentRowConfigs[globalIndex];

                return CategoryCard(
                  category: category,
                  index: globalIndex,
                  maxWidth: config['maxWidth'],
                  imageFit: config['imageFit'],
                  imageOffset: config['offset'],
                  width: config['width'],
                  height: config['height'],
                  radius: config['radius'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
