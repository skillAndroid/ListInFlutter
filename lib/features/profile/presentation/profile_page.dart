// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/product_entity.dart';
import 'package:list_in/features/explore/presentation/widgets/regular_product_card.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

// class ProfileScreen extends StatefulWidget {
//  final List<ProductEntity> products;
//   const ProfileScreen({super.key, required String userId, required this.products});

//   @override
//   State<ProfileScreen> createState() => _AnimatedProfileScreenState();
// }

// class _AnimatedProfileScreenState extends State<ProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late ScrollController _scrollController;
//   late TabController _tabController;

//   double _offset = 0;
//   final double _maxAppBarHeight = 180;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController()
//       ..addListener(() {
//         setState(() {
//           _offset = _scrollController.offset;
//         });
//       });
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgColor,
//       body: Stack(
//         children: [
//           NestedScrollView(
//             controller: _scrollController,
//             physics: const BouncingScrollPhysics(),
//             headerSliverBuilder: (context, innerBoxIsScrolled) {
//               return [
//                 _buildSliverAppBar(),
//                 _buildReviewSection(),
//               ];
//             },
//             body: _buildMainContent(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     final double progress = math.min(1.0, _offset / _maxAppBarHeight);
//     final Size screenSize = MediaQuery.of(context).size;
//     final double topPadding = MediaQuery.of(context).padding.top;

//     // Dynamic sizing based on screen width
//     final double maxAvatarSize = math.min(125, screenSize.width * 0.3);
//     final double minAvatarSize = 40;
//     final double avatarSize =
//         math.max(minAvatarSize, maxAvatarSize * (1 - progress));

//     // Calculate positions
//     final double avatarLeftPosition =
//         Tween<double>(begin: 16, end: 56).transform(progress);
//     final double avatarTopPosition =
//         Tween<double>(begin: 50, end: 8).transform(progress);

//     final double maxNameWidth = screenSize.width * 0.45;
//     final double nameScale =
//         Tween<double>(begin: 1.0, end: 0.85).transform(progress);
//     final double nameLeftPosition = Tween<double>(
//             begin: avatarLeftPosition + maxAvatarSize + 20,
//             end: avatarLeftPosition + minAvatarSize + 12)
//         .transform(progress);
//     final double nameTopPosition =
//         Tween<double>(begin: 70, end: 12).transform(progress);

//     final double statsOpacity = math.max(0, 1 - (progress * 2));
//     final double statsOffset = _offset * 0.3;

//     // Adjusted action buttons opacity to appear later
//     final double actionOpacity =
//         math.max(0, (progress - 0.7) * 3.3); // More delayed appearance

//     return SliverAppBar(
//       expandedHeight: _maxAppBarHeight,
//       pinned: true,
//       scrolledUnderElevation: 0,
//       backgroundColor: AppColors.bgColor.withOpacity(math.max(0, progress)),
//       elevation: progress > 0.5 ? 1 : 0,
//       automaticallyImplyLeading: false,
//       actions: [
//         Opacity(
//           opacity: actionOpacity,
//           child: Row(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.only(right: 8),
//                 child: TextButton(
//                   onPressed: () {
//                     setState(() {});
//                   },
//                   style: TextButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 6,
//                     ),
//                     shape: SmoothRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     minimumSize: const Size(80, 32),
//                   ),
//                   child: Text(
//                     'Following',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(
//                   CupertinoIcons.ellipsis,
//                   color: Colors.black,
//                   size: 22,
//                 ),
//                 onPressed: () {
//                   showCupertinoModalPopup(
//                     context: context,
//                     builder: (context) => CupertinoActionSheet(
//                       actions: [
//                         CupertinoActionSheetAction(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Share Profile'),
//                         ),
//                         CupertinoActionSheetAction(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Report'),
//                         ),
//                         CupertinoActionSheetAction(
//                           isDestructiveAction: true,
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Block User'),
//                         ),
//                       ],
//                       cancelButton: CupertinoActionSheetAction(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Cancel'),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(width: 8),
//             ],
//           ),
//         ),
//       ],
//       flexibleSpace: Stack(
//         children: [
//           // Back button with original style
//           Positioned(
//             top: topPadding + 4,
//             left: 8,
//             child: IconButton(
//               icon: const Icon(Ionicons.arrow_back, color: Colors.black),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),

//           // Avatar
//           Positioned(
//             left: avatarLeftPosition,
//             top: topPadding + avatarTopPosition,
//             child: Container(
//               width: avatarSize,
//               height: avatarSize,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipOval(
//                 child: Image.asset(AppImages.wAuto, fit: BoxFit.cover),
//               ),
//             ),
//           ),

