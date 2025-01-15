// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/post/data/models/category_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int index;
  final double width;
  final double height;
  final double maxWidth;
  final BoxFit imageFit;
  final Offset imageOffset;
  final double radius;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.maxWidth,
    required this.imageFit,
    required this.imageOffset,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
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
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          context.read<HomeTreeCubit>().selectCatalog(widget.category);
          context.goNamed(RoutesByName.subcategories);
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
          child: Stack(
            children: [
              SmoothClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
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
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: widget.maxWidth,
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
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SmoothClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: SizedBox(
                            width: widget.maxWidth,
                            height: widget.height,
                            child: SizedBox()),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: SizedBox(
                  width: widget.maxWidth,
                  child: Text(
                    widget.category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Transform.translate(
                  offset: widget.imageOffset,
                  child: SmoothClipRRect(
                    borderRadius: BorderRadius.circular(widget.radius),
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          widget.radius,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.category.logoUrl,
                          fit: widget.imageFit,
                        ),
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
