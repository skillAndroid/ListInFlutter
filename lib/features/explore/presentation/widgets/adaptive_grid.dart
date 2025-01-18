import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/pages/initial_page.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
class DynamicPublicationGrid extends StatelessWidget {
  final PagingController<int, GetPublicationEntity> pagingController;

  const DynamicPublicationGrid({
    super.key,
    required this.pagingController,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      sliver: PagedSliverGrid<int, GetPublicationEntity>(
        pagingController: pagingController,
        // Use custom delegate for dynamic grid layout
        gridDelegate: DynamicSliverGridDelegate(
          childAspectRatio: 0.66,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          getItemSpan: (GetPublicationEntity publication) {
            // Return full width for video publications
            return publication.videoUrl != null ? 2 : 1;
          },
        ),
        builderDelegate: PagedChildBuilderDelegate<GetPublicationEntity>(
          itemBuilder: (context, publication, index) {
            return RemouteRegularProductCard(
              key: ValueKey('publication_${publication.id}'),
              product: publication,
            );
          },
          firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
            error: pagingController.error,
            onTryAgain: () => pagingController.refresh(),
          ),
        ),
      ),
    );
  }
}

class DynamicSliverGridDelegate extends SliverGridDelegate {
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int Function(GetPublicationEntity item) getItemSpan;
  
  const DynamicSliverGridDelegate({
    required this.childAspectRatio,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.getItemSpan,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int baseCrossAxisCount = 2; // Default to 2 columns
    final double usableCrossAxisExtent = 
        constraints.crossAxisExtent - crossAxisSpacing * (baseCrossAxisCount - 1);
    final double cellWidth = usableCrossAxisExtent / baseCrossAxisCount;
    final double cellHeight = cellWidth / childAspectRatio;

    return SliverGridRegularTileLayout(
      crossAxisCount: baseCrossAxisCount,
      mainAxisStride: cellHeight + mainAxisSpacing,
      crossAxisStride: cellWidth + crossAxisSpacing,
      childMainAxisExtent: cellHeight,
      childCrossAxisExtent: cellWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(covariant DynamicSliverGridDelegate oldDelegate) {
    return childAspectRatio != oldDelegate.childAspectRatio ||
           mainAxisSpacing != oldDelegate.mainAxisSpacing ||
           crossAxisSpacing != oldDelegate.crossAxisSpacing;
  }
}