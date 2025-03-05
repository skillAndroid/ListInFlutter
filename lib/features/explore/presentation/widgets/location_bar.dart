// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocationBar extends StatelessWidget {
  const LocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.black,
                    size: 24,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.myRedBrown,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tashkent',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Uzbekistan',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IntrinsicWidth(
            // Added this to ensure proper width calculation
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize:
                        MainAxisSize.min, // Added this to ensure proper width
                    children: [
                      Icon(
                        Icons.edit_location_alt_rounded,
                        color: AppColors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2), // Added spacing before underline
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ClipOval(
                      child: Container(
                        height: 2, // Made line slightly thicker
                        color: AppColors
                            .containerColor, // Made line slightly visible
                        width: double
                            .infinity, // Makes the line take full width of parent
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
