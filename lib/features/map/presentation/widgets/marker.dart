// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/assets/app_lottie.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/map/presentation/bloc/MapState.dart';
import 'package:lottie/lottie.dart';

class AnimatedLocationMarker extends StatelessWidget {
  const AnimatedLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        bool isLocationRetrieved = state is! MapLoadingState;

        return LocationMarkerContent(
          isLocationRetrieved: isLocationRetrieved,
        );
      },
    );
  }
}

class LocationMarkerContent extends StatelessWidget {
  final bool isLocationRetrieved;

  const LocationMarkerContent({super.key, required this.isLocationRetrieved});
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: SizedBox(
        width: 45,
        height: 70,
        child: Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipOval(
                  child: Container(
                    width: 20,
                    height: 15,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.5,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipOval(
                    child: Container(
                        width: 14,
                        height: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2)),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.8,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipOval(
                    child: Container(
                        width: 6,
                        height: 4,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2)),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -4),
              child: Container(
                width: 55,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isLocationRetrieved
                              ? Icon(
                                  Icons.location_history,
                                  color: AppColors.white,
                                  size: 24,
                                )
                              : Lottie.asset(
                                  AppLottie.markerLoader,
                                  repeat: true,
                                  reverse: true,
                                ),
                        ),
                      ),
                      Container(
                        width: 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(2),
                            bottomRight: Radius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//
