// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/video/presentation/pages/detail_page_bottom_sheet.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// Updated progress painter class
class _SmoothProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _SmoothProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background line
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.butt; // Changed to butt for square ends

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      backgroundPaint,
    );

    // Draw progress line
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = size.height
        ..strokeCap = StrokeCap.butt; // Changed to butt for square ends

      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width * progress.clamp(0.0, 1.0), size.height / 2),
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColor != oldDelegate.progressColor;
  }
}

class ListInShorts extends StatefulWidget {
  const ListInShorts({
    super.key,
  });

  @override
  State<ListInShorts> createState() => _ListInShortsState();
}

class _ListInShortsState extends State<ListInShorts>
    with WidgetsBindingObserver {
  late PageController _pageController;
  late HomeTreeCubit _homeTreeCubit;
  List<GetPublicationEntity> _videos = [];

  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _initialVideosFetched = false; // Add this flag
  final int _forwardPreloadCount = 2;
  final int _backwardKeepCount = 1;

  // MediaKit player and controller management
  final Map<int, Player> _players = {};
  final Map<int, VideoController> _controllers = {};
  final Map<int, bool> _videoInitializing = {};
  final Map<int, bool> _videoInitialized = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _currentIndex = 0;
    _homeTreeCubit = context.read<HomeTreeCubit>();
    _pageController = PageController(initialPage: _currentIndex);

    // Fetch videos first, then initialize players
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _fetchInitialVideos();
      }
    });

    _setupNavigationObserver();
  }

  void _fetchInitialVideos() {
    debugPrint('🎬 Fetching initial videos...');
    setState(() {
      _isLoading = true;
    });

    _homeTreeCubit.fetchVideoFeeds(0);
  }

  void _setupNavigationObserver() {
    // Listen to route changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      // Listen to navigation events
      router.routerDelegate.addListener(_onRouteChanged);
    });
  }

  void _onRouteChanged() {
    // Check if current route is still the shorts screen
    if (!mounted) return;

    final String currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.toString();

    // Assuming your route path is something like '/shorts' or contains 'shorts'
    if (!currentRoute.contains('shorts') && !currentRoute.contains('explore')) {
      // We've navigated away from shorts
      _players[_currentIndex]!.pause();
    }
  }

  // Modified method - only call after videos are fetched
  void _loadCurrentAndPreloadVideos() {
    if (_videos.isEmpty) {
      debugPrint('⚠️ No videos available to load');
      return;
    }

    debugPrint('🎬 Loading current video: $_currentIndex');

    // First, load the current video
    _initializeVideo(_currentIndex, autoPlay: true);

    // Then preload forward videos
    for (int i = 1; i <= _forwardPreloadCount; i++) {
      final indexToPreload = _currentIndex + i;
      if (indexToPreload < _videos.length) {
        debugPrint('🔄 Preloading forward video: $indexToPreload');
        _initializeVideo(indexToPreload, autoPlay: false);
      }
    }

    // Keep one video behind if available
    final indexBehind = _currentIndex - 1;
    if (indexBehind >= 0) {
      if (!_videoInitialized.containsKey(indexBehind) &&
          !_videoInitializing.containsKey(indexBehind)) {
        debugPrint('🔄 Loading previous video: $indexBehind');
        _initializeVideo(indexBehind, autoPlay: false);
      }
    }

    // Clean up videos that are no longer needed
    _cleanupOldVideos();
  }

