// ignore_for_file: deprecated_member_use

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';

class ListInShorts extends StatefulWidget {
  final List<GetPublicationEntity> initialVideos;
  final int initialPage;
  final int initialIndex;

  const ListInShorts({
    super.key,
    required this.initialVideos,
    this.initialPage = 0,
    this.initialIndex = 0,
  });

  @override
  State<ListInShorts> createState() => _ListInShortsState();
}

class _ListInShortsState extends State<ListInShorts>
    with WidgetsBindingObserver {
  late PageController _pageController;
  late HomeTreeCubit _homeTreeCubit;
  List<GetPublicationEntity> _videos = [];

  // Current video state tracking
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isDisposed = false;

  // Preloading range control
  static const int _preloadForwardCount = 3;
  static const int _preloadBackwardCount = 1;

  // Controller management
  final Map<int, BetterPlayerController> _controllers = {};
  final Map<int, bool> _videoInitializing = {};
  final Map<int, bool> _videoInitialized = {};

  // Cache configuration for better performance
  final BetterPlayerCacheConfiguration _cacheConfig =
      BetterPlayerCacheConfiguration(
    useCache: true,
    preCacheSize: 5 * 1024 * 1024, // 5MB pre-cache
    maxCacheSize: 512 * 1024 * 1024, // 512MB max cache
    maxCacheFileSize: 30 * 1024 * 1024, // 30MB per file
  );

  // Buffering configuration for active videos
  final BetterPlayerBufferingConfiguration _activeBufferingConfig =
      BetterPlayerBufferingConfiguration(
    minBufferMs: 3000, // 3 seconds minimum buffer
    maxBufferMs: 30000, // 30 seconds max buffer
    bufferForPlaybackMs: 1500, // 1.5 seconds before playback begins
    bufferForPlaybackAfterRebufferMs: 3000, // 3 seconds after rebuffer
  );

  // Reduced buffering for preloaded videos
  final BetterPlayerBufferingConfiguration _preloadBufferingConfig =
      BetterPlayerBufferingConfiguration(
    minBufferMs: 1500, // 1.5 seconds minimum buffer
    maxBufferMs: 5000, // 5 seconds max buffer
    bufferForPlaybackMs: 500, // 0.5 seconds before playback begins
    bufferForPlaybackAfterRebufferMs: 1500, // 1.5 seconds after rebuffer
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _currentIndex = widget.initialIndex;
    _videos = List.from(widget.initialVideos);
    _homeTreeCubit = context.read<HomeTreeCubit>();
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize visible videos after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _initializeVisibleVideos();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes to optimize resource usage
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseAllVideos();
    } else if (state == AppLifecycleState.resumed) {
      _resumeCurrentVideo();
    }
  }

  void _pauseAllVideos() {
    for (final controller in _controllers.values) {
      if (controller.isVideoInitialized() == true &&
          controller.isPlaying() == true) {
        controller.pause();
      }
    }
  }

  void _resumeCurrentVideo() {
    if (_controllers.containsKey(_currentIndex) &&
        _controllers[_currentIndex]!.isVideoInitialized() == true) {
      _controllers[_currentIndex]!.play();
    }
  }

  void _initializeVisibleVideos() {
    // Initialize the current video first with higher priority
    _initializeController(_currentIndex, isActive: true);

    // Then preload videos in range
    _preloadVideosInRange();

    // Check if we need to load more videos
    _checkAndLoadMoreVideos();
  }

  void _preloadVideosInRange() {
    // Preload forward
    for (int i = 1; i <= _preloadForwardCount; i++) {
      final indexToPreload = _currentIndex + i;
      if (indexToPreload < _videos.length) {
        _initializeController(indexToPreload, isActive: false);
      }
    }

    // Preload backward
    for (int i = 1; i <= _preloadBackwardCount; i++) {
      final indexToPreload = _currentIndex - i;
      if (indexToPreload >= 0) {
        _initializeController(indexToPreload, isActive: false);
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

  void _initializeController(int index, {required bool isActive}) {
    if (index < 0 || index >= _videos.length) return;

    // Skip if already initialized or initializing
    if (_videoInitializing[index] == true || _videoInitialized[index] == true) {
      // If this is the active video and it's already initialized, just play it
      if (isActive &&
          _controllers.containsKey(index) &&
          _controllers[index]!.isVideoInitialized() == true) {
        _controllers[index]!.play();
      }
      return;
    }

    // Mark as initializing
    _videoInitializing[index] = true;

    final String videoUrl = 'https://${_videos[index].videoUrl}';

    // Create data source with appropriate buffering
    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      cacheConfiguration: _cacheConfig,
      bufferingConfiguration:
          isActive ? _activeBufferingConfig : _preloadBufferingConfig,
    );

    // Create configuration
    final BetterPlayerConfiguration playerConfig = BetterPlayerConfiguration(
      autoPlay: isActive, // Only auto-play if this is the active video
      looping: true,
      fit: BoxFit.cover,
      aspectRatio: 9 / 16,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        enableMute: false,
        enablePlayPause: false,
        enableProgressBar: false,
        enableSkips: false,
        enableFullscreen: false,
      ),
      placeholder: _buildPlaceholder(index),
      errorBuilder: (context, errorMessage) {
        debugPrint('❌ Video error at index $index: $errorMessage');
        _videoInitializing[index] = false;
        return _buildPlaceholder(index);
      },
    );

    // Create and store controller
    final controller = BetterPlayerController(playerConfig);
    _controllers[index] = controller;

    // Add event listeners
    controller.addEventsListener((event) {
      if (_isDisposed) return;

      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        debugPrint('✅ Video initialized for index: $index');
        _videoInitializing[index] = false;
        _videoInitialized[index] = true;

        // If this is the current video and we're mounted, play it
        if (!_isDisposed && index == _currentIndex && isActive) {
          controller.play();
          // Force rebuild to refresh UI
          if (mounted) setState(() {});
        }
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.exception) {
        debugPrint('⚠️ Video exception for index $index: ${event.parameters}');
        _videoInitializing[index] = false;
        _videoInitialized[index] = false;
      }
    });

    // Setup data source
    controller.setupDataSource(dataSource);

    // Force UI update if this is the active video
    if (isActive && mounted) {
      setState(() {});
    }
  }

  Widget _buildPlaceholder(int index) {
    if (index >= _videos.length) return const SizedBox.expand();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail background
        CachedNetworkImage(
          imageUrl: "https://${_videos[index].productImages[0].url}",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.black),
          errorWidget: (context, url, error) =>
              Container(color: Colors.black54),
        ),

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

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    debugPrint('🔄 Page change: $_currentIndex → $newIndex');

    // Pause the current video
    if (_controllers.containsKey(_currentIndex)) {
      _controllers[_currentIndex]!.pause();
    }

    // Update current index
    setState(() {
      _currentIndex = newIndex;
    });

    // Initialize and play the new current video
    _initializeController(newIndex, isActive: true);

    // Check if we need to load more videos
    _checkAndLoadMoreVideos();

    // Cleanup videos that are now out of the preload range
    _cleanupControllers();

    // Preload new videos in range
    _preloadVideosInRange();
  }

  void _cleanupControllers() {
    final keysToRemove = <int>[];
    final minKeepIndex = _currentIndex - _preloadBackwardCount - 1;
    final maxKeepIndex = _currentIndex + _preloadForwardCount + 1;

    _controllers.forEach((index, controller) {
      // Keep controllers only within preload range (with a buffer of 1)
      if (index < minKeepIndex || index > maxKeepIndex) {
        controller.dispose();
        keysToRemove.add(index);
        _videoInitializing.remove(index);
        _videoInitialized.remove(index);
      }
    });

    for (final key in keysToRemove) {
      _controllers.remove(key);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    _controllers.clear();
    _videoInitializing.clear();
    _videoInitialized.clear();
    _pageController.dispose();

    context.read<HomeTreeCubit>().clearVideos();
    super.dispose();
  }

  Future<void> _navigateToNewScreen(GetPublicationEntity product) async {
    // Pause video before navigation
    if (_controllers.containsKey(_currentIndex)) {
      await _controllers[_currentIndex]!.pause();
    }

    if (mounted) {
      await context.push(
        Routes.productDetails,
        extra: product,
      );

      // Resume video after returning, if still mounted
      if (mounted &&
          _controllers.containsKey(_currentIndex) &&
          _controllers[_currentIndex]!.isVideoInitialized() == true) {
        await _controllers[_currentIndex]!.play();
      }
    }
  }

  Future<void> _navigateToProfileScreen(String userId, bool isOwner) async {
    if (isOwner) return; // Don't navigate to your own profile

    // Pause video before navigation
    if (_controllers.containsKey(_currentIndex)) {
      await _controllers[_currentIndex]!.pause();
    }

    if (mounted) {
      await context.push(Routes.anotherUserProfile, extra: {
        'userId': userId,
      });

      // Resume video after returning, if still mounted
      if (mounted &&
          _controllers.containsKey(_currentIndex) &&
          _controllers[_currentIndex]!.isVideoInitialized() == true) {
        await _controllers[_currentIndex]!.play();
      }
    }
  }

  Widget _buildPlayPauseOverlay(int index) {
    final bool isInitialized = _controllers.containsKey(index) &&
        _controllers[index]!.isVideoInitialized() == true;

    // Only show play/pause UI when video is actually playable
    if (!isInitialized) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior
            .translucent, // Important for reliable touch detection
        onTap: () {
          if (!isInitialized) return;

          if (_controllers[index]!.isPlaying() == true) {
            _controllers[index]!.pause();
          } else {
            _controllers[index]!.play();
          }
          setState(() {});
        },
        child: AnimatedOpacity(
          opacity: _controllers[index]!.isPlaying() == true ? 0.0 : 0.7,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controllers[index]!.isPlaying() == true
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 44,
              ),
            ),
          ),
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
    // Set system UI styling
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return BlocListener<HomeTreeCubit, HomeTreeState>(
      listener: (context, state) {
        if (state.videoPublicationsRequestState == RequestState.completed) {
          final newVideos = state.videoPublications;

          // Add only new unique videos
          final uniqueNewVideos = newVideos.where((newVideo) =>
              !_videos.any((existingVideo) => existingVideo.id == newVideo.id));

          if (uniqueNewVideos.isNotEmpty) {
            setState(() {
              _videos.addAll(uniqueNewVideos);
              _isLoading = false;
            });

            // Initialize new videos if they're within preload range
            if (_currentIndex + _preloadForwardCount >=
                _videos.length - uniqueNewVideos.length) {
              _preloadVideosInRange();
            }
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28),
            onPressed: () => context.pop(),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _videos.length,
          onPageChanged: _handlePageChange,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          itemBuilder: (context, index) {
            final bool isActiveVideo = index == _currentIndex;
            final bool isVideoInitialized = _controllers.containsKey(index) &&
                _controllers[index]!.isVideoInitialized() == true;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Video player or placeholder
                isVideoInitialized
                    ? BetterPlayer(controller: _controllers[index]!)
                    : _buildPlaceholder(index),

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
              ],
            );
          },
        ),
      ),
    );
  }
}
