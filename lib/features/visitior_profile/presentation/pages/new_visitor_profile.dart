// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';

class StoreProfilePage extends StatelessWidget {
  const StoreProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {},
            ),
          ],
          title: Text(
            'Store',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 220,
                  collapsedHeight: 84,
                  floating: false,
                  pinned: true,
                  surfaceTintColor: AppColors.white,
                  shadowColor: AppColors.transparent,
                  backgroundColor: AppColors.containerColor2,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      // Get the top scroll position
                      final double expandRatio =
                          (constraints.maxHeight - kToolbarHeight) /
                              (220 - kToolbarHeight);
                      final double parallaxOffset =
                          (1.0 - expandRatio.clamp(0.0, 1.0)) * 80;

                      // Calculate opacity for the fixed animated container
                      // Show when collapsed to 50% (expandRatio ≈ 0.5), hide when expanded to 55% (expandRatio ≈ 0.55)
                      final double containerOpacity = expandRatio <= 0.5
                          ? 1.0
                          : expandRatio >= 0.55
                              ? 0.0
                              : (0.55 - expandRatio) *
                                  20; // Smooth transition in the 0.5-0.55 range

                      final double titleOpacity = expandRatio > 0.7
                          ? 0.0
                          : ((0.7 - expandRatio) * (10 / 3)).clamp(0.0, 1.0);

                      return Stack(
                        children: [
                          FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Banner with parallax effect
                                Positioned(
                                  top: -parallaxOffset,
                                  left: 0,
                                  right: 0,
                                  height: 220 - 120,
                                  child: Image.asset(
                                    AppImages.closes,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // Top white container with opacity animation
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 60, // Height for top container
                                  child: AnimatedOpacity(
                                    opacity:
                                        titleOpacity, // Using same opacity logic as title
                                    duration: Duration(milliseconds: 150),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.containerColor2,
                                            AppColors.containerColor2
                                                .withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Gradient overlay
                                AnimatedOpacity(
                                  opacity:
                                      (1.0 - expandRatio.clamp(0.0, 1.0)) * 0.5,
                                  duration: Duration(milliseconds: 150),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Profile section with parallax effect
                                Positioned(
                                  bottom: 0 + (parallaxOffset * 0.5),
                                  left: 0,
                                  right: 0,
                                  height: 130,
                                  child: Container(
                                    color: AppColors.containerColor2,
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16,
                                      top: 16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Profile Image with parallax
                                        Transform.translate(
                                          offset: Offset(
                                              0,
                                              -parallaxOffset *
                                                  0.3), // Avatar moves up too
                                          child: CircleAvatar(
                                            radius: 44,
                                            backgroundColor: Colors.black,
                                            backgroundImage: AssetImage(
                                              AppImages.appLogo,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        // Store Info with parallax
                                        Expanded(
                                          child: Transform.translate(
                                            offset: Offset(
                                                0,
                                                -parallaxOffset *
                                                    0.2), // Text moves up slightly
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Plique Luxury Boutique',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 21,
                                                    height: 1.3,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  '85 followers',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '100% positive feedback',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '1.2K items sold',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Favorite Button with parallax
                                        Transform.translate(
                                          offset: Offset(
                                              0,
                                              -parallaxOffset *
                                                  0.3), // Button moves up too
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.favorite_border,
                                              color: Colors.black,
                                              size: 28,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            collapseMode: CollapseMode.parallax,
                            centerTitle: false,
                          ),

                          // FIXED container on top that's only affected by visibility animation
                          // This container is completely separate from the collapsing content
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 70,
                            child: AnimatedOpacity(
                              opacity: containerOpacity,
                              duration: Duration(
                                  milliseconds: 100), // 100ms animation
                              child: Container(
                                color: AppColors.containerColor2,
                                child: SafeArea(
                                  top: true,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.black,
                                              backgroundImage: AssetImage(
                                                AppImages.appLogo,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Plique Luxury Boutique',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  '100% positive feedback',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.favorite_border),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      indicatorWeight: 0.1,
                      dividerColor: AppColors.transparent,
                      labelStyle: const TextStyle(
                        fontFamily: Constants.Arial,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                          fontFamily: Constants.Arial,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(
                          text: 'Shop',
                        ),
                        Tab(
                          text: 'Sale',
                        ),
                        Tab(
                          text: 'About',
                        ),
                        Tab(
                          text: 'Feedback',
                        ),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            // Tab content that scrolls underneath
            body: TabBarView(
              children: [
                // Shop Tab Content
                ShopTabContent(),
                // Sale Tab Content
                Center(child: Text('Sale Content')),
                // About Tab Content
                Center(child: Text('About Content')),
                // Feedback Tab Content
                Center(child: Text('Feedback Content')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Rest of the classes remain unchanged
class ShopTabContent extends StatelessWidget {
  const ShopTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          // Categories Row
          Row(
            children: [
              Expanded(
                child: CategoryCard(
                  image: 'assets/boots.jpg',
                  title: 'Boots',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CategoryCard(
                  image: 'assets/athletic_shoes.jpg',
                  title: 'Athletic Shoes',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CategoryCard(
                  image: 'assets/sandals.jpg',
                  title: 'Sandals',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // Add more content here
          Text(
            'New arrivals',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return ProductCard();
            },
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String image;
  final String title;

  const CategoryCard({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                color: Colors.grey[200],
              ),
              child: Center(
                child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
              ),
            ),
          ),
          // Product Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample Product',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '\$99.99',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
