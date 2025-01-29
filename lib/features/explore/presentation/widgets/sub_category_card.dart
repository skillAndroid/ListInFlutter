// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class SubcategoryCard extends StatefulWidget {
  final ChildCategoryModel category;
  final CategoryModel categoryM;
  final int categoryIndex;
  final int itemIndex;

  const SubcategoryCard({
    super.key,
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
          context.goNamed(RoutesByName.attributes, extra: {
            'category': widget.categoryM,
            'childCategory': widget.category,
          });
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: Padding(
                        padding: EdgeInsets.all(((widget.itemIndex != 7) &&
                                widget.categoryIndex == 1)
                            ? 0
                            : 5),
                        child: SmoothClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: widget.category.logoUrl,
                            fit: BoxFit.contain,
                          ),
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
