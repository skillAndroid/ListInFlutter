// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/global/likeds/liked_publications_bloc.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';
import 'package:list_in/global/likeds/liked_publications_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late ScrollController _scrollController;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    context.read<LikedPublicationsBloc>().add(FetchLikedPublications());
  }

  Future<void> _handleRefresh() async {
    context.read<LikedPublicationsBloc>().add(RefreshLikedPublications());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.favorites,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 1,
        strokeWidth: 3,
        displacement: 40,
        edgeOffset: 10,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        key: _refreshKey,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildLikedPublicationsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedPublicationsGrid() {
    return BlocConsumer<LikedPublicationsBloc, LikedPublicationsState>(
      listener: (context, state) {
        if (state.error != null) {
          _showErrorSnackbar(context, state.error!);
        }
      },
      builder: (context, state) {
        // Check if publications list is empty and not loading
        if (state.publications.isEmpty && !state.isLoading) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyFavoritesView(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= state.publications.length) {
                  if (state.isLoading) {
                    return Progress();
                  }
                  return null;
                }
                final publication = state.publications[index];
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: ProductCardContainer(
                    key: ValueKey(publication.id),
                    product: publication,
                  ),
                );
              },
              childCount: state.publications.length + (state.isLoading ? 1 : 0),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.63,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
          ),
        );
      },
    );
  }

  // New method to build the empty favorites view with cute animal
  Widget _buildEmptyFavoritesView() {
    // Randomly select one of the cute animal images
    final List<String> animalImages = [
      AppImages.rabbit,
      AppImages.rubi,
      AppImages.mia,
      AppImages.dimon,
    ];

    final String randomAnimalImage =
        animalImages[DateTime.now().millisecond % animalImages.length];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            randomAnimalImage,
            width: 275,
            height: 275,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'Oops! No favorites yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }
}