//           // Username
//           Positioned(
//             left: nameLeftPosition,
//             top: topPadding + nameTopPosition,
//             child: Transform.scale(
//               scale: nameScale,
//               child: Container(
//                 constraints: BoxConstraints(maxWidth: maxNameWidth),
//                 child: const Text(
//                   'Anna Dii',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//           ),

//           // Stats
//           Positioned(
//             left: nameLeftPosition,
//             top: topPadding + 110 - statsOffset,
//             child: Opacity(
//               opacity: statsOpacity,
//               child: Transform.translate(
//                 offset: Offset(0, -statsOffset),
//                 child: Container(
//                   constraints: BoxConstraints(maxWidth: maxNameWidth),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildStatItem('12', 'Following'),
//                       Container(
//                         height: 20,
//                         width: 1,
//                         margin: const EdgeInsets.symmetric(horizontal: 16),
//                         color: Colors.black,
//                       ),
//                       _buildStatItem('19', 'Followers'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// //
//   void _showIOSMenu(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) => CupertinoActionSheet(
//         title: const Text(
//           'Profile Settings',
//           style: TextStyle(fontFamily: "Syne"),
//         ),
//         message: const Text(
//           'Manage your profile',
//           style: TextStyle(fontFamily: "Syne"),
//         ),
//         actions: [
//           // Profile & Account Management
//           _buildActionSheetItem(
//             icon: CupertinoIcons.person_crop_circle_fill_badge_checkmark,
//             title: 'Edit Profile',
//             onPressed: () {
//               Navigator.pop(context);
//               // Handle edit profile
//             },
//           ),
//           _buildActionSheetItem(
//             icon: CupertinoIcons.camera_fill,
//             title: 'Change Profile Photo',
//             onPressed: () {
//               Navigator.pop(context);
//               // Handle photo change
//             },
//           ),
//           _buildActionSheetItem(
//             icon: CupertinoIcons.time,
//             title: 'Working Hours',
//             subtitle: '9:00 - 17:00',
//             onPressed: () {
//               Navigator.pop(context);
//               // Handle working hours
//             },
//           ),
//           _buildActionSheetItem(
//             icon: CupertinoIcons.moon_fill,
//             title: 'Theme',
//             subtitle: 'Light',
//             onPressed: () {
//               Navigator.pop(context);
//               // Handle theme change
//             },
//           ),
//           // Logout (Destructive Action)
//           CupertinoActionSheetAction(
//             isDestructiveAction: true,
//             onPressed: () {
//               Navigator.pop(context);
//               // Handle logout
//             },
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(CupertinoIcons.square_arrow_right),
//                 SizedBox(width: 10),
//                 Text('Logout',
//                     style: TextStyle(fontSize: 18, fontFamily: "Syne")),
//               ],
//             ),
//           ),
//         ],
//         cancelButton: CupertinoActionSheetAction(
//           onPressed: () => Navigator.pop(context),
//           child: Text(
//             'Cancel',
//             style: TextStyle(
//                 color: AppColors.black, fontSize: 18, fontFamily: "Syne"),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionSheetItem({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     required VoidCallback onPressed,
//   }) {
//     return CupertinoActionSheetAction(
//       onPressed: onPressed,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Icon with container
//             SmoothClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 color: AppColors.primary.withOpacity(0.1),
//                 child: Icon(
//                   icon,
//                   color: AppColors.primary,
//                   size: 20,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),

//             // Title
//             Expanded(
//               child: Text(
//                 title,
//                 textAlign: TextAlign.start,
//                 style: TextStyle(
//                   fontFamily: "Syne",
//                   color: AppColors.black,
//                   fontSize: 17,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),

//             // Subtitle if provided
//             if (subtitle != null) ...[
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: AppColors.grey,
//                   fontSize: 15,
//                   fontFamily: "Syne",
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(width: 4),
//             ],

