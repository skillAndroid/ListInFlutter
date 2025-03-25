// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/sub_category_card.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/data/models/category_tree/child_category_model.dart';

class SubcategoriesList extends StatefulWidget {
  final HomeTreeState state;
  final List<ChildCategoryModel> subcategories;
  final CategoryModel categoryModel;
  final String title;
  final int? categoryIndex;

  const SubcategoriesList({
    super.key,
    required this.state,
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
    final secondRow =
        widget.subcategories.skip(rowLength).take(rowLength).toList();
    final thirdRow =
        widget.subcategories.skip(rowLength * 2).take(rowLength).toList();

    return SizedBox(
      height: 245,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(firstRow, 0, true, widget.state),
                    const SizedBox(height: 8),
                    _buildRow(secondRow, 1, false, widget.state),
                    const SizedBox(height: 8),
                    _buildRow(thirdRow, 2, false, widget.state),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<ChildCategoryModel> items, int rowIndex,
      bool isFirstRow, HomeTreeState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5),
          child: SubcategoryCard(
            state: state,
            category: category,
            categoryM: widget.categoryModel,
            categoryIndex: widget.categoryIndex!,
            itemIndex: index + (rowIndex * items.length),
          ),
        );
      }).toList(),
    );
  }
}
