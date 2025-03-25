// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/config/theme/app_language.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/post/data/models/category_tree/category_model.dart';
import 'package:list_in/features/post/presentation/pages/atributes_releted/child_category_page.dart';

class CategoryCard extends StatefulWidget {
  final HomeTreeState state;
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
    required this.state,
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
    return BlocSelector<LanguageBloc, LanguageState, String>(
      selector: (state) =>
          state is LanguageLoaded ? state.languageCode : AppLanguages.english,
      builder: (context, languageCode) {
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: GestureDetector(
            onTap: () {
              context.read<HomeTreeCubit>().selectCatalog(widget.category);
              context.goNamed(RoutesByName.subcategories, extra: {
                'category': widget.category,
                'priceFrom': widget.state.priceFrom,
                'priceTo': widget.state.priceTo,
                'filterState': {
                  'bargain': widget.state.bargain,
                  'isFree': widget.state.isFree,
                  'condition': widget.state.condition,
                  'sellerType': widget.state.sellerType,
                  'country': widget.state.selectedCountry,
                  'state': widget.state.selectedState,
                  'county': widget.state.selectedCounty,
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
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
                            getLocalizedText(
                                widget.category.name,
                                widget.category.nameUz,
                                widget.category.nameRu,
                                languageCode),
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
                            width: widget.maxWidth,
                            height: widget.height,
                            child: SizedBox()),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: SizedBox(
                      width: widget.maxWidth,
                      child: Text(
                        getLocalizedText(
                            widget.category.name,
                            widget.category.nameUz,
                            widget.category.nameRu,
                            languageCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
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
                      offset: widget.imageOffset,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
