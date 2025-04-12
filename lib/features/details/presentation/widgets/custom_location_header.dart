// Create a ProductDetailsScreen
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomLocationHeader extends StatelessWidget {
  final String locationName;
  final VoidCallback onBackPressed;
  final VoidCallback onMapsPressed;
  final double elevation;
  final Color backgroundColor;
  final EdgeInsets padding;

  const CustomLocationHeader({
    super.key,
    required this.locationName,
    required this.onBackPressed,
    required this.onMapsPressed,
    this.elevation = 1,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      margin: EdgeInsets.zero,
      elevation: elevation,
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: onBackPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),

              // Location Section
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        locationName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 16,
              ),

              // Maps Button
              TextButton(
                onPressed: onMapsPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  localizations.map,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
