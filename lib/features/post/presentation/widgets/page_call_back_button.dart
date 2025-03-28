// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class CatalogBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isVisible;

  const CatalogBackButton(
      {super.key, required this.onTap, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return SmoothClipRRect(
      smoothness: 1,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 36,
        height: 36,
        child: InkWell(
          onTap: onTap,
          child: Card(
            elevation: 0,
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: SmoothRectangleBorder(
              smoothness: 1,
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.125),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                AppIcons.arrowBackNoShadow,
                width: 24,
                height: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//
