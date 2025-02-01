// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/explore/presentation/bloc/cubit.dart';
import 'package:list_in/features/explore/presentation/bloc/state.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:list_in/features/video/presentation/wigets/video_controlls.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

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

  final List<VideoPlayerController?> _controllers = [
    null,
    null,
    null,
    null,
    null,
  ];

  int _currentIndex = 0;
  final Map<int, Duration> _videoPositions = {};

  bool _isLoading = false;
  List<GetPublicationEntity> _videos = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _videos = widget.initialVideos;
    _homeTreeCubit = context.read<HomeTreeCubit>();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.95);
    _initializeControllers(_currentIndex);
  }

  void _loadMoreVideos() {
    if (_isLoading || _homeTreeCubit.state.videoHasReachedMax) {
      print('⚠️ Skip loading more videos:\n'
          '└─ Is loading: $_isLoading\n'
          '└─ Has reached max: ${_homeTreeCubit.state.videoHasReachedMax}');
      return;
    }

    print('📥 Loading more videos:\n'
        '└─ Current count: ${_videos.length}\n'
        '└─ Loading page: ${_videos.length ~/ 20}');

    setState(() {
      _isLoading = true;
    });

    _homeTreeCubit.fetchVideoFeeds(_videos.length ~/ 20);
  }

  void _initializeControllers(int index) {
    // Initialize current video with full load
    _initializeController(2, index, fullLoad: true);

    // Preload previous video with buffer
    if (index > 0) _initializeController(1, index - 1, fullLoad: false);

    // Preload next video with buffer
    if (index + 1 < widget.initialVideos.length) {
      _initializeController(3, index + 1, fullLoad: false);
    }

    // Preload after next video with buffer
    if (index + 2 < widget.initialVideos.length) {
      _initializeController(4, index + 2, fullLoad: false);
    }

    // Preload after after next video with buffer
    if (index + 3 < widget.initialVideos.length) {
      _initializeController(0, index + 3, fullLoad: false);
    }
  }

  void _initializeController(int position, int index,
      {required bool fullLoad}) {
    if (_controllers[position] == null) {
      print(
          '🎬 Starting video initialization for position: $position, index: $index');

      final controller = VideoPlayerController.network(
        'https://${widget.initialVideos[index].videoUrl}',
        httpHeaders: {
          if (!fullLoad) 'Range': 'bytes=0-500000',
        },
      );

      _controllers[position] = controller;
      controller.initialize().then((_) async {
        print('✅ Video initialized successfully:\n'
            '└─ Position: $position\n'
            '└─ Index: $index\n'
            '└─ Duration: ${controller.value.duration}\n'
            '└─ Size: ${controller.value.size}\n'
            '└─ Video URL Size: ${await _getVideoSize("https://${widget.initialVideos[index].videoUrl}")}');

        if (mounted) setState(() {});
        if (fullLoad) {
          controller.play();
          print('▶️ Starting playback for index: $index');
        }
      }).catchError((error) {
        print('❌ Video initialization failed:\n'
            '└─ Position: $position\n'
            '└─ Index: $index\n'
            '└─ Error: $error');
      });
    }
  }

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    print('🔄 Page change triggered:\n'
        '└─ Current index: $_currentIndex\n'
        '└─ New index: $newIndex');

    final currentController = _controllers[2];
    if (currentController != null && currentController.value.isInitialized) {
      _videoPositions[_currentIndex] = currentController.value.position;
      print('💾 Saved video position:\n'
          '└─ Index: $_currentIndex\n'
          '└─ Position: ${currentController.value.position}');
    }

    final previousIndex = _currentIndex;
    setState(() {
      _currentIndex = newIndex;
    });

    if (newIndex > previousIndex) {
      print('⏩ Moving forward in playlist:\n'
          '└─ Disposing controller at position 1');
      _disposeController(1);
      _controllers[1] = _controllers[2];
      _controllers[2] = _controllers[3];
      _controllers[3] = _controllers[4];
      _controllers[4] = _controllers[0];
      _controllers[0] = null;

      if (newIndex + 3 < widget.initialVideos.length) {
        print('🔄 Preloading next video:\n'
            '└─ Index: ${newIndex + 3}');
        _initializeController(0, newIndex + 3, fullLoad: false);
      }
    } else {
      print('⏪ Moving backward in playlist:\n'
          '└─ Disposing controller at position 4');
      _disposeController(4);
      _controllers[4] = _controllers[3];
      _controllers[3] = _controllers[2];
      _controllers[2] = _controllers[1];
      _controllers[1] = _controllers[0];
      _controllers[0] = null;

      if (newIndex > 0) {
        print('🔄 Preloading previous video:\n'
            '└─ Index: ${newIndex - 1}');
        _initializeController(0, newIndex - 1, fullLoad: false);
      }
    }

    if (_controllers[2] != null) {
      _controllers[2]?.play().then((_) {
        if (_videoPositions.containsKey(newIndex)) {
          _controllers[2]?.seekTo(_videoPositions[newIndex]!);
          print('⏱️ Restored video position:\n'
              '└─ Index: $newIndex\n'
              '└─ Position: ${_videoPositions[newIndex]}');
        }
      });
    }

    for (int i = 0; i < _controllers.length; i++) {
      if (i != 2) {
        _controllers[i]?.pause();
        print('⏸️ Paused video at position: $i');
      }
    }
  }

  void _disposeController(int index) {
    if (_controllers[index] != null) {
      print('🗑️ Disposing controller:\n'
          '└─ Position: $index\n'
          '└─ Was initialized: ${_controllers[index]?.value.isInitialized}');
      _controllers[index]?.dispose();
      _controllers[index] = null;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _videoPositions.clear();
    _pageController.dispose();
    context.read<HomeTreeCubit>().clearVideos();
    super.dispose();
  }

  Future<void> _navigateToNewScreen(GetPublicationEntity product) async {
    final currentController = _controllers[2]; // Current playing controller

    // Store the current position if video is initialized
    if (currentController != null && currentController.value.isInitialized) {
      _videoPositions[_currentIndex] = currentController.value.position;
      await currentController.pause();
    }

    if (mounted) {
      // Navigate and wait for return
      await context.push(
        Routes.productDetails,
        extra: product,
      );

      // Resume video from stored position when returning
      if (mounted) {
        final controller = _controllers[2];
        if (controller != null && controller.value.isInitialized) {
          final storedPosition = _videoPositions[_currentIndex];
          if (storedPosition != null) {
            await controller.seekTo(storedPosition);
            await controller.play();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // for Android
      statusBarBrightness: Brightness.dark, // for iOS
    ));
    return BlocListener<HomeTreeCubit, HomeTreeState>(
      listener: (context, state) {
        if (state.videoPublicationsRequestState == RequestState.completed) {
          setState(() {
            _videos.addAll(state.videoPublications);
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _videos.length,
            onPageChanged: (index) {
              _handlePageChange(index);
              if (!_isLoading && index >= _videos.length - 5) {
                _loadMoreVideos();
              }
            },
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final videoController = _controllers[index == _currentIndex
                  ? 2
                  : (index < _currentIndex
                      ? 1
                      : index == _currentIndex + 1
                          ? 3
                          : index == _currentIndex + 2
                              ? 4
                              : 0)];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2),
                shape: SmoothRectangleBorder(
                  smoothness: 0.85,
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (videoController != null &&
                        videoController
                            .value.isInitialized) // Changed condition here
                      ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: videoController,
                        builder: (context, value, child) {
                          if (value.hasError) {
                            print('⚠️ Video playback error:\n'
                                '└─ Index: $index\n'
                                '└─ Error: ${value.errorDescription}');
                          }

                          if (value.isBuffering) {
                            print('🔄 Video buffering:\n'
                                '└─ Index: $index\n'
                                '└─ Position: ${value.position}\n'
                                '└─ Buffered: ${value.buffered}');
                          }
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              if (value.isInitialized)
                                SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: value.size.width,
                                      height: value.size.height,
                                      child: VideoPlayer(videoController),
                                    ),
                                  ),
                                ),
                              ControlsOverlay(
                                controller: videoController,
                              ),
                              if (value.isBuffering)
                                Center(
                                  child: Transform.scale(
                                    scale: 0.75,
                                    child: Progress(),
                                  ),
                                ),
                            ],
                          );
                        },
                      )
                    else
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                "https://${widget.initialVideos[index].productImages[0].url}",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Center(
                            child: Transform.scale(
                              scale: 0.75,
                              child: CircularProgressIndicator(
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 64,
                      child: GestureDetector(
                        onTap: () {
                          _navigateToNewScreen(widget.initialVideos[index]);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SmoothClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  side: BorderSide(
                                      width: 2,
                                      color: AppColors.white.withOpacity(0.8)),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(
                                      "https://${widget.initialVideos[index].seller.profileImagePath}",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        widget.initialVideos[index].seller
                                            .nickName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '2.5M followers',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    shape: SmoothRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Follow',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                clipBehavior: Clip.antiAlias,
                                shape: SmoothRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: AppColors.white.withOpacity(0.75),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SmoothClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            side: BorderSide(
                                              width: 2,
                                              color: AppColors.white,
                                            ),
                                            child: SizedBox(
                                              width: 76,
                                              height: 76,
                                              child: Image.network(
                                                "https://${widget.initialVideos[index].productImages[0].url}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.initialVideos[index]
                                                      .title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget.initialVideos[index]
                                                      .description,
                                                  style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
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
                                                        '\$${widget.initialVideos[index].price}',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Icon(Ionicons
                                                          .arrow_forward)
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
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(
                          Ionicons.close,
                          size: 28,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String> _getVideoSize(String url) async {
    try {
      final uri = Uri.parse('https://$url');
      final request = await HttpClient().headUrl(uri);
      final response = await request.close();
      final size = response.headers.value('content-length');
      if (size != null) {
        final sizeInMB = (int.parse(size) / (1024 * 1024)).toStringAsFixed(2);
        return '$sizeInMB MB';
      }
      return 'Unknown';
    } catch (e) {
      return 'Error getting size';
    }
  }
}
