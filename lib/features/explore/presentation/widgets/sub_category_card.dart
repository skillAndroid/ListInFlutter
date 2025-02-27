// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';

class SubcategoryCard extends StatefulWidget {
  final HomeTreeState state;
  final ChildCategoryModel category;
  final CategoryModel categoryM;
  final int categoryIndex;
  final int itemIndex;

  const SubcategoryCard({
    super.key,
    required this.state,
    required this.category,
    required this.categoryIndex,
    required this.itemIndex,
    required this.categoryM,
  });

  @override
  State<SubcategoryCard> createState() => _SubcategoryCardState();
}

class _SubcategoryCardState extends State<SubcategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

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
      padding: const EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: () {
          context.read<HomeTreeCubit>().selectChildCategory(widget.category);
          context.goNamed(RoutesByName.attributes, extra: {
            'category': widget.categoryM,
            'childCategory': widget.category,
            'priceFrom': widget.state.priceFrom,
            'priceTo': widget.state.priceTo,
            'filterState': {
              'bargain': widget.state.bargain,
              'isFree': widget.state.isFree,
              'condition': widget.state.condition,
              'sellerType': widget.state.sellerType,
            },
          });
        },
        onTapDown: (_) {
          _scaleController.reverse();
        },
        onTapUp: (_) {
          _scaleController.forward();
        },
        onTapCancel: () {
          _scaleController.forward();
        },
        child: ScaleTransition(
          scale: _scaleController,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 75,
                      ),
                      child: Text(
                        widget.category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.transparent,
                          fontWeight: FontWeight.w500,
                         fontFamily: Constants.Arial,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: SizedBox(
                  width: 75,
                  child: Text(
                    widget.category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.Arial,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(-4, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: CachedNetworkImage(
                        imageUrl: widget.category.logoUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
