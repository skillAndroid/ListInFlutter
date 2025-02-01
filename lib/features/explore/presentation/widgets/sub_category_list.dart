// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/widgets/sub_category_card.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
class SubcategoriesList extends StatefulWidget {
  final List<ChildCategoryModel> subcategories;
  final CategoryModel categoryModel;
  final String title;
  final int? categoryIndex;

  const SubcategoriesList({
    super.key,
    required this.subcategories,
    required this.title,
    required this.categoryIndex,
    required this.categoryModel,
  });

  @override
  State<SubcategoriesList> createState() => _SubcategoriesListState();
}

class _SubcategoriesListState extends State<SubcategoriesList> {
  @override
  Widget build(BuildContext context) {
    // Split subcategories into three rows
    final int rowLength = (widget.subcategories.length / 3).ceil();
    final firstRow = widget.subcategories.take(rowLength).toList();
    final secondRow = widget.subcategories.skip(rowLength).take(rowLength).toList();
    final thirdRow = widget.subcategories.skip(rowLength * 2).take(rowLength).toList();

    return Container(
      color: AppColors.bgColor,
      height: 255, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(firstRow, 0, true),
                    const SizedBox(height: 8),
                    _buildRow(secondRow, 1, false),
                    const SizedBox(height: 8),
                    _buildRow(thirdRow, 2, false),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<ChildCategoryModel> items, int rowIndex, bool isFirstRow) {
    final List<Map<String, dynamic>> configs = [
      {
        'maxWidth': 75.0,
        'imageFit': BoxFit.contain,
        'offset': const Offset(16, 8),
        'width': 85.0,
        'height': 70.0,
        'radius': 16.0
      },
      {
        'maxWidth': 70.0,
        'imageFit': BoxFit.contain,
        'offset': const Offset(8, 8),
        'width': 80.0,
        'height': 70.0,
        'radius': 16.0
      },
      {
        'maxWidth': 70.0,
        'imageFit': BoxFit.contain,
        'offset': const Offset(8, 8),
        'width': 80.0,
        'height': 70.0,
        'radius': 16.0
      },
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final config = configs[index % configs.length];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SubcategoryCard(
            category: category,
            categoryM: widget.categoryModel,
            categoryIndex: widget.categoryIndex!,
            itemIndex: index + (rowIndex * items.length),
            config: config,
          ),
        );
      }).toList(),
    );
  }
}