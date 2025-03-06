// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/video/presentation/wigets/video_controlls.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/global_state.dart';
import 'package:list_in/global/global_status.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';
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

  VideoPlayerController? _currentController;

  int _currentIndex = 0;
  final Map<int, Duration> _videoPositions = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _videos = List.from(widget.initialVideos);
    _homeTreeCubit = context.read<HomeTreeCubit>();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.95);
    _initializeController(_currentIndex);
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

  void _initializeController(int index) {
    _disposeCurrentController();

    debugPrint('🎬 Starting video initialization for index: $index');

    final controller = VideoPlayerController.network(
      'https://${widget.initialVideos[index].videoUrl}',
    );

    _currentController = controller;
    controller.initialize().then((_) async {
      debugPrint('✅ Video initialized successfully:\n'
          '└─ Index: $index\n'
          '└─ Duration: ${controller.value.duration}\n'
          '└─ Size: ${controller.value.size}\n');

      if (mounted) {
        setState(() {});
        controller.play();
        debugPrint('▶️ Starting playback for index: $index');
      }
    }).catchError((error) {
      debugPrint('❌ Video initialization failed:\n'
          '└─ Index: $index\n'
          '└─ Error: $error');
    });
  }

  void _handlePageChange(int newIndex) {
    if (newIndex == _currentIndex) return;

    debugPrint('🔄 Page change triggered:\n'
        '└─ Current index: $_currentIndex\n'
        '└─ New index: $newIndex');

    // Store current position before changing
    if (_currentController != null && _currentController!.value.isInitialized) {
      _videoPositions[_currentIndex] = _currentController!.value.position;
    }

    setState(() {
      _currentIndex = newIndex;
    });

    _initializeController(newIndex);
  }

  void _disposeCurrentController() {
    if (_currentController != null) {
      debugPrint('🗑️ Disposing current controller');
      _currentController!.dispose();
      _currentController = null;
    }
  }

  @override
  void dispose() {
    _disposeCurrentController();
    _videoPositions.clear();
    _pageController.dispose();
    context.read<HomeTreeCubit>().clearVideos();
    super.dispose();
  }

  Future<void> _navigateToNewScreen(GetPublicationEntity product) async {
    if (_currentController != null && _currentController!.value.isInitialized) {
      _videoPositions[_currentIndex] = _currentController!.value.position;
      await _currentController!.pause();
    }

    if (mounted) {
      await context.push(
        Routes.productDetails,
        extra: product,
      );

      if (mounted &&
          _currentController != null &&
          _currentController!.value.isInitialized) {
        final storedPosition = _videoPositions[_currentIndex];
        if (storedPosition != null) {
          await _currentController!.seekTo(storedPosition);
          await _currentController!.play();
        }
      }
    }
  }

  Future<void> _navigateToProfileScreen(String userId, bool isOwner) async {
    if (_currentController != null && _currentController!.value.isInitialized) {
      _videoPositions[_currentIndex] = _currentController!.value.position;
      await _currentController!.pause();
    }

    if (mounted) {
      if (!isOwner) {
        context.push(Routes.anotherUserProfile, extra: {
          'userId': userId,
        });
      }

      if (mounted &&
          _currentController != null &&
          _currentController!.value.isInitialized) {
        final storedPosition = _videoPositions[_currentIndex];
        if (storedPosition != null) {
          await _currentController!.seekTo(storedPosition);
          await _currentController!.play();
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
                    if (_currentController != null &&
                        _currentController!.value.isInitialized &&
                        index == _currentIndex)
                      ValueListenableBuilder<VideoPlayerValue>(
                        valueListenable: _currentController!,
                        builder: (context, value, child) {
                          if (value.hasError) {
                            debugPrint('⚠️ Video playback error:\n'
                                '└─ Index: $index\n'
                                '└─ Error: ${value.errorDescription}');
                          }

                          if (value.isBuffering) {
                            debugPrint('🔄 Video buffering:\n'
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
                                      child: VideoPlayer(_currentController!),
                                    ),
                                  ),
                                ),
                              ControlsOverlay(
                                controller: _currentController!,
                              ),
                              if (value.isBuffering)
                                Center(
                                  child: Transform.scale(
                                    scale: 1.25,
                                    child: CircularProgressIndicator(
                                      strokeCap: StrokeCap.square,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.white),
                                    ),
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
                              scale: 1.25,
                              child: CircularProgressIndicator(
                                strokeCap: StrokeCap.square,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
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
                          final currentUserId =
                              AppSession.currentUserId; // Get current user ID
                          final isOwner = currentUserId ==
                              widget.initialVideos[index].seller.id;
                          if (!isOwner) {
                            _navigateToNewScreen(widget.initialVideos[index]);
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
                                final isOwner = currentUserId ==
                                    widget.initialVideos[index].seller.id;

                                _navigateToProfileScreen(
                                  widget.initialVideos[index].seller.id,
                                  isOwner,
                                );
                              },
                              child: Row(
                                children: [
                                  SmoothClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    side: BorderSide(
                                        width: 2,
                                        color:
                                            AppColors.white.withOpacity(0.8)),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(
                                        "https://${widget.initialVideos[index].seller.profileImagePath}",
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
                                      BlocBuilder<GlobalBloc, GlobalState>(
                                        builder: (context, state) {
                                          final followersCount =
                                              state.getFollowersCount(widget
                                                  .initialVideos[index]
                                                  .seller
                                                  .id);
                                          return Text(
                                            '$followersCount ${AppLocalizations.of(context)!.followers}',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 14,
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
                                          widget
                                              .initialVideos[index].seller.id);
                                      final followStatus =
                                          state.getFollowStatus(widget
                                              .initialVideos[index].seller.id);
                                      final isLoading = followStatus ==
                                          FollowStatus.inProgress;
                                      final currentUserId = AppSession
                                          .currentUserId; // Get current user ID
                                      final isOwner = currentUserId ==
                                          widget.initialVideos[index].seller
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
                                                  userId: widget
                                                      .initialVideos[index]
                                                      .seller
                                                      .id,
                                                  isFollowed: isFollowed,
                                                  context: context,
                                                ));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary
                                                .withOpacity(0.8),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            shape: SmoothRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Colors.blue),
                                                  ),
                                                )
                                              : Text(
                                                  isFollowed
                                                      ? AppLocalizations.of(context)!.unfollow
                                                      : AppLocalizations.of(context)!.follow,
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 14,
                                                    fontFamily: Constants.Arial,
                                                    fontWeight: FontWeight.w600,
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
}
