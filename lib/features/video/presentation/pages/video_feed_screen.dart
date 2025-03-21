// ignore_for_file: deprecated_member_use

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  _ListInShortsState createState() => _ListInShortsState();
}

class _ListInShortsState extends State<ListInShorts> {
  late PageController _pageController;
  late HomeTreeCubit _homeTreeCubit;
  List<GetPublicationEntity> _videos = [];

  // Map to manage BetterPlayerController instances
  final Map<int, BetterPlayerController> _controllers = {};

  // Track video initialization state
  final Map<int, bool> _videoInitializing = {};

  // Track current and neighboring indices
  int _currentIndex = 0;
  bool _isLoading = false;

  // Define the cache configuration
  final BetterPlayerCacheConfiguration _cacheConfig =
      BetterPlayerCacheConfiguration(
    useCache: true,
    preCacheSize: 10 * 1024 * 1024, // 10MB pre-cache
    maxCacheSize: 1024 * 1024 * 1024, // 1GB max cache
    maxCacheFileSize: 50 * 1024 * 1024, // 30MB per file
  );

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _videos = List.from(widget.initialVideos);
    _homeTreeCubit = context.read<HomeTreeCubit>();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 1);

    // Initialize visible and adjacent videos
    _initializeController(_currentIndex);

    // Pre-initialize the next video if available
    if (_currentIndex + 1 < _videos.length) {
      _preInitializeController(_currentIndex + 1);
    }
  }

  void _loadMoreVideos() {
    if (_isLoading || _homeTreeCubit.state.videoHasReachedMax) {
      debugPrint('⚠️ Skip loading more videos:\n'
          '└─ Is loading: $_isLoading\n'
          '└─ Has reached max: ${_homeTreeCubit.state.videoHasReachedMax}');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final nextPage = (_videos.length ~/ 10);
    _homeTreeCubit.fetchVideoFeeds(nextPage);
  }

  // Initialize controller for active video
  void _initializeController(int index) {
    if (index < 0 || index >= _videos.length) return;

    // Mark this video as initializing
    _videoInitializing[index] = true;

    // If already initialized and playing, return
    if (_controllers.containsKey(index) &&
        _controllers[index]!.isVideoInitialized()! &&
        _controllers[index]!.isPlaying()!) {
      _videoInitializing[index] = false;
      return;
    }

    // If controller exists but is not playing, play it
    if (_controllers.containsKey(index) &&
        _controllers[index]!.isVideoInitialized()!) {
      _controllers[index]!.play();
      _videoInitializing[index] = false;
      return;
    }

    debugPrint('🎬 Starting video initialization for index: $index');

    // Create data source
    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      'https://${_videos[index].videoUrl}',
      cacheConfiguration: _cacheConfig,
      bufferingConfiguration: BetterPlayerBufferingConfiguration(
        minBufferMs: 5000, // 15 seconds buffer
        maxBufferMs: 50000, // 30 seconds max buffer
        bufferForPlaybackMs: 100,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );

    // Create configuration
    final BetterPlayerConfiguration playerConfig = BetterPlayerConfiguration(
      autoPlay: true,
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
      errorBuilder: (context, errorMessage) {
        debugPrint('❌ Video error: $errorMessage');
        _videoInitializing[index] = false;
        return _buildPlaceholder(index);
      },
    );

    // Create controller
    final controller = BetterPlayerController(playerConfig);
    _controllers[index] = controller;

    // Add listeners to the controller to track video state
    controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        debugPrint('✅ Video initialized for index: $index');
        _videoInitializing[index] = false;
        if (mounted && index == _currentIndex) {
          setState(() {});
          controller.play();
        }
      }
    });

    // Setup data source after adding listeners
    controller.setupDataSource(dataSource);

    // Force rebuild to show the video
    if (mounted) setState(() {});
  }

  // Pre-initialize controller for nearby videos (buffering only)
  void _preInitializeController(int index) {
    if (index < 0 || index >= _videos.length) return;

    // Skip if already initialized or initializing
    if (_controllers.containsKey(index) ||
        _videoInitializing.containsKey(index)) return;

    debugPrint('🔄 Pre-initializing video for index: $index');
    _videoInitializing[index] = true;

    // Create data source with preload set to true (this loads but doesn't play)
    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      'https://${_videos[index].videoUrl}',
      cacheConfiguration: _cacheConfig,
      // Set lower buffer size for preloading
      bufferingConfiguration: BetterPlayerBufferingConfiguration(
        minBufferMs: 5000, // 5 seconds buffer for preload
        maxBufferMs: 10000, // 10 seconds max buffer for preload
      ),
    );

    // Create configuration with autoPlay disabled
    final BetterPlayerConfiguration playerConfig = BetterPlayerConfiguration(
      autoPlay: false,
      looping: true,
      fit: BoxFit.cover,
      aspectRatio: 9 / 16,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
      ),
    );

    // Create controller
    final controller = BetterPlayerController(playerConfig);
    _controllers[index] = controller;

    // Add listeners to track initialization
    controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        debugPrint('✅ Video pre-initialized for index: $index');
        _videoInitializing[index] = false;
        if (mounted && index == _currentIndex) {
          setState(() {});
          controller.play();
        }
      }
    });

    // Setup data source after adding listeners
    controller.setupDataSource(dataSource);

    // Preload video but pause immediately
    controller.preCache(dataSource);
  }

  Widget _buildPlaceholder(int index) {
    if (index >= _videos.length) return SizedBox.expand();
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: "https://${_videos[index].productImages[0].url}",
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Center(
          child: Transform.scale(
            scale: 1.25,
            child: CircularProgressIndicator(
              strokeCap: StrokeCap.square,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    debugPrint('🔄 Page change triggered:\n'
        '└─ Current index: $_currentIndex\n'
        '└─ New index: $newIndex');

    // Pause the current video
    if (_controllers.containsKey(_currentIndex)) {
      _controllers[_currentIndex]!.pause();
    }

    setState(() {
      _currentIndex = newIndex;
    });

    // Play the new current video
    _initializeController(newIndex);

    // Clean up controllers for videos that are now out of view range
    _cleanupControllers(newIndex);

    // Pre-initialize next and previous videos if they exist
    if (newIndex + 1 < _videos.length) {
      _preInitializeController(newIndex + 1);
    }
    if (newIndex - 1 >= 0) {
      _preInitializeController(newIndex - 1);
    }
  }

  // Cleanup controllers that are far from current view
  void _cleanupControllers(int currentIndex) {
    final keysToRemove = <int>[];

    _controllers.forEach((index, controller) {
      // Keep only current and adjacent indices
      if (index != currentIndex &&
          index != currentIndex + 1 &&
          index != currentIndex - 1) {
        controller.dispose();
        keysToRemove.add(index);
        _videoInitializing.remove(index);
      }
    });

    for (final key in keysToRemove) {
      _controllers.remove(key);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _videoInitializing.clear();
    _pageController.dispose();
    context.read<HomeTreeCubit>().clearVideos();
    super.dispose();
  }

  Future<void> _navigateToNewScreen(GetPublicationEntity product) async {
    if (_controllers.containsKey(_currentIndex)) {
      await _controllers[_currentIndex]!.pause();
    }

    if (mounted) {
      await context.push(
        Routes.productDetails,
        extra: product,
      );

      if (mounted && _controllers.containsKey(_currentIndex)) {
        await _controllers[_currentIndex]!.play();
      }
    }
  }

  Future<void> _navigateToProfileScreen(String userId, bool isOwner) async {
    if (_controllers.containsKey(_currentIndex)) {
      await _controllers[_currentIndex]!.pause();
    }

    if (mounted) {
      if (!isOwner) {
        context.push(Routes.anotherUserProfile, extra: {
          'userId': userId,
        });
      }

      if (mounted && _controllers.containsKey(_currentIndex)) {
        await _controllers[_currentIndex]!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // for Android
      statusBarBrightness: Brightness.dark, // for iOS
    ));
    return BlocListener<HomeTreeCubit, HomeTreeState>(
      listener: (context, state) {
        if (state.videoPublicationsRequestState == RequestState.completed) {
          final newVideos = state.videoPublications;
          final uniqueNewVideos = newVideos.where((newVideo) =>
              !_videos.any((existingVideo) => existingVideo.id == newVideo.id));

          setState(() {
            _videos.addAll(uniqueNewVideos);
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            SafeArea(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _videos.length,
                onPageChanged: (index) {
                  _handlePageChange(index);
                  if (!_isLoading && index >= _videos.length - 5) {
                    _loadMoreVideos();
                  }
                },
                allowImplicitScrolling: true,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                  decelerationRate: ScrollDecelerationRate.fast,
                ),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video player or placeholder
                      if (_controllers.containsKey(index) &&
                          _controllers[index]!.isVideoInitialized()!)
                        BetterPlayer(controller: _controllers[index]!)
                      else
                        _buildPlaceholder(index),

                      // Custom play/pause overlay
                      if (_controllers.containsKey(index))
                        GestureDetector(
                          onTap: () {
                            if (_controllers[index]!.isPlaying()!) {
                              _controllers[index]!.pause();
                            } else {
                              _controllers[index]!.play();
                            }
                            setState(() {});
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.transparent,
                              size: 44,
                            ),
                          ),
                        ),

                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 64,
                        child: GestureDetector(
                          onTap: () {
                            final currentUserId =
                                AppSession.currentUserId; // Get current user ID
                            final isOwner =
                                currentUserId == _videos[index].seller.id;
                            if (!isOwner) {
                              _navigateToNewScreen(_videos[index]);
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final currentUserId = AppSession
                                      .currentUserId; // Get current user ID
                                  final isOwner =
                                      currentUserId == _videos[index].seller.id;

                                  _navigateToProfileScreen(
                                    _videos[index].seller.id,
                                    isOwner,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: ShapeDecoration(
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: 100,
                                            cornerSmoothing: 1,
                                          ),
                                          side: BorderSide(
                                              width: 2,
                                              color: AppColors.white
                                                  .withOpacity(0.8)),
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          "https://${_videos[index].seller.profileImagePath}",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 130,
                                          child: Text(
                                            _videos[index].seller.nickName,
                                            style: TextStyle(
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
                                                state.getFollowersCount(
                                                    _videos[index].seller.id);
                                            return Text(
                                              '$followersCount ${AppLocalizations.of(context)!.followers}',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 13.5,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    BlocBuilder<GlobalBloc, GlobalState>(
                                      builder: (context, state) {
                                        final isFollowed = state.isUserFollowed(
                                            _videos[index].seller.id);
                                        final followStatus =
                                            state.getFollowStatus(
                                                _videos[index].seller.id);
                                        final isLoading = followStatus ==
                                            FollowStatus.inProgress;
                                        final currentUserId = AppSession
                                            .currentUserId; // Get current user ID
                                        final isOwner = currentUserId ==
                                            _videos[index]
                                                .seller
                                                .id; // Check if user is owner
                                        if (isOwner) {
                                          // Option 1: Show "You" text
                                          return Text(
                                            AppLocalizations.of(context)!.you,
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 14,
                                              fontFamily: Constants.Arial,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );

                                          // Option 2: Return empty container to hide the button completely
                                          // return const SizedBox.shrink();
                                        } else {
                                          return ElevatedButton(
                                            onPressed: () {
                                              context
                                                  .read<GlobalBloc>()
                                                  .add(UpdateFollowStatusEvent(
                                                    userId: _videos[index]
                                                        .seller
                                                        .id,
                                                    isFollowed: isFollowed,
                                                    context: context,
                                                  ));
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? AppColors.error.withOpacity(
                                                      0.6) // Darker shade for dark mode
                                                  : AppColors.error,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    4, // Reduced horizontal padding
                                                vertical: 1,
                                              ),
                                              minimumSize: const Size(60,
                                                  26), // Smaller overall button size
                                              shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius(
                                                  cornerRadius:
                                                      16, // Smaller corner radius
                                                  cornerSmoothing: 1,
                                                ),
                                              ),
                                              elevation:
                                                  0, // Remove shadow for cleaner dark mode look
                                            ),
                                            child: isLoading
                                                ? SizedBox(
                                                    width:
                                                        14, // Smaller loading indicator
                                                    height: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : Text(
                                                    isFollowed
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .unfollow
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .follow,
                                                    style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize:
                                                          12, // Smaller font size
                                                      fontFamily:
                                                          Constants.Arial,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 110,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  clipBehavior: Clip.hardEdge,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 20,
                                      cornerSmoothing: 0.8,
                                    ),
                                  ),
                                  color: AppColors.black.withOpacity(0.75),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: ShapeDecoration(
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius(
                                                    cornerRadius: 18,
                                                    cornerSmoothing: 0.8,
                                                  ),
                                                  side: BorderSide(
                                                    width: 2,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                              child: ClipSmoothRect(
                                                radius: SmoothBorderRadius(
                                                    cornerRadius: 18,
                                                    cornerSmoothing: 0.8),
                                                child: SizedBox(
                                                  width: 76,
                                                  height: 76,
                                                  child: Image.network(
                                                    "https://${_videos[index].productImages[0].url}",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    _videos[index].title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _videos[index].locationName,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 8.0,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          formatPrice(
                                                              _videos[index]
                                                                  .price
                                                                  .toString()),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Ionicons
                                                              .arrow_forward,
                                                          color:
                                                              AppColors.white,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SafeArea(
              child: Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 28,
                    color: AppColors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
