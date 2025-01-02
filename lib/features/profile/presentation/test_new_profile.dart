// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }



  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Custom App Bar with Profile Info
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                color: Colors.grey[800],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
                color: Colors.grey[800],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 60),
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  // Stories Section
                  _buildStoriesSection(),
                  const SizedBox(height: 20),
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          // Tabs
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue[700],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[700],
                isScrollable: true,
                tabs: const [
                  Tab(text: "Posts"),
                  Tab(text: "Products"),
                  Tab(text: "Wishlist"),
                  Tab(text: "Reviews"),
                  Tab(text: "About"),
                ],
              ),
            ),
            pinned: true,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsGrid(),
            _buildProductsGrid(),
            _buildWishlist(),
            _buildReviews(),
            _buildAboutSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Profile Picture with Story Ring
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple[400]!, Colors.orange[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/100'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Username and Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '@username',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 4),
              Icon(Icons.verified, color: Colors.blue[400], size: 20),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Top Seller',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bio
          Text(
            'Love finding great deals on electronics and fashion!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Followers', '1.2K'),
              Container(
                height: 24,
                width: 1,
                color: Colors.grey[300],
              ),
              _buildStat('Following', '845'),
              Container(
                height: 24,
                width: 1,
                color: Colors.grey[300],
              ),
              _buildStat('Products', '32'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == 0 ? Colors.grey[300]! : Colors.grey[200]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: index == 0
                        ? Icon(Icons.add, size: 30, color: Colors.grey[600])
                        : ClipOval(
                            child: Image.network(
                              'https://via.placeholder.com/60?text=Story${index}',
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  index == 0 ? 'New' : 'Story $index',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Follow'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.message_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => _buildGridItem(index),
    );
  }

  Widget _buildProductsGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (context, index) => _buildProductItem(),
    );
  }

  Widget _buildProductItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              'https://via.placeholder.com/400x300',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$299.99',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Product description goes here. This is a brief overview of the product.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlist() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5,
      itemBuilder: (context, index) => _buildWishlistItem(),
    );
  }

  Widget _buildWishlistItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            'https://via.placeholder.com/60',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: const Text('Wishlist Item'),
        subtitle: Text(
          '\$199.99',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5,
      itemBuilder: (context, index) => _buildReviewItem(),
    );
  }

  Widget _buildReviewItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reviewer Name',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '2d ago',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Great product and fast shipping! Exactly as described.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Contact Information',
          icon: Icons.contact_mail_outlined,
          children: [
            _buildInfoRow('Email', 'user@example.com'),
            _buildInfoRow('Phone', '+1 234 567 890'),
            _buildInfoRow('Location', 'New York, USA'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Shop Statistics',
          icon: Icons.analytics_outlined,
          children: [
            _buildInfoRow('Total Sales', '1,234'),
            _buildInfoRow('Average Rating', '4.8/5.0'),
            _buildInfoRow('Response Rate', '98%'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Business Hours',
          icon: Icons.access_time_outlined,
          children: [
            _buildInfoRow('Monday - Friday', '9:00 AM - 6:00 PM'),
            _buildInfoRow('Saturday', '10:00 AM - 4:00 PM'),
            _buildInfoRow('Sunday', 'Closed'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Achievements',
          icon: Icons.emoji_events_outlined,
          children: [
            _buildAchievementRow(
              'Top Seller 2024',
              'Maintained 4.8+ rating for 6 months',
              Icons.workspace_premium,
              Colors.amber,
            ),
            _buildAchievementRow(
              'Fast Shipper',
              'Average shipping time under 24 hours',
              Icons.local_shipping,
              Colors.blue,
            ),
            _buildAchievementRow(
              'Trusted Seller',
              'Over 1000 successful transactions',
              Icons.verified,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage('https://via.placeholder.com/150?text=Post${index + 1}'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Post stats
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${Random().nextInt(999)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

