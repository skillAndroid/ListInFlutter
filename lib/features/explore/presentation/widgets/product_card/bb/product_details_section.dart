import 'package:flutter/material.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/global/global_status.dart';

class ProductDetailsSection extends StatelessWidget {
  final String title;
  final String location;
  final String condition;
  final double price;
  final int likes;
  final String id;
  final bool isOwner;
  final bool isLiked;
  final LikeStatus likeStatus;
  final ValueChanged<bool>? onLikeChanged;

  const ProductDetailsSection({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.condition,
    required this.likes,
    required this.isOwner,
    required this.isLiked,
    required this.likeStatus,
    this.onLikeChanged,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatPrice(price.toString()),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: Constants.Arial,
          ),
        ), //
        // Text(
        //   location,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        //   style: TextStyle(
        //     color: Theme.of(context).colorScheme.surface,
        //     fontSize: 12,
        //     fontWeight: FontWeight.w300,
        //   ),
        // ),
        // const SizedBox(height: 4),
      ],
    );
  }
}
