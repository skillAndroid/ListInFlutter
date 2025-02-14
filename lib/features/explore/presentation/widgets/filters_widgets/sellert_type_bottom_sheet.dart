import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/pages/filter/filter.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class SellerTypeBottomSheet extends StatelessWidget {
  const SellerTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTreeCubit, HomeTreeState>(
      builder: (context, state) {
        return SmoothClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: const Text(
                    'Seller Type',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSellerOption(
                  context: context,
                  title: 'All',
                  isSelected: state.sellerType == SellerType.ALL,
                  onTap: () {
                    context
                        .read<HomeTreeCubit>()
                        .updateSellerType(SellerType.ALL, true);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildSellerOption(
                  context: context,
                  title: 'Individual',
                  isSelected: state.sellerType == SellerType.INDIVIDUAL_SELLER,
                  onTap: () {
                    context
                        .read<HomeTreeCubit>()
                        .updateSellerType(SellerType.INDIVIDUAL_SELLER, true);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildSellerOption(
                  context: context,
                  title: 'Shop',
                  isSelected: state.sellerType == SellerType.BUSINESS_SELLER,
                  onTap: () {
                    context
                        .read<HomeTreeCubit>()
                        .updateSellerType(SellerType.BUSINESS_SELLER, true);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSellerOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : Colors.black,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
