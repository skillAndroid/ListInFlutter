// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_in/features/details/presentation/pages/video_details.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
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
  int get totalItems => hasVideo ? widget.images.length + 1 : widget.images.length;

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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildBackButton(),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _transformationControllers[_currentIndex].value = Matrix4.identity();
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
          _buildImageCounter(),
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
          color: Colors.black,
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
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
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
          color: Colors.black,
          child: InteractiveViewer(
            transformationController: _transformationControllers[hasVideo ? index + 1 : index],
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: "https://${widget.images[index].url}",
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCounter() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black54,
            child: Text(
              '${_currentIndex + 1}/$totalItems',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      child: SmoothClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.white.withOpacity(0.2),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}