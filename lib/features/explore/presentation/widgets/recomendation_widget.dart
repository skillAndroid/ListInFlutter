// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class RecommendationsRow extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const RecommendationsRow({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = recommendations[index];
          return RecommendationCard(item: item);
        },
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final RecommendationItem item;

  const RecommendationCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 4, right: 8), // Add bottom padding here
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmoothClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
              ),
              child: Icon(
                item.icon,
                size: 16,
                color: item.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationItem {
  final String title;
  final IconData icon;
  final Color color;

  RecommendationItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}
