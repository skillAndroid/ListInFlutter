// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
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
  bool _followersInitialized = false;
  bool _followingsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'followers' ? 0 : 1,
    );

    // Load initial data based on starting tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index == 0) {
        _followersInitialized = true;
        context.read<SocialUserBloc>().add(
              FetchFollowers(userId: widget.userId),
            );
      } else {
        _followingsInitialized = true;
        context.read<SocialUserBloc>().add(
              FetchFollowings(userId: widget.userId),
            );
      }
    });

    // Add listener to handle tab changes
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 0 && !_followersInitialized) {
      _followersInitialized = true;
      context.read<SocialUserBloc>().add(
            FetchFollowers(userId: widget.userId),
          );
    } else if (_tabController.index == 1 && !_followingsInitialized) {
      _followingsInitialized = true;
      context.read<SocialUserBloc>().add(
            FetchFollowings(userId: widget.userId),
          );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.username,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 0.1,
          dividerColor: AppColors.transparent,
          isScrollable: true, // Makes tabs scrollable
          labelPadding:
              EdgeInsets.symmetric(horizontal: 20), // Padding between tabs
          indicatorSize:
              TabBarIndicatorSize.label, // Makes indicator match tab width
          tabAlignment: TabAlignment.start, // Aligns tabs to the start (left)
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
              text: AppLocalizations.of(context)!.followers,
            ),
            Tab(
              text: AppLocalizations.of(context)!.following,
            ),
          ],
          onTap: (index) {
            // Load data when tab is selected
            if (index == 0) {
              context.read<SocialUserBloc>().add(
                    FetchFollowers(userId: widget.userId),
                  );
            } else {
              context.read<SocialUserBloc>().add(
                    FetchFollowings(userId: widget.userId),
                  );
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Followers Tab
          _buildFollowersTab(context),
          // Followings Tab
          _buildFollowingsTab(context),
        ],
      ),
    );
  }

  Widget _buildFollowersTab(BuildContext context) {
    return BlocBuilder<SocialUserBloc, SocialUserState>(
      buildWhen: (previous, current) {
        // Only rebuild for follower-related states
        return current is SocialUserLoading ||
            current is FollowersLoaded ||
            current is SocialUserError ||
            (current is FollowActionSuccess && previous is FollowersLoaded);
      },
      builder: (context, state) {
        if (state is SocialUserLoading && !_followersInitialized) {
          return const Progress();
        } else if (state is FollowersLoaded) {
          return _buildUserList(
            context,
            state.followers,
            state.hasReachedMax,
            () => context.read<SocialUserBloc>().add(
                  FetchFollowers(userId: widget.userId),
                ),
          );
        } else if (state is SocialUserError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load followers',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<SocialUserBloc>().add(
                        FetchFollowers(userId: widget.userId, refresh: true),
                      ),
                  child: Text(
                    AppLocalizations.of(context)!.retry,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show a placeholder when the tab is not active
          return _followersInitialized ? const Progress() : const SizedBox();
        }
      },
    );
  }

  Widget _buildFollowingsTab(BuildContext context) {
    // Trigger the followings fetch when the tab is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index == 1) {
        context.read<SocialUserBloc>().add(
              FetchFollowings(userId: widget.userId),
            );
      }
    });

    return BlocBuilder<SocialUserBloc, SocialUserState>(
      builder: (context, state) {
        if (state is SocialUserLoading) {
          return const Progress();
        } else if (state is FollowingsLoaded) {
          return _buildUserList(
            context,
            state.followings,
            state.hasReachedMax,
            () => context.read<SocialUserBloc>().add(
                  FetchFollowings(userId: widget.userId),
                ),
          );
        } else if (state is SocialUserError) {
          return Center(
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
                  onPressed: () => context.read<SocialUserBloc>().add(
                        FetchFollowings(userId: widget.userId, refresh: true),
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          // Initial state or unknown state
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildUserList(
    BuildContext context,
    List<UserProfile> users,
    bool hasReachedMax,
    VoidCallback loadMore,
  ) {
    if (users.isEmpty) {
      return Center(
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
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.extentAfter < 200 &&
            !hasReachedMax) {
          loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: AppColors.white,
        elevation: 1,
        strokeWidth: 3,
        displacement: 40,
        edgeOffset: 10,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          if (_tabController.index == 0) {
            context.read<SocialUserBloc>().add(
                  FetchFollowers(userId: widget.userId, refresh: true),
                );
          } else {
            context.read<SocialUserBloc>().add(
                  FetchFollowings(userId: widget.userId, refresh: true),
                );
          }
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: hasReachedMax ? users.length : users.length + 1,
          itemBuilder: (context, index) {
            if (index >= users.length) {
              return const Progress();
            }

            final user = users[index];
            return UserListTile(
              user: user,
              onFollowTap: (isCurrentlyFollowing) {
                context.read<SocialUserBloc>().add(
                      FollowUser(
                        userId: user.userId,
                        isFollowing: !isCurrentlyFollowing,
                      ),
                    );
              },
            );
          },
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Hero(
                  tag: 'profile-${user.userId}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      width: 36,
                      height: 36,
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
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // You can add additional user information here if available
                      // such as bio, mutual friends, etc.
                    ],
                  ),
                ),

                // Message Button
                BlocBuilder<GlobalBloc, GlobalState>(
                  builder: (context, state) {
                    final isFollowed = state.isUserFollowed(user.userId);
                    final followStatus = state.getFollowStatus(user.userId);
                    final isLoading = followStatus == FollowStatus.inProgress;
                    return Container(
                      margin: EdgeInsets.only(top: 0),
                      height: 32,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<GlobalBloc>().add(
                                      UpdateFollowStatusEvent(
                                        userId: user.userId,
                                        isFollowed: isFollowed,
                                        context: context,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CupertinoColors.white,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: SmoothRectangleBorder(
                            side: BorderSide(width: 1, color: AppColors.black),
                            borderRadius: SmoothBorderRadius(cornerRadius: 18),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(4),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(
                                    isFollowed ? Icons.remove : Icons.add,
                                    size: 14,
                                    color: AppColors.black,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    isFollowed
                                        ? localizations.unfollow
                                        : localizations.follow,
                                    style: TextStyle(
                                      fontFamily: Constants.Arial,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                      fontSize: 12.5,
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
