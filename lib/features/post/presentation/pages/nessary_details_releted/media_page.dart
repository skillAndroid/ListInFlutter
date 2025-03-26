import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  MediaPageState createState() => MediaPageState();
}

class MediaPageState extends State<MediaPage> {
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
                color: Theme.of(context).colorScheme.secondary,
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
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.3),
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
                  side: BorderSide(
                    width: 1.5,
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                      child: Text(
                        AppLocalizations.of(context)!.main,
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).scaffoldBackgroundColor,
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
            Text(
              AppLocalizations.of(context)!.upload_images,
              style: const TextStyle(
                  fontSize: 18,
                  fontFamily: Constants.Arial,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
            if (provider.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDraggableImageList(provider.images, provider),
            ],
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.upload_images_tip,
              style: TextStyle(
                fontSize: 13.5,
                color: Theme.of(context).colorScheme.onSurface,
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
                    child: Icon(
                      EvaIcons.image,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.upload_images,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: Constants.Arial,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      AppLocalizations.of(context)!.image_format,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.upload_video,
              style: TextStyle(
                fontSize: 18,
                fontFamily: Constants.Arial,
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
                    color: Theme.of(context).cardColor,
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
            Text(
              AppLocalizations.of(context)!.upload_video_tip,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.video_orientation_tip,
              style: TextStyle(
                fontSize: 13.5,
                color: Theme.of(context).colorScheme.onSurface,
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
                    child: Icon(
                      EvaIcons.video,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.upload_product_video,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: Constants.Arial,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.max_video_duration,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Theme.of(context).colorScheme.onSurface,
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
