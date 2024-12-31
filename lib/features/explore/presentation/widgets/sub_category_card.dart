
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/post/data/models/child_category_model.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class SubcategoryCard extends StatefulWidget {
  final ChildCategoryModel category;

  const SubcategoryCard({
    super.key,
    required this.category,
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
          context.goNamed(RoutesByName.attributes);
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
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 16);
                          },
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
                      if (widget.category.attributes.isNotEmpty)
                        Text(
                          '${widget.category.attributes.length} items',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
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
