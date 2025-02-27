// // ignore_for_file: deprecated_member_use

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:list_in/config/assets/app_images.dart';
// import 'package:list_in/config/theme/app_colors.dart';
// import 'package:list_in/features/explore/domain/enties/product_entity.dart';
// import 'package:list_in/features/explore/presentation/widgets/product_card/bb/regular_product_card.dart';
// import 'package:list_in/features/explore/presentation/widgets/progress.dart';
// import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_bloc.dart';
// import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
// import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_bloc.dart';
// import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_event.dart';
// import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_state.dart';
// import 'package:list_in/global/global_bloc.dart';
// import 'package:list_in/global/global_event.dart';
// import 'package:list_in/global/global_state.dart';
// import 'package:list_in/global/global_status.dart';
// import 'package:smooth_corner_updated/smooth_corner.dart';

// class VisitorProfileScreen extends StatefulWidget {
//   final String userId;
//   final List<ProductEntity> products; // ID of the profile being viewed
//   const VisitorProfileScreen(
//       {super.key, required this.userId, required this.products});

//   @override
//   State<VisitorProfileScreen> createState() => _VisitorProfileScreenState();
// }

// class _VisitorProfileScreenState extends State<VisitorProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late ScrollController _scrollController;
//   late TabController _tabController;
//   bool isFollowing = false;

//   String selectedProductFilter = 'active';

//   @override
//   void initState() {
//     super.initState();
//     context.read<AnotherUserProfileBloc>().add(ClearUserData());

//     _scrollController = ScrollController();
//     _tabController = TabController(length: 2, vsync: this);

//     context
//         .read<AnotherUserProfileBloc>()
//         .add(GetAnotherUserData(widget.userId));
//     context.read<AnotherUserProfileBloc>().add(
//           FetchPublications(
//             userId: widget.userId,
//             isInitialFetch: true,
//           ),
//         );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _tabController.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Ensure the status bar color is set when the screen is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       SystemChrome.setSystemUIOverlayStyle(
//         const SystemUiOverlayStyle(
//           statusBarColor: Colors.white,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       );
//     });
//     return BlocConsumer<AnotherUserProfileBloc, AnotherUserProfileState>(
//       listener: (context, state) {
//         if (state.status == AnotherUserProfileStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state.status == AnotherUserProfileStatus.loading &&
//             state.profile == null) {
//           return const Scaffold(body: Progress());
//         }

//         final userData = state.profile;
//         // Add null check validation to prevent null UI
//         if (userData == null) {
//           return const Scaffold(
//               body: Center(child: Text('No user data available')));
//         }

