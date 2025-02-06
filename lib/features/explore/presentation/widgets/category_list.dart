// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/category_card.dart';
import 'package:list_in/features/post/data/models/category_model.dart';

class CategoriesList extends StatelessWidget {
  const CategoriesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        if (state.catalogs == null) {
          return const SizedBox.shrink();
        }

        // Split catalogs into two rows
        final int halfLength = (state.catalogs!.length / 2).ceil();
        final firstRow = state.catalogs!.take(halfLength).toList();
        final secondRow =
            state.catalogs!.skip(halfLength).take(halfLength).toList();

        return Container(
          color: AppColors.bgColor,
          height: 170, // Adjusted height for two rows
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(firstRow, true, state),
                  const SizedBox(height: 8),
                  _buildRow(secondRow, false, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(List<CategoryModel> items, bool isFirstRow, HomeTreeState state) {
    final List<Map<String, dynamic>> configs = isFirstRow
        ? [
            // First row configs
            {
              'maxWidth': 75.0,
              'imageFit': BoxFit.cover,
              'offset': const Offset(16, 8),
              'width': 90.0,
              'height': 70.0,
              'radius': 0.0
            },
            {
              'maxWidth': 70.0,
              'imageFit': BoxFit.contain,
              'offset': const Offset(8, -2),
              'width': 85.0,
              'height': 70.0,
              'radius': 0.0
            },
            {
              'maxWidth': 70.0,
              'imageFit': BoxFit.cover,
              'offset': const Offset(8, 12),
              'width': 95.0,
              'height': 70.0,
              'radius': 0.0
            },
            {
              'maxWidth': 60.0,
              'imageFit': BoxFit.contain,
              'offset': const Offset(10, 8),
              'width': 70.0,
              'height': 70.0,
              'radius': 0.0
            },
            {
              'maxWidth': 60.0,
              'imageFit': BoxFit.cover,
              'offset': const Offset(10, 16),
              'width': 70.0,
              'height': 70.0,
              'radius': 0.1
            },
          ]
        : [
            {
              'maxWidth': 62.0,
              'imageFit': BoxFit.contain,
              'offset': const Offset(8, 3.5),
              'width': 60.0,
              'height': 75.0,
              'radius': 0.0
            },
            {
              'maxWidth': 60.0,
              'imageFit': BoxFit.contain,
              'offset': const Offset(3, 12),
              'width': 80.0,
              'height': 75.0,
              'radius': 0.0
            },
            {
              'maxWidth': 80.0,
              'imageFit': BoxFit.cover,
              'offset': const Offset(4, 8),
              'width': 85.0,
              'height': 75.0,
              'radius': 0.0
            },
            {
              'maxWidth': 65.0,
              'imageFit': BoxFit.contain,
              'offset': const Offset(6, 8),
              'width': 60.0,
              'height': 75.0,
              'radius': 0.0
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final config = configs[index % configs.length];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: CategoryCard(
                state : state,
                category: category,
                index: index,
                maxWidth: config['maxWidth'],
                imageFit: config['imageFit'],
                imageOffset: config['offset'],
                width: config['width'],
                height: config['height'],
                radius: config['radius'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
