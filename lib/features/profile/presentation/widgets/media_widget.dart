import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({super.key});

  @override
  MediaPageState createState() => MediaPageState();
}

class MediaPageState extends State<MediaWidget> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  final bool _autoReplay = false;

  @override
  void initState() {
    super.initState();
    // Initialize video controller if there's a saved video
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PostProvider>(context, listen: false);
      if (provider.video != null) {
        _initializeVideoPlayer(provider.video!.path);
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImagesFromGallery(PostProvider provider) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 100,
      );

      if (pickedFiles.isNotEmpty) {
        provider.setImages(pickedFiles);
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _pickVideo(PostProvider provider) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        provider.setVideo(video);
        await _initializeVideoPlayer(video.path);
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  Future<void> _initializeVideoPlayer(String videoPath) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(videoPath));

    try {
      await _videoController!.initialize();
      _videoController!.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _videoListener() {
    if (_videoController!.value.position >= _videoController!.value.duration) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }

      if (_autoReplay) {
        _restartVideo();
      }
    }
  }

  void _restartVideo() {
    _videoController!.seekTo(Duration.zero);
    _videoController!.play();
    if (mounted) {
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Widget _buildVideoPreview(XFile? video) {
    if (video == null || _videoController == null) {
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
                    AspectRatio(
                      aspectRatio: 9 / 16,
                      child: VideoPlayer(_videoController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_outlined : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                          _isPlaying = !_isPlaying;
                        });
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
                    color: AppColors.error, // Set your background color here
                    shape: BoxShape
                        .circle, // Optional: make it circular like the IconButton
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Provider.of<PostProvider>(context, listen: false)
                          .clearVideo();
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

  Widget _buildDraggableImageList(List<XFile> images, PostProvider provider) {
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
                      // ignore: deprecated_member_use
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
          provider.reorderImages(oldIndex, newIndex);
        },
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 6),
        children: images.asMap().entries.map((entry) {
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
                  child: Image.file(
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
                        color:
                            AppColors.error, // Set your background color here
                        shape: BoxShape
                            .circle, // Optional: make it circular like the IconButton
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () {
                          provider.removeImageAt(index);
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
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
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
                  fontWeight: FontWeight.w500),
            ),
            if (provider.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDraggableImageList(provider.images, provider),
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
                    onPressed: () => _pickImagesFromGallery(provider),
                    child: const Icon(
                      EvaIcons.image,
                      color: AppColors.black,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
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
                    SizedBox(
                      height: 4,
                    ),
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
            if (provider.video != null) const SizedBox(height: 8),
            Row(
              children: [
                if (provider.video != null) ...[
                  _buildVideoPreview(provider.video),
                  const SizedBox(
                  width: 8,
                ),
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
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
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
                    onPressed: () => _pickVideo(provider),
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
                const SizedBox(
                  width: 16,
                ),
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
            )
          ],
        );
      },
    );
  }
}
