// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

import '../../../profile/presentation/widgets/action_sheet_menu.dart';
import '../../../profile/presentation/widgets/delete_confirmation.dart';
import '../../../profile/presentation/widgets/info_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileProductCard extends StatelessWidget {
  final GetPublicationEntity product;
  const ProfileProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          Routes.productDetails,
          extra: product,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(3),
                child: SmoothClipRRect(
                  smoothness: 0.8,
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: "https://${product.productImages[0].url}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: AppColors.white.withOpacity(0.9),
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded,
                            size: 14, color: AppColors.black),
                        SizedBox(width: 4),
                        Text(
                          product.views.toString(),
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productTitle,
                ),
                SizedBox(height: 4),
                Text(
                  formatPrice(product.price.toString()),
                  style: AppTextStyles.price,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded,
                            size: 16, color: AppColors.myRedBrown),
                        SizedBox(width: 4),
                        Text(
                          product.likes.toString(),
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            context
                                .read<PublicationUpdateBloc>()
                                .add(InitializePublication(product));
                            context.push(
                              Routes.publicationsEdit,
                              extra: product,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.containerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: AppColors.black,
                              size: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        InkWell(
                          onTap: () => _showPublicationOptions(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.containerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Ionicons.ellipsis_vertical,
                              color: AppColors.error,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) async {
    final shouldDelete = await ConfirmationDialog.show(
      context: context,
      title: AppLocalizations.of(context)!.delete_publication,
      message: AppLocalizations.of(context)!.delete_confirmation,
      isDestructiveAction: true,
    );

    if (shouldDelete) {
      context.read<UserPublicationsBloc>().add(
            DeleteUserPublication(publicationId: product.id),
          );
    }
  }

  void _showBoostUnavailableMessage(BuildContext context) {
    InfoDialog.show(
        context: context,
        title: AppLocalizations.of(context)!.boost_unavailable,
        message: AppLocalizations.of(context)!.boost_unavailable_description);
  }

  void _showPublicationOptions(BuildContext context) {
    final options = [
      ActionSheetOption(
        title: AppLocalizations.of(context)!.boost_publication,
        icon: CupertinoIcons.rocket,
        iconColor: AppColors.primary,
        onPressed: () => _showBoostUnavailableMessage(context),
      ),
      ActionSheetOption(
        title: AppLocalizations.of(context)!.delete_publication,
        icon: CupertinoIcons.delete,
        iconColor: AppColors.error,
        onPressed: () => _showDeleteConfirmation(context),
        isDestructive: true,
      ),
    ];

    ActionSheetMenu.show(
      context: context,
      title: AppLocalizations.of(context)!.publication_options,
      message: AppLocalizations.of(context)!.choose_action,
      options: options,
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  final Widget child;
  final bool isLiked;

  const ShimmerEffect({
    super.key,
    required this.child,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isLiked ? Colors.grey[300]! : Colors.grey[400]!,
      highlightColor: isLiked ? Colors.grey[100]! : Colors.grey[200]!,
      child: child,
    );
  }
}
