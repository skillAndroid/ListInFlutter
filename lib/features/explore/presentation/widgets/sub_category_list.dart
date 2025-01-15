// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/widgets/sub_category_card.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

class SubcategoriesList extends StatefulWidget {
  final List<ChildCategoryModel> subcategories;
  final String title;
  final int? categoryIndex; // Added category index

  const SubcategoriesList({
    super.key,
    required this.subcategories,
    required this.title,
    required this.categoryIndex, // New required parameter
  });

  @override
  _SubcategoriesListState createState() => _SubcategoriesListState();
}

class _SubcategoriesListState extends State<SubcategoriesList> {
  @override
  Widget build(BuildContext context) {
    final itemsPerRow = (widget.subcategories.length / 3).ceil();

    List<List<ChildCategoryModel>> rows = [];
    for (int i = 0; i < widget.subcategories.length; i += itemsPerRow) {
      final end = (i + itemsPerRow < widget.subcategories.length)
          ? i + itemsPerRow
          : widget.subcategories.length;
      rows.add(widget.subcategories.sublist(i, end));
    }

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
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          ...rows
              .map((rowItems) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: rowItems
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: SubcategoryCard(
                                    category: entry.value,
                                    categoryIndex: widget.categoryIndex!,
                                    itemIndex: entry.key +
                                        (rows.indexOf(rowItems) * itemsPerRow),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ))
              ,
        ],
      ),
    );
  }
}