//             // Arrow icon
//             Icon(
//               Ionicons.arrow_forward,
//               color: AppColors.grey,
//               size: 18,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String count, String label) {
//     return Column(
//       children: [
//         Text(
//           count,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w900,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: Colors.white.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildReviewSection() {
//     return SizedBox(
//       height: 115,
//       width: double.infinity,
//       child: Card(
//         color: AppColors.white,
//         elevation: 10,
//         shadowColor: AppColors.black.withOpacity(0.2),
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//         shape: SmoothRectangleBorder(
//           smoothness: 1,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Padding(
//           padding:
//               const EdgeInsets.only(right: 20, left: 8, top: 16, bottom: 16),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: 10,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       '4.8',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: List.generate(
//                         5,
//                         (index) => Icon(
//                           index < 4 ? Icons.star : Icons.star_half,
//                           color: Colors.amber,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4,
//                     ),
//                     Text(
//                       '(128 reviews)',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: AppColors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 height: 60,
//                 width: 1,
//                 color: Colors.grey.withOpacity(0.2),
//               ),
//               Expanded(
//                 flex: 11,
//                 child: _buildRecentReviewers(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentReviewers() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Recent Reviews',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 40,
//             child: Stack(
//               children: [
//                 for (var i = 0; i < 3; i++)
//                   Positioned(
//                     left: i * 25.0,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: AppColors.white,
//                           width: 2,
//                         ),
//                       ),
//                       child: CircleAvatar(
//                         radius: 16,
//                         backgroundImage: NetworkImage(
//                           'https://picsum.photos/200?random=$i',
//                         ),
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   left: 85,
//                   top: 8,
//                   child: Text(
//                     '+25 more',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Column(
//       children: [
//         const SizedBox(height: 16),
//         ...List.generate(
//           8,
//           (index) => _buildListItem(
//             icon: _getIcon(index),
//             title: _getTitle(index),
//             trailing: _getTrailing(index),
//             onTap: () {
//               if (index == 0) {
//                 context.goNamed(RoutesByName.myPosts);
//               }
//             },
//           ),
//         ),
//         SizedBox(height: screenHeight / 9),
//       ],
//     );
//   }

//   Widget _buildListItem({
//     required String icon,
//     required String title,
//     String? trailing,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       leading: SmoothClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//           ),
//           child: SizedBox(
//             width: 28,
//             height: 28,
//             child: Image.asset(
//               icon,
//               color: AppColors.primary,
//             ),
//           ),
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       trailing: trailing != null
//           ? Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   trailing,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.grey,
//                 ),
//               ],
//             )
//           : const Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Colors.grey,
//             ),
//       onTap: onTap,
//     );
//   }

//   String _getIcon(int index) {
//     final icons = [
//       AppIcons.addsIc,
//       AppIcons.favorite,
//       AppIcons.chatIc,
//       AppIcons.cardIc,
//       AppIcons.languageIc,
//       AppIcons.supportIc,
//       AppIcons.personIc,
//       AppIcons.logoutIc,
//     ];
//     return icons[index];
//   }

//   String _getTitle(int index) {
//     final titles = [
//       'My Ads',
//       'My Favorites',
//       'Chats',
//       'My Balance',
//       'Language',
//       'Help Center',
//       'About Us',
//       'Log Out',
//     ];
//     return titles[index];
//   }

//   String? _getTrailing(int index) {
//     switch (index) {
//       case 0:
//         return '5 active';
//       case 2:
//         return '3 unread';
//       case 3:
//         return '\$33';
//       case 4:
//         return 'English';
//       default:
//         return null;
//     }
//   }

//   Widget _buildInfinitePostsGrid() {
//     return SliverGrid(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//       ),
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           // Check if we need to load more data
//           if (index >= widget.products.length - 5) {
//             // Implement your load more logic here
//             // You can call a method to fetch more data
//             // loadMorePosts();
//           }

//           return GestureDetector(
//             onTap: () {},
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.asset(
//                   AppImages.wPlats,
//                   fit: BoxFit.cover,
//                 ),
//                 if (index % 3 == 0)
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.7),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Icon(
//                         Icons.play_arrow,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//         childCount: widget.products.length,
//       ),
//     );
//   }

//   Widget _buildInfiniteProductsGrid() {
//     return SliverGrid(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//         childAspectRatio: 0.65,
//       ),
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           // Check if we need to load more data
//           if (index >= widget.products.length - 4) {
//             // Implement your load more logic here
//             // loadMoreProducts();
//           }

//           return GestureDetector(
//             onTap: () {},
//             child: RegularProductCard(product: widget.products[index]),
//           );
//         },
//         childCount: widget.products.length,
//       ),
//     );
//   }

//   Widget _buildInfiniteVideosGrid() {
//     return SliverGrid(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//         childAspectRatio: 0.8,
//       ),
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           // Check if we need to load more data
//           if (index >= widget.products.length - 4) {
//             // Implement your load more logic here
//             // loadMoreVideos();
//           }

//           return GestureDetector(
//             onTap: () {},
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.asset(
//                   AppImages.wPlats,
//                   fit: BoxFit.cover,
//                 ),
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: const Text(
//                       '3:45',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.7),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.play_arrow,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 8,
//                   right: 8,
//                   bottom: 8,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Video ${index + 1}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${math.Random().nextInt(1000)}K views',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.8),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         childCount: widget.products.length,
//       ),
//     );
//   }
// }
// //
