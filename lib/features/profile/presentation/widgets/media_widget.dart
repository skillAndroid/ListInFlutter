// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_bloc.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/publication_update_state.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';
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

  Future<void> _editImage(int index, ImageItem image) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicationImageEditorPage(
          imagePath: image.path,
          imageIndex: index,
          isUrl: image.isUrl,
        ),
      ),
    );
  }

  Future<void> _pickImagesFromGallery(
      BuildContext context, ImagePicker picker) async {
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 100,
      );

      if (pickedFiles.isNotEmpty) {
        final state = context.read<PublicationUpdateBloc>().state;

        if (state.imageUrls?.isNotEmpty ?? false) {
          // Show Cupertino-style dialog if there are existing images
          final keepExisting = await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.existing_images,
                  style: const TextStyle(
                    fontFamily: Constants.Arial,
                  ),
                ),
                content: Text(
                  AppLocalizations.of(context)!.keep_existing_images,
                  style: const TextStyle(
                    fontFamily: Constants.Arial,
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text(
                      AppLocalizations.of(context)!.replace_all,
                      style: const TextStyle(
                        fontFamily: Constants.Arial,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(
                      AppLocalizations.of(context)!.keep_both,
                      style: const TextStyle(
                        fontFamily: Constants.Arial,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );

          if (keepExisting != null) {
            // User made a choice
            context
                .read<PublicationUpdateBloc>()
                .add(UpdateImages(pickedFiles, keepExisting: keepExisting));
          }
        } else {
          // No existing images, just add new ones
          context
              .read<PublicationUpdateBloc>()
              .add(UpdateImages(pickedFiles, keepExisting: false));
        }
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
                color: Theme.of(context).colorScheme.secondary,
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
                        color: Theme.of(context).iconTheme.color,
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
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).iconTheme.color,
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
    final List<ImageItem> allImages = [];
    if (state.imageUrls != null) {
      allImages.addAll(
          state.imageUrls!.map((url) => ImageItem(path: url, isUrl: true)));
    }

    allImages.addAll(state.newImages
        .map((file) => ImageItem(path: file.path, isUrl: false)));

    return SizedBox(
      height: 80,
      child: allImages.isNotEmpty
          ? ReorderableListView(
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    final elevationValue = animation.value * 8;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
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
                  key:
                      ValueKey('${image.isUrl ? "url" : "file"}-${image.path}'),
                  width: 80,
                  margin: const EdgeInsets.only(right: 6),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _editImage(index, image),
                        child: SmoothClipRRect(
                          smoothness: 1,
                          side: BorderSide(
                            width: 1.5,
                            color: Theme.of(context).scaffoldBackgroundColor,
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
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                              icon: Icon(
                                Icons.close,
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
                      // Add Edit button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Transform.translate(
                          offset: const Offset(4, -0),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                size: 14,
                              ),
                              onPressed: () => _editImage(index, image),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          : const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationUpdateBloc, PublicationUpdateState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.upload_images,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: Constants.Arial,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (state.imageUrls!.isNotEmpty ||
                  state.newImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDraggableImageList(context, state),
              ],
              const SizedBox(height: 8),
              Text(
                "${AppLocalizations.of(context)!.upload_images_tip} (Tap any image to edit)",
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
                      onPressed: () => _pickImagesFromGallery(
                          context, _picker), // Передаем context и _picker
                      child: Icon(
                        EvaIcons.image,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.upload_product_photos,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: Constants.Arial,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${AppLocalizations.of(context)!.image_format} (Instagram-like editing)",
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
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: Constants.Arial,
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
                      color: Theme.of(context).cardColor,
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
              Text(
                AppLocalizations.of(context)!.upload_video_tip,
                style: const TextStyle(
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
                      onPressed: _pickVideo,
                      child: Icon(
                        EvaIcons.video,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
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
              ),
            ],
          ),
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

class PublicationImageEditorPage extends StatefulWidget {
  final String imagePath;
  final int imageIndex;
  final bool isUrl;

  const PublicationImageEditorPage({
    super.key,
    required this.imagePath,
    required this.imageIndex,
    this.isUrl = false,
  });

  @override
  State<PublicationImageEditorPage> createState() =>
      _PublicationImageEditorPageState();
}

class _PublicationImageEditorPageState
    extends State<PublicationImageEditorPage> {
  late File imageFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareImage();
  }

  Future<void> _prepareImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (widget.isUrl) {
        // If it's a URL, we need to download the image first
        final response =
            await http.get(Uri.parse('https://${widget.imagePath}'));
        final tempDir = await getTemporaryDirectory();
        final file = File(path.join(tempDir.path, 'temp_edit_image.jpg'));
        await file.writeAsBytes(response.bodyBytes);
        imageFile = file;
      } else {
        imageFile = File(widget.imagePath);
      }
    } catch (e) {
      debugPrint('Error preparing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: ProImageEditor.file(
        imageFile.path,
        configs: const ProImageEditorConfigs(),
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            // Dispatch the EditImage event to the BLoC
            context.read<PublicationUpdateBloc>().add(
                  EditImage(
                    widget.imageIndex,
                    bytes,
                    isUrl: widget.isUrl,
                  ),
                );
          },
          onCloseEditor: () async {
            // Just return to previous screen without saving
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
