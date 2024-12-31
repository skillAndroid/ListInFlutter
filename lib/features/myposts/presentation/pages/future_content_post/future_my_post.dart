import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:list_in/config/theme/app_colors.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: innerBoxIsScrolled ? 2 : 0,
            backgroundColor: AppColors.bgColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'My Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.filter_list_rounded),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(110),
              child: Column(
                children: [
                  _buildContentTypeTabs(),
                  _buildQuickStats(),
                ],
              ),
            ),
          ),
        ],
        body: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateContentSheet,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildContentTypeTabs() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTabButton('All Content', 0, '48'),
          _buildTabButton('Products', 1, '24'),
          _buildTabButton('Posts', 2, '16'),
          _buildTabButton('Videos', 3, '8'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, String count) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.containerColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.white.withOpacity(0.2)
                    : AppColors.containerColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.darkGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem('Views Today', '2.5K', Icons.visibility_rounded),
          _buildStatItem('Total Likes', '12.4K', Icons.favorite_rounded),
          _buildStatItem('Active Posts', '48', Icons.article_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.containerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return MasonryGridView.count(
      padding: EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: 20,
      itemBuilder: (context, index) {
        // Alternate between different content types
        if (_selectedTabIndex == 0) {
          if (index % 3 == 0) return _buildProductCard(index);
          if (index % 3 == 1) return _buildVideoCard(index);
          return _buildPostCard(index);
        }
        
        // Show specific content type based on selected tab
        switch (_selectedTabIndex) {
          case 1:
            return _buildProductCard(index);
          case 2:
            return _buildPostCard(index);
          case 3:
            return _buildVideoCard(index);
          default:
            return _buildPostCard(index);
        }
      },
    );
  }

  Widget _buildProductCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: "https://picsum.photos/500/500?random=$index",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'For Sale',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _buildStatusBadge(
                      icon: Icons.visibility_rounded,
                      label: '2.5k',
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '\$${(index + 1) * 99}.99',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'In Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.more_vert_rounded,
                          onPressed: () {},
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

Widget _buildPostCard(int index) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: CachedNetworkImageProvider(
                  "https://picsum.photos/100/100?random=$index",
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '2 hours ago',
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              _buildActionButton(
                icon: Icons.more_vert_rounded,
                onPressed: () {},
              ),
            ],
          ),
        ),
        if (index % 2 == 0) // Add image for some posts
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: "https://picsum.photos/500/300?random=$index",
              fit: BoxFit.cover,
            ),
          ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post ${index + 1} - Example content for this social media post. This could be a longer text with multiple lines.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusBadge(
                    icon: Icons.favorite_rounded,
                    label: '${Random().nextInt(999)}',
                  ),
                  SizedBox(width: 8),
                  _buildStatusBadge(
                    icon: Icons.comment_rounded,
                    label: '${Random().nextInt(99)}',
                  ),
                  SizedBox(width: 8),
                  _buildStatusBadge(
                    icon: Icons.visibility_rounded,
                    label: '${Random().nextInt(9999)}',
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

Widget _buildVideoCard(int index) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: "https://picsum.photos/500/800?random=$index",
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3:45',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video ${index + 1} Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusBadge(
                    icon: Icons.visibility_rounded,
                    label: '${Random().nextInt(9999)}',
                  ),
                  SizedBox(width: 8),
                  _buildStatusBadge(
                    icon: Icons.favorite_rounded,
                    label: '${Random().nextInt(999)}',
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    onPressed: () {},
                  ),
                  SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.more_vert_rounded,
                    onPressed: () {},
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

Widget _buildStatusBadge({required IconData icon, required String label}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.containerColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.darkGray,
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.darkGray,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButton({
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 18,
        color: AppColors.darkGray,
      ),
    ),
  );
}

void _showCreateContentSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Create New Content',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                children: [
                  _buildCreateOption(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Product',
                    subtitle: 'List a new product for sale',
                    onTap: () {},
                  ),
                  _buildCreateOption(
                    icon: Icons.article_rounded,
                    title: 'Post',
                    subtitle: 'Share your thoughts or photos',
                    onTap: () {},
                  ),
                  _buildCreateOption(
                    icon: Icons.videocam_rounded,
                    title: 'Video',
                    subtitle: 'Upload a new video',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCreateOption({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.containerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.darkGray,
          ),
        ],
      ),
    ),
  );
}
}