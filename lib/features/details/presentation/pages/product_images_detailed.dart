// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:photo_view/photo_view.dart';

class ProductImagesDetailed extends StatefulWidget {
  final List<ProductImageEntity> images;
  final int initialIndex;
  final String heroTag;
  final String? videoUrl; // Add this

  const ProductImagesDetailed({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.heroTag,
    this.videoUrl, // Add this
  });

  @override
  State<ProductImagesDetailed> createState() => _ProductImagesDetailedState();
}

class _ProductImagesDetailedState extends State<ProductImagesDetailed> {
  late PageController _pageController;
  late int _currentIndex;
  final List<TransformationController> _transformationControllers = [];

  bool get hasVideo => widget.videoUrl != null;
  int get totalItems =>
      hasVideo ? widget.images.length + 1 : widget.images.length;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Add one more controller for video thumbnail if video exists
    for (var i = 0; i < totalItems; i++) {
      _transformationControllers.add(TransformationController());
    }
  }

  @override
  void dispose() {
    for (var controller in _transformationControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top:40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
              ),
              _buildBackButton(),
              SizedBox(
                width: 16,
              ),
              _buildImageCounter(),
            ],
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _transformationControllers[_currentIndex].value =
                    Matrix4.identity();
              });
            },
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (hasVideo && index == 0) {
                return _buildVideoThumbnail();
              }
              final imageIndex = hasVideo ? index - 1 : index;
              return _buildImageViewer(imageIndex);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.white,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoUrl: widget.videoUrl!,
                    thumbnailUrl: 'https://${widget.images[0].url}',
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://${widget.images[0].url}',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageViewer(int index) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        color: AppColors.bgColor,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            "https://${widget.images[index].url}",
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: BoxDecoration(
            color: AppColors.bgColor,
          ),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
          enableRotation: false,
          tightMode: true,
        ),
      );
    },
  );
}

  Widget _buildImageCounter() {
    return Text(
      '${_currentIndex + 1} of $totalItems',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        fontFamily: Constants.Arial,
      ),
    );
  }

 Widget _buildBackButton() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(100),
    child: Container(
      width: 36,
      height: 36,
      color: AppColors.containerColor,
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    ),
  );
}
}