// Clean up videos that are outside the keep range
  void _cleanupOldVideos() {
    final keysToRemove = <int>[];

    // Define the range of videos to keep
    final minKeepIndex = _currentIndex - _backwardKeepCount;
    final maxKeepIndex = _currentIndex + _forwardPreloadCount;

    _players.forEach((index, player) {
      if (index < minKeepIndex || index > maxKeepIndex) {
        debugPrint('🧹 Cleaning up video $index');
        player.dispose();
        keysToRemove.add(index);
        _videoInitialized.remove(index);
        _videoInitializing.remove(index);

        if (_controllers.containsKey(index)) {
          _controllers.remove(index);
        }
      }
    });

    for (final key in keysToRemove) {
      _players.remove(key);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Pause all videos when app goes to background
      for (final player in _players.values) {
        player.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume current video when app comes to foreground
      if (_players.containsKey(_currentIndex)) {
        _players[_currentIndex]!.play();
      }
    }
  }

// Initialize a single video
  Future<void> _initializeVideo(int index, {required bool autoPlay}) async {
    if (index < 0 || index >= _videos.length) return;

    // Skip if already initialized or initializing
    if (_videoInitializing[index] == true || _videoInitialized[index] == true) {
      // If it's the current video and should be playing, ensure it's playing
      if (autoPlay && index == _currentIndex && _players.containsKey(index)) {
        _players[index]!.play();
      }
      return;
    }

    // Mark as initializing
    _videoInitializing[index] = true;

    final videoUrl = 'https://${_videos[index].videoUrl}';
    debugPrint('⬇️ Initializing video $index: $videoUrl');

    try {
      // Create a new player
      final player = Player();
      _players[index] = player;

      // Create controller
      final controller = VideoController(player);
      _controllers[index] = controller;

      // Open media
      await player.open(Media(videoUrl), play: autoPlay);

      // Configure looping
      player.setPlaylistMode(PlaylistMode.single);

      // Mark as initialized
      _videoInitializing[index] = false;
      _videoInitialized[index] = true;

      debugPrint('✅ Successfully loaded video $index');

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Failed to load video $index: $e');
      _videoInitializing[index] = false;

      if (index == _currentIndex) {
        // For current video, try one more time with simpler options
        try {
          final player = Player(
            configuration: PlayerConfiguration(
              title: 'Video $index',
              ready: () {
                debugPrint('Player ready for index $index');
              },
            ),
          );

          _players[index] = player;
          _controllers[index] = VideoController(player);

          await player.open(Media(videoUrl), play: autoPlay);
          player.setPlaylistMode(PlaylistMode.single);

          _videoInitialized[index] = true;

          if (mounted) setState(() {});
        } catch (retryError) {
          debugPrint('❌ Retry also failed for video $index: $retryError');
        }
      }
    }
  }

  void _loadMoreVideos() {
    if (_isLoading || _homeTreeCubit.state.videoHasReachedMax) {
      debugPrint(
          '⚠️ Skip loading more videos: isLoading=$_isLoading, hasReachedMax=${_homeTreeCubit.state.videoHasReachedMax}');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nextPage = (_videos.length ~/ 10);
    _homeTreeCubit.fetchVideoFeeds(nextPage);
  }

  void _checkAndLoadMoreVideos() {
    // Load more videos when we're 5 or fewer videos away from the end
    if (_currentIndex >= _videos.length - 5) {
      _loadMoreVideos();
    }
  }

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    debugPrint('📱 Page changed: $_currentIndex -> $newIndex');

    // Pause current video
    if (_players.containsKey(_currentIndex)) {
      _players[_currentIndex]!.pause();
    }

    // Update current index
    setState(() {
      _currentIndex = newIndex;
    });

    // Ensure current video is loaded and playing
    if (_videoInitialized[newIndex] == true && _players.containsKey(newIndex)) {
      _players[newIndex]!.play();
    } else {
      _initializeVideo(newIndex, autoPlay: true);
    }

    // Load/preload videos based on new position
    _loadCurrentAndPreloadVideos();

    // Check if we need to load more videos from backend
    _checkAndLoadMoreVideos();
  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Dispose all players and controllers
    for (final player in _players.values) {
      player.dispose();
    }

    _players.clear();
    _controllers.clear();
    _videoInitialized.clear();
    _videoInitializing.clear();
    _pageController.dispose();

    super.dispose();
  }

// You can add this method to show visual feedback when debugging
  Future<void> showProductDetailsSheet(
      BuildContext context, GetPublicationEntity product) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductDetailsBottomSheet(product: product);
      },
    );
  }

  Future<void> _navigateToNewScreen(GetPublicationEntity product) async {
    // Pause video before navigation
    if (_players.containsKey(_currentIndex)) {
      await _players[_currentIndex]!.pause();
    }

    if (mounted) {
      await context.push(
        Routes.productDetails,
        extra: product,
      );

      // Resume video after returning
      if (mounted && _players.containsKey(_currentIndex)) {
        await _players[_currentIndex]!.play();
      }
    }
  }

  Future<void> _navigateToProfileScreen(String userId, bool isOwner) async {
    if (isOwner) return;

    // Pause video before navigation
    if (_players.containsKey(_currentIndex)) {
      await _players[_currentIndex]!.pause();
    }

    if (mounted) {
      await context.push(Routes.anotherUserProfile, extra: {
        'userId': userId,
      });

      // Resume video after returning
      if (mounted && _players.containsKey(_currentIndex)) {
        await _players[_currentIndex]!.play();
      }
    }
  }

  Widget _buildPlayPauseOverlay(int index) {
    final bool isInitialized =
        _videoInitialized[index] == true && _players.containsKey(index);

    if (!isInitialized) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!isInitialized) return;

          if (_players[index]!.state.playing) {
            _players[index]!.pause();
          } else {
            _players[index]!.play();
          }
          setState(() {});
        },
        child: StreamBuilder<bool>(
          stream: _players[index]!.stream.playing,
          builder: (context, snapshot) {
            final bool isPlaying = snapshot.data ?? false;

            return AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 0.7,
              duration: const Duration(milliseconds: 300),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.75),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      isPlaying ? AppIcons.pause_icon : AppIcons.play_icon,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoInfo(int index) {
    final currentUserId = AppSession.currentUserId;
    final isOwner = currentUserId == _videos[index].seller.id;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              GestureDetector(
                onTap: () =>
                    _navigateToProfileScreen(_videos[index].seller.id, isOwner),
                child: Container(
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 100,
                        cornerSmoothing: 1,
                      ),
                      side: BorderSide(
                          width: 2, color: AppColors.white.withOpacity(0.8)),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      "https://${_videos[index].seller.profileImagePath}",
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // User info
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToProfileScreen(
                      _videos[index].seller.id, isOwner),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          _videos[index].seller.nickName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      BlocBuilder<GlobalBloc, GlobalState>(
                        builder: (context, state) {
                          final followersCount =
                              state.getFollowersCount(_videos[index].seller.id);
                          return Text(
                            '$followersCount ${AppLocalizations.of(context)!.followers}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13.5,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Follow/unfollow button
              BlocBuilder<GlobalBloc, GlobalState>(
                builder: (context, state) {
                  if (isOwner) {
                    return Text(
                      AppLocalizations.of(context)!.you,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  } else {
                    final isFollowed =
                        state.isUserFollowed(_videos[index].seller.id);
                    final followStatus =
                        state.getFollowStatus(_videos[index].seller.id);
                    final isLoading = followStatus == FollowStatus.inProgress;

                    return SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isLoading) {
                            context
                                .read<GlobalBloc>()
                                .add(UpdateFollowStatusEvent(
                                  userId: _videos[index].seller.id,
                                  isFollowed: isFollowed,
                                  context: context,
                                ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.error.withOpacity(0.6)
                                  : AppColors.error,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 16,
                              cornerSmoothing: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                isFollowed
                                    ? AppLocalizations.of(context)!.unfollow
                                    : AppLocalizations.of(context)!.follow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Product info card
          GestureDetector(
            onTap: () => !isOwner ? _navigateToNewScreen(_videos[index]) : null,
            child: Container(
              height: 110,
              decoration: ShapeDecoration(
                color: AppColors.black.withOpacity(0.6),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 20,
                    cornerSmoothing: 0.8,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 18,
                            cornerSmoothing: 0.8,
                          ),
                          side: const BorderSide(
                            width: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ClipSmoothRect(
                        radius: SmoothBorderRadius(
                            cornerRadius: 18, cornerSmoothing: 0.8),
                        child: SizedBox(
                          width: 76,
                          height: 76,
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://${_videos[index].productImages[0].url}",
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, progress) =>
                                    Container(color: Colors.black45),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.black12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          // Title
                          Text(
                            _videos[index].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Location
                          Text(
                            _videos[index].locationName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 3),

                          // Price and arrow
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatPrice(_videos[index].price.toString()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Ionicons.arrow_forward,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // // Set system UI styling
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));

    return BlocListener<HomeTreeCubit, HomeTreeState>(
      listener: (context, state) {
        if (state.videoPublicationsRequestState == RequestState.completed) {
          final newVideos = state.videoPublications;

          if (!_initialVideosFetched) {
            // First time loading videos
            debugPrint('✅ Initial videos fetched: ${newVideos.length}');
            setState(() {
              _videos = List.from(newVideos);
              _isLoading = false;
              _initialVideosFetched = true;
            });

            // Now start loading and playing videos
            if (_videos.isNotEmpty && !_isDisposed) {
              _loadCurrentAndPreloadVideos();
            }
          } else {
            // Loading more videos (pagination)
            final uniqueNewVideos = newVideos.where((newVideo) => !_videos
                .any((existingVideo) => existingVideo.id == newVideo.id));

            if (uniqueNewVideos.isNotEmpty) {
              setState(() {
                _videos.addAll(uniqueNewVideos);
                _isLoading = false;
              });

              // Initialize new videos if they're within preload range
              if (_currentIndex + _forwardPreloadCount >=
                  _videos.length - uniqueNewVideos.length) {
                _loadCurrentAndPreloadVideos();
              }
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else if (state.videoPublicationsRequestState == RequestState.error) {
          // Handle error state
          setState(() {
            _isLoading = false;
          });
          debugPrint('❌ Failed to fetch videos');
        }
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: _videos.isEmpty && _isLoading
              ? _buildInitialLoadingScreen()
              : _videos.isEmpty
                  ? _buildEmptyState()
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _videos.length,
                      onPageChanged: _handlePageChange,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                        decelerationRate: ScrollDecelerationRate.fast,
                      ),
                      itemBuilder: (context, index) {
                        final bool isVideoInitialized =
                            _videoInitialized[index] == true &&
                                _controllers.containsKey(index);

                        return Stack(
                          children: [
                            Center(
                              child: isVideoInitialized
                                  ? Video(
                                      controller: _controllers[index]!,
                                      fit: BoxFit.contain,
                                      controls: null, // No default controls
                                    )
                                  : _buildPlaceholder(index),
                            ),

                            // Gradient overlay for better text visibility
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.005),
                                      Colors.black.withOpacity(0.15),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Play/pause overlay
                            _buildPlayPauseOverlay(index),

                            // Video info (user, product)
                            _buildVideoInfo(index),

                            // Positioned(
                            //   left: 0,
                            //   right: 0,
                            //   bottom: 0,
                            //   child: _buildVideoProgressIndicator(index),
                            // ),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildInitialLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading videos...',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            color: AppColors.white.withOpacity(0.6),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No videos available',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(int index) {
    if (index >= _videos.length) return const SizedBox.expand();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dim overlay to make loading indicator more visible
        Container(color: Colors.black.withOpacity(0.3)),

        // Loading indicator
        Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        ),
      ],
    );
  }

// Updated progress indicator widget
  Widget _buildVideoProgressIndicator(int index) {
    // Show loading indicator for videos that are initializing
    if (_videoInitializing[index] == true) {
      return Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: LinearProgressIndicator(
          backgroundColor: Colors.grey[800],
          valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.white.withOpacity(0.5)),
        ),
      );
    }

    // Don't show anything if not initialized and not initializing
    if (!_videoInitialized.containsKey(index) || !_videoInitialized[index]!) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onHorizontalDragStart: (details) {
        _players[index]?.pause();
      },
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final x = details.localPosition.dx;
        final percentage = x / box.size.width;
        final duration = _players[index]?.state.duration ?? Duration.zero;
        final newPosition = duration * percentage.clamp(0.0, 1.0);
        _players[index]?.seek(newPosition);
      },
      onHorizontalDragEnd: (details) {
        _players[index]?.play();
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final x = details.localPosition.dx;
        final percentage = x / box.size.width;
        final duration = _players[index]?.state.duration ?? Duration.zero;
        final newPosition = duration * percentage.clamp(0.0, 1.0);
        _players[index]?.seek(newPosition);
      },
      child: StreamBuilder<Duration>(
        stream: _players[index]!.stream.position,
        builder: (context, positionSnapshot) {
          final position = positionSnapshot.data ?? Duration.zero;

          return StreamBuilder<Duration>(
            stream: _players[index]!.stream.duration,
            builder: (context, durationSnapshot) {
              final duration = durationSnapshot.data ?? Duration.zero;

              if (duration.inSeconds == 0) {
                return const SizedBox.shrink();
              }

              final progress =
                  position.inMilliseconds / duration.inMilliseconds;

              return Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: CustomPaint(
                  painter: _SmoothProgressPainter(
                    progress: progress,
                    backgroundColor: Colors.grey[800]!,
                    progressColor: Colors.white.withOpacity(0.8),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
