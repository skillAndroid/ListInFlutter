import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/owner_dialog.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';

class ProductCardContainer extends StatelessWidget {
  final GetPublicationEntity product;

  const ProductCardContainer({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GlobalBloc, GlobalState, ProductCardViewModel>(
      selector: (state) => ProductCardViewModel.fromPublication(product, state),
      builder: (context, model) {
        return OptimizedProductCard(
          model: model,
          onTap: () => _handleTap(context, model),
          onLikeChanged: (isLiked) =>
              _handleLikeChanged(context, model.id, isLiked),
        );
      },
    );
  }

  void _handleTap(BuildContext context, ProductCardViewModel model) {
    if (model.isOwner) {
      _showOwnerDialog(context);
    } else {
      context.push(Routes.productDetails, extra: product);
    }
  }

  void _handleLikeChanged(BuildContext context, String id, bool isLiked) {
    // Update local state immediately
    context.read<LikedPublicationsBloc>().add(
          UpdateLocalLikedPublication(
            publicationId: id,
            isLiked: isLiked,
          ),
        );

    // Update global state
    context.read<GlobalBloc>().add(
          UpdateLikeStatusEvent(
            publicationId: id,
            isLiked: isLiked,
            context: context,
          ),
        );
  }

  void _showOwnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const OwnerDialog(),
    );
  }
}
