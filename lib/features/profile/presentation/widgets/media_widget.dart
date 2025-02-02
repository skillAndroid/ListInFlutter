// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({super.key});

  @override
  MediaWidgetState createState() => MediaWidgetState();
}

class MediaWidgetState extends State<MediaWidget> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PublicationUpdateBloc>().state;
      if (state.videoUrl != null) {
        _initializeVideoPlayer('https://${state.videoUrl!}');
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 100,
      );

      if (pickedFiles.isNotEmpty) {
        context.read<PublicationUpdateBloc>().add(UpdateImages(pickedFiles));
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        context.read<PublicationUpdateBloc>().add(UpdateVideo(video));
        await _initializeVideoPlayer(video.path);
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  Future<void> _initializeVideoPlayer(String videoSource) async {
    _videoController?.dispose();

    if (videoSource.startsWith('http')) {
      _videoController = VideoPlayerController.network(videoSource);
    } else {
      _videoController = VideoPlayerController.file(File(videoSource));
    }

    try {
      await _videoController!.initialize();
      _videoController!.addListener(_videoListener);
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _videoListener() {
    final bloc = context.read<PublicationUpdateBloc>();
    if (_videoController!.value.position >= _videoController!.value.duration) {
      bloc.add(ToggleVideoPlayback(false));
    }
  }

  Widget _buildVideoPreview(
      BuildContext context, PublicationUpdateState state) {
    if (state.videoUrl == null && state.newVideo == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SmoothClipRRect(
              smoothness: 1,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: AppColors.black,
                height: 176,
                width: 99,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    if (_videoController?.value.isInitialized ?? false)
                      AspectRatio(
                        aspectRatio: 9 / 16,
                        child: VideoPlayer(_videoController!),
                      ),
                    IconButton(
                      icon: Icon(
                        state.isVideoPlaying
                            ? Icons.pause_outlined
                            : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (state.isVideoPlaying) {
                          _videoController?.pause();
                        } else {
                          _videoController?.play();
                        }
                        context
                            .read<PublicationUpdateBloc>()
                            .add(ToggleVideoPlayback(!state.isVideoPlaying));
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Transform.translate(
                offset: const Offset(8, -8),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      context.read<PublicationUpdateBloc>().add(ClearVideo());
                      _videoController?.dispose();
                      setState(() {
                        _videoController = null;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDraggableImageList(
      BuildContext context, PublicationUpdateState state) {
    // Combine existing URLs and new images into a single list
    final List<ImageItem> allImages = [
      ...state.imageUrls!.map((url) => ImageItem(path: url, isUrl: true)),
      ...state.newImages
          .map((file) => ImageItem(path: file.path, isUrl: false)),
    ];

    return SizedBox(
      height: 80,
      child: ReorderableListView(
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final elevationValue = animation.value * 8;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.3),
                      blurRadius: elevationValue,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
          context.read<PublicationUpdateBloc>().add(
                ReorderImages(oldIndex, newIndex),
              );
        },
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 6),
        children: allImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return Container(
            key: ValueKey(image.path),
            width: 80,
            margin: const EdgeInsets.only(right: 6),
            child: Stack(
              children: [
                SmoothClipRRect(
                  smoothness: 1,
                  side: const BorderSide(
                    width: 1.5,
                    color: AppColors.white,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: image.isUrl
                      ? Image.network(
                          'https://${image.path}',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(image.path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                if (index == 0)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Main',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: const Offset(4, -0),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () {
                          context
                              .read<PublicationUpdateBloc>()
                              .add(RemoveImage(index));
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Upload Images',
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Syne",
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (state.imageUrls!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDraggableImageList(context, state),
            ],
            const SizedBox(height: 8),
            const Text(
              'Tip: The first photo will be featured as your main image. Simply drag and drop photos to change their order.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(
              height: 1,
              color: AppColors.lightGray,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: ElevatedButton(
                    onPressed: _pickImagesFromGallery,
                    child: const Icon(
                      EvaIcons.image,
                      color: AppColors.black,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload product photo(s)',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Syne",
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Format JPG or PNG',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Video',
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Syne",
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (state.videoUrl != null || state.newVideo != null)
              const SizedBox(height: 8),
            Row(
              children: [
                if (state.videoUrl != null || state.newVideo != null) ...[
                  _buildVideoPreview(context, state),
                  const SizedBox(width: 8),
                ],
                SmoothClipRRect(
                  smoothness: 1,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 245,
                    height: 176,
                    color: AppColors.containerColor,
                    child: Image.asset(
                      AppImages.videoVector,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            // Rest of the UI remains the same but with bloc state
            const SizedBox(height: 8),
            const Text(
              'Attract more buyers with quick show case',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Tip: Use vertical (9:16) orientation for your videos to best suit for application',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(
              height: 1,
              color: AppColors.lightGray,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: ElevatedButton(
                    onPressed: _pickVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGray,
                    ),
                    child: const Icon(
                      EvaIcons.video,
                      color: AppColors.black,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload product video',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Syne",
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Max video duration 1:30 min',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ImageItem {
  final String path;
  final bool isUrl;

  ImageItem({required this.path, required this.isUrl});
}
