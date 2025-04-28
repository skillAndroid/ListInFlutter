import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/features/details/presentation/bloc/details_bloc.dart';
import 'package:list_in/features/details/presentation/bloc/details_state.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/product_card_container.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';

import '../bloc/details_event.dart';

class ProductsGridWidget extends StatelessWidget {
  final bool isOwner;

  const ProductsGridWidget({
    super.key,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<DetailsBloc, DetailsState>(
      builder: (context, state) {
        if (state.status == DetailsStatus.loading &&
            state.publications.isEmpty) {
          return Progress();
        }
        if (state.status == DetailsStatus.failure &&
            state.publications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    context.read<DetailsBloc>().add(
                          FetchPublications(
                            userId: state.profile?.id ?? '',
                            isInitialFetch: true,
                          ),
                        );
                  },
                  child: Text(localizations.retry),
                ),
                if (state.errorMessage != null) Text(state.errorMessage!),
              ],
            ),
          );
        }
        if (state.publications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.inventory, size: 72, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  localizations.no_publications_available,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 24, left: 0),
          child: SizedBox(
            height: 300, // Adjust height based on your product card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount:
                  state.publications.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Check if we need to load more
                if (index >= state.publications.length - 4 &&
                    !state.isLoadingMore &&
                    !state.hasReachedEnd) {
                  context.read<DetailsBloc>().add(
                        FetchPublications(
                          userId: state.profile?.id ?? '',
                        ),
                      );
                }

                if (index == state.publications.length) {
                  if (state.isLoadingMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return null;
                }

                final publication = state.publications[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 : 4),
                  child: SizedBox(
                    width: 180, // Adjust width based on your design
                    child: ProductCardContainer(
                      product: publication,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
