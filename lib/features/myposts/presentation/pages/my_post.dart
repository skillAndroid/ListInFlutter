// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class MyPosts extends StatelessWidget {
  const MyPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgColor,
        elevation: 8,
        shadowColor: AppColors.black.withOpacity(0.1),
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Row(
          children: [
            SmoothClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.all(8),
                color: AppColors.containerColor,
                child: Text(
                  'My Posts',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Spacer(),
            IconButton(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  AppIcons.searchIcon,
                  color: AppColors.black,
                ),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  AppIcons.filterIc,
                  color: AppColors.black,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // Second SliverAppBar
          SliverAppBar(
            toolbarHeight: 60,
            floating: true,
            snap: true,
            pinned: false,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.bgColor,
            scrolledUnderElevation: 0,
            flexibleSpace: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                  left: 2, right: 2, top: 12), // Add padding here
              child: Row(
                children: [
                  _buildStatusPill('Active', '24', true),
                  _buildStatusPill('In Queue', '8', false),
                  _buildStatusPill('Inactive', '12', false),
                ],
              ),
            ),
          ),
          // Product List
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            sliver: SliverToBoxAdapter(
              child: MasonryGridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                itemCount: 10,
                itemBuilder: (context, index) => _buildProductCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, String count, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: isActive ? AppColors.littleGreen : AppColors.containerColor,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.black : AppColors.darkGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.white.withOpacity(0.2)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: isActive ? AppColors.black : AppColors.darkGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: SmoothRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: SmoothClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: SmoothClipRRect(
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
                          '2.5k',
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
                SmoothClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor,
                    ),
                    child: Text(
                      'Boosted',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Product Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '\$299.99',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded,
                            size: 16, color: AppColors.myRedBrown),
                        SizedBox(width: 4),
                        Text(
                          '1.2k',
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
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
}
