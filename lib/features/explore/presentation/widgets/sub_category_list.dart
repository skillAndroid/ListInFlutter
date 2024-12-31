// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/widgets/sub_category_card.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

class SubcategoriesList extends StatefulWidget {
  final List<ChildCategoryModel> subcategories;
  final String title;

  const SubcategoriesList({
    super.key,
    required this.subcategories,
    required this.title,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SubcategoriesListState createState() => _SubcategoriesListState();
}

class _SubcategoriesListState extends State<SubcategoriesList> {
  bool _showAll = false; // To toggle between showing limited and full list.

  @override
  Widget build(BuildContext context) {
    // Determine the subcategories to display based on the toggle state.
    final displayedSubcategories =
        _showAll ? widget.subcategories : widget.subcategories.take(7).toList();

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
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 8, // Horizontal spacing between cards.
              runSpacing: 8, // Vertical spacing between lines.
              children: displayedSubcategories
                  .map((category) => SubcategoryCard(
                        category: category,
                      ))
                  .toList(),
            ),
          ),
          if (widget.subcategories.length > 7)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll; // Toggle the state.
                  });
                },
                child: Text(
                  _showAll ? "Show Less" : "Show All",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
