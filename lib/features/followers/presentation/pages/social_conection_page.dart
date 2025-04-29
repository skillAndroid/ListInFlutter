// social_connections_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';
import 'package:list_in/features/followers/presentation/bloc/social_user_bloc.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';

//
class SocialConnectionsPage extends StatefulWidget {
  final String userId;
  final String username;
  final String initialTab; // 'followers' or 'followings'

  const SocialConnectionsPage({
    super.key,
    required this.userId,
    required this.username,
    this.initialTab = 'followers',
  });

  @override
  State<SocialConnectionsPage> createState() => _SocialConnectionsPageState();
}

class _SocialConnectionsPageState extends State<SocialConnectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Paging controllers for infinite pagination
  final PagingController<int, UserProfile> _followersController =
      PagingController(firstPageKey: 0);
  final PagingController<int, UserProfile> _followingsController =
      PagingController(firstPageKey: 0);

  bool _followersInitialized = false;
  bool _followingsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Set up tab controller
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'followers' ? 0 : 1,
    );

    // Set up paging controllers
    _followersController.addPageRequestListener(_fetchFollowersPage);
    _followingsController.addPageRequestListener(_fetchFollowingsPage);

    // Listen to global state changes to update UI when follow status changes
    _setupFollowStatusListener();

    // Set up tab change listener
    _tabController.addListener(_handleTabChange);

    // Initial load based on starting tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index == 0) {
        _followersInitialized = true;
        _followersController.refresh();
      } else {
        _followingsInitialized = true;
        _followingsController.refresh();
      }
    });
  }

  void _setupFollowStatusListener() {
    // Listen to global bloc changes to update UI when follow status changes
    context.read<GlobalBloc>().stream.listen((globalState) {
      // Update followers controller items when follow status changes
      final followerItems = _followersController.itemList;
      if (followerItems != null && followerItems.isNotEmpty) {
        final updatedItems = followerItems.map((user) {
          final isFollowed = globalState.isUserFollowed(user.userId);
          if (user.isFollowing != isFollowed) {
            return UserProfile(
              userId: user.userId,
              nickName: user.nickName,
              profileImagePath: user.profileImagePath,
              isFollowing: isFollowed,
              followers: user.followers + (isFollowed ? 1 : -1),
              following: user.following,
            );
          }
          return user;
        }).toList();

        _followersController.itemList = updatedItems;
      }

      // Do the same for followings
      final followingItems = _followingsController.itemList;
      if (followingItems != null && followingItems.isNotEmpty) {
        final updatedItems = followingItems.map((user) {
          final isFollowed = globalState.isUserFollowed(user.userId);
          if (user.isFollowing != isFollowed) {
            return UserProfile(
              userId: user.userId,
              nickName: user.nickName,
              profileImagePath: user.profileImagePath,
              isFollowing: isFollowed,
              followers: user.followers,
              following: user.following,
            );
          }
          return user;
        }).toList();

        _followingsController.itemList = updatedItems;
      }
    });
  }

  void _fetchFollowersPage(int pageKey) {
    context.read<SocialUserBloc>().add(
          FetchFollowers(
            userId: widget.userId,
            page: pageKey,
            onSuccess: (users, isLastPage) {
              final nextPageKey = isLastPage ? null : pageKey + 1;

              try {
                if (isLastPage) {
                  _followersController.appendLastPage(users);
                } else {
                  _followersController.appendPage(users, nextPageKey);
                }
              } catch (error) {
                _followersController.error = error;
              }
            },
            onError: (error) {
              print('❌ Error fetching followers: $error');
              _followersController.error = error;
            },
          ),
        );
  }

  void _fetchFollowingsPage(int pageKey) {
    print('🔄 Fetching followings page: $pageKey');
    context.read<SocialUserBloc>().add(
          FetchFollowings(
            userId: widget.userId,
            page: pageKey,
            onSuccess: (users, isLastPage) {
              print(
                  '✅ Loaded ${users.length} followings. Last page: $isLastPage');
              final nextPageKey = isLastPage ? null : pageKey + 1;

              try {
                if (isLastPage) {
                  _followingsController.appendLastPage(users);
                } else {
                  _followingsController.appendPage(users, nextPageKey);
                }
              } catch (error) {
                print('❌ Error appending to followings controller: $error');
                _followingsController.error = error;
              }
            },
            onError: (error) {
              print('❌ Error fetching followings: $error');
              _followingsController.error = error;
            },
          ),
        );
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    print('📑 Tab changed to: ${_tabController.index}');

    // First tab (Followers)
    if (_tabController.index == 0 && !_followersInitialized) {
      print('🔄 Initializing followers tab');
      _followersInitialized = true;
      _followersController.refresh();
    }
    // Second tab (Followings)
    else if (_tabController.index == 1 && !_followingsInitialized) {
      print('🔄 Initializing followings tab');
      _followingsInitialized = true;
      _followingsController.refresh();
    }
  }

  @override
  void dispose() {
    _followersController.dispose();
    _followingsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0, // No space for title
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                // Back button aligned with tabs
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () => Navigator.pop(context),
                ),
                // Tabs in center
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: AppColors.transparent,
                    labelColor: Colors.black,
                    indicatorPadding: EdgeInsets.zero,
                    labelStyle: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    tabAlignment: TabAlignment.center,
                    indicatorWeight: 0.1,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    unselectedLabelColor: Colors.black,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context)!.followers,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.following,
                      ),
                    ],
                  ),
                ),
                // Empty space to balance the back button
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 16),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Followers Tab
            _buildFollowersTab(context),
            // Followings Tab
            _buildFollowingsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowersTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _followersController.refresh();
        return Future.value();
      },
      child: PagedListView<int, UserProfile>(
        pagingController: _followersController,
        builderDelegate: PagedChildBuilderDelegate<UserProfile>(
          itemBuilder: (context, user, index) => UserListTile(
            user: user,
            onFollowTap: (isCurrentlyFollowing) {
              context.read<SocialUserBloc>().add(
                    FollowUser(
                      userId: user.userId,
                      isFollowing: isCurrentlyFollowing,
                      context: context,
                    ),
                  );
            },
          ),
          firstPageProgressIndicatorBuilder: (_) => const Progress(),
          newPageProgressIndicatorBuilder: (_) => const Progress(),
          noItemsFoundIndicatorBuilder: (_) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.no_items_found,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          noMoreItemsIndicatorBuilder: (_) => const SizedBox(height: 20),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load followers',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _followersController.refresh(),
                  child: Text(
                    AppLocalizations.of(context)!.retry,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _followingsController.refresh();
        return Future.value();
      },
      child: PagedListView<int, UserProfile>(
        pagingController: _followingsController,
        builderDelegate: PagedChildBuilderDelegate<UserProfile>(
          itemBuilder: (context, user, index) => UserListTile(
            user: user,
            onFollowTap: (isCurrentlyFollowing) {
              context.read<SocialUserBloc>().add(
                    FollowUser(
                      userId: user.userId,
                      isFollowing: isCurrentlyFollowing,
                      context: context,
                    ),
                  );
            },
          ),
          firstPageProgressIndicatorBuilder: (_) => const Progress(),
          newPageProgressIndicatorBuilder: (_) => const Progress(),
          noItemsFoundIndicatorBuilder: (_) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.no_items_found,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          noMoreItemsIndicatorBuilder: (_) => const SizedBox(height: 20),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load followings',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _followingsController.refresh(),
                  child: Text(
                    AppLocalizations.of(context)!.retry,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserListTile extends StatelessWidget {
  final UserProfile user;
  final Function(bool isCurrentlyFollowing)? onFollowTap;
  final bool showFollowButton;

  const UserListTile({
    super.key,
    required this.user,
    this.onFollowTap,
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Material(
        color: const Color.fromARGB(0, 46, 42, 42),
        child: InkWell(
          borderRadius: BorderRadius.circular(0),
          onTap: () {
            context.push(Routes.anotherUserProfile, extra: {
              'userId': user.userId,
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Hero(
                  tag: 'profile-${user.userId}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CachedNetworkImage(
                        imageUrl: 'https://${user.profileImagePath}',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Image.asset(AppImages.appLogo);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // You can add additional user information here if available
                    ],
                  ),
                ),

                // Follow/Unfollow Button
                if (showFollowButton)
                  BlocBuilder<GlobalBloc, GlobalState>(
                    builder: (context, state) {
                      final isFollowed = state.isUserFollowed(user.userId);
                      final followStatus = state.getFollowStatus(user.userId);
                      final isLoading = followStatus == FollowStatus.inProgress;

                      return Container(
                        margin: const EdgeInsets.only(top: 0),
                        height: 36,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (onFollowTap != null) {
                                    onFollowTap!(isFollowed);
                                  } else {
                                    context.read<GlobalBloc>().add(
                                          UpdateFollowStatusEvent(
                                            userId: user.userId,
                                            isFollowed: isFollowed,
                                            context: context,
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).cardColor,
                            foregroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            elevation: 0,
                            shape: SmoothRectangleBorder(
                              borderRadius:
                                  SmoothBorderRadius(cornerRadius: 12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                          ),
                          child: isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Text(
                                      isFollowed
                                          ? localizations.unfollow
                                          : localizations.follow,
                                      style: TextStyle(
                                        fontFamily: Constants.Arial,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
