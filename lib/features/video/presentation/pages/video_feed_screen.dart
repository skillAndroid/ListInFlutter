// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:system_info_plus/system_info_plus.dart';
import 'package:video_player/video_player.dart'; // Simple video player
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

  late int _preloadForwardCount;

  // Controller management
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _videoInitializing = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, String> _cachedVideoFiles = {}; // Track cached video paths

  // Custom cache manager for videos
  late final DefaultCacheManager _cacheManager;
  final Dio _dio = Dio();

  // Preload settings
  static const int _preloadSizeInBytes = 2 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _determinePlatformSpecificPreloadCount();
    _cacheManager = DefaultCacheManager();

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

  Future<void> _determinePlatformSpecificPreloadCount() async {
    if (Platform.isIOS) {
      // For iOS, check the version
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      final version =
          double.tryParse(iosInfo.systemVersion.split('.').first) ?? 0;

      if (version >= 11) {
        _preloadForwardCount = 5; // Higher-end iOS devices
      } else {
        _preloadForwardCount = 3; // Older iOS devices
      }
    } // Then in your code:
    else if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final apiLevel = androidInfo.version.sdkInt;

      // Get system memory in MB
      int totalMemoryMB = 0;
      try {
        final memoryInfo = await SystemInfoPlus.physicalMemory;
        totalMemoryMB = (memoryInfo! ~/ (1024 * 1024)); // Convert bytes to MB
      } catch (e) {
        // Fallback based on API level if memory info unavailable
        if (apiLevel >= 30) {
          totalMemoryMB = 6144;
        } else if (apiLevel >= 28)
          totalMemoryMB = 4096;
        else
          totalMemoryMB = 2048;
      }

      if (totalMemoryMB >= 8192) {
        // 8GB or more
        _preloadForwardCount = 4;
      } else if (totalMemoryMB >= 6144) {
        // 6GB or more
        _preloadForwardCount = 3;
      } else if (totalMemoryMB >= 4096 && apiLevel >= 30) {
        // 4GB + newer Android
        _preloadForwardCount = 3;
      } else {
        _preloadForwardCount = 1; // Lower-end or older devices
      }
    }

    // Update state if needed
    if (mounted) {
      setState(() {});
    }
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
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _resumeCurrentVideo() {
    if (_controllers.containsKey(_currentIndex) &&
        _controllers[_currentIndex]!.value.isInitialized) {
      _controllers[_currentIndex]!.play();
    }
  }

  void _initializeVisibleVideos() {
    // Initialize the current video first with higher priority
    _initializeController(_currentIndex, isActive: true, fullVideo: true);

    // Then preload forward videos
    _preloadForwardVideos();

    // Check if we need to load more videos
    _checkAndLoadMoreVideos();
  }

  void _preloadForwardVideos() {
    // Only preload forward videos
    for (int i = 1; i <= _preloadForwardCount; i++) {
      final indexToPreload = _currentIndex + i;
      if (indexToPreload < _videos.length) {
        // Preload partial video for upcoming videos
        _initializeController(indexToPreload,
            isActive: false, fullVideo: false);
      }
    }
  }

  // Check if video is already cached
  Future<bool> _isVideoCached(String videoUrl) async {
    final fileInfo = await _cacheManager.getFileFromCache(videoUrl);
    return fileInfo != null;
  }

  // Get cached file path or download
  Future<String?> _getCachedVideoPath(String videoUrl,
      {bool fullVideo = true}) async {
    try {
      if (await _isVideoCached(videoUrl)) {
        final fileInfo = await _cacheManager.getFileFromCache(videoUrl);
        return fileInfo?.file.path;
      }

      if (fullVideo) {
        // Download and cache full video
        final fileInfo = await _cacheManager.downloadFile(videoUrl);
        return fileInfo.file.path;
      } else {
        // Preload only partial video data and cache
        await _preloadPartialVideo(videoUrl);
        return null; // Return null as we're not waiting for full download
      }
    } catch (e) {
      debugPrint('⚠️ Error caching video: $e');
      return null;
    }
  }

  // Preload only first few MB of a video
  Future<void> _preloadPartialVideo(String videoUrl) async {
    try {
      final response = await _dio.get(
        videoUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Range': 'bytes=0-$_preloadSizeInBytes'},
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final cacheFile =
          File('${tempDir.path}/${videoUrl.hashCode}_partial.mp4');

      // Save partial data to cache directory
      final sink = cacheFile.openWrite();
      await response.data.stream.pipe(sink);
      await sink.flush();
      await sink.close();

      // Store the reference for cleanup later
      _cachedVideoFiles[videoUrl.hashCode] = cacheFile.path;

      debugPrint('🔄 Preloaded partial data for: $videoUrl');
    } catch (e) {
      debugPrint('⚠️ Error preloading partial video: $e');
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

  Future<void> _initializeController(int index,
      {required bool isActive, required bool fullVideo}) async {
    if (index < 0 || index >= _videos.length) return;

    // Skip if already initialized or initializing
    if (_videoInitializing[index] == true || _videoInitialized[index] == true) {
      // If this is the active video and it's already initialized, just play it
      if (isActive &&
          _controllers.containsKey(index) &&
          _controllers[index]!.value.isInitialized) {
        _controllers[index]!.play();
      }
      return;
    }

    // Mark as initializing
    _videoInitializing[index] = true;

    final String videoUrl = 'https://${_videos[index].videoUrl}';

    try {
      // Get cached path or download
      final cachedPath =
          await _getCachedVideoPath(videoUrl, fullVideo: fullVideo);

      if (cachedPath != null) {
        // Use cached file if available
        final file = File(cachedPath);
        if (await file.exists()) {
          debugPrint('🎯 Using cached video for index $index: $cachedPath');
          final controller = VideoPlayerController.file(file);
          _controllers[index] = controller;

          // Initialize and setup the controller
          await controller.initialize();
          controller.setLooping(true);

          _videoInitializing[index] = false;
          _videoInitialized[index] = true;

          if (!_isDisposed && index == _currentIndex && isActive) {
            controller.play();
            if (mounted) setState(() {});
          }
          return;
        }
      }

      // If no cached file available, use network
      debugPrint('⬇️ Using network video for index $index');
      final controller = VideoPlayerController.network(videoUrl);
      _controllers[index] = controller;

      // Initialize for immediate playback
      await controller.initialize();
      controller.setLooping(true);

      _videoInitializing[index] = false;
      _videoInitialized[index] = true;

      if (isActive && !_isDisposed) {
        controller.play();
        if (mounted) setState(() {});
      }
    } catch (error) {
      debugPrint('⚠️ Video exception for index $index: $error');
      _videoInitializing[index] = false;
      _videoInitialized[index] = false;

      // Retry logic for important videos (current and next)
      if (index == _currentIndex || index == _currentIndex + 1) {
        debugPrint('🔄 Retrying video initialization for index $index');

        // Use a different approach as fallback
        try {
          final controller = VideoPlayerController.network(videoUrl);
          _controllers[index] = controller;

          await controller.initialize();
          controller.setLooping(true);

          _videoInitializing[index] = false;
          _videoInitialized[index] = true;

          if (isActive && !_isDisposed) {
            controller.play();
            if (mounted) setState(() {});
          }
        } catch (retryError) {
          debugPrint('⚠️ Retry failed for index $index: $retryError');
          // Final failure - just mark as not initializing so we can try again later
          _videoInitializing[index] = false;
        }
      }
    }

    // Force UI update if this is the active video
    if (isActive && mounted) {
      setState(() {});
    }
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

    // Initialize and play the new current video with full video
    _initializeController(newIndex, isActive: true, fullVideo: true);

    // Check if we need to load more videos
    _checkAndLoadMoreVideos();

    // Cleanup videos that are now out of the preload range
    _cleanupControllers();

    // Preload new videos in range
    _preloadForwardVideos();
  }

  void _cleanupControllers() {
    final keysToRemove = <int>[];

    // Only keep current and forward preload count videos
    final minKeepIndex = _currentIndex;
    final maxKeepIndex = _currentIndex + _preloadForwardCount;

    _controllers.forEach((index, controller) {
      // Keep controllers only within preload range
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

    // No need to clean up partial preloads - let cache manager handle it
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

    // Clean up temp cache files
    _cleanupTempCacheFiles();

    context.read<HomeTreeCubit>().clearVideos();
    super.dispose();
  }

  // Clean up temporary cache files
  Future<void> _cleanupTempCacheFiles() async {
    for (final path in _cachedVideoFiles.values) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('⚠️ Error cleaning up temp file: $e');
      }
    }
    _cachedVideoFiles.clear();
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
          _controllers[_currentIndex]!.value.isInitialized) {
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
          _controllers[_currentIndex]!.value.isInitialized) {
        await _controllers[_currentIndex]!.play();
      }
    }
  }

  Widget _buildPlayPauseOverlay(int index) {
    final bool isInitialized = _controllers.containsKey(index) &&
        _controllers[index]!.value.isInitialized;

    // Only show play/pause UI when video is actually playable
    if (!isInitialized) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!isInitialized) return;

          if (_controllers[index]!.value.isPlaying) {
            _controllers[index]!.pause();
          } else {
            _controllers[index]!.play();
          }
          setState(() {});
        },
        child: AnimatedOpacity(
          opacity: _controllers[index]!.value.isPlaying ? 0.0 : 0.7,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controllers[index]!.value.isPlaying
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

// This is a complete implementation of the preloading mechanism
  void _preloadVideosInRange() {
    // Preload the current video first with full quality
    _initializeController(_currentIndex, isActive: true, fullVideo: true);

    // Preload forward videos with partial loading
    for (int i = 1; i <= _preloadForwardCount; i++) {
      final indexToPreload = _currentIndex + i;
      if (indexToPreload < _videos.length) {
        _initializeController(indexToPreload,
            isActive: false, fullVideo: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI styling
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
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
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
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
              final bool isVideoInitialized = _controllers.containsKey(index) &&
                  _controllers[index]!.value.isInitialized;

              return Stack(
                children: [
                  Center(
                    child: isVideoInitialized
                        ? AspectRatio(
                            aspectRatio: _controllers[index]!.value.aspectRatio,
                            child: VideoPlayer(_controllers[index]!),
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
                ],
              );
            },
          ),
        ),
      ),
    );
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
}