//         return SafeArea(
//           top: true,
//           bottom: false,
//           child: Scaffold(
//             backgroundColor: AppColors.bgColor,
//             body: Padding(
//               padding: EdgeInsets.only(top: 0),
//               child: NestedScrollView(
//                 controller: _scrollController,
//                 physics: const BouncingScrollPhysics(
//                   parent: AlwaysScrollableScrollPhysics(),
//                 ),
//                 headerSliverBuilder: (context, innerBoxIsScrolled) {
//                   return [
//                     SliverAppBar(
//                       floating: true,
//                       pinned: false,
//                       snap: false,
//                       toolbarHeight: 56,
//                       automaticallyImplyLeading: false,
//                       elevation: 0,
//                       backgroundColor: Colors.white,
//                       surfaceTintColor: Colors.transparent,
//                       leadingWidth: 80,
//                       leading: GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         onTap: () => context.pop(),
//                         child: Container(
//                           padding: const EdgeInsets.only(left: 16),
//                           alignment: Alignment.centerLeft,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.arrow_back,
//                                 size: 24,
//                                 color: Colors.black87,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       actions: [
//                         IconButton(
//                           icon: Icon(
//                             Icons.info_outline_rounded,
//                             color: Colors.black87,
//                             size: 24,
//                           ),
//                           onPressed: () {},
//                           style: IconButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size(48, 48),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             Icons.more_vert,
//                             color: Colors.black87,
//                             size: 24,
//                           ),
//                           onPressed: () {},
//                           style: IconButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size(48, 48),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                       ],
//                       bottom: PreferredSize(
//                         preferredSize: Size.fromHeight(1),
//                         child: Container(
//                           height: 1,
//                           color: AppColors.white.withOpacity(0.2),
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0, vertical: 12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // First row: Image, Name and Role
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 // Profile image
//                                 SizedBox(
//                                   width: 75,
//                                   height: 75,
//                                   child: Stack(
//                                     children: [
//                                       SmoothClipRRect(
//                                         borderRadius: BorderRadius.circular(36),
//                                         child: userData.profileImagePath != null
//                                             ? CachedNetworkImage(
//                                                 width: double.infinity,
//                                                 height: double.infinity,
//                                                 imageUrl:
//                                                     'https://${userData.profileImagePath!}',
//                                                 fit: BoxFit.cover,
//                                                 placeholder: (context, url) =>
//                                                     const Center(
//                                                   child:
//                                                       CircularProgressIndicator(
//                                                     color: Colors.lightGreen,
//                                                     strokeWidth: 2,
//                                                   ),
//                                                 ),
//                                                 errorWidget:
//                                                     (context, url, error) =>
//                                                         Image.asset(
//                                                             AppImages.appLogo),
//                                               )
//                                             : Image.asset(AppImages.appLogo),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 36),
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 4.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       _buildStatItem(
//                                           '${userData.rating}', 'Rating'),
//                                       const SizedBox(width: 32),
//                                       BlocBuilder<GlobalBloc, GlobalState>(
//                                         builder: (context, state) {
//                                           final followersCount =
//                                               state.getFollowersCount(
//                                                   userData.id ?? '');
//                                           final followingCount =
//                                               state.getFollowingCount(
//                                                   userData.id ?? '');

//                                           return Row(
//                                             children: [
//                                               _buildStatItem('$followersCount',
//                                                   'Followers'),
//                                               const SizedBox(width: 32),
//                                               _buildStatItem('$followingCount',
//                                                   'Following'),
//                                             ],
//                                           );
//                                         },
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 SizedBox(
//                                   width: 2,
//                                 ),
//                                 Text(
//                                   userData.nickName ?? 'User',
//                                   style: const TextStyle(
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(2),
//                                   ),
//                                   width: 2,
//                                   height: 14,
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Text(
//                                   userData.role ?? 'User Type',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 2),
//                               child: Text(
//                                 userData.biography ?? "No bio yet!",
//                                 maxLines: 1,
//                                 style: TextStyle(
//                                   fontSize: 12.5,
//                                   overflow: TextOverflow.ellipsis,
//                                   color: Colors.grey[800],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const SizedBox(width: 12),
//                             BlocBuilder<GlobalBloc, GlobalState>(
//                               builder: (context, state) {
//                                 final isFollowed =
//                                     state.isUserFollowed(widget.userId);
//                                 final followStatus =
//                                     state.getFollowStatus(widget.userId);
//                                 final isLoading =
//                                     followStatus == FollowStatus.inProgress;

//                                 return InkWell(
//                                   onTap: isLoading
//                                       ? null
//                                       : () {
//                                           context.read<GlobalBloc>().add(
//                                                 UpdateFollowStatusEvent(
//                                                   userId: widget.userId,
//                                                   isFollowed: isFollowed,
//                                                   context: context,
//                                                 ),
//                                               );
//                                         },
//                                   child: SmoothClipRRect(
//                                     smoothness: 0.9,
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       constraints: const BoxConstraints(
//                                         minWidth: 110,
//                                         minHeight: 50,
//                                       ),
//                                       decoration: BoxDecoration(
//                                           color: AppColors.primary),
//                                       child: isLoading
//                                           ? const SizedBox(
//                                               width: 20,
//                                               height: 20,
//                                               child: CircularProgressIndicator(
//                                                 color: Colors.white,
//                                                 strokeWidth: 2,
//                                               ),
//                                             )
//                                           : Row(
//                                               children: [
//                                                 Icon(
//                                                     isFollowed
//                                                         ? Icons.person_remove
//                                                         : Icons.person_add,
//                                                     color: Colors.white,
//                                                     size: 20),
//                                                 const SizedBox(width: 6),
//                                                 Text(
//                                                   isFollowed == true
//                                                       ? 'Unfollow'
//                                                       : 'Follow',
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 15,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             const SizedBox(width: 12),
//                             InkWell(
//                               onTap: () {},
//                               child: SmoothClipRRect(
//                                 side: BorderSide(
//                                   width: 1.2,
//                                   color: AppColors.containerColor,
//                                 ),
//                                 smoothness: 0.9,
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Container(
//                                   alignment: Alignment.center,
//                                   constraints: const BoxConstraints(
//                                     minWidth: 110,
//                                     minHeight: 50,
//                                   ),
//                                   decoration:
//                                       BoxDecoration(color: AppColors.white),
//                                   child: Row(
//                                     children: [
//                                       Icon(EvaIcons.phoneCall,
//                                           color: Colors.black, size: 20),
//                                       const SizedBox(width: 6),
//                                       const Text(
//                                         'Call',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             InkWell(
//                               onTap: () {},
//                               child: SmoothClipRRect(
//                                 side: BorderSide(
//                                   width: 1.2,
//                                   color: AppColors.containerColor,
//                                 ),
//                                 smoothness: 0.9,
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Container(
//                                   alignment: Alignment.center,
//                                   constraints: const BoxConstraints(
//                                     minWidth: 110,
//                                     minHeight: 50,
//                                   ),
//                                   decoration:
//                                       BoxDecoration(color: AppColors.bgColor),
//                                   child: Row(
//                                     children: [
//                                       Icon(EvaIcons.messageSquare,
//                                           color: Colors.black, size: 20),
//                                       const SizedBox(width: 6),
//                                       const Text(
//                                         'Messege',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: SizedBox(
//                         height: 12,
//                       ),
//                     ),
//                     SliverPersistentHeader(
//                       delegate: _SliverTabBarDelegate(
//                         TabBar(
//                           controller: _tabController,
//                           tabs: [
//                             Tab(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.inventory_rounded,
//                                     size: 22,
//                                   ),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                   Text(
//                                     'Publications',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Tab(
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.reviews_outlined,
//                                     size: 22,
//                                   ),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                   Text(
//                                     'Reviews',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         backgroundColor: AppColors.bgColor,
//                       ),
//                       pinned: true,
//                     ),
//                   ];
//                 },
//                 body: Padding(
//                   padding: const EdgeInsets.only(top: 0, right: 4, left: 4),
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       // Products Tab
//                       NotificationListener<ScrollNotification>(
//                         onNotification: (ScrollNotification scrollInfo) {
//                           // Check if we're near the bottom
//                           if (scrollInfo is ScrollEndNotification) {
//                             if (scrollInfo.metrics.pixels >=
//                                 scrollInfo.metrics.maxScrollExtent * 0.7) {
//                               final publicationsState =
//                                   context.read<UserPublicationsBloc>().state;
//                               if (!publicationsState.hasReachedEnd &&
//                                   !publicationsState.isLoading) {
//                                 context
//                                     .read<UserPublicationsBloc>()
//                                     .add(LoadMoreUserPublications());
//                               }
//                             }
//                           }
//                           return true;
//                         },
//                         child: CustomScrollView(
//                           slivers: [
//                             _buildProductsGrid(),
//                           ],
//                         ),
//                       ),
//                       _buildEmptyTab(
//                         icon: CupertinoIcons.star,
//                         text: "Empty List",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatItem(String value, String label) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//             height: 1.2,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey[600],
//             height: 1.1,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProductsGrid() {
//     return BlocBuilder<AnotherUserProfileBloc, AnotherUserProfileState>(
//       builder: (context, state) {
//         if (state.status == AnotherUserProfileStatus.loading &&
//             state.publications.isEmpty) {
//           return SliverToBoxAdapter(
//             child: Progress(),
//           );
//         }

//         if (state.status == AnotherUserProfileStatus.failure) {
//           return SliverToBoxAdapter(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       context.read<AnotherUserProfileBloc>().add(
//                             FetchPublications(
//                               userId: state.profile?.id ?? '',
//                               isInitialFetch: true,
//                             ),
//                           );
//                     },
//                     child: Text("Retry"),
//                   ),
//                   if (state.errorMessage != null) Text(state.errorMessage!),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (state.publications.isEmpty) {
//           return SliverToBoxAdapter(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 32),
//                   Icon(Icons.inventory, size: 72, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No publications available',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return SliverPadding(
//           padding: EdgeInsets.only(bottom: 16, left: 8, right: 8),
//           sliver: SliverGrid(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 // Check if we need to load more
//                 if (index >= state.publications.length - 4 &&
//                     !state.isLoadingMore &&
//                     !state.hasReachedEnd) {
//                   context.read<AnotherUserProfileBloc>().add(
//                         FetchPublications(
//                           userId: state.profile?.id ?? '',
//                         ),
//                       );
//                 }

//                 if (index == state.publications.length) {
//                   if (state.isLoadingMore) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   return null;
//                 }

//                 final publication = state.publications[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(0),
//                   child: ProductCardContainer(
//                     product: publication,
//                   ),
//                 );
//               },
//               childCount:
//                   state.publications.length + (state.isLoadingMore ? 1 : 0),
//             ),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 0,
//               mainAxisSpacing: 0,
//               childAspectRatio: 0.59,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyTab({required IconData icon, required String text}) {
//     return CustomScrollView(
//       slivers: [
//         SliverToBoxAdapter(
//           child: Column(
//             children: [
//               const SizedBox(height: 56),
//               Icon(icon, size: 76, color: AppColors.grey),
//               const SizedBox(height: 16),
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.grey,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

// class CustomLineIndicator extends Decoration {
//   final double lineHeight;
//   final double lineWidth;
//   final Color color;

//   const CustomLineIndicator({
//     this.lineHeight = 2.0,
//     this.lineWidth = 20.0,
//     this.color = Colors.black,
//   });

//   @override
//   BoxPainter createBoxPainter([VoidCallback? onChanged]) {
//     return _CustomLinePainter(
//       lineHeight: lineHeight,
//       lineWidth: lineWidth,
//       color: color,
//       onChange: onChanged,
//     );
//   }
// }

// class _CustomLinePainter extends BoxPainter {
//   final double lineHeight;
//   final double lineWidth;
//   final Color color;

//   _CustomLinePainter({
//     required this.lineHeight,
//     required this.lineWidth,
//     required this.color,
//     VoidCallback? onChange,
//   }) : super(onChange);

//   @override
//   void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
//     assert(configuration.size != null);
//     final Paint paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final Offset center = Offset(
//       offset.dx + configuration.size!.width / 2,
//       offset.dy + 2,
//     );

//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//           Rect.fromCenter(
//             center: center,
//             width: lineWidth,
//             height: lineHeight,
//           ),
//           Radius.circular(1)),
//       paint,
//     );
//   }
// }

// class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   final Color backgroundColor;

//   _SliverTabBarDelegate(this.tabBar, {this.backgroundColor = Colors.white});

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [
//           Container(
//             height: 1, // Height of the bottom grey line
//             color: AppColors.containerColor, // Light grey color for the line
//           ),
//           Expanded(
//             child: Transform.translate(
//               offset: Offset(0, -1),
//               child: TabBar(
//                 padding: EdgeInsets.zero,
//                 controller: tabBar.controller,
//                 tabs: tabBar.tabs,
//                 labelColor: Colors.black,
//                 unselectedLabelColor: AppColors.grey,
//                 indicator: CustomLineIndicator(
//                   lineHeight: 3.5,
//                   lineWidth: 20,
//                   color: Colors.black,
//                 ),
//                 labelPadding: const EdgeInsets.symmetric(vertical: 16),
//                 dividerColor: Colors.transparent,
//                 overlayColor: MaterialStateProperty.all(Colors.transparent),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 61;

//   @override
//   double get minExtent => 61;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return true;
//   }
// }
