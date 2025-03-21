import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/di/di_managment.dart';
import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';
import 'package:list_in/features/followers/presentation/bloc/social_user_bloc.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
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
          return const Center(child: CircularProgressIndicator());
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
                const Text(
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
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          // Show a placeholder when the tab is not active
          return _followersInitialized
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox();
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
          return const Center(child: CircularProgressIndicator());
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
              'No users found',
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(),
                ),
              );
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
    Key? key,
    required this.user,
    this.onFollowTap,
    this.showFollowButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = 'current-user-id'; // Replace with your auth mechanism
    final isCurrentUser = user.userId == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to user profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(userId: user.userId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Hero(
                  tag: 'profile-${user.userId}',
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(user.profileImagePath),
                    backgroundColor: Colors.grey[200],
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // You can add additional user information here if available
                      // such as bio, mutual friends, etc.
                    ],
                  ),
                ),
                if (showFollowButton && !isCurrentUser)
                  BlocBuilder<SocialUserBloc, SocialUserState>(
                    builder: (context, state) {
                      // Determine if this user is being followed
                      bool isFollowing = user.isFollowed ?? false;

                      if (state is FollowActionSuccess &&
                          state.userId == user.userId) {
                        isFollowing = state.isFollowing;
                      }

                      return FollowButton(
                        isFollowing: isFollowing,
                        onTap: () => onFollowTap?.call(isFollowing),
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

class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isFollowing ? Colors.grey[200] : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: isFollowing ? Border.all(color: Colors.grey) : null,
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFollowing ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// This is just a placeholder for the navigator
class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text('User Profile: $userId'),
      ),
    );
  }
}

// Extended UserProfile to include follow status
extension on UserProfile {
  bool? get isFollowed {
    // You would need to add this property to your UserProfile class
    // or implement a way to check follow status
    return null;
  }
}
